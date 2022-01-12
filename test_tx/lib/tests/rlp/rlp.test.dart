import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart_example/tests/rlp/rlp_data.dart';
import 'package:web3dart/src/utils/rlp.dart' as rlp;
import 'package:web3dart_example/utils/widget.dart';

final List<Widget> RLPTests = RLP_Data.map((e) => TestShower(
      isOk: _isRLPOk(e),
      errMessage: !_isRLPOk(e)
          ? "rlp should be ${e[1]}, but it is ${bytesToHex(rlp.encode(e[0]))}"
          : "",
    )).toList();

bool _isRLPOk(List<Object> e) {
  return bytesToHex(rlp.encode(e[0])) == e[1];
}
