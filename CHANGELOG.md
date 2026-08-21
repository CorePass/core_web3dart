# Changelog

All notable changes to Core Web3Dart are documented in this file.

## 2.5.0

- Updated the Dart SDK baseline and direct dependencies.
- Migrated ED448 integration to the public `flutter_ed448` API.
- Added strict ED448 key, signature, and public-key length validation.
- Protected private-key credentials from caller-side byte mutation.
- Added constant-time wallet MAC comparison.
- Added bounds and validation for untrusted PBKDF2 and scrypt parameters.
- Updated contract generator output for current Dart formatting.
- Rebuilt package documentation and continuous integration.
- Added GitHub issue forms and automated test and pub.dev release workflows.
- Added configurable IPFS gateway resolution with bounded JSON loading.
- Added typed CIP-150, CIP-151, and CIP-152 contract metadata support.
- Added Core custom-unit token discovery and balance APIs compatible with Tone
  and Core API.
- Preserved canonical amounts, calculated unit amounts, and live multipliers
  as exact `BigInt` values.

## 2.4.9

- Maintained Core Blockchain RPC, wallet, transaction, and contract support.

## 2.3.3

- Fixed signing legacy transactions without energy and without a client.

## 2.3.2

- Added support for dynamic-fee transactions.

## 2.3.1

- Fixed initialization in the `Web3Client.custom` constructor.

## 2.3.0

- Added generated bindings for overloaded contract methods.

## 2.2.0

- Added public-key access for private-key credentials.
- Improved injected-provider detection in browsers.

## 2.1.4

- Fixed contract generation for unexpected developer-documentation values.

## 2.1.3

- Fixed intermittent random private-key generation failures.

## 2.1.2

- Fixed contract event generation.
- Ignored fallback methods during binding generation.
- Improved parsing of ABIs containing unknown function types.

## 2.1.1

- Respected transaction values during energy estimation.

## 2.1.0

- Added browser integration.
- Added smart-contract binding generation.
- Added fungible-token contract helpers.

## 2.0.0

- Migrated the package to Dart null safety.
- Added raw transaction submission and message-signature verification.
- Added event filters, transaction receipts, and dynamic energy estimation.
- Removed the legacy background-isolate client option.

## 1.0.0

- Introduced the fluent RPC client, transaction model, event streams, and
  account support used as the foundation of Core Web3Dart.
