import 'package:web3dart/src/crypto/formatting.dart';
import 'package:web3dart/web3dart.dart';

import '../../web3dart.dart';
import '../crypto/formatting.dart';

class BlockInformation {
  final XCBAmount? baseFeePerEnergy;
  final DateTime timestamp;

  BlockInformation({
    required this.baseFeePerEnergy,
    required this.timestamp,
  });

  factory BlockInformation.fromJson(Map<String, dynamic> json) {
    return BlockInformation(
      baseFeePerEnergy: json.containsKey('baseFeePerEnergy')
          ? XCBAmount.fromUnitAndValue(
              XCBUnit.ore, hexToInt(json['baseFeePerEnergy'] as String))
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        hexToDartInt(json['timestamp'] as String) * 1000,
        isUtc: true,
      ),
    );
  }

  bool get isSupportEIP1559 => baseFeePerEnergy != null;
}
