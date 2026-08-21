import 'dart:convert';

import 'package:core_web3dart/ipfs.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('IpfsGateway', () {
    test('resolves ipfs URI through ipf.sk by default', () {
      final gateway = IpfsGateway();
      expect(
        gateway.resolve('ipfs://bafyTest/lab.json').toString(),
        'https://ipf.sk/bafyTest/lab.json',
      );
    });

    test('supports a custom endpoint', () {
      final gateway = IpfsGateway(
        template: 'https://gateway.example/ipfs/{cid}',
      );
      expect(
        gateway.resolve('QmExample/file.json').toString(),
        'https://gateway.example/ipfs/QmExample/file.json',
      );
    });

    test('does not rewrite direct HTTP references', () {
      final gateway = IpfsGateway();
      expect(
        gateway.resolve('https://example.com/lab.json').toString(),
        'https://example.com/lab.json',
      );
    });

    test('loads bounded JSON responses', () async {
      final gateway = IpfsGateway(
        client: MockClient((request) async {
          expect(request.url, Uri.parse('https://ipf.sk/bafy/lab.json'));
          return Response(jsonEncode({'pH': 6.5}), 200);
        }),
      );
      expect(await gateway.readJson('ipfs://bafy/lab.json'), {'pH': 6.5});
    });

    test('rejects invalid templates and oversized responses', () async {
      expect(
        () => IpfsGateway(template: 'https://example.com/ipfs'),
        throwsArgumentError,
      );
      final gateway = IpfsGateway(
        maxResponseBytes: 2,
        client: MockClient((_) async => Response('{}\n', 200)),
      );
      await expectLater(
        gateway.readJson('bafy'),
        throwsA(isA<ClientException>()),
      );
    });
  });
}
