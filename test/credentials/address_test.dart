import 'package:core_web3dart/credentials.dart';
import 'package:test/test.dart';

void main() {
  final invalidAddresses = [
    "ab46388940f73e43ef8ab7d448888c782b63f9ccf071",
    "ab46388940f73e43ef8ab7d444888c782b63f9ccf072",
    "ab46377940f73e43ef8ab7d444888c782b63f9ccf071",
    "ab100618f1167cce99b4c886ff055185573100f2bb02",
    "ab100618f1167cce95b4c886ff055185573100f2aa02",
    "ab07a624a0fb7511eb9e054a7a60b6b76c81e863c014",
  ];
  final validAddresses = [
    "ab46388940f73e43ef8ab7d444888c782b63f9ccf071",
    "ab03a922ee6e149b6da6dae0f805507852cf335bc505",
    "ab100618f1167cce95b4c886ff055185573100f2bb02",
    "ab07a624a0fb7511eb9e054a7a60b6b77c81e863c014",
    "ab21be9f765a23bd023e26798b7ac4067ed5ae3e20d1",
  ];

  invalidAddresses.forEach((String invalidAddr) {
    test(
      'invalid addresses validation',
      () {
        final address = XCBAddress.fromHex(invalidAddr);
        expect(address.isValidAddress(), false);
      },
    );
  });

  validAddresses.forEach((String validAddr) {
    test(
      'valid addresses validation',
      () {
        final address = XCBAddress.fromHex(validAddr);
        expect(address.isValidAddress(), true);
      },
    );
  });
}
