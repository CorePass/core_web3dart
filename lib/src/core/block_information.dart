import 'package:web3dart/src/crypto/formatting.dart';
import 'package:web3dart/web3dart.dart';

class BlockInformation {
  XCBAmount? baseFeePerEnergy;

  BlockInformation({this.baseFeePerEnergy});

  factory BlockInformation.fromJson(Map<String, dynamic> json) {
    return BlockInformation(
        baseFeePerEnergy: json.containsKey('baseFeePerEnergy')
            ? XCBAmount.fromUnitAndValue(
                XCBUnit.ore, hexToInt(json['baseFeePerEnergy'] as String))
            : null);
  }

  bool get isSupportEIP1559 => baseFeePerEnergy != null;
}
