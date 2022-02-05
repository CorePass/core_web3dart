part of 'package:core_web3dart/web3dart.dart';

class TransactionInformation {
  TransactionInformation.fromMap(Map<String, dynamic> map)
      : blockHash = map['blockHash'] as String,
        blockNumber = map['blockNumber'] != null
            ? BlockNum.exact(int.parse(map['blockNumber'] as String))
            : const BlockNum.pending(),
        from = XCBAddress.fromHex(map['from'] as String),
        energy = int.parse(map['energy'] as String),
        energyPrice =
            XCBAmount.inOre(BigInt.parse(map['energyPrice'] as String)),
        hash = map['hash'] as String,
        input = hexToBytes(map['input'] as String),
        nonce = int.parse(map['nonce'] as String),
        to = map['to'] != null ? XCBAddress.fromHex(map['to'] as String) : null,
        transactionIndex = map['transactionIndex'] != null
            ? int.parse(map['transactionIndex'] as String)
            : null,
        value = XCBAmount.inOre(BigInt.parse(map['value'] as String)),
        signature = hexToBytes(strip0x(map['signature'] as String));

  /// The hash of the block containing this transaction. If this transaction has
  /// not been mined yet and is thus in no block, it will be `null`
  final String? blockHash;

  /// [BlockNum] of the block containing this transaction, or [BlockNum.pending]
  /// when the transaction is not part of any block yet.
  final BlockNum blockNumber;

  /// The sender of this transaction.
  final XCBAddress from;

  /// How many units of energy have been used in this transaction.
  final int energy;

  /// The amount of Core that was used to pay for one unit of energy.
  final XCBAmount energyPrice;

  /// A hash of this transaction, in hexadecimal representation.
  final String hash;

  /// The data sent with this transaction.
  final Uint8List input;

  /// The nonce of this transaction. A nonce is incremented per sender and
  /// transaction to make sure the same transaction can't be sent more than
  /// once.
  final int nonce;

  /// Address of the receiver. `null` when its a contract creation transaction
  final XCBAddress? to;

  /// Integer of the transaction's index position in the block. `null` when it's
  /// pending.
  int? transactionIndex;

  /// The amount of Core sent with this transaction.
  final XCBAmount value;

  /// The ECDSA full signature used to sign this transaction.
  final Uint8List signature;
}

class TransactionReceipt {
  TransactionReceipt(
      {required this.transactionHash,
      required this.transactionIndex,
      required this.blockHash,
      required this.cumulativeEnergyUsed,
      this.blockNumber = const BlockNum.pending(),
      this.contractAddress,
      this.status,
      this.from,
      this.to,
      this.energyUsed,
      this.effectiveEnergyPrice,
      this.logs = const []});

  TransactionReceipt.fromMap(Map<String, dynamic> map)
      : transactionHash = hexToBytes(map['transactionHash'] as String),
        transactionIndex = hexToDartInt(map['transactionIndex'] as String),
        blockHash = hexToBytes(map['blockHash'] as String),
        blockNumber = map['blockNumber'] != null
            ? BlockNum.exact(int.parse(map['blockNumber'] as String))
            : const BlockNum.pending(),
        from = map['from'] != null
            ? XCBAddress.fromHex(map['from'] as String)
            : null,
        to = map['to'] != null ? XCBAddress.fromHex(map['to'] as String) : null,
        cumulativeEnergyUsed = hexToInt(map['cumulativeEnergyUsed'] as String),
        energyUsed = map['energyUsed'] != null
            ? hexToInt(map['energyUsed'] as String)
            : null,
        effectiveEnergyPrice = map['effectiveEnergyPrice'] != null
            ? XCBAmount.inOre(
                BigInt.parse(map['effectiveEnergyPrice'] as String))
            : null,
        contractAddress = map['contractAddress'] != null
            ? XCBAddress.fromHex(map['contractAddress'] as String)
            : null,
        status = map['status'] != null
            ? (hexToDartInt(map['status'] as String) == 1)
            : null,
        logs = map['logs'] != null
            ? (map['logs'] as List<dynamic>)
                .map((log) => FilterEvent.fromMap(log as Map<String, dynamic>))
                .toList()
            : [];

  /// Hash of the transaction (32 bytes).
  final Uint8List transactionHash;

  /// Index of the transaction's position in the block.
  final int transactionIndex;

  /// Hash of the block where this transaction is in (32 bytes).
  final Uint8List blockHash;

  /// Block number where this transaction is in.
  final BlockNum blockNumber;

  /// Address of the sender.
  final XCBAddress? from;

  /// Address of the receiver or `null` if it was a contract creation
  /// transaction.
  final XCBAddress? to;

  /// The total amount of energy used when this transaction was executed in the
  /// block.
  final BigInt cumulativeEnergyUsed;

  /// The amount of energy used by this specific transaction alone.
  final BigInt? energyUsed;

  /// The address of the contract created if the transaction was a contract
  /// creation. `null` otherwise.
  final XCBAddress? contractAddress;

  /// Whether this transaction was executed successfully.
  final bool? status;

  /// Array of logs generated by this transaction.
  final List<FilterEvent> logs;

  final XCBAmount? effectiveEnergyPrice;

  @override
  String toString() {
    return 'TransactionReceipt{transactionHash: ${bytesToHex(transactionHash)}, '
        'transactionIndex: $transactionIndex, blockHash: ${bytesToHex(blockHash)}, '
        'blockNumber: $blockNumber, from: ${from?.hex}, to: ${to?.hex}, '
        'cumulativeEnergyUsed: $cumulativeEnergyUsed, energyUsed: $energyUsed, '
        'contractAddress: ${contractAddress?.hex}, status: $status, '
        'effectiveEnergyPrice: $effectiveEnergyPrice, logs: $logs}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionReceipt &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(transactionHash, other.transactionHash) &&
          transactionIndex == other.transactionIndex &&
          const ListEquality().equals(blockHash, other.blockHash) &&
          blockNumber == other.blockNumber &&
          from == other.from &&
          to == other.to &&
          cumulativeEnergyUsed == other.cumulativeEnergyUsed &&
          energyUsed == other.energyUsed &&
          contractAddress == other.contractAddress &&
          status == other.status &&
          effectiveEnergyPrice == other.effectiveEnergyPrice &&
          const ListEquality().equals(logs, other.logs);

  @override
  int get hashCode =>
      transactionHash.hashCode ^
      transactionIndex.hashCode ^
      blockHash.hashCode ^
      blockNumber.hashCode ^
      from.hashCode ^
      to.hashCode ^
      cumulativeEnergyUsed.hashCode ^
      energyUsed.hashCode ^
      contractAddress.hashCode ^
      status.hashCode ^
      effectiveEnergyPrice.hashCode ^
      logs.hashCode;
}
