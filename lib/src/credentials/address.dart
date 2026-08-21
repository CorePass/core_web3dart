import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:core_web3dart/crypto.dart';

final _precompiledContracts = [
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      1,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      2,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      3,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      4,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      5,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      6,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      7,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      8,
    ]),
  ),
  bytesToHex(
    Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      9,
    ]),
  ),
];

/// Represents an Core Block Chain address.
@immutable
class XCBAddress {
  static final xcbAddrLength = 44;
  static final RegExp basicAddress = RegExp(
    r'((cb)|(ce)|(ab))[0-9a-f]{42}',
    caseSensitive: false,
  );

  /// The length of an ethereum address, in bytes.
  static const addressByteLength = 22;

  final Uint8List addressBytes;

  /// An ethereum address from the raw address bytes.
  const XCBAddress(this.addressBytes);

  /// Constructs an Core Block Chain address from a public key. The address is formed by
  /// the last 20 bytes of the keccak hash of the public key.
  factory XCBAddress.fromPublicKey(Uint8List publicKey, int networkId) {
    return XCBAddress(publicKeyToAddress(publicKey, networkId));
  }

  /// Parses an Core Block Chain address from the hexadecimal representation. The
  /// representation must have a length of 20 bytes (or 40 hexadecimal chars),
  /// and can optionally be prefixed with "0x".
  ///

  factory XCBAddress.fromHex(String hex) {
    if (!basicAddress.hasMatch(hex)) {
      throw ArgumentError.value(
        hex,
        'address',
        'Must be a hex string with a length of $xcbAddrLength',
      );
    }

    if (hex.toUpperCase() == hex || hex.toLowerCase() == hex) {
      return XCBAddress(hexToBytes(hex));
    }

    return XCBAddress(hexToBytes(hex));
  }

  bool isValidAddress() {
    if (_precompiledContracts.contains(bytesToHex(addressBytes))) {
      return true;
    }

    if (bytesToHex(addressBytes.sublist(1, 2)) !=
        calculateCheckSum(
          addressBytes.sublist(2),
          addressBytes.sublist(0, 1),
        )) {
      return false;
    }

    return true;
  }

  /// A hexadecimal representation of this address, padded to a length of 44
  /// characters or 22 bytes, and prefixed with "0x".
  String get hex =>
      bytesToHex(addressBytes, include0x: true, forcePadLength: xcbAddrLength);

  /// A hexadecimal representation of this address, padded to a length of 44
  /// characters or 20 bytes, but not prefixed with "0x".
  String get hexNo0x =>
      bytesToHex(addressBytes, include0x: false, forcePadLength: xcbAddrLength);

  @override
  String toString() => hex;

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        (other is XCBAddress &&
            const ListEquality().equals(addressBytes, other.addressBytes));
  }

  @override
  int get hashCode {
    return hex.hashCode;
  }
}
