# Core Web3Dart

Core Web3Dart is a Dart SDK for Core Blockchain applications. It provides
JSON-RPC access, ED448 account operations, CORE ID address derivation,
transaction signing, V3 wallet support, and strongly typed smart-contract
bindings.

## Features

- Connect to Core Blockchain JSON-RPC endpoints.
- Derive ED448 keys and network-aware CORE ID addresses.
- Create, sign, and submit Core transactions.
- Sign and verify Core personal messages.
- Read balances, blocks, receipts, logs, and contract state.
- Encode and decode smart-contract ABI values.
- Generate typed Dart contract clients from `.abi.json` files.
- Encrypt and unlock V3 wallet files with bounded PBKDF2 or scrypt settings.

## Requirements

- Dart SDK 3.7 or newer.
- A Core Blockchain JSON-RPC endpoint for network operations.

## Installation

Add the package to a Dart or Flutter project:

```console
dart pub add core_web3dart
```

## Connect to Core Blockchain

```dart
import 'package:core_web3dart/web3dart.dart';
import 'package:http/http.dart';

Future<void> main() async {
  final httpClient = Client();
  final client = Web3Client(
    'https://xcbapi.coreblockchain.net/',
    httpClient,
    '',
    '',
  );

  try {
    final networkId = await client.getNetworkId();
    print('Connected to Core network $networkId');
  } finally {
    await client.dispose();
    httpClient.close();
  }
}
```

## ED448 accounts and CORE IDs

Create a deterministic account from seed material and an index:

```dart
import 'package:core_web3dart/web3dart.dart';

final credentials = XCBPrivateKey.createPrivateKey(seedHex, 0);
final address = credentials.extractAddress(1);

print(address.hex);
```

Treat seed material and private keys as secrets. Generate seeds with a
cryptographically secure source and store them only in platform secure storage.

## Sign and send a transaction

```dart
final transaction = Transaction(
  to: XCBAddress.fromHex(recipientCoreId),
  value: XCBAmount.fromUnitAndValue(XCBUnit.core, 1),
  maxEnergy: 100000,
);

final transactionId = await client.sendTransaction(
  credentials,
  transaction,
  networkId: await client.getNetworkId(),
);
```

Use `client.signTransaction` when the signed bytes must be transported by a
different channel.

## Encrypted wallets

The package can read and create version 3 wallet JSON files:

```dart
import 'dart:math';

final wallet = Wallet.createNew(
  credentials,
  password,
  Random.secure(),
);

final encoded = wallet.toJson();
final unlocked = Wallet.fromJson(encoded, password).privateKey;
```

Wallet JSON should still be treated as sensitive. Use a strong password, keep
backups offline, and never log decrypted key material.

## Contract code generation

Place a contract ABI in `lib/` with an `.abi.json` suffix and add
`build_runner` to the consuming project's development dependencies. Generate
the typed client with:

```console
dart run build_runner build --delete-conflicting-outputs
```

The generated `.g.dart` file contains a typed client for contract calls,
transactions, and events.

## IPFS and Core metadata standards

`IpfsGateway` resolves `ipfs://` references through `https://ipf.sk/{cid}` by
default. Applications can provide their own HTTP(S) gateway template and HTTP
client:

```dart
final gateway = IpfsGateway(
  template: 'https://gateway.example/ipfs/{cid}',
);
final metadata = await gateway.readJson('ipfs://bafy.../metadata.json');
```

The package also provides typed support for:

- CIP-150 on-chain key-value metadata reads, writes, sealing, and enumeration.
- CIP-151 token expiration and trading-stop timestamps.
- CIP-152 IPFS-backed `lab.json` certificate resolution and validation.

```dart
final metadata = Cip150MetadataContract(
  address: contractAddress,
  client: client,
  networkId: await client.getNetworkId(),
);

final lifecycle = await metadata.readLifecycle();
final certificate = await metadata.readLabCertificate(gateway);
```

### Custom-unit tokens

Tone and Core API use Core token unit discovery to display
contract-calculated balances whose multiplier can change over time. The
library validates the mandatory `units` capability and keeps both balances
exact:

```dart
final token = CustomUnitToken(client, tokenContract);
final units = await token.discover();
if (units != null) {
  final balance = await token.balance(
    walletAddress,
    unit: units.preferredUnit,
  );
  print('${balance.unitAmount} ${balance.unit}');
  print('canonical: ${balance.canonicalAmount}');
}
```

Because custom-unit multipliers can change with contract state or time, query
the balance again when freshness matters. Use `multiplierNumerator` and
`multiplierDenominator` for financial calculations instead of floating point.

## Security

Report vulnerabilities privately by following [SECURITY.md](SECURITY.md). Do
not open a public issue containing private keys, seed phrases, exploitable
details, or production credentials.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development and verification steps.

## License

Core Web3Dart is available under the [CORE License](LICENSE).
