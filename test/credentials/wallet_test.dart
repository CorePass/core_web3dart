import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:core_web3dart/src/credentials/credentials.dart';
import 'package:test/test.dart';
import 'package:core_web3dart/src/credentials/wallet.dart';
import 'package:core_web3dart/src/crypto/formatting.dart';

import 'example_keystores.dart' as data;

void main() {
  final wallets = json.decode(data.content) as Map;

  wallets.forEach((testName, content) {
    test('unlocks wallet $testName', () {
      final password = content['password'] as String;
      final privateKey = content['priv'] as String;
      final walletData = content['json'] as Map;

      final wallet = Wallet.fromJson(json.encode(walletData), password);
      expect(bytesToHex(wallet.privateKey.privateKey), privateKey);

      final encodedWallet = json.decode(wallet.toJson()) as Map;

      expect(
        encodedWallet['crypto']['ciphertext'],
        walletData['crypto']['ciphertext'],
      );
    }, tags: 'expensive');
  });

  test('rejects unsafe scrypt parameters before allocation', () {
    expect(
      () => Wallet.createNew(
        XCBPrivateKey(Uint8List(57)),
        'password',
        Random(1),
        scryptN: 1073741824,
      ),
      throwsFormatException,
    );
  });

  test('rejects excessive scrypt memory requirements', () {
    expect(
      () => Wallet.createNew(
        XCBPrivateKey(Uint8List(57)),
        'password',
        Random(1),
        scryptN: 1048576,
      ),
      throwsFormatException,
    );
  });

  test('rejects unbounded PBKDF2 parameters from JSON', () {
    final walletData = Map<String, dynamic>.from(
      (wallets.values.first as Map)['json'] as Map,
    );
    final crypto = Map<String, dynamic>.from(walletData['crypto'] as Map);
    crypto['kdf'] = 'pbkdf2';
    crypto['kdfparams'] = <String, dynamic>{
      'c': 10000001,
      'dklen': 32,
      'prf': 'hmac-sha256',
      'salt': List<String>.filled(32, '00').join(),
    };
    walletData['crypto'] = crypto;

    expect(
      () => Wallet.fromJson(json.encode(walletData), 'password'),
      throwsFormatException,
    );
  });
}
