import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:traccar_client/l10n/app_localizations.dart';

class PasswordService {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _passwordKey = 'password';

  static Future<bool> authenticate(BuildContext context) async {
    if (!await _secureStorage.containsKey(key: _passwordKey)) return true;
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
                final password = await _secureStorage.read(key: _passwordKey);
                if (context.mounted) {
                  Navigator.pop(context, password == controller.text);
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
      await _secureStorage.write(key: _passwordKey, value: password);
    } else {
      await _secureStorage.delete(key: _passwordKey);
    }
  }
}
