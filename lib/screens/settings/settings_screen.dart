import 'package:flutter/material.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/services/location_service.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/theme/spacing.dart';
import 'package:luminalink/widgets/widgets.dart';
import 'package:luminalink/screens/settings/edit_profile_screen.dart';
import 'package:luminalink/screens/settings/privacy_dashboard_screen.dart';

/// Settings screen for LuminaLink
///
/// Provides access to:
/// - Privacy controls (location sharing toggle)
/// - Profile management
/// - Account settings
/// - App information
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final CircleService _circleService = CircleService();

  bool _isLocationSharingEnabled = false;
  bool _isLoadingLocationStatus = true;
  AppUser? _currentUser;
  List<Circle> _circles = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLocationSharingStatus();
    _loadCircles();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadLocationSharingStatus() async {
    setState(() => _isLoadingLocationStatus = true);
    final isEnabled = await _locationService.isLocationSharingEnabled();
    if (mounted) {
      setState(() {
        _isLocationSharingEnabled = isEnabled;
        _isLoadingLocationStatus = false;
      });
    }
  }

  Future<void> _loadCircles() async {
    final circles = await _circleService.getMyCircles();
    if (mounted) {
      setState(() {
        _circles = circles;
      });
    }
  }

  Future<void> _toggleLocationSharing(bool value) async {
    try {
      setState(() => _isLoadingLocationStatus = true);

      if (value) {
        await _locationService.enableLocationSharing();
      } else {
        // Show confirmation dialog before disabling
        final confirmed = await _showDisableConfirmationDialog();
        if (!confirmed) {
          setState(() => _isLoadingLocationStatus = false);
          return;
        }
        await _locationService.disableLocationSharing();
      }

      setState(() {
        _isLocationSharingEnabled = value;
        _isLoadingLocationStatus = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Location sharing enabled'
                  : 'Location sharing disabled',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingLocationStatus = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update location sharing: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<bool> _showDisableConfirmationDialog() async {
    final result = await PlatformAwareDialog.show<bool>(
      context: context,
      title: 'Disable Location Sharing?',
      content: 'Your location will no longer be visible to your circles. '
          'You can re-enable this anytime in settings.',
      actions: [
        PlatformDialogAction(
          text: 'Cancel',
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, false),
        ),
        PlatformDialogAction(
          text: 'Disable',
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    return result ?? false;
  }

  Future<void> _signOut() async {
    final confirmed = await PlatformAwareDialog.show<bool>(
      context: context,
      title: 'Sign Out?',
      content: 'Are you sure you want to sign out?',
      actions: [
        PlatformDialogAction(
          text: 'Cancel',
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, false),
        ),
        PlatformDialogAction(
          text: 'Sign Out',
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
        // Navigation handled by AuthWrapper
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _currentUser == null
          ? const Center(child: PlatformAwareLoading())
          : ListView(
              children: [
                // Profile Section
                _buildProfileHeader(),
                SizedBox(height: LuminaSpacing.md),

                // Privacy Controls Section
                _buildSectionHeader('Privacy & Location'),
                _buildLocationSharingTile(),
                _buildPrivacyDashboardTile(),
                SizedBox(height: LuminaSpacing.md),

                // Account Section
                _buildSectionHeader('Account'),
                _buildEditProfileTile(),
                _buildChangePasswordTile(),
                _buildSignOutTile(),
                SizedBox(height: LuminaSpacing.md),

                // About Section
                _buildSectionHeader('About'),
                _buildAboutTile(),
                _buildPrivacyPolicyTile(),
                SizedBox(height: LuminaSpacing.lg),

                // Version info
                _buildVersionInfo(),
                SizedBox(height: LuminaSpacing.xl),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(LuminaSpacing.lg),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              _currentUser?.initials ?? '?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(width: LuminaSpacing.md),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.displayName ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: LuminaSpacing.xxs),
                Text(
                  _currentUser?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        LuminaSpacing.lg,
        LuminaSpacing.md,
        LuminaSpacing.lg,
        LuminaSpacing.xs,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildLocationSharingTile() {
    return SwitchListTile(
      title: const Text('Location Sharing'),
      subtitle: Text(
        _isLocationSharingEnabled
            ? 'Your location is visible to ${_circles.length} ${_circles.length == 1 ? 'circle' : 'circles'}'
            : 'Location sharing is disabled',
      ),
      secondary: Icon(
        _isLocationSharingEnabled
            ? Icons.location_on
            : Icons.location_off_outlined,
      ),
      value: _isLocationSharingEnabled,
      onChanged: _isLoadingLocationStatus ? null : _toggleLocationSharing,
    );
  }

  Widget _buildPrivacyDashboardTile() {
    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: const Text('Privacy Dashboard'),
      subtitle: const Text('See who can view your location'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrivacyDashboardScreen(),
          ),
        );
        // Reload circles in case they changed
        _loadCircles();
      },
    );
  }

  Widget _buildEditProfileTile() {
    return ListTile(
      leading: const Icon(Icons.person_outline),
      title: const Text('Edit Profile'),
      subtitle: const Text('Update your display name'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditProfileScreen(),
          ),
        );
        if (updated == true) {
          _loadUserData();
        }
      },
    );
  }

  Widget _buildChangePasswordTile() {
    return ListTile(
      leading: const Icon(Icons.lock_outline),
      title: const Text('Change Password'),
      subtitle: const Text('Update your account password'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final result = await _showChangePasswordDialog();
        if (result == true && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully')),
          );
        }
      },
    );
  }

  Future<bool?> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              SizedBox(height: LuminaSpacing.md),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return 'Must be at least 8 characters';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Must contain uppercase letter';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Must contain number';
                  }
                  return null;
                },
              ),
              SizedBox(height: LuminaSpacing.md),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await _authService.changePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to change password: ${e.toString()}'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutTile() {
    return ListTile(
      leading: Icon(
        Icons.logout,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(
        'Sign Out',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      onTap: _signOut,
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('About LuminaLink'),
      subtitle: const Text('Learn more about our app'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'LuminaLink',
          applicationVersion: '1.0.0',
          applicationIcon: Icon(
            Icons.family_restroom_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            const Text(
              'Stay connected with your family and friends through safe, '
              'private location sharing.',
            ),
            SizedBox(height: LuminaSpacing.md),
            const Text(
              'LuminaLink is designed with privacy first. Your location data '
              'is encrypted and only shared with circles you create.',
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrivacyPolicyTile() {
    return ListTile(
      leading: const Icon(Icons.policy_outlined),
      title: const Text('Privacy Policy'),
      subtitle: const Text('How we protect your data'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Open privacy policy URL
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Privacy policy will be available soon'),
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Text(
        'LuminaLink v1.0.0',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
      ),
    );
  }
}
