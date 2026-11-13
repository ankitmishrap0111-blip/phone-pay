import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const _maxRequestBytes = 8192;
const _maxQrPayloadLength = 4096;

Map<String, Object?> resolveQrPayload(String payload) {
  final value = payload.trim();
  if (value.isEmpty || value.length > _maxQrPayloadLength) {
    return _result(
      'invalid',
      'The QR content is empty or too large to review.',
    );
  }

  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme.toLowerCase() != 'upi' ||
      uri.host.toLowerCase() != 'pay') {
    return _result(
      'unsupported',
      'This QR is readable, but it is not a supported UPI payment QR.',
    );
  }

  final parameters = uri.queryParameters;
  final payeeAddress = parameters['pa']?.trim();
  if (payeeAddress == null ||
      !RegExp(r'^[A-Za-z0-9._+-]{1,128}@[A-Za-z0-9.-]{1,64}$')
          .hasMatch(payeeAddress)) {
    return _result('invalid', 'The QR does not contain a valid UPI ID.');
  }

  final amount = parameters['am']?.trim();
  if (amount != null &&
      (!RegExp(r'^\d{1,9}(?:\.\d{1,2})?$').hasMatch(amount) ||
          double.parse(amount) <= 0)) {
    return _result('invalid', 'The QR contains an invalid payment amount.');
  }

  final currency = parameters['cu']?.trim() ?? 'INR';
  if (!RegExp(r'^[A-Za-z]{3}$').hasMatch(currency)) {
    return _result('invalid', 'The QR contains an invalid currency code.');
  }

  return {
    'status': 'resolved',
    'message': 'QR details extracted. Confirm them in your payment app.',
    'payeeName': _limitedText(parameters['pn'], 120),
    'payeeAddress': payeeAddress,
    'amount': amount,
    'currency': currency.toUpperCase(),
    'note': _limitedText(parameters['tn'], 120),
    'verified': false,
    'payable': false,
  };
}

Map<String, Object?> _result(String status, String message) => {
      'status': status,
      'message': message,
      'verified': false,
      'payable': false,
    };

String? _limitedText(String? value, int maxLength) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed.substring(0, trimmed.length.clamp(0, maxLength).toInt());
}

Future<void> handleQrApiRequest(HttpRequest request) async {
  _addCorsHeaders(request.response);

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  if (request.method == 'GET' && request.uri.path == '/api/health') {
    await _writeJson(request.response, HttpStatus.ok, {'status': 'ok'});
    return;
  }

  if (request.uri.path != '/api/qr/resolve') {
    await _writeJson(
      request.response,
      HttpStatus.notFound,
      {'error': 'API route not found.'},
    );
    return;
  }

  if (request.method != 'POST') {
    await _writeJson(
      request.response,
      HttpStatus.methodNotAllowed,
      {'error': 'Use POST to resolve a QR code.'},
    );
    return;
  }

  if (request.headers.contentType?.mimeType != 'application/json') {
    await _writeJson(
      request.response,
      HttpStatus.unsupportedMediaType,
      {'error': 'Content-Type must be application/json.'},
    );
    return;
  }

  try {
    final bytes = await _readBody(request);
    final body = jsonDecode(utf8.decode(bytes));
    if (body is! Map<String, dynamic> || body['qrPayload'] is! String) {
      await _writeJson(
        request.response,
        HttpStatus.badRequest,
        {'error': 'Request must contain a string qrPayload.'},
      );
      return;
    }
    await _writeJson(
      request.response,
      HttpStatus.ok,
      resolveQrPayload(body['qrPayload'] as String),
    );
  } on _RequestTooLarge {
    await _writeJson(
      request.response,
      HttpStatus.requestEntityTooLarge,
      {'error': 'QR request is too large.'},
    );
  } on FormatException {
    await _writeJson(
      request.response,
      HttpStatus.badRequest,
      {'error': 'Request body must be valid JSON.'},
    );
  }
}

Future<List<int>> _readBody(HttpRequest request) async {
  final bytes = BytesBuilder(copy: false);
  await for (final chunk in request) {
    if (bytes.length + chunk.length > _maxRequestBytes) {
      throw const _RequestTooLarge();
    }
    bytes.add(chunk);
  }
  return bytes.takeBytes();
}

void _addCorsHeaders(HttpResponse response) {
  response.headers
    ..set(HttpHeaders.accessControlAllowOriginHeader, '*')
    ..set(HttpHeaders.accessControlAllowMethodsHeader, 'GET, POST, OPTIONS')
    ..set(HttpHeaders.accessControlAllowHeadersHeader, 'Content-Type')
    ..set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
}

Future<void> _writeJson(
  HttpResponse response,
  int statusCode,
  Map<String, Object?> body,
) async {
  response.statusCode = statusCode;
  response.write(jsonEncode(body));
  await response.close();
}

class _RequestTooLarge implements Exception {
  const _RequestTooLarge();
}

Future<void> main(List<String> args) async {
  var host = '127.0.0.1';
  var port = 8081;
  for (final argument in args) {
    if (argument.startsWith('--host=')) {
      host = argument.substring('--host='.length);
    } else if (argument.startsWith('--port=')) {
      final parsedPort = int.tryParse(argument.substring('--port='.length));
      if (parsedPort == null || parsedPort < 1 || parsedPort > 65535) {
        throw ArgumentError('Port must be between 1 and 65535.');
      }
      port = parsedPort;
    } else {
      throw ArgumentError('Unknown backend option: $argument');
    }
  }

  final server = await HttpServer.bind(host, port);
  stdout.writeln('QR review backend listening on http://${server.address.host}:'
      '${server.port}');
  server.listen((request) {
    unawaited(handleQrApiRequest(request));
  });
}
