import 'cip150.dart';

/// CIP-151 metadata key for token expiry.
const cip151TokenExpirationKey = 'tokenExpiration';

/// CIP-151 metadata key for the recommended trading stop.
const cip151TradingStopKey = 'tradingStop';

/// Typed lifecycle metadata defined by CIP-151.
class Cip151Lifecycle {
  const Cip151Lifecycle({this.tokenExpiration, this.tradingStop});

  final DateTime? tokenExpiration;
  final DateTime? tradingStop;

  bool isExpiredAt(DateTime time) =>
      tokenExpiration != null && !time.toUtc().isBefore(tokenExpiration!);

  bool isTradingStoppedAt(DateTime time) =>
      tradingStop != null && !time.toUtc().isBefore(tradingStop!);

  factory Cip151Lifecycle.fromMetadata(Map<String, String> metadata) {
    return Cip151Lifecycle(
      tokenExpiration: _parseTimestamp(
        metadata[cip151TokenExpirationKey],
        cip151TokenExpirationKey,
      ),
      tradingStop: _parseTimestamp(
        metadata[cip151TradingStopKey],
        cip151TradingStopKey,
      ),
    );
  }

  static DateTime? _parseTimestamp(String? value, String key) {
    if (value == null || value.isEmpty) return null;
    final seconds = int.tryParse(value);
    if (seconds == null || seconds < 0) {
      throw FormatException('$key must be a non-negative Unix timestamp.');
    }
    return DateTime.fromMillisecondsSinceEpoch(
      seconds * Duration.millisecondsPerSecond,
      isUtc: true,
    );
  }
}

extension Cip151MetadataContractExtension on Cip150MetadataContract {
  /// Reads CIP-151 lifecycle values that exist on this contract.
  Future<Cip151Lifecycle> readLifecycle() async {
    final metadata = <String, String>{};
    for (final key in const [cip151TokenExpirationKey, cip151TradingStopKey]) {
      if (await hasKey(key)) metadata[key] = await getValue(key);
    }
    return Cip151Lifecycle.fromMetadata(metadata);
  }
}
