import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool editDeviceId;

  const SettingsScreen({super.key, this.editDeviceId = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool loading = true;
  late SharedPreferences preferences;
  bool buffering = true;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  void _initPreferences() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      loading = false;
      buffering = preferences.getBool(Preferences.buffer) ?? true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.editDeviceId) {
        _editSetting(AppLocalizations.of(context)!.idLabel, Preferences.id, false);
      }
    });
  }

  Future<void> _editSetting(String title, String key, bool isInt) async {
    final initialValue = isInt
        ? preferences.getInt(key)?.toString() ?? '0'
        : preferences.getString(key) ?? '';

    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: isInt ? TextInputType.number : TextInputType.text,
          inputFormatters: isInt ? [FilteringTextInputFormatter.digitsOnly] : [],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(AppLocalizations.of(context)!.saveButton),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (isInt) {
        final intValue = int.tryParse(result);
        if (intValue != null) {
          await preferences.setInt(key, intValue);
        }
      } else {
        await preferences.setString(key, result);
      }
      await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig(preferences));
      setState(() {});
    }
  }

  Widget _buildListTile(String title, String key, bool isInt) {
    final value = isInt ? preferences.getInt(key)?.toString() : preferences.getString(key);
    return ListTile(
      title: Text(title),
      subtitle: Text(value ?? ''),
      onTap: () => _editSetting(title, key, isInt),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildListTile(AppLocalizations.of(context)!.idLabel, Preferences.id, false),
          _buildListTile(AppLocalizations.of(context)!.urlLabel, Preferences.url, false),
          _buildListTile(AppLocalizations.of(context)!.accuracyLabel, Preferences.accuracy, false),
          _buildListTile(AppLocalizations.of(context)!.intervalLabel, Preferences.interval, true),
          _buildListTile(AppLocalizations.of(context)!.distanceLabel, Preferences.distance, true),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.bufferLabel),
            value: buffering,
            onChanged: (value) async {
              await preferences.setBool(Preferences.buffer, value);
              await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig(preferences));
              setState(() => buffering = value);
            },
          ),
        ],
      ),
    );
  }
}
