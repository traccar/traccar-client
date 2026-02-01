import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traccar_client/l10n/app_localizations.dart';
import 'package:traccar_client/preferences.dart';

class PasswordService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _passwordKey = 'password';

  static Future<void> migrate() async {
    final oldPassword = await _secureStorage.read(key: _passwordKey);
    if (oldPassword == null) return;
    await Preferences.instance.setString(_passwordKey, oldPassword);
    await _secureStorage.delete(key: _passwordKey);
  }

  static Future<bool> authenticate(BuildContext context) async {
    final storedPassword = Preferences.instance.getString(_passwordKey);
    if (storedPassword == null || storedPassword.isEmpty) return true;
    final controller = TextEditingController();
    bool? result;
    if (context.mounted) {
      result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          scrollable: true,
          content: TextField(
            controller: controller,
            autofocus: true,
            obscureText: true,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.passwordLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancelButton),
            ),
            TextButton(
              onPressed: () async {
                if (context.mounted) {
                  Navigator.pop(context, storedPassword == controller.text);
                }
              },
              child: Text(AppLocalizations.of(context)!.okButton),
            ),
          ],
        ),
      );
    }
    if (result != true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.passwordError)),
      );
      return false;
    }
    return result == true;
  }

  static Future<void> setPassword(String password) async {
    if (password.isNotEmpty) {
      await Preferences.instance.setString(_passwordKey, password);
    } else {
      await Preferences.instance.remove(_passwordKey);
    }
  }
}
