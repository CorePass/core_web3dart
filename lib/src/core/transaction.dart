part of 'package:core_web3dart/web3dart.dart';

class Transaction {
  /// The address of the sender of this transaction.
  ///
  /// This can be set to null, in which case the client will use the address
  /// belonging to the credentials used to this transaction.
  final XCBAddress? from;

  /// The recipient of this transaction, or null for transactions that create a
  /// contract.
  final XCBAddress? to;

  /// The maximum amount of energy to spend.
  ///
  /// If [maxEnergy] is `null`, this library will ask the rpc node to estimate a
  /// reasonable spending via [Web3Client.estimateEnergy].
  ///
  /// Energy that is not used but included in [maxEnergy] will be returned.
  final int? maxEnergy;

  /// How much ether to spend on a single unit of energy. Can be null, in which
  /// case the rpc server will choose this value.
  final XCBAmount? energyPrice;

  /// How much ether to send to [to]. This can be null, as some transactions
  /// that call a contracts method won't have to send ether.
  final XCBAmount? value;

  /// For transactions that call a contract function or create a contract,
  /// contains the hashed function name and the encoded parameters or the
  /// compiled contract code, respectively.
  final Uint8List? data;

  /// The nonce of this transaction. A nonce is incremented per sender and
  /// transaction to make sure the same transaction can't be sent more than
  /// once.
  ///
  /// If null, it will be determined by checking how many transactions
  /// have already been sent by [from].
  final int? nonce;

  Transaction({
    this.from,
    this.to,
    this.maxEnergy,
    this.energyPrice,
    this.value,
    this.data,
    this.nonce,
  });

  /// Constructs a transaction that can be used to call a contract function.
  Transaction.callContract({
    required DeployedContract contract,
    required ContractFunction function,
    required List<dynamic> parameters,
    this.from,
    this.maxEnergy,
    this.energyPrice,
    this.value,
    this.nonce,
  })  : to = contract.address,
        data = function.encodeCall(parameters);

  Transaction copyWith(
      {XCBAddress? from,
      XCBAddress? to,
      int? maxEnergy,
      XCBAmount? energyPrice,
      XCBAmount? value,
      Uint8List? data,
      int? nonce,
      XCBAmount? maxPriorityFeePerEnergy,
      XCBAmount? maxFeePerEnergy}) {
    return Transaction(
      from: from ?? this.from,
      to: to ?? this.to,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      energyPrice: energyPrice ?? this.energyPrice,
      value: value ?? this.value,
      data: data ?? this.data,
      nonce: nonce ?? this.nonce,
    );
  }
}
