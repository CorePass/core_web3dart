import 'dart:typed_data';

import 'package:pointycastle/digests/keccak.dart';

class Crypto {
  final KeccakDigest keccakDigest = KeccakDigest(256);

  Uint8List hash(Uint8List input) {
    keccakDigest.reset();
    return keccakDigest.process(input);
  }
}
