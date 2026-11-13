import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:phonepe_replicte/qr_backend_client.dart';

import '../tool/qr_backend.dart';

void main() {
  group('QR review backend', () {
    test('extracts payee and amount from a UPI QR', () {
      final result = resolveQrPayload(
        'upi://pay?pa=shop%40bank&pn=Corner%20Shop&am=25.50&cu=INR&tn=Tea',
      );

      expect(result['status'], 'resolved');
      expect(result['payeeAddress'], 'shop@bank');
      expect(result['payeeName'], 'Corner Shop');
      expect(result['amount'], '25.50');
      expect(result['currency'], 'INR');
      expect(result['note'], 'Tea');
      expect(result['verified'], isFalse);
      expect(result['payable'], isFalse);
    });

    test('rejects malformed amounts and unsupported QR types', () {
      expect(
        resolveQrPayload('upi://pay?pa=shop%40bank&am=-1')['status'],
        'invalid',
      );
      expect(
        resolveQrPayload('https://example.com')['status'],
        'unsupported',
      );
    });
  });

  group('QR backend client', () {
    test('posts QR text and parses the backend response', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/qr/resolve');
        expect(jsonDecode(request.body), {'qrPayload': 'upi://pay?pa=a%40b'});
        return http.Response(
          jsonEncode(resolveQrPayload('upi://pay?pa=a%40b')),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(client.close);
      final backend = QrBackendClient(
        httpClient: client,
        baseUri: Uri.parse('http://localhost:8081'),
      );

      final result = await backend.resolve('upi://pay?pa=a%40b');

      expect(result.status, QrReviewStatus.resolved);
      expect(result.payeeAddress, 'a@b');
    });

    test('surfaces backend errors instead of pretending resolution succeeded',
        () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({'error': 'Service unavailable.'}),
          503,
          headers: {'content-type': 'application/json'},
        ),
      );
      addTearDown(client.close);
      final backend = QrBackendClient(
        httpClient: client,
        baseUri: Uri.parse('http://localhost:8081'),
      );

      await expectLater(
        backend.resolve('upi://pay?pa=a%40b'),
        throwsA(
          isA<QrBackendException>().having(
            (error) => error.message,
            'message',
            'Service unavailable.',
          ),
        ),
      );
    });
  });
}
