import 'dart:convert';

import 'package:http/http.dart';

/// Default public IPFS gateway used by Core applications.
const defaultIpfsGatewayTemplate = 'https://ipf.sk/{cid}';

/// Resolves IPFS references through a configurable gateway.
///
/// [template] must be an HTTP(S) URL containing `{cid}`. The placeholder is
/// replaced with the CID and any path present in an `ipfs://` reference.
class IpfsGateway {
  IpfsGateway({
    this.template = defaultIpfsGatewayTemplate,
    Client? client,
    this.maxResponseBytes = 1024 * 1024,
  }) : _client = client ?? Client() {
    _validateTemplate(template);
    if (maxResponseBytes <= 0) {
      throw ArgumentError.value(
        maxResponseBytes,
        'maxResponseBytes',
        'must be positive',
      );
    }
  }

  final String template;
  final int maxResponseBytes;
  final Client _client;

  /// Converts [reference] into a fetchable URI.
  ///
  /// HTTP(S) references are returned unchanged. IPFS references and bare CIDs
  /// are routed through [template].
  Uri resolve(String reference) {
    final value = reference.trim();
    if (value.isEmpty) {
      throw const FormatException('IPFS reference cannot be empty.');
    }

    final direct = Uri.tryParse(value);
    if (direct != null &&
        (direct.scheme == 'https' || direct.scheme == 'http')) {
      return direct;
    }

    final ipfsPath = _ipfsPath(value);
    final encodedPath = ipfsPath.split('/').map(Uri.encodeComponent).join('/');
    return Uri.parse(template.replaceFirst('{cid}', encodedPath));
  }

  /// Loads a JSON document, rejecting oversized or non-successful responses.
  Future<Object?> readJson(String reference) async {
    final request = Request('GET', resolve(reference));
    request.headers['accept'] = 'application/json';
    final response = await _client.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ClientException(
        'IPFS gateway returned HTTP ${response.statusCode}.',
        request.url,
      );
    }

    final bytes = <int>[];
    await for (final chunk in response.stream) {
      if (bytes.length + chunk.length > maxResponseBytes) {
        throw ClientException(
          'IPFS response exceeds $maxResponseBytes bytes.',
          request.url,
        );
      }
      bytes.addAll(chunk);
    }
    return jsonDecode(utf8.decode(bytes));
  }

  static void _validateTemplate(String template) {
    final uri = Uri.tryParse(template);
    if (!template.contains('{cid}') ||
        uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw ArgumentError.value(
        template,
        'template',
        'must be an HTTP(S) URL containing {cid}',
      );
    }
  }

  static String _ipfsPath(String reference) {
    var path = reference;
    if (path.startsWith('ipfs://')) {
      path = path.substring('ipfs://'.length);
    } else if (path.startsWith('/ipfs/')) {
      path = path.substring('/ipfs/'.length);
    }
    path = path.replaceFirst(RegExp(r'^ipfs/'), '');
    if (!RegExp(r'^[A-Za-z0-9]+(?:/[^?#]*)?$').hasMatch(path)) {
      throw FormatException('Invalid IPFS reference: $reference');
    }
    return path;
  }
}
