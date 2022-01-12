import 'package:flutter/material.dart';
import 'package:web3dart_example/tests/contract/contract_tester.dart';
import 'package:web3dart_example/tests/keys/keys.test.dart';
import 'package:web3dart_example/tests/rlp/rlp.test.dart';
import 'package:web3dart_example/tests/transaction/tx_tester.dart';

final List<Data> tests = [
  Data(data: ContractTests, name: "contract"),
  Data(data: RLPTests, name: "RLP"),
  Data(data: KeyTests, name: "Keys"),
  Data(data: TxTests, name: "Transaction")
];

class Data {
  final List<Widget> data;
  final String name;

  Data({required this.data, required this.name});
}
