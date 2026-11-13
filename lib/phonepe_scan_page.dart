import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phonepe_replicte/qr_backend_client.dart';
import 'package:phonepe_replicte/qr_image_decoder.dart';
import 'package:phonepe_replicte/phonepe_theme.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({
    super.key,
    required this.onBack,
    this.cameraEnabled = true,
  });

  final VoidCallback onBack;
  final bool cameraEnabled;

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  MobileScannerController? _controller;
  final _imagePicker = ImagePicker();
  final _qrBackend = QrBackendClient();
  String? _scannedValue;
  String? _cameraMessage;
  QrReviewResult? _reviewResult;
  String? _backendMessage;
  bool _isResolving = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameraEnabled) {
      _controller = MobileScannerController(
        cameraResolution: const Size(1280, 720),
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 200,
        formats: const [BarcodeFormat.qrCode],
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _qrBackend.close();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!mounted || _scannedValue != null || _isPickingImage) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value == null || value.isEmpty) continue;

      unawaited(_acceptScannedValue(value));
      return;
    }
  }

  Future<void> _acceptScannedValue(
    String value, {
    bool cameraAlreadyStopped = false,
  }) async {
    if (!mounted || _scannedValue != null || _isResolving) return;
    setState(() {
      _scannedValue = value;
      _cameraMessage = null;
      _backendMessage = null;
      _reviewResult = null;
      _isResolving = true;
    });
    if (!cameraAlreadyStopped) await _stopCamera();
    await _resolveScannedValue(value);
  }

  Future<void> _resolveScannedValue(String value) async {
    try {
      final result = await _qrBackend.resolve(value);
      if (!mounted) return;
      setState(() {
        _reviewResult = result;
        _backendMessage = null;
      });
    } on QrBackendException catch (error) {
      if (!mounted) return;
      setState(() => _backendMessage = error.message);
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  Future<void> _retryBackend() async {
    final value = _scannedValue;
    if (value == null || _isResolving) return;
    setState(() {
      _backendMessage = null;
      _isResolving = true;
    });
    await _resolveScannedValue(value);
  }

  Future<void> _stopCamera() async {
    try {
      await _controller?.stop();
    } on MobileScannerException catch (error) {
      if (mounted) {
        setState(() => _cameraMessage = 'Could not pause camera: $error');
      }
    }
  }

  Future<void> _restartCamera() async {
    setState(() {
      _scannedValue = null;
      _cameraMessage = null;
      _backendMessage = null;
      _reviewResult = null;
      _isResolving = false;
    });
    try {
      await _controller?.start();
    } on MobileScannerException catch (error) {
      if (mounted) setState(() => _cameraMessage = error.toString());
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null ||
        controller.value.torchState == TorchState.unavailable) {
      _showNotice('Torch is unavailable on this camera.');
      return;
    }

    try {
      await controller.toggleTorch();
    } on MobileScannerException catch (error) {
      if (mounted) setState(() => _cameraMessage = error.toString());
    }
  }

  Future<void> _switchCamera() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.switchCamera();
      if (mounted) setState(() => _cameraMessage = null);
    } on MobileScannerException catch (error) {
      if (mounted) {
        setState(() => _cameraMessage = 'Could not switch camera: $error');
      }
    } on UnsupportedError catch (error) {
      if (mounted) setState(() => _cameraMessage = error.message);
    }
  }

  Future<void> _pickQrImage() async {
    if (_isPickingImage || _isResolving || _scannedValue != null) return;

    final controller = _controller;
    final resumeCamera = controller?.value.isRunning ?? false;
    var cameraStopped = false;
    setState(() {
      _isPickingImage = true;
      _cameraMessage = null;
    });

    try {
      if (resumeCamera) {
        await controller!.stop();
        cameraStopped = true;
      }

      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
      );
      if (image == null || !mounted) return;

      final value = decodeQrImageBytes(await image.readAsBytes())?.trim();
      if (!mounted) return;
      if (value == null || value.isEmpty) {
        _showNotice('No QR code was found in that image.');
        return;
      }
      await _acceptScannedValue(value, cameraAlreadyStopped: cameraStopped);
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _cameraMessage = 'Could not read the selected image: '
            '${error.message ?? error.code}');
      }
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _cameraMessage = 'Could not process the selected image: '
            '$error');
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
      if (mounted && _scannedValue == null && resumeCamera && cameraStopped) {
        await _resumeCamera();
      }
    }
  }

  Future<void> _resumeCamera() async {
    final controller = _controller;
    if (controller == null || controller.value.isRunning) return;
    try {
      await controller.start();
    } on MobileScannerException catch (error) {
      if (mounted) setState(() => _cameraMessage = error.toString());
    }
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('scan-screen'),
      backgroundColor: PhonePeColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller case final controller?)
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
              onDetectError: (error, stackTrace) {
                if (mounted) {
                  setState(
                      () => _cameraMessage = 'QR detection failed: $error');
                }
              },
              errorBuilder: (context, error) => _CameraError(
                error: error,
                onRetry: _restartCamera,
              ),
              placeholderBuilder: (_) => const ColoredBox(
                color: PhonePeColors.surfaceLight,
                child: Center(
                  child: CircularProgressIndicator(
                    color: PhonePeColors.accent,
                  ),
                ),
              ),
            )
          else
            const ColoredBox(color: PhonePeColors.surfaceLight),
          ColoredBox(color: Colors.black.withValues(alpha: 0.42)),
          SafeArea(
            child: Column(
              children: [
                _ScanHeader(onBack: widget.onBack),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final edge = math
                            .min(
                              constraints.maxWidth - 48,
                              constraints.maxHeight * 0.76,
                            )
                            .clamp(150.0, 290.0)
                            .toDouble();
                        return SizedBox(
                          key: const ValueKey('scanner-frame'),
                          width: edge,
                          height: edge,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomPaint(
                              painter: _ScanFramePainter(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_isResolving)
                  const _BackendProgress()
                else if (_backendMessage case final message?)
                  _BackendErrorCard(
                    message: message,
                    qrPayload: _scannedValue ?? '',
                    onRetry: _retryBackend,
                    onScanAgain: _restartCamera,
                  )
                else if (_reviewResult case final result?)
                  _QrReviewCard(
                    result: result,
                    qrPayload: _scannedValue ?? '',
                    onScanAgain: _restartCamera,
                  )
                else
                  _ScanActions(
                    controller: _controller,
                    isPickingImage: _isPickingImage,
                    onSwitchCamera: _switchCamera,
                    onToggleTorch: _toggleTorch,
                    onTorchUnavailable: () => _showNotice(
                      'Torch is unavailable on this camera.',
                    ),
                    onUpload: _pickQrImage,
                  ),
                if (_cameraMessage case final message?)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PhonePeColors.danger,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => _showNotice(
                    'Fingerprint authentication is not enabled in this demo.',
                  ),
                  icon: const Icon(Icons.fingerprint, size: 23),
                  label: const Text('Pay faster with your Fingerprint'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 10),
                  child: Text(
                    'BHIM  |  UPI',
                    style: TextStyle(
                      color: PhonePeColors.muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanHeader extends StatelessWidget {
  const _ScanHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan any QR',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Text(
                  'PhonePe • Google Pay • BHIM • Paytm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: PhonePeColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: PhonePeColors.surface,
                title: const Text('QR scan help'),
                content: const Text(
                  'Allow camera access and place a QR code inside the frame. '
                  'Or choose a QR image from your gallery. Scanned data is '
                  'sent to the local review backend to read UPI details. '
                  'Accounts are not verified and no payment is sent.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            ),
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
    );
  }
}

class _ScanActions extends StatelessWidget {
  const _ScanActions({
    required this.controller,
    required this.isPickingImage,
    required this.onSwitchCamera,
    required this.onToggleTorch,
    required this.onTorchUnavailable,
    required this.onUpload,
  });

  final MobileScannerController? controller;
  final bool isPickingImage;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleTorch;
  final VoidCallback onTorchUnavailable;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final scannerController = controller;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ScanAction(
          icon: isPickingImage ? Icons.hourglass_top : Icons.image_outlined,
          label: isPickingImage ? 'Opening gallery' : 'Upload QR',
          onTap: isPickingImage ? null : onUpload,
          enabled: !isPickingImage,
        ),
        const SizedBox(width: 12),
        if (scannerController != null)
          _ScanAction(
            icon: Icons.cameraswitch_outlined,
            label: 'Switch camera',
            onTap: onSwitchCamera,
          )
        else
          const _ScanAction(
            icon: Icons.cameraswitch_outlined,
            label: 'Camera unavailable',
            onTap: null,
            enabled: false,
          ),
        const SizedBox(width: 12),
        if (scannerController != null)
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: scannerController,
            builder: (context, state, _) {
              final available = state.torchState != TorchState.unavailable;
              return _ScanAction(
                icon: state.torchState == TorchState.on
                    ? Icons.flashlight_on
                    : Icons.flashlight_off,
                label: available ? 'Torch' : 'Torch unavailable',
                onTap: available ? onToggleTorch : onTorchUnavailable,
                enabled: available,
              );
            },
          )
        else
          const _ScanAction(
            icon: Icons.flashlight_off,
            label: 'Torch unavailable',
            onTap: null,
            enabled: false,
          ),
      ],
    );
  }
}

class _ScanAction extends StatelessWidget {
  const _ScanAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0x66585858),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: enabled ? Colors.white : PhonePeColors.muted,
                size: 26,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: enabled ? Colors.white : PhonePeColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackendProgress extends StatelessWidget {
  const _BackendProgress();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: PhonePeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhonePeColors.border),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: PhonePeColors.accent,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Checking QR details with backend...',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendErrorCard extends StatelessWidget {
  const _BackendErrorCard({
    required this.message,
    required this.qrPayload,
    required this.onRetry,
    required this.onScanAgain,
  });

  final String message;
  final String qrPayload;
  final VoidCallback onRetry;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PhonePeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhonePeColors.danger),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backend unavailable',
            style: TextStyle(
              color: PhonePeColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: PhonePeColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'QR scanned. Raw content:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 4),
          SelectableText(
            qrPayload,
            maxLines: 3,
            style: const TextStyle(color: PhonePeColors.muted, fontSize: 12),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: onScanAgain,
                  child: const Text('Scan again'),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrReviewCard extends StatelessWidget {
  const _QrReviewCard({
    required this.result,
    required this.qrPayload,
    required this.onScanAgain,
  });

  final QrReviewResult result;
  final String qrPayload;
  final VoidCallback onScanAgain;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PhonePeColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhonePeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch (result.status) {
              QrReviewStatus.resolved => 'UPI QR details',
              QrReviewStatus.unsupported => 'Unsupported QR code',
              QrReviewStatus.invalid => 'Invalid QR details',
            },
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (result.payeeName case final name?) ...[
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          if (result.payeeAddress case final address?)
            _QrDetailRow(label: 'UPI ID', value: address),
          if (result.amount case final amount?)
            _QrDetailRow(
              label: 'Amount',
              value: '${result.currency ?? 'INR'} $amount',
            ),
          if (result.note case final note?)
            _QrDetailRow(label: 'Note', value: note),
          if (result.payeeAddress == null)
            _QrDetailRow(label: 'QR content', value: qrPayload),
          const SizedBox(height: 8),
          Text(
            result.message,
            style: const TextStyle(color: PhonePeColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 6),
          const Text(
            'Not account-verified • no payment will be sent',
            style: TextStyle(color: PhonePeColors.accentLight, fontSize: 11),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onScanAgain,
              child: const Text('Scan again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrDetailRow extends StatelessWidget {
  const _QrDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(
                color: PhonePeColors.muted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PhonePeColors.surfaceLight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 42),
              const SizedBox(height: 12),
              const Text(
                'Camera unavailable',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Allow camera access to scan a QR code. '
                'On a phone browser, open this app over HTTPS. '
                '(${error.errorCode.name})',
                textAlign: TextAlign.center,
                style: const TextStyle(color: PhonePeColors.muted),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try camera again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PhonePeColors.accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const length = 34.0;
    const inset = 2.0;

    final corners = <Path>[
      Path()
        ..moveTo(inset, length)
        ..lineTo(inset, inset + 8)
        ..quadraticBezierTo(inset, inset, inset + 8, inset)
        ..lineTo(length, inset),
      Path()
        ..moveTo(size.width - length, inset)
        ..lineTo(size.width - inset - 8, inset)
        ..quadraticBezierTo(
            size.width - inset, inset, size.width - inset, inset + 8)
        ..lineTo(size.width - inset, length),
      Path()
        ..moveTo(inset, size.height - length)
        ..lineTo(inset, size.height - inset - 8)
        ..quadraticBezierTo(
          inset,
          size.height - inset,
          inset + 8,
          size.height - inset,
        )
        ..lineTo(length, size.height - inset),
      Path()
        ..moveTo(size.width - length, size.height - inset)
        ..lineTo(size.width - inset - 8, size.height - inset)
        ..quadraticBezierTo(
          size.width - inset,
          size.height - inset,
          size.width - inset,
          size.height - inset - 8,
        )
        ..lineTo(size.width - inset, size.height - length),
    ];

    for (final corner in corners) {
      canvas.drawPath(corner, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) => false;
}
