import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart_example/utils/consts.dart';
import 'package:web3dart_example/utils/contract.g.dart';
import 'package:web3dart_example/utils/widget.dart';

final List<Widget> ContractTests = [
  FutureBuilder<List<Widget>>(
    future: _testContract(),
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

Future<List<Widget>> _testContract() async {
  List<Widget> _res = [];
  var web3 = Web3Client(blockChainURL, http.Client(), "", "");
  final networkId = await web3.getNetworkId();
  var ctr = Contract(
      address: XCBAddress.fromHex(CONTRACT_ADDRESS),
      client: web3,
      networkId: networkId);
  ctr.balancChangedEvents().listen((event) {
    print(event);
  });
  try {
    var balance = await ctr.getBalance();
    print("this is balance:  " + balance.toString());
    _res.add(const TestShower(isOk: true, errMessage: ""));
  } catch (e) {
    _res.add(
        const TestShower(isOk: false, errMessage: "error in getting balance"));
  }
  try {
    var hash = await ctr.deposit(BigInt.one,
        credentials: XCBPrivateKey.fromHex(privateKey));
    _res.add(const TestShower(isOk: true, errMessage: ""));
  } catch (e) {
    _res.add(
        const TestShower(isOk: false, errMessage: "error in deposit balance"));
  }

  return _res;
}
