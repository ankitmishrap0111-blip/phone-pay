import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:phonepe_replicte/qr_image_decoder.dart';
import 'package:zxing2/qrcode.dart';

void main() {
  test('decodes QR content from a gallery image', () {
    const payload = 'demo:phonepe-gallery-scan';
    final qrCode = Encoder.encode(payload, ErrorCorrectionLevel.h);
    final matrix = qrCode.matrix!;
    const scale = 8;
    const quietZone = 4;
    final imageSize = (matrix.width + quietZone * 2) * scale;
    final image = img.Image(
      width: imageSize,
      height: imageSize,
      numChannels: 4,
    );
    img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));

    for (var y = 0; y < matrix.height; y++) {
      for (var x = 0; x < matrix.width; x++) {
        if (matrix.get(x, y) != 1) continue;
        final left = (x + quietZone) * scale;
        final top = (y + quietZone) * scale;
        img.fillRect(
          image,
          x1: left,
          y1: top,
          x2: left + scale - 1,
          y2: top + scale - 1,
          color: img.ColorRgba8(0, 0, 0, 255),
        );
      }
    }

    final pngBytes = Uint8List.fromList(img.encodePng(image));
    expect(decodeQrImageBytes(pngBytes), payload);
  });

  test('returns null for an image with no decodable QR code', () {
    final image = img.Image(width: 64, height: 64, numChannels: 4);
    img.fill(image, color: img.ColorRgba8(255, 255, 255, 255));
    final pngBytes = Uint8List.fromList(img.encodePng(image));

    expect(decodeQrImageBytes(pngBytes), isNull);
    expect(decodeQrImageBytes(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
