import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart' as pbkdf2;
import 'package:pointycastle/key_derivators/scrypt.dart' as scrypt;
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/stream/ctr.dart';
import 'package:core_web3dart/crypto.dart';

import '../crypto/random_bridge.dart';
import '../utils/typed_data.dart';
import '../utils/uuid.dart';
import 'credentials.dart';

abstract class _KeyDerivator {
  Uint8List deriveKey(Uint8List password);

  String get name;
  Map<String, dynamic> encode();
}

class _PBDKDF2KeyDerivator extends _KeyDerivator {
  final int iterations;
  final Uint8List salt;
  final int dklen;

  // The docs (https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition)
  // say that HMAC with SHA-256 is the only mac supported at the moment
  static final Mac mac = HMac(SHA256Digest(), 64);

  _PBDKDF2KeyDerivator(this.iterations, this.salt, this.dklen);

  @override
  Uint8List deriveKey(Uint8List password) {
    final impl = pbkdf2.PBKDF2KeyDerivator(mac)
      ..init(Pbkdf2Parameters(salt, iterations, dklen));

    return impl.process(password);
  }

  @override
  Map<String, dynamic> encode() {
    return {
      'c': iterations,
      'dklen': dklen,
      'prf': 'hmac-sha256',
      'salt': bytesToHex(salt),
    };
  }

  @override
  final String name = 'pbkdf2';
}

class _ScryptKeyDerivator extends _KeyDerivator {
  final int dklen;
  final int n;
  final int r;
  final int p;
  final Uint8List salt;

  _ScryptKeyDerivator(this.dklen, this.n, this.r, this.p, this.salt);

  @override
  Uint8List deriveKey(Uint8List password) {
    final impl = scrypt.Scrypt()..init(ScryptParameters(n, r, p, dklen, salt));

    return impl.process(password);
  }

  @override
  Map<String, dynamic> encode() {
    return {'dklen': dklen, 'n': n, 'r': r, 'p': p, 'salt': bytesToHex(salt)};
  }

  @override
  final String name = 'scrypt';
}

/// Represents a wallet file. Wallets are used to securely store credentials
/// like a private key belonging to an Core address. The private key in a
/// wallet is encrypted with a secret password that needs to be known in order
/// to obtain the private key.
@immutable
class Wallet {
  static const int _derivedKeyLength = 32;
  static const int _maximumPbkdf2Iterations = 10000000;
  static const int _maximumScryptN = 1048576;
  static const int _maximumScryptWorkFactor = 1048576;
  static const int _maximumScryptMemoryBytes = 256 * 1024 * 1024;

  /// The credentials stored in this wallet file
  final XCBPrivateKey privateKey;

  /// The key derivator used to obtain the aes decryption key from the password
  final _KeyDerivator _derivator;

  final Uint8List _password;
  final Uint8List _iv;

  final Uint8List _id;

  const Wallet._(
    this.privateKey,
    this._derivator,
    this._password,
    this._iv,
    this._id,
  );

  /// Gets the random uuid assigned to this wallet file
  String get uuid => formatUuid(_id);

  /// Encrypts the private key using the secret specified earlier and returns
  /// a json representation of its data as a v3-wallet file.
  String toJson() {
    final ciphertextBytes = _encryptPrivateKey();

    final map = {
      'crypto': {
        'cipher': 'aes-128-ctr',
        'cipherparams': {'iv': bytesToHex(_iv)},
        'ciphertext': bytesToHex(ciphertextBytes),
        'kdf': _derivator.name,
        'kdfparams': _derivator.encode(),
        'mac': _generateMac(_derivator.deriveKey(_password), ciphertextBytes),
      },
      'id': uuid,
      'version': 3,
    };

    return json.encode(map);
  }

