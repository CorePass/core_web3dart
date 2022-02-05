import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:core_web3dart/crypto.dart';
import 'package:core_web3dart/src/eip712/abi/abi_helper.dart';
import 'package:core_web3dart/src/eip712/utils/contants.dart';
import 'package:core_web3dart/src/eip712/utils/crypto.dart';

class EIP712 {
  final _crypto = Crypto();
  final _abiHelper = ABIHelper();

  /// Get a signable message from the typed data, accepts `typedData` and `hash` and hash is used when you want the hashed result of the output (keccak hash which ethereum uses)

  String getMessageForSign(
      {required Map<String, dynamic> typedData,
      bool hash = true,
      bool include0x = true}) {
    Uint8List _primaryTypeHash = Uint8List.fromList([]);
    // MARK: step1. sanitize data
    final sanitizedData = sanitizeData(typedData);
    // MARK: step2. get struct hash of typedData with type EIP712Domain
    final _eip712DomainHash = hashStruct(
        'EIP712Domain', sanitizedData['domain'], sanitizedData['types']);
    // MARK: step3. get struct hash of typedData with type primaryType

    if (sanitizedData['primaryType'] != 'EIP712Domain') {
      _primaryTypeHash = hashStruct(
        sanitizedData["primaryType"],
        sanitizedData['message'],
        sanitizedData['types'],
      );
    }
    // MARK: step4. concat `EIP_191_PREFIX` and first and second step to get the message
    final message = Uint8List.fromList(
        [...EIP_191_PREFIX, ..._eip712DomainHash, ..._primaryTypeHash]);
    if (hash) {
      final _res = HEX.encode(_crypto.hash(message));
      return include0x ? "0x$_res" : _res;
    }
    final _res = HEX.encode(message);
    return include0x ? "0x$_res" : _res;
  }

  // ignore: slash_for_doc_comments
  /**
   * Removes properties from a message Map<String,dynamic> that are not defined per EIP-712
   *
   * @param {Map<String, dynamic>} data - typed message Map<String, dynamic>
   * @returns {Map<String, dynamic>} - typed message Map<String, dynamic> with only allowed fields
   */
  Map<String, dynamic> sanitizeData(Map<String, dynamic> typedData) {
    assert(typedData['types'] != null,
        "the types property of the input typedData needs to be provided");
    assert(typedData['primaryType'] != null,
        "the primaryType property of the input typedData needs to be provided");
    assert(typedData['domain'] != null,
        "the domain property of the input typedData needs to be provided");
    assert(typedData['message'] != null,
        "the message property of the input typedData needs to be provided");
    Map<String, dynamic> _sanitizedData = {};
    for (var key in (TYPED_MESSAGE_SCHEMA["properties"] as Map<String, dynamic>)
        .keys
        .toList()) {
      if (typedData[key] != null) {
        _sanitizedData[key] = typedData[key];
      }
    }
    if (_sanitizedData["types"]["EIP712Domain"] == null) {
      _sanitizedData["types"]["EIP712Domain"] =
          List<Map<String, String>>.from([]);
    }
    return _sanitizedData;
  }

  // ignore: slash_for_doc_comments
  /**
   * Hashes a Map<String, dynamic>
   *
   * @param {string} primaryType - Root type
   * @param {Map<String,dynamic>} data - Map<String,dynamic> to hash
   * @param {Map<String,dynamic>} types - Type definitions
   * @returns {Uint8List} - Hash of a Map<String, dynamic>
   */

  Uint8List hashStruct(
    String primaryType,
    Map<String, dynamic> data,
    Map<String, dynamic> types,
  ) {
    final encoded = encodeData(primaryType, data, types);
    final hashed = _crypto.hash(Uint8List.fromList(HEX.decode(encoded)));
    return hashed;
  }

  // ignore: slash_for_doc_comments
  /**
   * Encodes a Map<String, dynamic> by encoding and concatenating each of its members
   *
   * @param {string} primaryType - Root type
   * @param {Map<String,dynamic>} data - Map<String,dynamic> to encode
   * @param {Map<String,dynamic>} types - Type definitions
   * @returns {Uint8List} - Encoded representation of an Map<String,dynamic>
   */
  String encodeData(String primaryType, Map<String, dynamic> data,
      Map<String, dynamic> types) {
    List<String> encodedTypes = ['bytes32'];
    List<dynamic> encodedValues = List<dynamic>.from([]);
    encodedValues.add(hashType(primaryType, types));
    for (var field in types[primaryType]) {
      final _enc =
          encodeField(field["name"], field["type"], data[field["name"]], types);
      encodedTypes.add(_enc[0]);
      encodedValues.add(_enc[1]);
    }

    final _res = _abiHelper.rawEncode(encodedTypes, encodedValues);

    return HEX.encode(_res);
  }

