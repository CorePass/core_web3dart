import 'package:test/test.dart';
import 'package:core_web3dart/contracts.dart';
import 'package:core_web3dart/src/credentials/address.dart';
import 'package:core_web3dart/src/crypto/formatting.dart';

void main() {
  final event = ContractEvent(false, 'Transfer', const [
    EventComponent(FunctionParameter('from', AddressType()), true),
    EventComponent(FunctionParameter('to', AddressType()), true),
    EventComponent(FunctionParameter('amount', UintType()), false),
  ]);

  test('creates signature', () {
    expect(bytesToHex(event.signature),
        'c17a9d92b89f27cb79cc390f23a1a5d302fefab8c7911075ede952ac2b5607a1');
  });

  test('decodes return data', () {
    const topics = [
      '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef',
      '0x000000000000000000000000Dd611f2b2CaF539aC9e12CF84C09CB9bf81CA37F',
      '0x0000000000000000000000006c87E1a114C3379BEc929f6356c5263d62542C13',
    ];
    const data =
        '0x0000000000000000000000000000000000000000000000000000000000001234';

    final decoded = event.decodeResults(topics, data);

    expect(decoded, [
      XCBAddress(hexToBytes('0000Dd611f2b2CaF539aC9e12CF84C09CB9bf81CA37F')),
      XCBAddress(hexToBytes('00006c87E1a114C3379BEc929f6356c5263d62542C13')),
      BigInt.from(0x1234),
    ]);
  });
}
