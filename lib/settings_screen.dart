import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences prefs;

  final deviceIdController = TextEditingController();
  final serverUrlController = TextEditingController();
  final accuracyController = TextEditingController();
  final distanceController = TextEditingController();
  final frequencyController = TextEditingController();
  bool offlineBuffering = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    prefs = await SharedPreferences.getInstance();

    setState(() {
      deviceIdController.text = prefs.getString('deviceId') ?? '';
      serverUrlController.text = prefs.getString('serverUrl') ?? '';
      accuracyController.text = prefs.getString('accuracy') ?? 'high';
      distanceController.text = prefs.getString('distance') ?? '50';
      frequencyController.text = prefs.getString('frequency') ?? '60';
      offlineBuffering = prefs.getBool('offlineBuffering') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    await prefs.setString('deviceId', deviceIdController.text);
    await prefs.setString('serverUrl', serverUrlController.text);
    await prefs.setString('accuracy', accuracyController.text);
    await prefs.setString('distance', distanceController.text);
    await prefs.setString('frequency', frequencyController.text);
    await prefs.setBool('offlineBuffering', offlineBuffering);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  void dispose() {
    deviceIdController.dispose();
    serverUrlController.dispose();
    accuracyController.dispose();
    distanceController.dispose();
    frequencyController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField('Device ID', deviceIdController),
          _buildTextField('Server URL', serverUrlController),
          _buildTextField('Location Accuracy', accuracyController),
          _buildTextField('Distance (meters)', distanceController),
          _buildTextField('Frequency (seconds)', frequencyController),
          SwitchListTile(
            title: const Text('Offline Buffering'),
            value: offlineBuffering,
            onChanged: (value) {
              setState(() => offlineBuffering = value);
            },
          ),
        ],
      ),
    );
  }
}
