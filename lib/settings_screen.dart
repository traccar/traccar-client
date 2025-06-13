import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

import 'l10n/app_localizations.dart';
import 'preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool buffering = true;
  bool preventSuspend = false;
  bool stopDetection = false;
  bool advanced = false;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    setState(() {
      buffering = Preferences.instance.getBool(Preferences.buffer) ?? true;
      preventSuspend = Preferences.instance.getBool(Preferences.preventSuspend) ?? false;
      stopDetection = Preferences.instance.getBool(Preferences.stopDetection) ?? true;
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
        ? Preferences.instance.getInt(key)?.toString() ?? '0'
        : Preferences.instance.getString(key) ?? '';

    final controller = TextEditingController(text: initialValue);
    final scaffoldManager = ScaffoldMessenger.of(context);
    final errorMessage = AppLocalizations.of(context)!.invalidValue;

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
      if (key == Preferences.url) {
        final uri = Uri.tryParse(result);
        if (uri == null || uri.host.isEmpty || !(uri.scheme == 'http' || uri.scheme == 'https')) {
          scaffoldManager.showSnackBar(SnackBar(content: Text(errorMessage)));
          return;
        }
      }
      if (isInt) {
        int? intValue = int.tryParse(result);
        if (intValue != null) {
          if (key == Preferences.heartbeat && intValue > 0 && intValue < 60) {
            intValue = 60; // minimum heartbeat is 60 seconds
          }
          await Preferences.instance.setInt(key, intValue);
        }
      } else {
        await Preferences.instance.setString(key, result);
      }
      await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig());
      setState(() {});
    }
  }

  Widget _buildListTile(String title, String key, bool isInt) {
    final value = isInt ? Preferences.instance.getInt(key)?.toString() : Preferences.instance.getString(key);
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
      subtitle: Text(_getAccuracyLabel(Preferences.instance.getString(Preferences.accuracy))),
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
          await Preferences.instance.setString(Preferences.accuracy, selectedAccuracy);
          await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig());
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: ListView(
        children: [
          _buildListTile(AppLocalizations.of(context)!.idLabel, Preferences.id, false),
          _buildListTile(AppLocalizations.of(context)!.urlLabel, Preferences.url, false),
          _buildAccuracyListTile(),
          _buildListTile(AppLocalizations.of(context)!.distanceLabel, Preferences.distance, true),
          if (Platform.isAndroid && Preferences.instance.getInt(Preferences.distance) == 0)
            _buildListTile(AppLocalizations.of(context)!.intervalLabel, Preferences.interval, true),
          _buildListTile(AppLocalizations.of(context)!.heartbeatLabel, Preferences.heartbeat, true),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.advancedLabel),
            value: advanced,
            onChanged: (value) {
              setState(() => advanced = value);
            },
          ),
          if (advanced)
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.bufferLabel),
              value: buffering,
              onChanged: (value) async {
                await Preferences.instance.setBool(Preferences.buffer, value);
                await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig());
                setState(() => buffering = value);
              },
            ),
          if (advanced)
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.stopDetectionLabel),
              value: stopDetection,
              onChanged: (value) async {
                await Preferences.instance.setBool(Preferences.stopDetection, value);
                await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig());
                setState(() => stopDetection = value);
              },
            ),
          if (advanced && Platform.isIOS)
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.preventSuspendLabel),
              value: preventSuspend,
              onChanged: (value) async {
                await Preferences.instance.setBool(Preferences.preventSuspend, value);
                await bg.BackgroundGeolocation.setConfig(Preferences.geolocationConfig());
                setState(() => preventSuspend = value);
              },
            ),
        ],
      ),
    );
  }
}
