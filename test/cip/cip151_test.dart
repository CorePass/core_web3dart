import 'package:core_web3dart/cip.dart';
import 'package:test/test.dart';

void main() {
  group('Cip151Lifecycle', () {
    test('parses standard Unix timestamps as UTC', () {
      final lifecycle = Cip151Lifecycle.fromMetadata(const {
        'tokenExpiration': '1719878400',
        'tradingStop': '1719705600',
      });
      expect(lifecycle.tokenExpiration, DateTime.utc(2024, DateTime.july, 2));
      expect(lifecycle.tradingStop, DateTime.utc(2024, DateTime.june, 30));
      expect(lifecycle.isExpiredAt(DateTime.utc(2024, 7, 2)), isTrue);
      expect(lifecycle.isTradingStoppedAt(DateTime.utc(2024, 6, 29)), isFalse);
    });

    test('allows absent optional lifecycle values', () {
      final lifecycle = Cip151Lifecycle.fromMetadata(const {});
      expect(lifecycle.tokenExpiration, isNull);
      expect(lifecycle.tradingStop, isNull);
    });

    test('rejects malformed timestamps', () {
      expect(
        () => Cip151Lifecycle.fromMetadata(const {'tokenExpiration': '-1'}),
        throwsFormatException,
      );
    });
  });
}
