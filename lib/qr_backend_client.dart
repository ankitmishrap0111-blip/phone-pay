import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum QrReviewStatus { resolved, unsupported, invalid }

class QrReviewResult {
  const QrReviewResult({
    required this.status,
    required this.message,
    this.payeeName,
    this.payeeAddress,
    this.amount,
    this.currency,
    this.note,
  });

  final QrReviewStatus status;
  final String message;
  final String? payeeName;
  final String? payeeAddress;
  final String? amount;
  final String? currency;
  final String? note;

  factory QrReviewResult.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']) {
      'resolved' => QrReviewStatus.resolved,
      'unsupported' => QrReviewStatus.unsupported,
      'invalid' => QrReviewStatus.invalid,
      _ => throw const FormatException('Unknown QR review status.'),
    };
    final message = json['message'];
    if (message is! String || message.isEmpty) {
      throw const FormatException('QR backend response has no message.');
    }

    String? optionalString(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is! String) {
        throw FormatException('QR backend field "$key" must be a string.');
      }
      return value;
    }

    return QrReviewResult(
      status: status,
      message: message,
      payeeName: optionalString('payeeName'),
      payeeAddress: optionalString('payeeAddress'),
      amount: optionalString('amount'),
      currency: optionalString('currency'),
      note: optionalString('note'),
    );
  }
}

class QrBackendException implements Exception {
  const QrBackendException(this.message);

  final String message;

  @override
  String toString() => message;
}

class QrBackendClient {
  QrBackendClient({
    http.Client? httpClient,
    Uri? baseUri,
    this.timeout = const Duration(seconds: 8),
  })  : _httpClient = httpClient ?? http.Client(),
        _ownsClient = httpClient == null,
        baseUri = baseUri ?? _defaultBaseUri();

  final http.Client _httpClient;
  final bool _ownsClient;
  final Uri baseUri;
  final Duration timeout;

  Future<QrReviewResult> resolve(String qrPayload) async {
    final response = await _post(qrPayload);
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const QrBackendException(
        'The scanner backend returned an unreadable response.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const QrBackendException(
        'The scanner backend returned an invalid response.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['error'];
      throw QrBackendException(
        message is String
            ? message
            : 'Scanner backend returned HTTP ${response.statusCode}.',
      );
    }

    try {
      return QrReviewResult.fromJson(decoded);
    } on FormatException catch (error) {
      throw QrBackendException(error.message);
    }
  }

  Future<http.Response> _post(String qrPayload) async {
    try {
      return await _httpClient
          .post(
            baseUri.resolve('/api/qr/resolve'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({'qrPayload': qrPayload}),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const QrBackendException(
        'The scanner backend took too long to respond. Try again.',
      );
    } on http.ClientException catch (error) {
      throw QrBackendException(
        'Could not reach the scanner backend at $baseUri. '
        'Check that it is running and reachable from this device. '
        '(${error.message})',
      );
    }
  }

  void close() {
    if (_ownsClient) _httpClient.close();
  }

  static Uri _defaultBaseUri() {
    const configuredUrl = String.fromEnvironment('QR_BACKEND_URL');
    if (configuredUrl.isNotEmpty) return Uri.parse(configuredUrl);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return Uri.parse('http://10.0.2.2:8081');
    }
    return Uri.parse('http://localhost:8081');
  }
}
