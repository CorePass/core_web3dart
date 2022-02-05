part of 'package:core_web3dart/web3dart.dart';

class _SigningInput {
  _SigningInput(
      {required this.transaction,
      required this.credentials,
      required this.networkId});

  final Transaction transaction;
  final Credentials credentials;
  final int networkId;
}

Future<_SigningInput> _fillMissingData({
  required Credentials credentials,
  required Transaction transaction,
  required int networkId,
  Web3Client? client,
}) async {
  final sender = transaction.from ?? credentials.extractAddress(networkId);
  var energyPrice = transaction.energyPrice;

  if (client == null &&
      (transaction.nonce == null ||
          transaction.maxEnergy == null ||
          (energyPrice == null))) {
    throw ArgumentError('Client is required to perform network actions');
  }

  energyPrice ??= await client!.getEnergyPrice();

  final nonce = transaction.nonce ??
      await client!
          .getTransactionCount(sender, atBlock: const BlockNum.pending());

  final maxEnergy = transaction.maxEnergy ??
      await client!
          .estimateEnergy(
            sender: sender,
            to: transaction.to,
            data: transaction.data,
            value: transaction.value,
            energyPrice: energyPrice,
          )
          .then((bigInt) => bigInt.toInt());

  // apply default values to null fields
  final modifiedTransaction = transaction.copyWith(
    value: transaction.value ?? XCBAmount.zero(),
    maxEnergy: maxEnergy,
    from: sender,
    data: transaction.data ?? Uint8List(0),
    energyPrice: energyPrice,
    nonce: nonce,
  );

  int resolvedChainId;
  resolvedChainId = networkId;

  return _SigningInput(
    transaction: modifiedTransaction,
    credentials: credentials,
    networkId: resolvedChainId,
  );
}

Uint8List _signTransaction(
    Transaction transaction, Credentials c, BigInt networkId) {
  final _enRlp = _encodeRawToRlp(transaction, networkId);

  final _enLp = rlp.encode(_enRlp);
  final encoded = uint8ListFromList(_enLp);
  final signature = c.signToSignature(encoded, networkId: networkId.toInt());
  final _sigEnRlp = _encodeToRlp(transaction, signature, networkId);
  print(_sigEnRlp.toString());
  final _sigLp = rlp.encode(_sigEnRlp);
  final _res = uint8ListFromList(_sigLp);

  return _res;
}

List<dynamic> _encodeToRlp(
    Transaction transaction, Uint8List signature, BigInt networkId) {
  final list = [
    transaction.nonce ?? 0,
    transaction.energyPrice?.getInOre ?? 0,
    transaction.maxEnergy ?? 0,
    networkId
  ];

  if (transaction.to != null) {
    list.add(transaction.to!.addressBytes);
  } else {
    list.add('');
  }

  list
    ..add(transaction.value?.getInOre ?? 0)
    ..add(transaction.data ?? 0);

  list..add(signature);

  return list;
}

List<dynamic> _encodeRawToRlp(Transaction transaction, BigInt networkId) {
  final list = [
    transaction.nonce ?? 0,
    transaction.energyPrice?.getInOre ?? 0,
    transaction.maxEnergy ?? 0,
  ];

  if (transaction.to != null) {
    list.add(transaction.to!.addressBytes);
  } else {
    list.add('');
  }
  list
    ..add(transaction.value?.getInOre ?? 0)
    ..add(transaction.data ?? 0)
    ..add(networkId);
  return list;
}
