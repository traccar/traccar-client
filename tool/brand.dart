import 'dart:io';

const appName = 'ACME Client';
const packageId = 'com.acme.client';
const version = '1.0.0+1';
const url = "https://example.com";
final iconPath = '${Platform.environment['HOME']}/Downloads/icon.png';

const keystoreFilePath = 'android/android.keystore';
const keystoreAlias = 'key';
const keystorePassword = 'password';

Future<void> main() async {
  await _generateIcons(iconPath);
  await _updateTitle(appName);
  await _updatePackageId(packageId);
  await _updateVersion(version);
  await _updateUrl(url);
  await _createKeystore();
  stdout.writeln('Please run `flutterfire configure` now.');
}

Future<void> _generateIcons(String icon) async {
  final dir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
  dir.deleteSync(recursive: true);
  dir.createSync();

  File('android/app/src/main/res/drawable/ic_launcher_foreground.xml').delete();
  File('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml').delete();

  final f = await _writeTempYaml('flutter_launcher_icons.yaml', '''
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "$icon"
  remove_alpha_ios: true
''');
  await _run('flutter', ['pub', 'run', 'flutter_launcher_icons']);
  await f.delete();

  await _replaceInFile(
    'android/app/src/main/AndroidManifest.xml',
    RegExp(r'\s*<meta-data\s+android:name="com\.google\.firebase\.messaging\.default_notification_icon"[\s\S]*?/>', multiLine: true),
    '',
  );
}

Future<void> _updateTitle(String name) async {
  await _replaceInFile(
    'android/app/src/main/AndroidManifest.xml',
    RegExp(r'android:label="[^"]*"'),
    'android:label="$name"',
  );

  await _replaceInFile(
    'ios/Runner/Info.plist',
    RegExp(r'<key>CFBundleDisplayName</key>\s*<string>.*?</string>'),
    '<key>CFBundleDisplayName</key>\n\t<string>$name</string>',
  );
}

Future<void> _updatePackageId(String id) async {
  await _replaceInFile(
    'android/app/build.gradle.kts',
    RegExp(r'applicationId = ".*?"'),
    'applicationId = "$id"',
  );

  await _replaceInFile(
    'ios/Runner.xcodeproj/project.pbxproj',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = org\.traccar.*?;'),
    'PRODUCT_BUNDLE_IDENTIFIER = $id;',
  );
}

Future<void> _updateVersion(String version) async {
  await _replaceInFile(
    'pubspec.yaml',
    RegExp(r'^version:\s*.*$', multiLine: true),
    'version: $version',
  );
}

Future<void> _updateUrl(String url) async {
  await _replaceInFile(
    'lib/preferences.dart',
    RegExp(r'https://demo\.traccar\.org:5055'),
    url,
  );
}

Future<void> _createKeystore() async {
  final args = [
    '-genkeypair',
    '-v',
    '-keystore', keystoreFilePath,
    '-alias', keystoreAlias,
    '-keyalg', 'RSA',
    '-keysize', '2048',
    '-validity', '10000',
    '-storepass', keystorePassword,
    '-keypass', keystorePassword,
    '-dname', 'CN=Brand, OU=Dev, O=Company, L=City, S=State, C=US',
  ];
  await _run('keytool', args);

  final file = File('android/key.properties');
  final content = '''
storePassword=$keystorePassword
keyPassword=$keystorePassword
keyAlias=$keystoreAlias
storeFile=../../$keystoreFilePath
''';
  await file.writeAsString(content);

  await _replaceInFile(
    'android/app/build.gradle.kts',
    RegExp(r'val\s+keystorePropertiesFile\s*=.*'),
    'val keystorePropertiesFile = rootProject.file("key.properties")',
  );
}

Future<File> _writeTempYaml(String name, String content) async {
  final file = File(name);
  await file.writeAsString(content);
  return file;
}

Future<void> _replaceInFile(String path, RegExp pattern, String replacement) async {
  final file = File(path);
  if (!await file.exists()) return;
  final text = await file.readAsString();
  final newText = text.replaceAll(pattern, replacement);
  if (newText != text) await file.writeAsString(newText);
}

Future<void> _run(String cmd, List<String> args) async {
  final proc = await Process.start(cmd, args);
  await stdout.addStream(proc.stdout);
  await stderr.addStream(proc.stderr);
  final code = await proc.exitCode;
  if (code != 0) throw Exception('$cmd ${args.join(" ")} failed ($code)');
}
