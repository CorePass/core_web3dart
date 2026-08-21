import 'package:core_web3dart/crypto.dart';
import 'package:core_web3dart/web3dart.dart';
import 'package:test/test.dart';

void main() {
  test('custom-unit ABI selectors match Core API', () {
    const functions = <ContractFunction>[
      ContractFunction('supportsUnit', [
        FunctionParameter('unit', StringType()),
      ]),
      ContractFunction('supportedUnits', []),
      ContractFunction('preferredUnit', []),
      ContractFunction('balanceOfUnit', [
        FunctionParameter('account', AddressType()),
        FunctionParameter('unit', StringType()),
      ]),
    ];

    expect(functions.map((function) => bytesToHex(function.selector)), [
      '7699d01c',
      '9edb0a19',
      '73d23bf0',
      'a81abaa1',
    ]);
  });

  group('CustomUnitDiscovery', () {
    test('accepts the Core custom-unit discovery contract', () {
      const discovery = CustomUnitDiscovery(
        supportedUnits: ['units', 'GRAM'],
        preferredUnit: 'GRAM',
      );

      expect(discovery.isValid, isTrue);
      expect(discovery.supports('GRAM'), isTrue);
      expect(discovery.supports('USD'), isFalse);
    });

    test('rejects a response without mandatory units capability', () {
      const discovery = CustomUnitDiscovery(
        supportedUnits: ['GRAM'],
        preferredUnit: 'GRAM',
      );

      expect(discovery.isValid, isFalse);
    });

    test('rejects a preferred unit not advertised by the contract', () {
      const discovery = CustomUnitDiscovery(
        supportedUnits: ['units', 'GRAM'],
        preferredUnit: 'KG',
      );

      expect(discovery.isValid, isFalse);
    });
  });

  group('CustomUnitBalance', () {
    test('keeps the live multiplier exact', () {
      final balance = CustomUnitBalance(
        canonicalAmount: BigInt.from(8),
        unitAmount: BigInt.from(10),
        unit: 'GRAM',
      );

      expect(balance.multiplierNumerator, BigInt.from(10));
      expect(balance.multiplierDenominator, BigInt.from(8));
      expect(balance.approximateMultiplier, 1.25);
    });

    test('does not divide a zero canonical balance', () {
      final balance = CustomUnitBalance(
        canonicalAmount: BigInt.zero,
        unitAmount: BigInt.zero,
        unit: 'GRAM',
      );

      expect(balance.approximateMultiplier, isNull);
    });
  });
}
