import 'dart:typed_data';

import 'package:flutter_ed448/flutter_ed448.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/src/crypto/formatting.dart';

/// Generates a public key for the given private key using the ed448 curve which
/// core blockchain uses.
Future<Uint8List> privateKeyBytesToPublic(Uint8List privateKey) async {
  var response =
      await FlutterEd448.getPublicKeyFromPrivateKey(bytesToHex(privateKey));
  return hexToBytes(response);
}

/// Generates a public key for the given private key using the ecdsa curve which
/// core blockchain uses.
Future<Uint8List> privateKeyToPublic(BigInt privateKey) async {
  Uint8List intPriv = intToBytes(privateKey);
  final response = privateKeyBytesToPublic(intPriv);
  //skip the type flag, https://github.com/ethereumjs/ethereumjs-util/blob/master/index.js#L319
  return response;
}

/// Generates a new private key using the random instance provided. Please make
/// sure you're using a cryptographically secure generator.
Future<BigInt> generateNewPrivateKey(String seed, String index) async {
  final response = await FlutterEd448.generatePrivateKey(seed, index);
  return hexToInt(response);
}

/// Constructs the core blockchain address associated with the given public key by
/// taking the lower 160 bits of the key's sha3 hash.
// TODO: get network id
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

/// Signs the hashed data in [messageHash] using the given private key.
Future<Uint8List> signWithPrivKey(
    Uint8List messageHash, Uint8List privateKey) async {
  final signedMsg = await FlutterEd448.signWithPrivateKeyNConcatPubkey(
      bytesToHex(privateKey), bytesToHex(messageHash));

  return hexToBytes(signedMsg);
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
Future<bool> isValidSignature(
    Uint8List messageHash, Uint8List signedMsg, Uint8List publicKey) async {
  List<int> extractedSign = [];
  for (var i = 0; i < 114; i++) {
    extractedSign.add(signedMsg[i]);
  }
  bool verifyResult = await FlutterEd448.verifySignature(
      bytesToHex(messageHash),
      bytesToHex(extractedSign),
      bytesToHex(publicKey));

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
  } else if (networkId == 3 || networkId == 4) {
    return "ab";
  } else if ((networkId > 10) || networkId == 0) {
    return "ce";
  } else {
    throw new Exception("Invalid Network Id");
  }
}
