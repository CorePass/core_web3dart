import 'package:core_web3dart/web3dart.dart';

void main() {
  final address = XCBAddress.fromHex(
    'cb95f07b1f6086861871808348ff0a6b2e8bc7c6f3fdc871f398b6c6',
  );
  print(address.hex);
}
