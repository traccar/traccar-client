import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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
    _initState();
  }

  void _initState() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      loading = false;
      buffering = preferences.getBool(Preferences.buffer) ?? true;
    });
  }

  String _getAccuracyLabel(String? key) {
    return switch (key) {
      'high' => AppLocalizations.of(context)!.highAccuracyLabel,
      'low' => AppLocalizations.of(context)!.lowAccuracyLabel,
      _ => AppLocalizations.of(context)!.mediumAccuracyLabel,
    };
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

  Widget _buildAccuracyListTile() {
    final accuracyOptions = ['high', 'medium', 'low'];
    return ListTile(
      title: Text(AppLocalizations.of(context)!.accuracyLabel),
      subtitle: Text(_getAccuracyLabel(preferences.getString(Preferences.accuracy))),
      onTap: () async {
        final selectedAccuracy = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(AppLocalizations.of(context)!.accuracyLabel),
            children: accuracyOptions.map((option) => SimpleDialogOption(
              child: Text(_getAccuracyLabel(option)),
              onPressed: () => Navigator.pop(context, option),
            )).toList(),
          ),
        );
        if (selectedAccuracy != null) {
          await preferences.setString(Preferences.accuracy, selectedAccuracy);
          await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig(preferences));
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        children: [
          _buildListTile(AppLocalizations.of(context)!.idLabel, Preferences.id, false),
          _buildListTile(AppLocalizations.of(context)!.urlLabel, Preferences.url, false),
          _buildAccuracyListTile(),
          _buildListTile(AppLocalizations.of(context)!.distanceLabel, Preferences.distance, true),
          _buildListTile(AppLocalizations.of(context)!.intervalLabel, Preferences.interval, true),
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
