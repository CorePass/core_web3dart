import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:core_web3dart/credentials.dart';
import 'package:core_web3dart/crypto.dart';
import 'package:core_web3dart/src/utils/typed_data.dart';

/// The sign method from ed448, so that it can be used inside [Credentials].

/// Anything that can sign payloads with a private key.
abstract class Credentials {
  static const _messagePrefix = '\u0019CoreBlockchain Signed Message:\n';

  /// Whether these [Credentials] are safe to be copied to another isolate and
  /// can operate there.
  /// If this getter returns true, the client might chose to perform the
  /// expensive signing operations on another isolate.
  bool get isolateSafe => false;

  /// Loads the ethereum address specified by these credentials.
  XCBAddress extractAddress(int networkId);

  /// Signs the [payload] with a private key. The output will be like the
  /// bytes representation of the [xcb_sign RPC method](https://github.com/ethereum/wiki/wiki/JSON-RPC#xcb_sign),
  /// but without the "Core signed message" prefix.
  /// The [payload] parameter contains the raw data, not a hash.
  Uint8List sign(Uint8List payload, {required int networkId}) {
    final signature = signToSignature(payload, networkId: networkId);

    return signature;
  }

  /// Signs the [payload] with a private key and returns the obtained
  /// signature.
  Uint8List signToSignature(Uint8List payload, {required int networkId});

  /// Signs an Core Block Chain specific signature. This method is equivalent to
  /// [sign], but with a special prefix so that this method can't be used to
  /// sign, for instance, transactions.
  Uint8List signPersonalMessage(Uint8List payload, {required int networkId}) {
    final prefix = _messagePrefix + payload.length.toString();
    final prefixBytes = ascii.encode(prefix);

    // will be a Uint8List, see the documentation of Uint8List.+
    final concat = uint8ListFromList(prefixBytes + payload);

    return sign(concat, networkId: networkId);
  }
}

/// Credentials that can sign payloads with an Core Block Chain private key.
class XCBPrivateKey extends Credentials {
  final Uint8List privateKey;
  XCBAddress? _cachedAddress;

  XCBPrivateKey(this.privateKey);

  XCBPrivateKey.fromHex(String hex) : privateKey = hexToBytes(hex);

  @override
  final bool isolateSafe = true;

  @override
  XCBAddress extractAddress(int networkId) {
    var _pubKey = privateKeyBytesToPublic(privateKey);
    return _cachedAddress ??=
        XCBAddress(publicKeyToAddress(_pubKey, networkId));
  }

  /// Creates a new, random private key from the [random] number generator.
  ///
  /// For security reasons, it is very important that the random generator used
  /// is cryptographically secure. The private key could be reconstructed by
  /// someone else otherwise. Just using [Random()] is a very bad idea! At least
  /// use [Random.secure()].
  factory XCBPrivateKey.createPrivateKey(String seed, int index) {
    final key = generateNewPrivateKey(seed, index);
    return XCBPrivateKey(key);
  }
  @override
  Uint8List signToSignature(Uint8List payload, {required int networkId}) {
    final signature = signWithPrivKey(sha3_256(payload), privateKey);
    return signature;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XCBPrivateKey &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(privateKey, other.privateKey);

  @override
  int get hashCode => privateKey.hashCode;
}
