import 'package:flutter/material.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart_example/utils/widget.dart';

final List<Widget> TxTests = [
  FutureBuilder<List<Widget>>(
    future: _testTx(),
    builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
      List<Widget> children;
      if (snapshot.hasData) {
        children = snapshot.data ?? [];
      } else if (snapshot.hasError) {
        children = <Widget>[
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text('Error: ${snapshot.error}'),
          )
        ];
      } else {
        children = const <Widget>[
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('Awaiting result...'),
          )
        ];
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      );
    },
  )
];

Future<List<Widget>> _testTx() async {
  List<Widget> _res = [];
  final _tx = Transaction(
      to: XCBAddress.fromHex("ce276773ac97d16855a3c8faa45399136b56d4194860"),
      value: XCBAmount.fromUnitAndValue(XCBUnit.ore, 200),
      nonce: 0,
      maxEnergy: 999999,
      energyPrice: XCBAmount.fromUnitAndValue(XCBUnit.ore, 10),
      data: hexToBytes(""));
  final _txRes = bytesToHex(await Web3Client("url", http.Client(), "", "")
      .signTransaction(
          XCBPrivateKey.fromHex(
              "69bb68c3a00a0cd9cbf2cab316476228c758329bbfe0b1759e8634694a9497afea05bcbf24e2aa0627eac4240484bb71de646a9296872a3c0e"),
          _tx,
          networkId: 0));
  _res.add(TestShower(
      isOk: _txRes ==
          "f8ce800a830f423f8096ce276773ac97d16855a3c8faa45399136b56d419486081c880b8ab448eafc4ad76f52262dc04c09738e017dbf7dac5cee6d7bf0a8c0b60aaa1403d10e3d3a28f2d0ce9a9ffb64ebb9e0a59a3637f0f48aa597f80722d2c29acab15b7e2677f3df91ea86ecbb0f6cc871fdf39a154262ed467ae6e2996cdc09dbce205c318b7581d28bae84c0eb3d118edf61000315484db568379ce94f9c894e3e6e4c7ee216676b713ca892d9b26746ae902a772e217a6a8bb493ce2bb313cf0cb66e76765d4c45ec6b68600",
      errMessage: ""));
  return _res;
}
