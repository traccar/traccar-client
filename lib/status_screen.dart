import 'package:flutter/material.dart';
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
  List<String> _logs = const [];

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    final logs = await GeolocationService.tracker.getLogs();
    setState(() {
      _logs = logs.reversed.map(_format).toList(growable: false);
    });
  }

  Future<void> _shareLogs() async {
    await SharePlus.instance.share(ShareParams(text: _logs.reversed.join('\n')));
  }

  Future<void> _clearLogs() async {
    await GeolocationService.tracker.clearLogs();
    setState(() => _logs = const []);
  }

  static String _format(LogEntry entry) {
    final time = DateTime.fromMillisecondsSinceEpoch(entry.time).toIso8601String();
    return '$time ${entry.message}';
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
        itemBuilder: (_, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            _logs[index],
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
