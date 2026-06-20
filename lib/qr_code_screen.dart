import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'configuration_service.dart';
import 'l10n/app_localizations.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  late final MobileScannerController _controller;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return false;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null) continue;
      final uri = Uri.tryParse(rawValue);
      if (uri == null || uri.scheme.isEmpty) continue;
      _scanned = true;
      await ConfigurationService.applyUri(uri);
      if (mounted) Navigator.pop(context);
      return true;
    }
    return false;
  }

  Future<void> _scanImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (image == null) return;

    final capture = await _controller.analyzeImage(
      image.path,
      formats: [BarcodeFormat.qrCode],
    );
    if (!mounted) return;
    if (capture == null || capture.barcodes.isEmpty) {
      _showScanError(AppLocalizations.of(context)!.qrNotFoundMessage);
    } else if (!await _onDetect(capture) && mounted) {
      _showScanError(AppLocalizations.of(context)!.qrInvalidMessage);
    }
  }

  void _showScanError(String message) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(Icons.qr_code_2, color: colors.onInverseSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onInverseSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _scanImage,
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              return IconButton(
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                ),
                onPressed: state.torchState == TorchState.unavailable
                        ? null
                        : () => _controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
        fit: BoxFit.cover,
        onDetect: _onDetect,
        errorBuilder: (context, error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_off_outlined, size: 120),
                  Text(AppLocalizations.of(context)!.disabledValue),
                  SizedBox(height: 24,),
                  FilledButton.tonal(
                    onPressed:
                        () => AppSettings.openAppSettings(
                          type: AppSettingsType.settings,
                        ),
                    child: Text(AppLocalizations.of(context)!.settingsTitle),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
