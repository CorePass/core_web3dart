enum XCBUnit {
  ///Ore, the smallest and atomic amount of Core
  ore,

  ///fecore, 1000 ore
  fecore,

  ///Picore, one million ore
  picore,

  ///Nacore, one billion ore. Typically a reasonable unit to measure energy prices.
  nacore,

  ///Μcore, 10^12 ore or 1 μCore
  mcore,

  ///micore, 10^15 ore or 1 mcore
  micore,

  core
}

/// Utility class to easily convert amounts of Core into different units of
/// quantities.
class XCBAmount {
  static final Map<XCBUnit, BigInt> _factors = {
    XCBUnit.ore: BigInt.one,
    XCBUnit.fecore: BigInt.from(10).pow(3),
    XCBUnit.picore: BigInt.from(10).pow(6),
    XCBUnit.nacore: BigInt.from(10).pow(9),
    XCBUnit.mcore: BigInt.from(10).pow(12),
    XCBUnit.micore: BigInt.from(10).pow(15),
    XCBUnit.core: BigInt.from(10).pow(18)
  };

  final BigInt _value;

  BigInt get getInOre => _value;
  BigInt get getInCore => getValueInUnitBI(XCBUnit.core);

  const XCBAmount.inOre(this._value);

  XCBAmount.zero() : this.inOre(BigInt.zero);

  /// Constructs an amount of Core by a unit and its amount. [amount] can
  /// either be a base10 string, an int, or a BigInt.
  factory XCBAmount.fromUnitAndValue(XCBUnit unit, dynamic amount) {
    BigInt parsedAmount;

    if (amount is BigInt) {
      parsedAmount = amount;
    } else if (amount is int) {
      parsedAmount = BigInt.from(amount);
    } else if (amount is String) {
      parsedAmount = BigInt.parse(amount);
    } else {
      throw ArgumentError('Invalid type, must be BigInt, string or int');
    }

    return XCBAmount.inOre(parsedAmount * _factors[unit]!);
  }

  /// Gets the value of this amount in the specified unit as a whole number.
  /// **WARNING**: For all units except for [XCBUnit.ore], this method will
  /// discard the remainder occurring in the division, making it unsuitable for
  /// calculations or storage. You should store and process amounts of ether by
  /// using a BigInt storing the amount in wei.
  BigInt getValueInUnitBI(XCBUnit unit) => _value ~/ _factors[unit]!;

  /// Gets the value of this amount in the specified unit. **WARNING**: Due to
  /// rounding errors, the return value of this function is not reliable,
  /// especially for larger amounts or smaller units. While it can be used to
  /// display the amount of ether in a human-readable format, it should not be
  /// used for anything else.
  num getValueInUnit(XCBUnit unit) {
    final factor = _factors[unit]!;
    final value = _value ~/ factor;
    final remainder = _value.remainder(factor);

    return value.toInt() + (remainder.toInt() / factor.toInt());
  }

  @override
  String toString() {
    return 'XCBAmount: $getInOre ore';
  }

  @override
  int get hashCode => getInOre.hashCode;

  @override
  bool operator ==(dynamic other) =>
      other is XCBAmount && other.getInOre == getInOre;
}