  encodeField(
      String name, String type, dynamic value, Map<String, dynamic> types) {
    if (types[type] != null) {
      dynamic _a =
          '0x0000000000000000000000000000000000000000000000000000000000000000';
      if (value != null) {
        var _cc = encodeData(type, value, types);
        var _bb = Uint8List.fromList(HEX.decode(_cc));
        _a = _crypto.hash(Uint8List.fromList(_bb));
      }

      return [
        'bytes32',
        // eslint-disable-line no-eq-null
        _a
      ];
    }

    if (value == null) {
      throw Exception("missing value for field $name of type $type");
    }

    if (type == 'bytes') {
      if (value is String) {
        return [
          'bytes32',
          _crypto.hash((Uint8List.fromList(HEX.decode(strip0x(value)))))
        ];
      } else {
        throw Exception("not recognized type for $name with type $type");
      }
    }

    if (type == 'string') {
      // convert string to byteArray - prevents _crypto from interpreting strings like '0xabcd' as hex
      final _val = Uint8List.fromList(utf8.encode(value));
      return ['bytes32', _crypto.hash(_val)];
    }

    if (type.lastIndexOf(']') == type.length - 1) {
      final parsedType = type.substring(0, type.lastIndexOf('['));
      final typeValuePairs =
          value.map((item) => encodeField(name, parsedType, item, types));
      return [
        'bytes32',
        _crypto.hash(
          (_abiHelper.rawEncode(
              // MARK: 0 to get the types and 1 to get the values
              typeValuePairs.map((t) => t[0]).toList(),
              typeValuePairs.map((t) => t[1]).toList())),
        )
      ];
    }

    return [type, value];
  }

  Uint8List hashType(String primaryType, Map<String, dynamic> types) {
    return _crypto
        .hash(Uint8List.fromList(utf8.encode(encodeType(primaryType, types))));
  }

  /**
   * Encodes the type of an Map<String,dynamic> by encoding a comma delimited list of its members
   *
   * @param {string} primaryType - Root type to encode
   * @param {Map<String,dynamic>} types - Type definitions
   * @returns {string} - Encoded representation of the type of an Map<String,dynamic>
   */
  String encodeType(String primaryType, Map<String, dynamic> types) {
    String result = '';
    List<String> deps =
        findTypeDependencies(primaryType, types, List<String>.from([]))
            .where((dep) => dep != primaryType)
            .toList();
    deps.sort();
    deps = [primaryType, ...deps];

    for (var type in deps) {
      final children = types[type];
      if (children == null) {
        throw Exception("No type definition specified: $type");
      }
      final _additions = (types[type] as List<Map<String, dynamic>>)
          .map((e) => "${e['type']} ${e['name']}")
          .join(",");
      result += "$type($_additions)";
    }
    return result;
  }

  /**
   * Finds all types within a type definition Map<String,dynamic>
   *
   * @param {string} primaryType - Root type
   * @param {Map<String,dynamic>} types - Type definitions
   * @param {Array} results - current set of accumulated types
   * @returns {Array} - Set of all types found in the type definition
   */
  List<String> findTypeDependencies(
      String primaryType, Map<String, dynamic> types, List<String> results) {
    String _prType = primaryType;
    final _regex = RegExp('/^\w*/u');
    final _matches = _regex.allMatches(primaryType).toList();
    if (_matches.isNotEmpty) {
      for (var match in _matches) {
        for (var name in match.groupNames) {
          if (name == primaryType) {
            _prType = name;
            break;
          }
        }
      }
    }
    if (results.contains(_prType) || types[_prType] == null) {
      return results;
    }
    results.add(_prType);
    // TODO: add this part
    for (var field in types[_prType]) {
      for (var dep in findTypeDependencies(field['type'], types, results)) {
        if (!results.contains(dep)) {
          results.add(dep);
        }
      }
    }
    return results;
  }

  // String recoverTypedSignature(
  //     Map<String, dynamic> data, MsgSignature signature) {
  //   String messageHash = getMessageForSign(typedData: data);
  //   Uint8List publicKey = ecRecover(hexToBytes(messageHash), signature);
  //   Uint8List sender = publicKeyToAddress(publicKey);
  //   return bytesToHex(sender);
  // }
}
