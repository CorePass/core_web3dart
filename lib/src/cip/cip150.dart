import '../../web3dart.dart';

const _cip150Abi = '''
[
 {"inputs":[{"name":"key","type":"string"}],"name":"getMetadataValue","outputs":[{"name":"value","type":"string"}],"stateMutability":"view","type":"function"},
 {"inputs":[{"name":"key","type":"string"}],"name":"hasMetadataKey","outputs":[{"name":"exists","type":"bool"}],"stateMutability":"view","type":"function"},
 {"inputs":[{"name":"key","type":"string"}],"name":"isMetadataSealed","outputs":[{"name":"sealed","type":"bool"}],"stateMutability":"view","type":"function"},
 {"inputs":[],"name":"listMetadataKeys","outputs":[{"name":"keys","type":"string[]"}],"stateMutability":"view","type":"function"},
 {"inputs":[{"name":"index","type":"uint256"}],"name":"getMetadataByIndex","outputs":[{"name":"key","type":"string"},{"name":"value","type":"string"}],"stateMutability":"view","type":"function"},
 {"inputs":[],"name":"metadataCount","outputs":[{"name":"total","type":"uint256"}],"stateMutability":"view","type":"function"},
 {"inputs":[{"name":"key","type":"string"},{"name":"value","type":"string"}],"name":"setMetadataValue","outputs":[],"stateMutability":"nonpayable","type":"function"},
 {"inputs":[{"name":"key","type":"string"}],"name":"sealMetadataKey","outputs":[],"stateMutability":"nonpayable","type":"function"}
]
''';

/// A CIP-150 metadata entry.
class Cip150MetadataEntry {
  const Cip150MetadataEntry({
    required this.key,
    required this.value,
    this.sealed,
  });

  final String key;
  final String value;
  final bool? sealed;
}

/// Client for the CIP-150 on-chain key-value metadata interface.
class Cip150MetadataContract extends GeneratedContract {
  Cip150MetadataContract({
    required XCBAddress address,
    required Web3Client client,
    required int networkId,
  }) : super(
         DeployedContract(ContractAbi.fromJson(_cip150Abi, 'CIP150'), address),
         client,
         networkId,
       );

  Future<String> getValue(String key, {BlockNum? atBlock}) async {
    final result = await read(self.function('getMetadataValue'), [
      key,
    ], atBlock);
    return result.single as String;
  }

  Future<bool> hasKey(String key, {BlockNum? atBlock}) async {
    final result = await read(self.function('hasMetadataKey'), [key], atBlock);
    return result.single as bool;
  }

  Future<bool> isSealed(String key, {BlockNum? atBlock}) async {
    final result = await read(self.function('isMetadataSealed'), [
      key,
    ], atBlock);
    return result.single as bool;
  }

  Future<List<String>> listKeys({BlockNum? atBlock}) async {
    final result = await read(self.function('listMetadataKeys'), [], atBlock);
    return List<String>.unmodifiable(result.single as List);
  }

  Future<Cip150MetadataEntry> getByIndex(
    BigInt index, {
    BlockNum? atBlock,
  }) async {
    final result = await read(self.function('getMetadataByIndex'), [
      index,
    ], atBlock);
    return Cip150MetadataEntry(
      key: result[0] as String,
      value: result[1] as String,
    );
  }

  Future<BigInt> count({BlockNum? atBlock}) async {
    final result = await read(self.function('metadataCount'), [], atBlock);
    return result.single as BigInt;
  }

  /// Reads every entry, optionally including its sealed state.
  Future<List<Cip150MetadataEntry>> readAll({
    BlockNum? atBlock,
    bool includeSealedState = true,
  }) async {
    final keys = await listKeys(atBlock: atBlock);
    final entries = await Future.wait(
      keys.map((key) async {
        final values = await Future.wait<Object?>([
          getValue(key, atBlock: atBlock),
          if (includeSealedState) isSealed(key, atBlock: atBlock),
        ]);
        return Cip150MetadataEntry(
          key: key,
          value: values[0]! as String,
          sealed: includeSealedState ? values[1]! as bool : null,
        );
      }),
    );
    return List.unmodifiable(entries);
  }

  Future<String> setValue(
    String key,
    String value, {
    required Credentials credentials,
    Transaction? transaction,
  }) => write(credentials, transaction, self.function('setMetadataValue'), [
    key,
    value,
  ]);

  Future<String> sealKey(
    String key, {
    required Credentials credentials,
    Transaction? transaction,
  }) =>
      write(credentials, transaction, self.function('sealMetadataKey'), [key]);
}
