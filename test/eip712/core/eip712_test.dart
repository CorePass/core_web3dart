import 'dart:convert';
import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/src/eip712/core/eip712.dart';
import 'package:web3dart/web3dart.dart';

import '../constants/consts.dart';

void main() {
  final eip712 = EIP712();
  test("getMessageToSign Works correctly", () {
    expect(
        eip712.getMessageForSign(
          typedData: TEST_TYPED_DATA,
        ),
        "0x16172e4ec2553f8a69a47f2f0d8fbd7bb036a0f65348c32dbd5f7f0fb7f040c0");
    expect(
        eip712.getMessageForSign(
          typedData: TEST_TYPED_DATA_2,
        ),
        "0xa85c2e2b118698e88db68a8105b794a8cc7cec074e89ef991cb4f5f533819cc2");
    expect(
        eip712.getMessageForSign(
          typedData: TEST_TYPED_DATA_3,
        ),
        "0xed0727841a7250e119946c02ca9e85f40c4ddd28f805954b3e495a4622b177af");
    expect(
        eip712.getMessageForSign(
          typedData: TEST_TYPED_DATA_4,
        ),
        "0x842dbd7696b8b4c7be71192bef971f5f909a51322ec0f056277fa384ba46b415");
  });
  test('sanitizer works correctly', () {
    expect(eip712.sanitizeData(TEST_TYPED_DATA), SANITIZED_TYPED_DATA);
    expect(eip712.sanitizeData(TEST_TYPED_DATAWithoutEipDomain),
        SANITIZED_TYPED_DATA_WITHOUT_EIP);
    expect(eip712.sanitizeData(TEST_TYPED_DATA_2), SANITIZED_TYPED_DATA2);
    expect(eip712.sanitizeData(TEST_TYPED_DATA_2_WITHOUT_EIP),
        SANITIZED_TYPED_DATA2_WITHOUT_EIP);
  });
  test("encodeType is working correctly", () {
    expect(eip712.encodeType("EIP712Domain", TEST_TYPES),
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    expect(eip712.encodeType("Bounty", TEST_TYPES),
        'Bounty(address target,bytes data,uint256 reward,uint256 nonce,uint256 deadline)');
    expect(eip712.encodeType("Mail", TEST_TYPES_2),
        'Mail(Person from,Person[] to,string contents)Person(string name,address[] wallets)');
  });
  test("hashType works correctly", () {
    final _hasRes1 = HEX.encode(eip712.hashType("EIP712Domain", TEST_TYPES));
    expect(_hasRes1,
        "8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f");
    final _hasRes2 = HEX.encode(eip712.hashType("Bounty", TEST_TYPES));
    expect(_hasRes2,
        "c45ff68f110559a1e8268337170ac7c09eff079f5ac0c321e575a080cd3118bd");
    final _hasRes3 = HEX.encode(eip712.hashType("Mail", TEST_TYPES_2));
    expect(_hasRes3,
        "4bd8a9a2b93427bb184aca81e24beb30ffa3c747e2a33d4225ec08bf12e2e753");
  });
  test("encodeData is working corectly", () {
    expect(
        eip712.encodeData(
            "Mail",
            {
              "contents": "Hello, Bob!",
              "from": {
                "name": "Cow",
                "wallets": [
                  "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                  "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF",
                ],
              },
              "to": [
                {
                  "name": "Bob",
                  "wallets": [
                    "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
                    "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
                    "0xB0B0b0b0b0b0B000000000000000000000000000",
                  ],
                },
              ],
            },
            TEST_TYPES_2),
        "4bd8a9a2b93427bb184aca81e24beb30ffa3c747e2a33d4225ec08bf12e2e7539b4846dd48b866f0ac54d61b9b21a9e746f921cefa4ee94c4c0a1c49c774f67fca322beec85be24e374d18d582a6f2997f75c54e7993ab5bc07404ce176ca7cdb5aadf3154a261abdd9086fc627b61efca26ae5702701d05cd2305f7c52a2fc8");
    expect(
        eip712.encodeData(
            "EIP712Domain",
            {
              "name": 'BountiableTokenTester',
              "version": '1',
              "chainId": 31337,
              "verifyingContract": '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9'
            },
            TEST_TYPES),
        "8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f295a1eee18326a1bf3a3453f94aff9bd734f9f997608e90e73dc075210e7b11ec89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc60000000000000000000000000000000000000000000000000000000000007a690000000000000000000000007a9ec1d04904907de0ed7b6839ccdd59c3716ac9");
    expect(
        eip712.encodeData(
            "EIP712Domain",
            {
              "chainId": 1,
              "name": "Ether Mail",
              "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
              "version": "1",
            },
            TEST_TYPES_2),
        "8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400fc70ef06638535b4881fafcac8287e210e3769ff1a8e91f1b95d6246e61e4d3c6c89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc60000000000000000000000000000000000000000000000000000000000000001000000000000000000000000cccccccccccccccccccccccccccccccccccccccc");
    expect(
        eip712.encodeData(
            "Bounty",
            {
              "target": '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9',
              "data": '0x713d3e3e',
              "reward": 50,
              "nonce": 0,
              "deadline": 1624373141
            },
            TEST_TYPES),
        "c45ff68f110559a1e8268337170ac7c09eff079f5ac0c321e575a080cd3118bd0000000000000000000000007a9ec1d04904907de0ed7b6839ccdd59c3716ac95f613c6be2378d6df7858b314c3a2c48dbace67d10153b54b2ba5a9d9b3f5038000000000000000000000000000000000000000000000000000000000000003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060d1f795");
    expect(
        eip712.encodeData(
            "Person",
            {
              "name": "Cow",
              "wallets": [
                "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF",
              ],
            },
            TEST_TYPES_2),
        "fabfe1ed996349fc6027709802be19d047da1aa5d6894ff5f6486d92db2e68608c1d2bd5348394761719da11ec67eedae9502d137e8940fee8ecd6f641ee16488a8bfe642b9fc19c25ada5dadfd37487461dc81dd4b0778f262c163ed81b5e2a");
    expect(
        eip712.encodeData(
            "Person",
            {
              "name": "Bob",
              "wallets": [
                "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
                "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
                "0xB0B0b0b0b0b0B000000000000000000000000000",
              ],
            },
            TEST_TYPES_2),
        "fabfe1ed996349fc6027709802be19d047da1aa5d6894ff5f6486d92db2e686028cac318a86c8a0a6a9156c2dba2c8c2363677ba0514ef616592d81557e679b6d2734f4c86cc3bd9cabf04c3097589d3165d95e4648fc72d943ed161f651ec6d");
  });
  test("encodeField works correctly", () {
    expect(
        eip712.encodeField(
            "from",
            "Person",
            {
              "name": "Cow",
              "wallets": [
                "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
                "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF"
              ]
            },
            TEST_TYPES_2),
        [
          "bytes32",
          Uint8List.fromList(HEX.decode(
              "9b4846dd48b866f0ac54d61b9b21a9e746f921cefa4ee94c4c0a1c49c774f67f"))
        ]);
    expect(
        eip712.encodeField(
            "to",
            "Person[]",
            [
              {
                "name": "Bob",
                "wallets": [
                  "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
                  "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
                  "0xB0B0b0b0b0b0B000000000000000000000000000"
                ]
              }
            ],
            TEST_TYPES_2),
        [
          "bytes32",
          Uint8List.fromList(HEX.decode(
              "ca322beec85be24e374d18d582a6f2997f75c54e7993ab5bc07404ce176ca7cd"))
        ]);
    expect(
        eip712.encodeField("contents", "string", "Hello, Bob!", TEST_TYPES_2), [
      "bytes32",
      Uint8List.fromList(HEX.decode(
          "b5aadf3154a261abdd9086fc627b61efca26ae5702701d05cd2305f7c52a2fc8"))
    ]);
    // for int
    expect(eip712.encodeField('chainId', 'uint256', 31337, TEST_TYPES),
        ['uint256', 31337]);
    // for address
    expect(
        eip712.encodeField('verifyingContract', 'address',
            '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9', TEST_TYPES),
        ['address', '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9']);
    // for string
    expect(
        eip712.encodeField(
            'name', 'string', 'BountiableTokenTester', TEST_TYPES),
        [
          'bytes32',
          Uint8List.fromList([
            41,
            90,
            30,
            238,
            24,
            50,
            106,
            27,
            243,
            163,
            69,
            63,
            148,
            175,
            249,
            189,
            115,
            79,
            159,
            153,
            118,
            8,
            233,
            14,
            115,
            220,
            7,
            82,
            16,
            231,
            177,
            30
          ])
        ]);
    // for bytes
    expect(eip712.encodeField('data', 'bytes', '0x713d3e3e', TEST_TYPES), [
      'bytes32',
      Uint8List.fromList([
        95,
        97,
        60,
        107,
        226,
        55,
        141,
        109,
        247,
        133,
        139,
        49,
        76,
        58,
        44,
        72,
        219,
        172,
        230,
        125,
        16,
        21,
        59,
        84,
        178,
        186,
        90,
        157,
        155,
        63,
        80,
        56
      ])
    ]);
  });

  // String privateKey = "privateKey";
  // String address = "address";
  // test("recoverTypedSignature function works correctly", () {
  //   EIP712 eip712 = EIP712();

  //   Map<String, dynamic> person1 = {
  //     "address": "0x2b2b416b194cAde47C544a73D7Ff5390B5d0d2cf",
  //     "privateKey":
  //         "5b5f0db8819bd54e4e219fc24b21d905b44f3d1cce996f69b42119c4824c544b"
  //   };
  //   Map<String, dynamic> person2 = {
  //     "address": "0xe9A1F1dF30cF831Af22e8EAcAD4B34f4ea78eB9d",
  //     "privateKey":
  //         "c90d0eeadddb8d115d4658a89b17f9f1baf7d80fc06e2ff834437467f1d8693e"
  //   };
  //   Map<String, dynamic> person3 = {
  //     "address": "0x7De0Dd2484659911013d9B5A57CC0457e61Ae56f",
  //     "privateKey":
  //         "885e27faa554947f8da14d26f306697bf90f06bbf525627be04f16c3ae0696c3"
  //   };

  //   String messageHash1 = eip712.getMessageForSign(typedData: TEST_TYPED_DATA);

  //   String messageHash2 =
  //       eip712.getMessageForSign(typedData: TEST_TYPED_DATA_2);

  //   String messageHash3 =
  //       eip712.getMessageForSign(typedData: TEST_TYPED_DATA_3);

  //   String recoverdAddress1 = eip712.recoverTypedSignature(TEST_TYPED_DATA,
  //       sign(hexToBytes(messageHash1), hexToBytes(person1[privateKey])));

  //   String recoverdAddress2 = eip712.recoverTypedSignature(TEST_TYPED_DATA_2,
  //       sign(hexToBytes(messageHash2), hexToBytes(person2[privateKey])));

  //   String recoverdAddress3 = eip712.recoverTypedSignature(TEST_TYPED_DATA_3,
  //       sign(hexToBytes(messageHash3), hexToBytes(person3[privateKey])));

  //   expect("0x" + recoverdAddress1, person1[address].toLowerCase());

  //   expect("0x" + recoverdAddress2, person2[address].toLowerCase());

  //   expect("0x" + recoverdAddress3, person3[address].toLowerCase());
  // });
}
