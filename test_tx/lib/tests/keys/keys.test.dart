import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart_example/tests/keys/keys_data.dart';
import 'package:web3dart_example/utils/widget.dart';

final List<Widget> KeyTests = [
  FutureBuilder<List<Widget>>(
    future: _checkItems(),
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
Future<List<Widget>> _checkItems() async {
  List<Widget> _res = [];
  await Future.forEach(Key_Data, (List<dynamic> element) async {
    final _pub = bytesToHex(await privateKeyToPublic(hexToInt(element[0])));
    final _addr = bytesToHex(publicKeyToAddress(hexToBytes(_pub), element[3]));

    _res.add(TestShower(
      isOk: _isKeyOK(element, _pub, _addr),
      errMessage: !_isKeyOK(element, _pub, _addr)
          ? "pub should be ${element[1]}, but is $_pub, the addr should be ${element[2]}, but is $_addr"
          : "",
    ));
  });
  return _res;
}

_isKeyOK(List<dynamic> element, String pub, String addr) {
  return pub == element[1] && addr == element[2];
}
