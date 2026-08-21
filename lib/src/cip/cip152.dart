import '../ipfs/gateway.dart';
import 'cip150.dart';

/// CIP-152 metadata key containing the lab certificate reference.
const cip152LabKey = 'lab';

/// One measured property from a CIP-152 `lab.json` document.
class Cip152LabMeasurement {
  const Cip152LabMeasurement({required this.value, this.unit});

  final Object value;
  final String? unit;
}

/// A validated CIP-152 laboratory certificate.
class Cip152LabCertificate {
  Cip152LabCertificate(Map<String, Cip152LabMeasurement> measurements)
    : measurements = Map.unmodifiable(measurements);

  final Map<String, Cip152LabMeasurement> measurements;

  factory Cip152LabCertificate.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('CIP-152 lab.json must be a JSON object.');
    }
    final measurements = <String, Cip152LabMeasurement>{};
    for (final entry in json.entries) {
      final property = entry.value;
      if (property is! Map<String, dynamic> || !property.containsKey('value')) {
        throw FormatException(
          'CIP-152 property ${entry.key} must contain a value.',
        );
      }
      final value = property['value'];
      if (value is! num && value is! String) {
        throw FormatException(
          'CIP-152 property ${entry.key} has an invalid value.',
        );
      }
      final unit = property['unit'];
      if (unit != null && unit is! String) {
        throw FormatException(
          'CIP-152 property ${entry.key} has an invalid unit.',
        );
      }
      measurements[entry.key] = Cip152LabMeasurement(
        value: value,
        unit: unit as String?,
      );
    }
    return Cip152LabCertificate(measurements);
  }
}

extension Cip152MetadataContractExtension on Cip150MetadataContract {
  /// Resolves and validates the current CIP-152 lab certificate.
  Future<Cip152LabCertificate?> readLabCertificate(IpfsGateway gateway) async {
    if (!await hasKey(cip152LabKey)) return null;
    final reference = await getValue(cip152LabKey);
    final path = Uri.tryParse(reference)?.path ?? reference;
    if (!path.endsWith('/lab.json') && path != 'lab.json') {
      throw const FormatException(
        'CIP-152 lab reference must point to lab.json.',
      );
    }
    return Cip152LabCertificate.fromJson(await gateway.readJson(reference));
  }
}
