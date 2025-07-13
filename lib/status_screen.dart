import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'l10n/app_localizations.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  Future<void> _refreshLogs() async {
    final logs = await bg.Logger.getLog(bg.SQLQuery(
      order: bg.SQLQuery.ORDER_DESC,
      limit: 2000,
    ));
    setState(() {
      _logs.clear();
      _logs.addAll(logs.split('\n'));
    });
  }

  Future<void> _emailLogs() async {
    await bg.Logger.emailLog("support@traccar.org", bg.SQLQuery(
      order: bg.SQLQuery.ORDER_DESC,
      limit: 25000,
    ));
  }

  Future<void> _clearLogs() async {
    await bg.Logger.destroyLog();
    setState(() => _logs.clear());
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
            onPressed: _emailLogs,
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
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
