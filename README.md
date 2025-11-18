# 🌟 LuminaLink

### *Stay Connected, Stay Safe – Privacy-First Family Location Sharing*

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Project Status](https://img.shields.io/badge/Status-Feature%20Complete-green.svg)](https://github.com/Nickalus12/LuminaLink)
[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.7.2-02569B.svg?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://github.com/Nickalus12/LuminaLink)

---

## 📖 Overview

**LuminaLink** is a next-generation, privacy-first family safety application built on Flutter. Born from the open-source Traccar Client, LuminaLink has been completely reimagined to provide families with a beautiful, intuitive, and secure way to stay connected through real-time location sharing.

Unlike traditional tracking apps, LuminaLink puts **your privacy first**. You control who sees your location, when they see it, and for how long. With Firebase security rules and transparent data practices, LuminaLink ensures your family's safety without compromising your privacy.

> **Mission:** To create a world where families can share their whereabouts confidently, knowing their data is protected and their privacy is respected.

---

## ✨ Key Features

### 🎯 Core Features (Implemented)

- 🗺️ **Real-Time Location Sharing** – See your loved ones' locations on Google Maps with color-coded circle markers
- 👨‍👩‍👧‍👦 **Private Circles** – Create secure groups with 6-character invite codes for family, friends, or teams
- 📍 **Place Alerts (Geofencing)** – Automated notifications when family members arrive at or leave important locations
- 🔒 **Privacy-First Design** – Granular controls over location sharing with privacy dashboard
- 🌙 **Platform-Native Experience** – Beautiful Material Design 3 on Android, seamless Cupertino on iOS
- 🔋 **Battery Optimized** – Smart background location tracking that respects battery life
- 🎨 **The "Lumina" Theme** – Warm amber/teal color scheme with 8-point grid system
- 🔔 **Smart Notifications** – FCM push notifications with 5-minute debouncing to prevent spam
- 🔐 **Data Security** – Comprehensive Firestore security rules with role-based access control

### 🛡️ Privacy Features

- **Location Sharing Toggle**: Enable/disable sharing instantly from settings
- **Circle-Based Sharing**: Location only visible to circles you create or join
- **Notification Controls**: Choose which places trigger entry/exit notifications
- **Privacy Dashboard**: See exactly which circles can view your location
- **Automatic Cleanup**: Old location data (>24hrs) automatically deleted
- **No Third-Party Sharing**: Your data never sold to advertisers

---

## 🛠️ Technology Stack

LuminaLink is built with modern, production-ready technologies:

| **Category**       | **Technology**                                                                 |
|--------------------|--------------------------------------------------------------------------------|
| **Framework**      | [Flutter](https://flutter.dev) 3.7.2+ (Cross-platform mobile)                |
| **Language**       | [Dart](https://dart.dev) ^3.7.2                                               |
| **Backend**        | [Firebase](https://firebase.google.com) (Auth, Firestore, Messaging, Storage) |
| **Maps**           | [Google Maps SDK](https://developers.google.com/maps) for Android & iOS       |
| **Location**       | [flutter_background_geolocation](https://pub.dev/packages/flutter_background_geolocation) ^4.18.1 |
| **Notifications**  | [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging) + flutter_local_notifications |
| **Storage**        | Cloud Firestore (real-time), shared_preferences, flutter_secure_storage       |
| **UI Patterns**    | Platform-adaptive widgets, Material 3, Cupertino                              |

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (^3.7.2): [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (included with Flutter)
- **Android Studio** or **Xcode** (for Android/iOS development respectively)
- **Firebase Account**: [Sign up for Firebase](https://console.firebase.google.com/)
- **Google Cloud Account**: [Sign up for Google Cloud](https://console.cloud.google.com/) (for Maps API)
- **Git**: [Install Git](https://git-scm.com/downloads)

### Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/Nickalus12/LuminaLink.git
cd LuminaLink
```

#### 2. Install Flutter Dependencies

```bash
flutter pub get
```

#### 3. Configure Firebase (Required)

Firebase is required for authentication, real-time database, and push notifications.

**A. Create Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the wizard
3. Enable Google Analytics (optional but recommended)

**B. Add Android App**

1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.luminalink.app`
3. Download `google-services.json`
4. Place file in `android/app/google-services.json`

**C. Add iOS App**

1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.luminalink.app`
3. Download `GoogleService-Info.plist`
4. Place file in `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Drag `GoogleService-Info.plist` into Runner folder

**D. Enable Firebase Services**

In Firebase Console, enable the following:

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"

2. **Cloud Firestore**
   - Go to Firestore Database → Create database
   - Start in **production mode**
   - Choose a location (preferably close to your users)
   - Deploy security rules from `firestore.rules`:
     ```bash
     firebase deploy --only firestore:rules
     ```
     (Requires Firebase CLI: `npm install -g firebase-tools`)

3. **Cloud Messaging**
   - Already enabled by default
   - No additional configuration needed

4. **Storage** (Optional - for future profile pictures)
   - Go to Storage → Get started
   - Start in production mode

#### 4. Configure Google Maps API (Required)

Google Maps is required for the map screen and place selection.

**A. Enable Maps APIs**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project (or create linked project)
3. Go to "APIs & Services" → "Library"
4. Enable the following APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**

**B. Create API Keys**

1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "API Key"
3. Create two keys (one for Android, one for iOS)

**C. Restrict API Keys (Important for security)**

For Android key:
- Application restrictions: Android apps
- Add package name: `com.luminalink.app`
- Add SHA-1 certificate fingerprint (get via `keytool` or Android Studio)
- API restrictions: Maps SDK for Android

For iOS key:
- Application restrictions: iOS apps
- Add bundle ID: `com.luminalink.app`
- API restrictions: Maps SDK for iOS

**D. Add API Keys to Project**

**Android:**
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <!-- Add this inside <application> tag -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_ANDROID_API_KEY_HERE"/>
    </application>
</manifest>
```

**iOS:**
Edit `ios/Runner/AppDelegate.swift`:
```swift
import UIKit
import Flutter
import GoogleMaps  // Add this import

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")  // Add this line
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### 5. Update flutter_background_geolocation License (Required)

The app uses flutter_background_geolocation which requires a license for production use.

1. Get a license from [Transistor Software](https://www.transistorsoft.com/shop/products/flutter-background-geolocation)
2. Edit `lib/preferences.dart` and add your license key to the config

For development/testing, you can use the free tier with limitations.

#### 6. Run the App

**For Android:**
```bash
flutter run -d android
```

**For iOS (macOS only):**
```bash
cd ios
pod install
cd ..
flutter run -d ios
```

#### 7. Build for Release (Optional)

**Android:**
```bash
flutter build apk --release      # APK for distribution
flutter build appbundle          # App Bundle for Google Play
```

**iOS:**
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode
# Archive and upload to App Store Connect
```

---

## 📱 Platform Support

| Platform | Minimum Version | Status |
|----------|----------------|--------|
| **Android** | 6.0 (API 23) | ✅ Fully Supported |
| **iOS** | 12.0 | ✅ Fully Supported |

---

## 🏗️ Architecture

### Project Structure

```
LuminaLink/
├── android/                    # Android-specific code and configuration
├── ios/                        # iOS-specific code and configuration
├── lib/
│   ├── main.dart              # Application entry point
│   ├── models/                # Data models (User, Circle, Place, Location)
│   │   ├── app_user.dart
│   │   ├── circle.dart
│   │   ├── place.dart
│   │   ├── user_location.dart
│   │   └── models.dart        # Barrel export
│   ├── services/              # Business logic and backend integration
│   │   ├── auth_service.dart          # Firebase Authentication
│   │   ├── circle_service.dart        # Circle CRUD operations
│   │   ├── location_service.dart      # Location tracking & sharing
│   │   ├── place_service.dart         # Geofencing management
│   │   ├── notification_service.dart  # FCM & local notifications
│   │   └── geofence_service.dart      # Automated place monitoring
│   ├── screens/               # UI screens (organized by feature)
│   │   ├── auth/              # Login, signup, forgot password
│   │   ├── onboarding/        # First-time user experience
│   │   ├── circles/           # Circle list, create, join, details
│   │   ├── places/            # Place list, create/edit
│   │   ├── map/               # Real-time location map
│   │   ├── settings/          # Settings, profile, privacy dashboard
│   │   └── home_screen.dart   # Bottom navigation hub
│   ├── widgets/               # Reusable UI components
│   │   ├── platform_aware_button.dart
│   │   ├── platform_aware_dialog.dart
│   │   ├── platform_aware_loading.dart
│   │   ├── platform_aware_switch.dart
│   │   └── widgets.dart       # Barrel export
│   ├── theme/                 # Design system
│   │   ├── colors.dart        # Lumina color palette
│   │   ├── typography.dart    # Material 3 text styles
│   │   ├── spacing.dart       # 8-point grid system
│   │   └── theme.dart         # Complete theme configuration
│   ├── l10n/                  # Localization (inherited from Traccar)
│   └── utils/                 # Utility functions
├── firestore.rules            # Firestore security rules
├── .github/
│   └── PULL_REQUEST_TEMPLATE.md
└── pubspec.yaml               # Project dependencies
```

### Data Flow

```
User Action (UI)
    ↓
Screen/Widget
    ↓
Service Layer (Business Logic)
    ↓
Firebase/Backend
    ↓
Stream/Future
    ↓
StreamBuilder/FutureBuilder
    ↓
Updated UI
```

### Key Services

- **AuthService**: User authentication, profile management, FCM token registration
- **CircleService**: Circle CRUD, member management, invite code generation
- **LocationService**: Background geolocation, Firestore sync, privacy controls
- **PlaceService**: Geofence management, place CRUD, location containment checks
- **NotificationService**: FCM integration, local notifications, permission handling
- **GeofenceService**: Automated monitoring, entry/exit detection, notification debouncing

---

## 🧑‍💻 Development

### Code Quality Standards

LuminaLink adheres to the highest code quality standards:

- ✅ **Zero linting violations** (using `flutter_lints`)
- ✅ **Comprehensive documentation** (all public APIs documented)
- ✅ **Platform-adaptive UI** (Material 3 + Cupertino widgets)
- ✅ **Consistent code style** (dart format)
- ✅ **Privacy-first architecture** (security by design)

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests (when implemented)
flutter test integration_test
```

### Code Formatting

```bash
# Format all Dart files
dart format .

# Analyze code
flutter analyze
```

### Debugging

```bash
# Run with verbose logging
flutter run -v

# Run with specific flavor (if configured)
flutter run --flavor dev
flutter run --flavor prod

# Check background geolocation logs
# Android: Use logcat filtering for "TSLocationManager"
# iOS: Use Xcode console filtering for "TSLocationManager"
```

---

## 🤝 Contributing

We welcome contributions from the community! LuminaLink is built on the foundation of open-source collaboration.

Please read our [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md) before submitting changes. All contributions must:

- ✅ Pass all linting checks (`flutter analyze`)
- ✅ Include tests for new features
- ✅ Follow the established code style
- ✅ Include clear documentation
- ✅ Be tested on both Android and iOS (where applicable)

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 🔒 Privacy & Security

Privacy is not an afterthought—it's built into LuminaLink's DNA.

### Security Measures

- 🔐 **Firestore Security Rules**: Production-ready rules enforce role-based access
- 🎯 **Minimal Data Collection**: Only collect what's necessary for functionality
- 🚫 **No Third-Party Tracking**: Location never sold or shared with advertisers
- 👤 **User Control**: Granular privacy controls in settings
- 📜 **Transparent Practices**: Clear, human-readable privacy messaging in-app
- 🔒 **Firebase Security**: Leverages Firebase Auth and Firestore security
- ⏰ **Data Expiration**: Automatic cleanup of location data older than 24 hours

### Security Best Practices

- All sensitive data stored in Firestore with security rules
- FCM tokens managed securely
- API keys restricted by package/bundle ID and API scope
- No hardcoded secrets in source code
- HTTPS-only communication

For security issues, please create a private security advisory on GitHub or email security@luminalink.app.

---

## 📄 License

LuminaLink is licensed under the **Apache License 2.0**.

```
Copyright 2025 LuminaLink Contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

See [LICENSE.txt](LICENSE.txt) for the full license text.

---

## 🙏 Acknowledgments

LuminaLink is built upon the foundation of the [Traccar Client](https://github.com/traccar/traccar-client-android), an excellent open-source GPS tracking application created by Anton Tananaev. We are deeply grateful for the Traccar project and the broader open-source community.

Special thanks to:
- **Traccar Project** for the foundational codebase
- **Flutter Team** for the incredible framework
- **Firebase Team** for the backend infrastructure
- **Open Source Community** for countless packages and libraries

---

## 📬 Contact & Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/Nickalus12/LuminaLink/issues)
- **Discussions**: [Join the community](https://github.com/Nickalus12/LuminaLink/discussions)
- **Email**: support@luminalink.app (coming soon)

---

## 🗺️ Roadmap

### Phase 0: Foundation ✅ (Complete)
- [x] Professional documentation
- [x] GitHub best practices (PR template)
- [x] Apache 2.0 license

### Phase 1: Branding & UI/UX ✅ (Complete)
- [x] Rename project to LuminaLink
- [x] Implement "Lumina" design system (warm amber/teal theme)
- [x] Platform-adaptive theming (Material 3 + Cupertino)
- [x] Complete theme system (colors, typography, spacing)
- [x] Platform-aware widgets library

### Phase 2: Core Authentication & Circles ✅ (Complete)
- [x] Firebase Authentication integration
- [x] Email/password signup & login
- [x] Password reset & change
- [x] User profile management
- [x] Onboarding flow (5 screens)
- [x] Circle data model with role-based access
- [x] Circle CRUD operations
- [x] 6-character invite code system
- [x] Circle member management
- [x] Firestore security rules

### Phase 3: Location Sharing & Privacy ✅ (Complete)
- [x] Background geolocation integration
- [x] Real-time location sharing via Firestore
- [x] Circle-based location visibility
- [x] Privacy controls (enable/disable sharing)
- [x] Privacy dashboard showing circle access
- [x] Circle management UI (list, create, join, details)
- [x] Home screen with bottom navigation
- [x] Settings screen with profile editing

### Phase 4: Maps & Geofencing ✅ (Complete)
- [x] Google Maps integration with real-time markers
- [x] Circle filtering on map
- [x] Color-coded member markers
- [x] Member info bottom sheets
- [x] Place model with geofence logic
- [x] Place CRUD operations
- [x] Place management UI (list, create/edit)
- [x] Interactive map picker for places
- [x] Notification service (FCM + local)
- [x] Geofence monitoring service
- [x] Automated place entry/exit notifications
- [x] Notification debouncing (5-minute cooldown)

### Phase 5: Testing & Refinement 🔄 (Next)
- [ ] Unit tests for all services
- [ ] Widget tests for key components
- [ ] Integration tests for critical user flows
- [ ] Performance optimization
- [ ] Battery usage analysis and optimization
- [ ] Security audit of Firestore rules
- [ ] Accessibility audit (WCAG AA compliance)
- [ ] Code coverage >80%

### Phase 6: Production Polish 🚀 (Planned)
- [ ] App icons and splash screens
- [ ] Store screenshots and promotional materials
- [ ] Privacy policy page
- [ ] Terms of service page
- [ ] User onboarding improvements
- [ ] Crash reporting with Firebase Crashlytics
- [ ] Analytics dashboard
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Beta testing program
- [ ] App Store submission
- [ ] Google Play submission

### Future Enhancements 💡
- [ ] In-app chat between circle members
- [ ] Location history playback
- [ ] Battery level indicators on map
- [ ] Driving vs walking activity detection
- [ ] Offline mode with local storage
- [ ] Multi-language support (i18n)
- [ ] Dark mode auto-switching
- [ ] Custom circle icons
- [ ] Emergency SOS button
- [ ] Location sharing time limits
- [ ] Anonymous mode for temporary hiding

---

## 📊 Project Stats

- **Lines of Code**: ~10,000+
- **Screens**: 17
- **Services**: 6
- **Models**: 4
- **Platform Widgets**: 4
- **Development Time**: 2 weeks
- **Status**: Feature-complete core app

---

## 🎯 Current Status

**LuminaLink is feature-complete** with all core functionality implemented and ready for testing:

✅ **User Authentication** - Email/password auth with Firebase
✅ **Circle Management** - Create, join, invite, manage members
✅ **Real-Time Location** - Background tracking with Firestore sync
✅ **Google Maps Integration** - Live member locations with filtering
✅ **Place Alerts** - Geofencing with automated notifications
✅ **Privacy Controls** - Granular settings and dashboard
✅ **Push Notifications** - FCM with local notification display
✅ **Platform-Adaptive UI** - Native feel on Android and iOS

**Next Steps**: Testing, refinement, and production polish before store submission.

---

<p align="center">
  <strong>Made with ❤️ by developers who believe privacy matters</strong>
</p>

<p align="center">
  <a href="https://github.com/Nickalus12/LuminaLink/stargazers">⭐ Star this repo</a> if you believe in privacy-first family safety!
</p>
