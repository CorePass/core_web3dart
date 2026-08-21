import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'package:core_web3dart/src/eip712/core/eip712.dart';

import '../constants/consts.dart';

void main() {
  final eip712 = EIP712();
  test("getMessageToSign Works correctly", () {
    expect(
      eip712.getMessageForSign(typedData: TEST_TYPED_DATA),
      "0x3402b6e10b1933e0060f3d36b08e594b29958d34cf869b56138303a448034b55",
    );
    expect(
      eip712.getMessageForSign(typedData: TEST_TYPED_DATA_2),
      "0xd902c81791cdda6e20059a0f5e75f67bfee297427bfc1e6468c731ad24ab3ac4",
    );
    expect(
      eip712.getMessageForSign(typedData: TEST_TYPED_DATA_3),
      "0x2676a1ec8b4e8bcf83336c4601872c867d23a7ba76b133da44da3f1a3a5dc035",
    );
    expect(
      eip712.getMessageForSign(typedData: TEST_TYPED_DATA_4),
      "0xf9e3df6d6f790371ef02cc68b2e4ab0995b633611b2fc3c8a636d4fd7527080d",
    );
  });
  test('sanitizer works correctly', () {
    expect(eip712.sanitizeData(TEST_TYPED_DATA), SANITIZED_TYPED_DATA);
    expect(
      eip712.sanitizeData(TEST_TYPED_DATAWithoutEipDomain),
      SANITIZED_TYPED_DATA_WITHOUT_EIP,
    );
    expect(eip712.sanitizeData(TEST_TYPED_DATA_2), SANITIZED_TYPED_DATA2);
    expect(
      eip712.sanitizeData(TEST_TYPED_DATA_2_WITHOUT_EIP),
      SANITIZED_TYPED_DATA2_WITHOUT_EIP,
    );
  });
  test("encodeType is working correctly", () {
    expect(
      eip712.encodeType("EIP712Domain", TEST_TYPES),
      "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)",
    );
    expect(
      eip712.encodeType("Bounty", TEST_TYPES),
      'Bounty(address target,bytes data,uint256 reward,uint256 nonce,uint256 deadline)',
    );
    expect(
      eip712.encodeType("Mail", TEST_TYPES_2),
      'Mail(Person from,Person[] to,string contents)Person(string name,address[] wallets)',
    );
  });
  test("hashType works correctly", () {
    final _hasRes1 = HEX.encode(eip712.hashType("EIP712Domain", TEST_TYPES));
    expect(
      _hasRes1,
      "ddd4c7674758e5d4c23d41c55c47f7e721630ab5231f61f3fc4146a99a4880fe",
    );
    final _hasRes2 = HEX.encode(eip712.hashType("Bounty", TEST_TYPES));
    expect(
      _hasRes2,
      "3eb5d7e624f143ef15cf199637c60dfa3596cd0a2d5493d45256019eebf3223a",
    );
    final _hasRes3 = HEX.encode(eip712.hashType("Mail", TEST_TYPES_2));
    expect(
      _hasRes3,
      "fb4baac61f69c6f67857383b588ba10ecf8f4ba21a79337623d882825f9e4a79",
    );
  });
  test("encodeData is working corectly", () {
    expect(
      eip712.encodeData("Mail", {
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
      }, TEST_TYPES_2),
      "fb4baac61f69c6f67857383b588ba10ecf8f4ba21a79337623d882825f9e4a796366c51b8923fca0a4bd591b0c9202a9e6cb62dcba9138ceef728778d10270b451666d5a2b98986905494eecb6358efe4ca3ad827bababd689f125c8ee549379b58543c145f315ad2c9210b45c29c13e6c9fc5396a140d3b07f766925fda360e",
    );
    expect(
      eip712.encodeData("EIP712Domain", {
        "name": 'BountiableTokenTester',
        "version": '1',
        "chainId": 31337,
        "verifyingContract": '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9',
      }, TEST_TYPES),
      "ddd4c7674758e5d4c23d41c55c47f7e721630ab5231f61f3fc4146a99a4880fea3f78a5c1a86adfee0a48f53d25cdc1198cda9d54e3eae7031faf8a3c639199667b176705b46206614219f47a05aee7ae6a3edbe850bbbe214c536b989aea4d20000000000000000000000000000000000000000000000000000000000007a690000000000000000000000007a9ec1d04904907de0ed7b6839ccdd59c3716ac9",
    );
    expect(
      eip712.encodeData("EIP712Domain", {
        "chainId": 1,
        "name": "Core Mail",
        "verifyingContract": "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC",
        "version": "1",
      }, TEST_TYPES_2),
      "ddd4c7674758e5d4c23d41c55c47f7e721630ab5231f61f3fc4146a99a4880fe1824f9815a3fa3af4b631c8e445249a8b59390837501c5a9aa72a5e28535d4e767b176705b46206614219f47a05aee7ae6a3edbe850bbbe214c536b989aea4d20000000000000000000000000000000000000000000000000000000000000001000000000000000000000000cccccccccccccccccccccccccccccccccccccccc",
    );
    expect(
      eip712.encodeData("Bounty", {
        "target": '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9',
        "data": '0x713d3e3e',
        "reward": 50,
        "nonce": 0,
        "deadline": 1624373141,
      }, TEST_TYPES),
      "3eb5d7e624f143ef15cf199637c60dfa3596cd0a2d5493d45256019eebf3223a0000000000000000000000007a9ec1d04904907de0ed7b6839ccdd59c3716ac97b8b9fc3be3033749eb3f83157dd20dbfefaef6a8ea0538b24434374439a8f23000000000000000000000000000000000000000000000000000000000000003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060d1f795",
    );
    expect(
      eip712.encodeData("Person", {
        "name": "Cow",
        "wallets": [
          "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
          "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF",
        ],
      }, TEST_TYPES_2),
      "1014221b846c7f0e0f67d9894ff14430d19c6bab520a7b20fd21861971f94d39cbfe11cbdd252b33144a30cfb7e1510879f2109187ee218e341f3ac903347d3b667abff5202477d232933f89b33446e6a4c2958504eb633b197d06a67d3fc1b6",
    );
    expect(
      eip712.encodeData("Person", {
        "name": "Bob",
        "wallets": [
          "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
          "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
          "0xB0B0b0b0b0b0B000000000000000000000000000",
        ],
      }, TEST_TYPES_2),
      "1014221b846c7f0e0f67d9894ff14430d19c6bab520a7b20fd21861971f94d39b50b22901ba019b7f48327a891d21a9af254749359c76f1f4755bd28c49c33ab00a3bd9a6ea270bf07e204406811a9927426d4359240fb41459d538b16a565fd",
    );
  });
  test("encodeField works correctly", () {
    expect(
      eip712.encodeField("from", "Person", {
        "name": "Cow",
        "wallets": [
          "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
          "0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF",
        ],
      }, TEST_TYPES_2),
      [
        "bytes32",
        Uint8List.fromList(
          HEX.decode(
            "6366c51b8923fca0a4bd591b0c9202a9e6cb62dcba9138ceef728778d10270b4",
          ),
        ),
      ],
    );
    expect(
      eip712.encodeField("to", "Person[]", [
        {
          "name": "Bob",
          "wallets": [
            "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB",
            "0xB0BdaBea57B0BDABeA57b0bdABEA57b0BDabEa57",
            "0xB0B0b0b0b0b0B000000000000000000000000000",
          ],
        },
      ], TEST_TYPES_2),
      [
        "bytes32",
        Uint8List.fromList(
          HEX.decode(
            "51666d5a2b98986905494eecb6358efe4ca3ad827bababd689f125c8ee549379",
          ),
        ),
      ],
    );
    expect(
      eip712.encodeField("contents", "string", "Hello, Bob!", TEST_TYPES_2),
      [
        "bytes32",
        Uint8List.fromList(
          HEX.decode(
            "b58543c145f315ad2c9210b45c29c13e6c9fc5396a140d3b07f766925fda360e",
          ),
        ),
      ],
    );
    // for int
    expect(eip712.encodeField('chainId', 'uint256', 31337, TEST_TYPES), [
      'uint256',
      31337,
    ]);
    // for address
    expect(
      eip712.encodeField(
        'verifyingContract',
        'address',
        '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9',
        TEST_TYPES,
      ),
      ['address', '0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9'],
    );
    // for string
    expect(
      eip712.encodeField('name', 'string', 'BountiableTokenTester', TEST_TYPES),
      [
        'bytes32',
        Uint8List.fromList([
          163,
          247,
          138,
          92,
          26,
          134,
          173,
          254,
          224,
          164,
          143,
          83,
          210,
          92,
          220,
          17,
          152,
          205,
          169,
          213,
          78,
          62,
          174,
          112,
          49,
          250,
          248,
          163,
          198,
          57,
          25,
          150,
        ]),
      ],
    );
    // for bytes
    expect(eip712.encodeField('data', 'bytes', '0x713d3e3e', TEST_TYPES), [
      'bytes32',
      Uint8List.fromList([
        123,
        139,
        159,
        195,
        190,
        48,
        51,
        116,
        158,
        179,
        248,
        49,
        87,
        221,
        32,
        219,
        254,
        250,
        239,
        106,
        142,
        160,
        83,
        139,
        36,
        67,
        67,
        116,
        67,
        154,
        143,
        35,
      ]),
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
