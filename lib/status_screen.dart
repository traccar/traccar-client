import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:traccar_client_sdk/traccar_client_sdk.dart';

import 'geolocation_service.dart';
import 'l10n/app_localizations.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  static final _displayFormat = DateFormat('HH:mm:ss');
  static final _fullFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  List<LogEntry> _logs = const [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        _refreshLogs();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshLogs() async {
    final logs = await GeolocationService.tracker.getLogs();
    if (!mounted) return;
    setState(() {
      _logs = logs.reversed.toList(growable: false);
    });
  }

  Future<void> _shareLogs() async {
    if (_logs.isEmpty) return;
    final text = _logs.reversed.map((entry) {
      final t = DateTime.fromMillisecondsSinceEpoch(entry.time);
      return '${_fullFormat.format(t)} ${entry.message}';
    }).join('\n');
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _clearLogs() async {
    await GeolocationService.tracker.clearLogs();
    if (!mounted) return;
    setState(() => _logs = const []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statusTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLogs,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: ListView.builder(
        reverse: true,
        itemCount: _logs.length,
        itemBuilder: (_, index) {
          final entry = _logs[index];
          final t = DateTime.fromMillisecondsSinceEpoch(entry.time);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '${_displayFormat.format(t)} ${entry.message}',
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          );
        },
      ),
    );
  }
}
