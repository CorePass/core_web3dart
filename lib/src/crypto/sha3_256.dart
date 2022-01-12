import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import '../utils/typed_data.dart';

final SHA3Digest sha3digest = SHA3Digest(256);

Uint8List sha3_256(Uint8List input) {
  sha3digest.reset();
  return sha3digest.process(input);
}

Uint8List sha3Utf8(String input) {
  return sha3_256(uint8ListFromList(utf8.encode(input)));
}

Uint8List sha3Ascii(String input) {
  return sha3_256(ascii.encode(input));
}
