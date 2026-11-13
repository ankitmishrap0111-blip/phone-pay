import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

String? decodeQrImageBytes(Uint8List bytes) {
  final img.Image? decodedImage;
  try {
    decodedImage = img.decodeImage(bytes);
  } on img.ImageException {
    return null;
  }
  if (decodedImage == null) return null;

  final rgbaImage = decodedImage.convert(numChannels: 4);
  final luminanceSource = RGBLuminanceSource(
    rgbaImage.width,
    rgbaImage.height,
    rgbaImage.getBytes(order: img.ChannelOrder.abgr).buffer.asInt32List(),
  );
  final bitmap = BinaryBitmap(GlobalHistogramBinarizer(luminanceSource));

  try {
    return QRCodeReader().decode(bitmap).text;
  } on ReaderException {
    return null;
  }
}
