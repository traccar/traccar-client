import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

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
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final logs = await bg.Logger.getLog(); // Fetch logs
    setState(() {
      _logs.clear();
      _logs.addAll(logs.split('\n').reversed); // Latest logs first
    });
  }

  Future<void> _clearLogs() async {
    await bg.Logger.destroyLog();
    setState(() => _logs.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Geolocation Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: _logs.isEmpty
          ? const Center(child: Text('No logs available.'))
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 2.0, horizontal: 8.0),
                child: Text(
                  _logs[index],
                  style: const TextStyle(fontSize: 12.0),
                ),
              ),
            ),
    );
  }
}
