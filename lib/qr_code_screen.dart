import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'configuration_service.dart';
import 'l10n/app_localizations.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;
    if (rawValue == null) return;
    final uri = Uri.tryParse(rawValue);
    if (uri == null || uri.scheme.isEmpty) return;
    _scanned = true;
    await ConfigurationService.applyUri(uri);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: MobileScanner(
        fit: BoxFit.cover,
        onDetect: _onDetect,
      ),
    );
  }
}
