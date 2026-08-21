import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:core_web3dart/crypto.dart';
import 'package:core_web3dart/web3dart.dart';

const _privateKey1 =
    '352982b8db63897619f8b182d3b9e91d3189ec62b9b101e34098acadac583801388e9549fe144d7684b8106bc94827a459805132030668ae9f';
const _privateKey2 =
    'b922de7256c7ec4d5c65641685ef0ad8e8a4e6e39a7129e604dafe596e61ad9778241d2593ceb2eb5879a8e15e8b07ada346319eb465ce89ce';

void main() {
  late int rpcPort;

  late XCBPrivateKey first;
  late XCBPrivateKey second;

  late Web3Client client;

  final networkId = 1337;

  setUpAll(() async {
    rpcPort = 8545;
    print('Starting ganache on port $rpcPort');

    print('Waiting for ganache to start up');
    var connectionAttempts = 0;
    var successful = false;
    do {
      connectionAttempts++;
      try {
        await get(Uri.parse('http://127.0.0.1:$rpcPort'));
        successful = true;
      } on SocketException {
        await Future.delayed(const Duration(seconds: 2));
      }
    } while (connectionAttempts < 5);

    if (!successful) {
      throw StateError('ganache did not start up');
    }
  });

  setUp(() {
    first = XCBPrivateKey(hexToBytes(_privateKey1));
    second = XCBPrivateKey(hexToBytes(_privateKey2));

    client = Web3Client(
      'http://127.0.0.1:$rpcPort',
      Client(),
      'ping-dev',
      'caC12cas',
    );
  });

  tearDown(() => client.dispose());

  test('simple transactions', () async {
    final firstAddress = await first.extractAddress(networkId);
    final secondAddress = await second.extractAddress(networkId);

    final balanceOfFirst = await client.getBalance(firstAddress);
    final balanceOfSecond = await client.getBalance(secondAddress);
    final value = BigInt.from(1337);

    final hash = await client.sendTransaction(
      first,
      Transaction(
        to: secondAddress,
        value: XCBAmount.inOre(value),
        energyPrice: XCBAmount.zero(),
      ),
      networkId: networkId,
    );

    expect(
      (await client.getBalance(firstAddress)).getInOre,
      balanceOfFirst.getInOre - value,
    );
    expect(
      (await client.getBalance(secondAddress)).getInOre,
      balanceOfSecond.getInOre + value,
    );

    final receipt = await client.getTransactionReceipt(hash);
    expect(
      receipt,
      isA<TransactionReceipt>()
          .having((e) => e.to, 'to', secondAddress)
          .having((e) => e.from, 'from', firstAddress),
    );
  });

  test('EIP-1559 transactions', () async {
    final firstAddress = await first.extractAddress(networkId);
    final secondAddress = await second.extractAddress(networkId);

    final balanceOfFirst = await client.getBalance(firstAddress);
    final balanceOfSecond = await client.getBalance(secondAddress);
    final value = BigInt.from(1337);

    final hash = await client.sendTransaction(
      first,
      Transaction(to: secondAddress, value: XCBAmount.inOre(value)),
      networkId: networkId,
    );

    expect(
      (await client.getBalance(firstAddress)).getInOre,
      balanceOfFirst.getInOre - value,
    );
    expect(
      (await client.getBalance(secondAddress)).getInOre,
      balanceOfSecond.getInOre + value,
    );

    final receipt = await client.getTransactionReceipt(hash);
    expect(
      receipt,
      isA<TransactionReceipt>()
          .having((e) => e.to, 'to', secondAddress)
          .having((e) => e.from, 'from', firstAddress),
    );
  });

  test('getTransactionReceipt returns null for unknown transactions', () {
    expect(
      client.getTransactionReceipt(
        '0x1234567812345678123456781234567812345678123456781234567812345678',
      ),
      completion(isNull),
    );
  });
}
