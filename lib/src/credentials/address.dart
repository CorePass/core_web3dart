import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:web3dart/crypto.dart';

/// Represents an Core Block Chain address.
@immutable
class XCBAddress {
  // TODO: proper Regex should be added here
  static final xcbAddrLength = 44;
  static final RegExp _basicAddress =
      RegExp(r'^(0x)?[0-9a-f]{44}', caseSensitive: false);

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

  factory XCBAddress.fromHex(
    String hex,
  ) {
    if (!_basicAddress.hasMatch(hex)) {
      throw ArgumentError.value(hex, 'address',
          'Must be a hex string with a length of $xcbAddrLength');
    }

    if (hex.toUpperCase() == hex || hex.toLowerCase() == hex) {
      return XCBAddress(hexToBytes(hex));
    }

    return XCBAddress(hexToBytes(hex));
  }

  /// A hexadecimal representation of this address, padded to a length of 40
  /// characters or 20 bytes, and prefixed with "0x".
  String get hex =>
      bytesToHex(addressBytes, include0x: true, forcePadLength: xcbAddrLength);

  /// A hexadecimal representation of this address, padded to a length of 40
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
