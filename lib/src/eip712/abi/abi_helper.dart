import 'dart:convert';
import 'dart:typed_data';

import 'package:web3dart/src/crypto/formatting.dart';

class ABIHelper {
  Uint8List rawEncode(types, values) {
    List<List<int>> output = [];
    List<List<int>> data = [];
    List<int> _res = List<int>.from([]);

    var headLength = getHeadLength(types);

    for (var i = 0; i < types.length; i++) {
      var type = elementaryName(types[i]);
      var value = values[i];
      var cur = encodeSingle(type, value);

      // Use the head/tail method for storing dynamic data
      if (isDynamic(type)) {
        output.add(encodeSingle('uint256', headLength));
        data.add(cur);
        headLength += (cur.length as int);
      } else {
        output.add(cur);
      }
    }
    for (var _li in output) {
      for (var _it in _li) {
        _res.add(_it);
      }
    }
    for (var _li in data) {
      for (var _it in _li) {
        _res.add(_it);
      }
    }
    ;
    return Uint8List.fromList(_res);
  }

// Encodes a single item (can be dynamic array)
// @returns: Buffer
  encodeSingle(String type, arg) {
    if (type == 'address') {
      return encodeSingle('uint160', parseNumber(arg));
    } else if (type == 'bool') {
      return encodeSingle('uint8', arg ? 1 : 0);
    } else if (type == 'string') {
      return encodeSingle('bytes', Uint8List.fromList(utf8.encode(arg)));
    } else if (isArray(type)) {
      // this part handles fixed-length ([2]) and variable length ([]) arrays
      // NOTE: we catch here all calls to arrays, that simplifies the rest
      if (arg is! List) {
        throw Exception('Not an array?');
      }
      var size = parseTypeArray(type);
      if (size != 'dynamic' && size != 0 && arg.length > size) {
        throw Exception('Elements exceed array size: ' + size);
      }
      var ret = List<int>.from([]);
      type = type.substring(0, type.lastIndexOf('['));

      for (var i in arg) {
        ret.add(encodeSingle(type, arg[i]));
      }
      if (size == 'dynamic') {
        var length = encodeSingle('uint256', arg.length);
        ret.insert(0, length);
      }
      return Uint8List.fromList(ret);
    } else if (type == 'bytes') {
      arg = Uint8List.fromList(arg);

      var ret = Uint8List.fromList(
          [...encodeSingle('uint256', arg.length), ...(arg as Uint8List)]);

      if ((arg.length % 32) != 0) {
        ret = Uint8List.fromList([
          ...ret,
          ...Uint8List.fromList(
              List<int>.generate(32 - (arg.length % 32), (index) => 0))
        ]);
      }

      return ret;
    } else if (type.startsWith('bytes')) {
      var size = parseTypeN(type);
      if (size < 1 || size > 32) {
        throw Exception('Invalid bytes<N> width: ' + size.toString());
      }

      return padRightZeros(arg, 32);
    } else if (type.startsWith('uint')) {
      int size = parseTypeN(type);
      if ((size % 8 != 0) || (size < 8) || (size > 256)) {
        throw Exception('Invalid uint<N> width: ' + size.toString());
      }
      BigInt _bigNum = parseNumber(arg);
      if (_bigNum.bitLength > size) {
        throw Exception('Supplied uint exceeds width: ' +
            size.toString() +
            ' vs ' +
            _bigNum.bitLength.toString());
      }
      if (_bigNum.isNegative) {
        throw Exception('Supplied uint is negative');
      }
      return toArrayLike(_bigNum, 32);
    } else if (type.startsWith('int')) {
      int size = parseTypeN(type);
      if ((size % 8 != 0) || (size < 8) || (size > 256)) {
        throw Exception('Invalid int<N> width: ' + size.toString());
      }
      BigInt _bigNum = parseNumber(arg);
      if (_bigNum.bitLength > size) {
        throw new Exception('Supplied int exceeds width: ' +
            size.toString() +
            ' vs ' +
            _bigNum.bitLength.toString());
      }

      return toArrayLike(_bigNum, 32);
    }

    throw Exception('Unsupported or invalid type: ' + type);
  }

  BigInt parseNumber(arg) {
    if (arg is String) {
      if (hexHasPrefix(arg)) {
        return BigInt.parse(strip0x(arg), radix: 16);
      } else {
        return BigInt.parse(arg, radix: 10);
      }
    } else if (arg is num) {
      return BigInt.from(arg);
    } else if (arg is BigInt) {
      // assume this is a BN for the moment, replace with BN.isBN soon
      return arg;
    } else {
      throw new Exception('Argument is not a number');
    }
  }

  int getHeadLength(types) {
    var headLength = 0;

    types.forEach((type) {
      if (isArray(type)) {
        var size = parseTypeArray(type);

        if (size != 'dynamic') {
          headLength += (32 * (size as int));
        } else {
          headLength += 32;
        }
      } else {
        headLength += 32;
      }
    });
    return headLength;
  }

  isArray(type) {
    return type.lastIndexOf(']') == type.length - 1;
  }

  // Parse N in type[<N>] where "type" can itself be an array type.
  parseTypeArray(type) {
    final _reg = RegExp('/(.*)\[(.*?)\]');
    var tmp = _reg.allMatches(type).toList();
    if (tmp.isNotEmpty) {
      final _tar = tmp.elementAt(2);
      return (type as String).substring(_tar.start, _tar.end) == ''
          ? 'dynamic'
          : int.parse((type).substring(_tar.start, _tar.end), radix: 10);
    }
    return null;
  }

  // Convert from short to canonical names
  // FIXME: optimise or make this nicer?
  elementaryName(String name) {
    if (name.startsWith('int[')) {
      return 'int256' + name.substring(3);
    } else if (name == 'int') {
      return 'int256';
    } else if (name.startsWith('uint[')) {
      return 'uint256' + name.substring(4);
    } else if (name == 'uint') {
      return 'uint256';
    } else if (name.startsWith('fixed[')) {
      return 'fixed128x128' + name.substring(5);
    } else if (name == 'fixed') {
      return 'fixed128x128';
    } else if (name.startsWith('ufixed[')) {
      return 'ufixed128x128' + name.substring(6);
    } else if (name == 'ufixed') {
      return 'ufixed128x128';
    }
    return name;
  }

  int parseTypeN(String type) {
    final _str = type.replaceAll(new RegExp(r'[^0-9]'), '');
    return int.parse(_str, radix: 10);
  }

  padRightZeros(Uint8List arg, int size) {
    if (arg.length < 32) {
      final _dif = 32 - arg.length;
      return Uint8List.fromList([...arg, ...Uint8List(_dif)]);
    }
    return arg;
  }

  Uint8List toArrayLike(BigInt bigNum, int size) {
    final _bytes = intToBytes(bigNum);
    if (_bytes.length < size) {
      final _dif = size - _bytes.length;
      return Uint8List.fromList([...Uint8List(_dif), ..._bytes]);
    }
    return _bytes;
  }

  // Is a type dynamic?
  isDynamic(String type) {
    // FIXME: handle all types? I don't think anything is missing now
    return (type == 'string') ||
        (type == 'bytes') ||
        (parseTypeArray(type) == 'dynamic');
  }
}
