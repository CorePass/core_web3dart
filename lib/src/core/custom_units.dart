part of '../../web3dart.dart';

const _customUnitAbi = '''
[
  {"type":"function","name":"supportsUnit","stateMutability":"view","inputs":[{"name":"unit","type":"string"}],"outputs":[{"name":"","type":"bool"}]},
  {"type":"function","name":"supportedUnits","stateMutability":"view","inputs":[],"outputs":[{"name":"","type":"string[]"}]},
  {"type":"function","name":"preferredUnit","stateMutability":"view","inputs":[],"outputs":[{"name":"","type":"string"}]},
  {"type":"function","name":"balanceOf","stateMutability":"view","inputs":[{"name":"account","type":"address"}],"outputs":[{"name":"","type":"uint256"}]},
  {"type":"function","name":"balanceOfUnit","stateMutability":"view","inputs":[{"name":"account","type":"address"},{"name":"unit","type":"string"}],"outputs":[{"name":"","type":"uint256"}]}
]
''';

/// Unit capabilities reported by a Core token contract.
@immutable
class CustomUnitDiscovery {
  /// Every unit reported by `supportedUnits()`.
  final List<String> supportedUnits;

  /// The contract's default display and calculation unit.
  final String preferredUnit;

  const CustomUnitDiscovery({
    required this.supportedUnits,
    required this.preferredUnit,
  });

  /// Whether this response satisfies the Core custom-unit contract.
  bool get isValid =>
      supportedUnits.contains('units') &&
      preferredUnit.isNotEmpty &&
      supportedUnits.contains(preferredUnit);

  /// Whether [unit] can be used with unit-aware contract methods.
  bool supports(String unit) => supportedUnits.contains(unit);
}

/// Exact canonical and custom-unit balances returned by a token contract.
@immutable
class CustomUnitBalance {
  /// Result of the canonical `balanceOf(address)` call.
  final BigInt canonicalAmount;

  /// Result of `balanceOfUnit(address, unit)`.
  final BigInt unitAmount;

  /// Unit used for [unitAmount].
  final String unit;

  const CustomUnitBalance({
    required this.canonicalAmount,
    required this.unitAmount,
    required this.unit,
  });

  /// Exact multiplier numerator. The multiplier is this value divided by
  /// [multiplierDenominator].
  BigInt get multiplierNumerator => unitAmount;

  /// Exact multiplier denominator.
  BigInt get multiplierDenominator => canonicalAmount;

  /// Convenience approximation of the current multiplier.
  ///
  /// Financial code should use the exact numerator and denominator instead.
  double? get approximateMultiplier =>
      canonicalAmount == BigInt.zero
          ? null
          : unitAmount.toDouble() / canonicalAmount.toDouble();
}

/// Read-only interface for Core tokens implementing calculated custom units.
class CustomUnitToken {
  final Web3Client _client;
  final DeployedContract _contract;

  /// Creates a custom-unit reader for [contractAddress].
  CustomUnitToken(Web3Client client, XCBAddress contractAddress)
    : _client = client,
      _contract = DeployedContract(
        ContractAbi.fromJson(_customUnitAbi, 'CustomUnitToken'),
        contractAddress,
      );

  Future<List<dynamic>> _read(
    String function,
    List<dynamic> parameters, {
    BlockNum? atBlock,
  }) => _client.call(
    contract: _contract,
    function: _contract.function(function),
    params: parameters,
    atBlock: atBlock,
  );

  /// Calls `supportsUnit(unit)`.
  Future<bool> supportsUnit(String unit, {BlockNum? atBlock}) async {
    final normalized = unit.trim();
    if (normalized.isEmpty) return false;
    final result = await _read('supportsUnit', [normalized], atBlock: atBlock);
    return result.single as bool;
  }

  /// Calls `supportedUnits()` without applying discovery validation.
  Future<List<String>> supportedUnits({BlockNum? atBlock}) async {
    final result = await _read('supportedUnits', const [], atBlock: atBlock);
    return List<String>.unmodifiable((result.single as List).cast<String>());
  }

  /// Calls `preferredUnit()` without applying discovery validation.
  Future<String> preferredUnit({BlockNum? atBlock}) async {
    final result = await _read('preferredUnit', const [], atBlock: atBlock);
    return (result.single as String).trim();
  }

  /// Detects and validates the custom-unit capability used by Tone/Core API.
  Future<CustomUnitDiscovery?> discover({BlockNum? atBlock}) async {
    if (!await supportsUnit('units', atBlock: atBlock)) return null;
    final discovery = CustomUnitDiscovery(
      supportedUnits: await supportedUnits(atBlock: atBlock),
      preferredUnit: await preferredUnit(atBlock: atBlock),
    );
    return discovery.isValid ? discovery : null;
  }

  /// Reads the canonical token balance.
  Future<BigInt> canonicalBalance(
    XCBAddress account, {
    BlockNum? atBlock,
  }) async {
    final result = await _read('balanceOf', [account], atBlock: atBlock);
    return result.single as BigInt;
  }

  /// Reads a calculated balance in [unit].
  Future<BigInt> balanceOfUnit(
    XCBAddress account,
    String unit, {
    BlockNum? atBlock,
  }) async {
    final normalized = unit.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(unit, 'unit', 'Must not be empty');
    }
    final result = await _read('balanceOfUnit', [
      account,
      normalized,
    ], atBlock: atBlock);
    return result.single as BigInt;
  }

  /// Reads canonical and calculated balances at the same block reference.
  Future<CustomUnitBalance> balance(
    XCBAddress account, {
    String? unit,
    BlockNum? atBlock,
  }) async {
    final resolvedUnit =
        unit?.trim().isNotEmpty == true
            ? unit!.trim()
            : await preferredUnit(atBlock: atBlock);
    if (resolvedUnit.isEmpty) {
      throw StateError('The token contract did not provide a preferred unit');
    }
    final values = await Future.wait<BigInt>([
      canonicalBalance(account, atBlock: atBlock),
      balanceOfUnit(account, resolvedUnit, atBlock: atBlock),
    ]);
    return CustomUnitBalance(
      canonicalAmount: values[0],
      unitAmount: values[1],
      unit: resolvedUnit,
    );
  }
}
