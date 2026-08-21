import 'package:core_web3dart/cip.dart';
import 'package:test/test.dart';

void main() {
  group('Cip152LabCertificate', () {
    test('parses a flat lab certificate', () {
      final certificate = Cip152LabCertificate.fromJson({
        'moisture': {'value': 9.7, 'unit': 'percent'},
        'pH': {'value': 6.51},
        'color': {'value': 'white'},
      });
      expect(certificate.measurements['moisture']?.value, 9.7);
      expect(certificate.measurements['moisture']?.unit, 'percent');
      expect(certificate.measurements['pH']?.unit, isNull);
    });

    test('rejects properties without values', () {
      expect(
        () => Cip152LabCertificate.fromJson({
          'pH': {'unit': 'pH'},
        }),
        throwsFormatException,
      );
    });
  });
}
