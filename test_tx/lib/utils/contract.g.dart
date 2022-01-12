// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"int256","name":"balance","type":"int256"}],"name":"BalancChanged","type":"event"},{"inputs":[{"internalType":"int256","name":"amt","type":"int256"}],"name":"deposit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getBalance","outputs":[{"internalType":"int256","name":"","type":"int256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"int256","name":"amt","type":"int256"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"}]',
    'Contract');

class Contract extends _i1.GeneratedContract {
  Contract(
      {required _i1.XCBAddress address,
      required _i1.Web3Client client,
      required int networkId})
      : super(_i1.DeployedContract(_contractAbi, address), client, networkId);

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> deposit(BigInt amt,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[1];
    final params = [amt];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getBalance({_i1.BlockNum? atBlock}) async {
    final function = self.abi.functions[2];
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> withdraw(BigInt amt,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.abi.functions[3];
    final params = [amt];
    return write(credentials, transaction, function, params);
  }

  /// Returns a live stream of all BalancChanged events emitted by this contract.
  Stream<BalancChanged> balancChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('BalancChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return BalancChanged(decoded);
    });
  }
}

class BalancChanged {
  BalancChanged(List<dynamic> response) : balance = (response[0] as BigInt);

  final BigInt balance;
}
