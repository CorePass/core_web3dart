import 'dart:typed_data';

import 'package:core_web3dart/crypto.dart';
import 'package:flutter_ed448/src/HDWallets/ed448_hd_wallets.dart';

final ed448Wallet = Ed448HDWallet();

/// Generates a public key for the given private key using the ed448 curve which
/// core blockchain uses.
Uint8List privateKeyBytesToPublic(Uint8List privateKey) {
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
BigInt generateNewPrivateKey(String seed, int index) {
  final response = ed448Wallet.HDWalletGenerateKey(hexToBytes(seed), index);
  return bytesToInt(response);
}

/// Constructs the core blockchain address associated with the given public key by
/// taking the lower 160 bits of the key's sha3 hash.
Uint8List publicKeyToAddress(Uint8List publicKey, int networkId) {
  assert(publicKey.length == 57);
  final hash = sha3_256(publicKey);
  final networkBytes = hexToBytes(getNetworkIdPrefix(networkId));
  List<int> purgedHash = [];
  for (var i = 12; i < hash.length; i++) {
    purgedHash.add(hash[i]);
  }
  final checksum =
      calculateCheckSum(Uint8List.fromList(purgedHash), networkBytes);
  var _tmpConcated = BytesBuilder();
  _tmpConcated.add(networkBytes);
  _tmpConcated.add(hexToBytes(checksum));
  _tmpConcated.add(purgedHash);
  var concated = _tmpConcated.toBytes();
  return concated;
}
// in sign index 114 => pubkey

/// Signs the hashed data in [messageHash] using the given private key, also concats the public key at the end.
Uint8List signWithPrivKey(Uint8List messageHash, Uint8List privateKey) {
  final signedMsg = ed448Wallet.ed448Sign(privateKey, messageHash);
  final publicKey = ed448Wallet.ed448DerivePublicKey(privateKey);
  return Uint8List.fromList(signedMsg + publicKey);
}

/// Given an arbitrary core blockchain message signature encoded in bytes, returns
/// the public key that was used to sign it.
/// https://github.com/web3j/web3j/blob/c0b7b9c2769a466215d416696021aa75127c2ff1/crypto/src/main/java/org/web3j/crypto/Sign.java#L241
Uint8List ecRecover(Uint8List signedMessage) {
  List<int> pubKey = [];
  for (var i = 114; i < signedMessage.length; i++) {
    pubKey.add(signedMessage[i]);
  }
  return Uint8List.fromList(pubKey);
}

/// Given an arbitrary message hash, an Core Block Chain message signature encoded in bytes and
/// a public key encoded in bytes, confirms whether that public key was used to sign
/// the message or not.
bool isValidSignature(
    Uint8List messageHash, Uint8List signedMsg, Uint8List publicKey) {
  List<int> extractedSign = [];
  for (var i = 0; i < 114; i++) {
    extractedSign.add(signedMsg[i]);
  }
  final verifyResult = ed448Wallet.ed448Verify(
      publicKey, messageHash, Uint8List.fromList(extractedSign));

  return verifyResult;
}

String calculateCheckSum(Uint8List address, Uint8List prefix) {
  var _tmpConcated = BytesBuilder();
  _tmpConcated.add(address);
  _tmpConcated.add(prefix);
  var concated = _tmpConcated.toBytes();
  var hexedConcat = (bytesToHex(concated) + "00").toUpperCase();
  var mods = "";
  hexedConcat.runes.forEach((int rune) {
    if (rune > 64 && rune < 91) {
      mods += (rune - 55).toString();
    } else {
      mods += (rune - 48).toString();
    }
  });
  var bigVal = BigInt.parse(mods);
  var val97 = BigInt.from(97);
  var val98 = BigInt.from(98);
  var remainder = bigVal % val97;
  var checkSum = val98 - remainder;
  var result = checkSum.toInt();
  if (result < 10) {
    return ("0" + result.toString());
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
    throw new Exception("Invalid Network Id");
  }
}
