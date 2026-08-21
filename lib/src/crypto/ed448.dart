import 'dart:typed_data';

import 'package:core_web3dart/crypto.dart';
import 'package:flutter_ed448/flutter_ed448.dart' show Ed448HDWallet;

final ed448Wallet = Ed448HDWallet();

const int _privateKeyLength = 57;
const int _publicKeyLength = 57;
const int _signatureLength = 114;
const int _recoverableSignatureLength = _signatureLength + _publicKeyLength;

/// Generates a public key for the given private key using the ed448 curve which
/// core blockchain uses.
Uint8List privateKeyBytesToPublic(Uint8List privateKey) {
  _validateLength(privateKey, _privateKeyLength, 'privateKey');
  final response = ed448Wallet.ed448DerivePublicKey(privateKey);
  return response;
}

/// Generates a public key for the given private key using the ecdsa curve which
/// core blockchain uses.
Uint8List privateKeyToPublic(BigInt privateKey) {
  final intPriv = intToBytes(privateKey);
  final response = privateKeyBytesToPublic(intPriv);
  //skip the type flag, https://github.com/ethereumjs/ethereumjs-util/blob/master/index.js#L319
  return response;
}

/// Generates a new private key using the seed. Please make
/// sure you're using a cryptographically secure generator.
Uint8List generateNewPrivateKey(String seed, int index) {
  if (index < 0) {
    throw ArgumentError.value(index, 'index', 'Must not be negative');
  }
  return ed448Wallet.HDWalletGenerateKey(hexToBytes(seed), index);
}

/// Constructs the core blockchain address associated with the given public key by
/// taking the lower 160 bits of the key's sha3 hash.
Uint8List publicKeyToAddress(Uint8List publicKey, int networkId) {
  _validateLength(publicKey, _publicKeyLength, 'publicKey');
  final hash = sha3_256(publicKey);
  final networkBytes = hexToBytes(getNetworkIdPrefix(networkId));
  final purgedHash = <int>[];
  for (var i = 12; i < hash.length; i++) {
    purgedHash.add(hash[i]);
  }
  final checksum = calculateCheckSum(
    Uint8List.fromList(purgedHash),
    networkBytes,
  );
  final concatenated =
      BytesBuilder()
        ..add(networkBytes)
        ..add(hexToBytes(checksum))
        ..add(purgedHash);
  return concatenated.toBytes();
}
// in sign index 114 => pubkey

/// Signs the hashed data in [messageHash] using the given private key, also concats the public key at the end.
Uint8List signWithPrivKey(Uint8List messageHash, Uint8List privateKey) {
  _validateLength(privateKey, _privateKeyLength, 'privateKey');
  final signedMsg = ed448Wallet.ed448Sign(privateKey, messageHash);
  final publicKey = ed448Wallet.ed448DerivePublicKey(privateKey);
  return Uint8List.fromList(signedMsg + publicKey);
}

/// Given an arbitrary core blockchain message signature encoded in bytes, returns
/// the public key that was used to sign it.
/// https://github.com/web3j/web3j/blob/c0b7b9c2769a466215d416696021aa75127c2ff1/crypto/src/main/java/org/web3j/crypto/Sign.java#L241
Uint8List ecRecover(Uint8List signedMessage) {
  _validateLength(signedMessage, _recoverableSignatureLength, 'signedMessage');
  return Uint8List.fromList(signedMessage.sublist(_signatureLength));
}

/// Given an arbitrary message hash, an Core Block Chain message signature encoded in bytes and
/// a public key encoded in bytes, confirms whether that public key was used to sign
/// the message or not.
bool isValidSignature(
  Uint8List messageHash,
  Uint8List signedMsg,
  Uint8List publicKey,
) {
  _validateLength(signedMsg, _recoverableSignatureLength, 'signedMsg');
  _validateLength(publicKey, _publicKeyLength, 'publicKey');
  final extractedSign = Uint8List.fromList(
    signedMsg.sublist(0, _signatureLength),
  );
  final verifyResult = ed448Wallet.ed448Verify(
    publicKey,
    messageHash,
    extractedSign,
  );

  return verifyResult;
}

String calculateCheckSum(Uint8List address, Uint8List prefix) {
  final concatenated =
      BytesBuilder()
        ..add(address)
        ..add(prefix);
  final hexedConcat = '${bytesToHex(concatenated.toBytes())}00'.toUpperCase();
  var mods = '';
  for (final rune in hexedConcat.runes) {
    if (rune > 64 && rune < 91) {
      mods += (rune - 55).toString();
    } else {
      mods += (rune - 48).toString();
    }
  }
  final result =
      (BigInt.from(98) - BigInt.parse(mods) % BigInt.from(97)).toInt();
  if (result < 10) {
    return '0$result';
  }
  return result.toString();
}

String getNetworkIdPrefix(int networkId) {
  if (networkId == 1) {
    return "cb";
  } else if (networkId == 3) {
    return "ab";
  } else if (networkId >= 4) {
    return "ce";
  } else {
    throw ArgumentError.value(networkId, 'networkId', 'Invalid network ID');
  }
}

void _validateLength(Uint8List value, int expected, String name) {
  if (value.length != expected) {
    throw ArgumentError.value(
      value.length,
      name,
      'Must contain exactly $expected bytes',
    );
  }
}