  /// Creates a new wallet wrapping the specified [credentials] by encrypting
  /// the private key with the [password]. The [random] instance, which should
  /// be cryptographically secure, is used to generate encryption keys.
  /// You can configure the parameter N of the scrypt algorithm if you need to.
  /// The default value for [scryptN] is 8192. Be aware that this N must be a
  /// power of two.
  factory Wallet.createNew(
    XCBPrivateKey credentials,
    String password,
    Random random, {
    int scryptN = 8192,
    int p = 1,
  }) {
    _validateScryptParameters(_derivedKeyLength, scryptN, 8, p);
    final passwordBytes = Uint8List.fromList(utf8.encode(password));
    final dartRandom = RandomBridge(random);

    final salt = dartRandom.nextBytes(32);
    final derivator = _ScryptKeyDerivator(32, scryptN, 8, p, salt);

    final uuid = generateUuidV4();

    final iv = dartRandom.nextBytes(128 ~/ 8);

    return Wallet._(credentials, derivator, passwordBytes, iv, uuid);
  }

  /// Reads and unlocks the wallet denoted in the json string given with the
  /// specified [password]. [encoded] must be the String contents of a valid
  /// v3 Core wallet file.
  factory Wallet.fromJson(String encoded, String password) {
    /*
      In order to read the wallet and obtain the secret key stored in it, we
      need to do the following:
      1: Key Derivation: Based on the key derivator specified (either pbdkdf2 or
         scryt), we need to use the password to obtain the aes key used to
         decrypt the private key.
      2: Using the obtained aes key and the iv parameter, decrypt the private
         key stored in the wallet.
    */

    final decoded = json.decode(encoded);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Wallet must be a JSON object');
    }
    final data = decoded;

    // Ensure version is 3, only version that we support at the moment
    final version = data['version'];
    if (version != 3) {
      throw ArgumentError.value(
        version,
        'version',
        'Library only supports '
            'version 3 of wallet files at the moment. However, the following value'
            ' has been given:',
      );
    }

    final cryptoValue = data['crypto'] ?? data['Crypto'];
    if (cryptoValue is! Map<String, dynamic>) {
      throw const FormatException('Wallet crypto data is missing or invalid');
    }
    final crypto = cryptoValue;

    final kdf = _requiredString(crypto, 'kdf');
    _KeyDerivator derivator;

    switch (kdf) {
      case 'pbkdf2':
        final derParams = _requiredMap(crypto, 'kdfparams');

        if (derParams['prf'] != 'hmac-sha256') {
          throw ArgumentError(
            'Invalid prf supplied with the pdf: was ${derParams["prf"]}, expected hmac-sha256',
          );
        }

        final iterations = _requiredInt(derParams, 'c');
        final dklen = _requiredInt(derParams, 'dklen');
        _validatePbkdf2Parameters(dklen, iterations);
        derivator = _PBDKDF2KeyDerivator(
          iterations,
          _decodeHex(_requiredString(derParams, 'salt'), 'salt'),
          dklen,
        );

        break;
      case 'scrypt':
        final derParams = _requiredMap(crypto, 'kdfparams');
        final dklen = _requiredInt(derParams, 'dklen');
        final n = _requiredInt(derParams, 'n');
        final r = _requiredInt(derParams, 'r');
        final p = _requiredInt(derParams, 'p');
        _validateScryptParameters(dklen, n, r, p);
        derivator = _ScryptKeyDerivator(
          dklen,
          n,
          r,
          p,
          _decodeHex(_requiredString(derParams, 'salt'), 'salt'),
        );
        break;
      default:
        throw ArgumentError(
          'Wallet file uses $kdf as key derivation function, which is not supported.',
        );
    }

    // Now that we have the derivator, let's obtain the aes key:
    final encodedPassword = Uint8List.fromList(utf8.encode(password));
    final derivedKey = derivator.deriveKey(encodedPassword);
    final aesKey = Uint8List.fromList(derivedKey.sublist(0, 16));

    final encryptedPrivateKey = _decodeHex(
      _requiredString(crypto, 'ciphertext'),
      'ciphertext',
    );

