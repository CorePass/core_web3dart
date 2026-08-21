# Contributing

Contributions to Core Web3Dart should remain focused on Core Blockchain and
must preserve ED448 and CORE ID behavior.

## Development setup

```console
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
```

When contract generator output changes, regenerate its snapshots:

```console
dart run tool/generate_goldens.dart
```

## Pull requests

- Add tests for behavior changes and security fixes.
- Update `CHANGELOG.md` for user-visible changes.
- Avoid committing secrets, generated dependency lock files, or local build
  output.
- Keep public APIs documented and use Core Blockchain terminology.
