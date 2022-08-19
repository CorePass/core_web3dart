import 'package:core_web3dart/src/crypto/formatting.dart';
import 'package:core_web3dart/web3dart.dart';

import '../../web3dart.dart';
import '../crypto/formatting.dart';

class BlockInformation {
  final XCBAmount? baseFeePerEnergy;
   List<TransactionInformation> transactions;
  final DateTime timestamp;

  BlockInformation({
    required this.baseFeePerEnergy,
    required this.transactions,
    required this.timestamp,
  });

  factory BlockInformation.fromJson(Map<String, dynamic> json) {
    return BlockInformation(
      baseFeePerEnergy: json.containsKey('baseFeePerEnergy')
          ? XCBAmount.fromUnitAndValue(
              XCBUnit.ore, hexToInt(json['baseFeePerEnergy'] as String))
          : null,
          transactions: json.containsKey('transactions')
            ? (json["transactions"] as List<dynamic>)
                .map((e) =>
                    TransactionInformation.fromMap(e as Map<String, dynamic>))
                .toList()
            : [],

      timestamp: DateTime.fromMillisecondsSinceEpoch(
        hexToDartInt(json['timestamp'] as String) * 1000,
        isUtc: true,
      ),
    );
  }

  bool get isSupportEIP1559 => baseFeePerEnergy != null;
}