    // Validate the derived key without leaking where the MAC differs.
    final derivedMac = _decodeHex(
      _generateMac(derivedKey, encryptedPrivateKey),
      'derivedMac',
    );
    final expectedMac = _decodeHex(_requiredString(crypto, 'mac'), 'mac');
    if (!_constantTimeEquals(derivedMac, expectedMac)) {
      throw ArgumentError(
        'Could not unlock wallet file. You either supplied the wrong password or the file is corrupted',
      );
    }

    // We only support this mode at the moment
    if (crypto['cipher'] != 'aes-128-ctr') {
      throw ArgumentError(
        'Wallet file uses ${crypto["cipher"]} as cipher, but only aes-128-ctr is supported.',
      );
    }
    final cipherParams = _requiredMap(crypto, 'cipherparams');
    final iv = _decodeHex(_requiredString(cipherParams, 'iv'), 'iv');
    if (iv.length != 16) {
      throw const FormatException('Wallet IV must contain exactly 16 bytes');
    }

    // Decrypt the private key

    final aes = _initCipher(false, aesKey, iv);

    final privateKey = aes.process(Uint8List.fromList(encryptedPrivateKey));
    final credentials = XCBPrivateKey(privateKey);

    final id = parseUuid(data['id'] as String);

    return Wallet._(credentials, derivator, encodedPassword, iv, id);
  }

  static String _generateMac(List<int> dk, List<int> ciphertext) {
    final macBody = <int>[...dk.sublist(16, 32), ...ciphertext];

    return bytesToHex(sha3_256(uint8ListFromList(macBody)));
  }

  static void _validatePbkdf2Parameters(int dklen, int iterations) {
    _validateDerivedKeyLength(dklen);
    if (iterations <= 0 || iterations > _maximumPbkdf2Iterations) {
      throw const FormatException('Wallet PBKDF2 iteration count is unsafe');
    }
  }

  static void _validateScryptParameters(int dklen, int n, int r, int p) {
    _validateDerivedKeyLength(dklen);
    if (n <= 1 || n > _maximumScryptN || (n & (n - 1)) != 0) {
      throw const FormatException(
        'Wallet scrypt N must be a safe power of two',
      );
    }
    if (r <= 0 || p <= 0 || r * p > _maximumScryptWorkFactor) {
      throw const FormatException('Wallet scrypt work factor is unsafe');
    }
    if (128 * n * r > _maximumScryptMemoryBytes) {
      throw const FormatException('Wallet scrypt memory requirement is unsafe');
    }
  }

  static void _validateDerivedKeyLength(int dklen) {
    if (dklen < _derivedKeyLength || dklen > 64) {
      throw const FormatException(
        'Wallet derived key length must be 32 to 64 bytes',
      );
    }
  }

  static Map<String, dynamic> _requiredMap(
    Map<String, dynamic> source,
    String key,
  ) {
    final value = source[key];
    if (value is! Map<String, dynamic>) {
      throw FormatException('Wallet field "$key" must be an object');
    }
    return value;
  }

  static String _requiredString(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Wallet field "$key" must be a non-empty string');
    }
    return value;
  }

  static int _requiredInt(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is! int) {
      throw FormatException('Wallet field "$key" must be an integer');
    }
    return value;
  }

  static Uint8List _decodeHex(String value, String field) {
    try {
      return Uint8List.fromList(hexToBytes(value));
    } on Object catch (_) {
      throw FormatException('Wallet field "$field" is not valid hexadecimal');
    }
  }

  static bool _constantTimeEquals(List<int> first, List<int> second) {
    var difference = first.length ^ second.length;
    final length = min(first.length, second.length);
    for (var index = 0; index < length; index++) {
      difference |= first[index] ^ second[index];
    }
    return difference == 0;
  }

  static CTRStreamCipher _initCipher(
    bool forEncryption,
    Uint8List key,
    Uint8List iv,
  ) {
    return CTRStreamCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv));
  }

  List<int> _encryptPrivateKey() {
    final derived = _derivator.deriveKey(_password);
    final aesKey = Uint8List.view(derived.buffer, 0, 16);

    final aes = _initCipher(true, aesKey, _iv);
    return aes.process(privateKey.privateKey);
  }
}
