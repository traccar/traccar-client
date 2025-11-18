import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:luminalink/screens/map/map_screen.dart';
import 'package:luminalink/screens/circles/circles_screen.dart';
import 'package:luminalink/screens/settings/settings_screen.dart';
import 'package:luminalink/services/location_service.dart';
import 'package:luminalink/services/notification_service.dart';
import 'package:luminalink/services/geofence_service.dart';

/// Home screen with bottom navigation
///
/// Main navigation hub with tabs for:
/// - Map: Real-time member locations
/// - Circles: Circle management
/// - Settings: App settings and profile
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final GeofenceService _geofenceService = GeofenceService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _geofenceService.stopMonitoring();
    super.dispose();
  }

  /// Initialize all location and notification services
  ///
  /// Sets up:
  /// - Background location sharing with Firestore
  /// - Push notifications via FCM
  /// - Geofence monitoring for place alerts
  Future<void> _initializeServices() async {
    // Initialize location sharing
    await _locationService.initializeLocationSharing();

    // Initialize notifications
    await _notificationService.initialize();

    // Start geofence monitoring
    await _geofenceService.startMonitoring();
  }

  final List<Widget> _screens = const [
    MapScreen(),
    CirclesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group),
              label: 'Circles',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) => _screens[index],
          );
        },
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Circles',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
