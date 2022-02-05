import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'package:core_web3dart/src/crypto/formatting.dart';
import 'package:core_web3dart/src/eip712/abi/abi_helper.dart';

main() {
  final abiHepler = ABIHelper();
  test("rawEncode works correctly", () {
    expect(
        HEX.encode(abiHepler.rawEncode([
          "bytes32",
          "bytes32",
          "bytes32",
          "uint256",
          "address",
        ], [
          Uint8List.fromList([
            139,
            115,
            195,
            198,
            155,
            184,
            254,
            61,
            81,
            46,
            204,
            76,
            247,
            89,
            204,
            121,
            35,
            159,
            123,
            23,
            155,
            15,
            250,
            202,
            169,
            167,
            93,
            82,
            43,
            57,
            64,
            15
          ]),
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
            30,
          ]),
          Uint8List.fromList([
            200,
            158,
            253,
            170,
            84,
            192,
            242,
            12,
            122,
            223,
            97,
            40,
            130,
            223,
            9,
            80,
            245,
            169,
            81,
            99,
            126,
            3,
            7,
            205,
            203,
            76,
            103,
            47,
            41,
            139,
            139,
            198,
          ]),
          31337,
          "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
        ])),
        "8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f295a1eee18326a1bf3a3453f94aff9bd734f9f997608e90e73dc075210e7b11ec89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc60000000000000000000000000000000000000000000000000000000000007a690000000000000000000000007a9ec1d04904907de0ed7b6839ccdd59c3716ac9");
    expect(
        HEX.encode(abiHepler.rawEncode([
          "bytes32",
          "address",
          "bytes32",
          "uint256",
          "uint256",
          "uint256",
        ], [
          Uint8List.fromList([
            196,
            95,
            246,
            143,
            17,
            5,
            89,
            161,
            232,
            38,
            131,
            55,
            23,
            10,
            199,
            192,
            158,
            255,
            7,
            159,
            90,
            192,
            195,
            33,
            229,
            117,
            160,
            128,
            205,
            49,
            24,
            189,
          ]),
          "0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9",
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
            56,
          ]),
          50,
          0,
          1624373141,
        ])),
        "c45ff68f110559a1e8268337170ac7c09eff079f5ac0c321e575a080cd3118bd0000000000000000000000007a9ec1d04904907de0ed7b6839ccdd59c3716ac95f613c6be2378d6df7858b314c3a2c48dbace67d10153b54b2ba5a9d9b3f5038000000000000000000000000000000000000000000000000000000000000003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060d1f795");
  });
  test("parseNumber works correctly", () {
    final _resAddr = HEX.encode(intToBytes(
        abiHepler.parseNumber("0x7A9Ec1d04904907De0ED7b6839CcdD59c3716AC9")));

    final _resNum = HEX.encode(intToBytes(abiHepler.parseNumber(31337)));

    expect(_resAddr, "7a9ec1d04904907de0ed7b6839ccdd59c3716ac9");
    expect(_resNum, "7a69");
  });
  test("getHeadLength and isArray and parseTypeArray are working correctly",
      () {
    expect(
        abiHepler.getHeadLength([
          "bytes32",
          "bytes32",
          "bytes32",
          "uint256",
          "address",
        ]),
        160);
  });
  test("elementaryName works properly", () {
    expect(abiHepler.elementaryName("bytes32"), "bytes32");
    expect(abiHepler.elementaryName("uint256"), "uint256");
    expect(abiHepler.elementaryName("address"), "address");
  });
  test("parseTypeN works correctly", () {
    expect(abiHepler.parseTypeN("bytes32"), 32);
    expect(abiHepler.parseTypeN("uint256"), 256);
    expect(abiHepler.parseTypeN("uint160"), 160);
  });
  test("padRightZeros works correctly", () {
    final _res = abiHepler.padRightZeros(Uint8List.fromList([1, 2, 3]), 32);
    final _res2 = abiHepler.padRightZeros(
        Uint8List.fromList(
          [
            ...Uint8List.fromList([1, 2, 3]),
            ...List<int>.generate(29, (index) => 0)
          ],
        ),
        32);
    expect(
      _res,
      Uint8List.fromList(
        [
          ...Uint8List.fromList([1, 2, 3]),
          ...List<int>.generate(29, (index) => 0)
        ],
      ),
    );
    expect(
      _res2,
      Uint8List.fromList(
        [
          ...Uint8List.fromList([1, 2, 3]),
          ...List<int>.generate(29, (index) => 0)
        ],
      ),
    );
  });
  test("toArrayLike works correctly", () {
    final _big1 = abiHepler.parseNumber(31337);
    final _res1 = abiHepler.toArrayLike(_big1, 32);
    final _big2 = abiHepler.parseNumber(3133636346734647);
    final _res2 = abiHepler.toArrayLike(_big2, 32);
    expect(HEX.encode(_res1),
        "0000000000000000000000000000000000000000000000000000000000007a69");
    expect(HEX.encode(_res2),
        "000000000000000000000000000000000000000000000000000b2206914d6837");
  });
}
