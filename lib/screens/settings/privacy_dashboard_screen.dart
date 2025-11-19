import 'package:flutter/material.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/services/location_service.dart';
import 'package:luminalink/theme/spacing.dart';
import 'package:luminalink/widgets/widgets.dart';

/// Privacy dashboard screen
///
/// Shows the user which circles can see their location and provides
/// granular privacy controls.
class PrivacyDashboardScreen extends StatefulWidget {
  const PrivacyDashboardScreen({super.key});

  @override
  State<PrivacyDashboardScreen> createState() => _PrivacyDashboardScreenState();
}

class _PrivacyDashboardScreenState extends State<PrivacyDashboardScreen> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final CircleService _circleService = CircleService();

  bool _isLoading = true;
  bool _isLocationSharingEnabled = false;
  List<Circle> _circles = [];
  UserLocation? _myLocation;

  @override
  void initState() {
    super.initState();
    _loadPrivacyData();
  }

  Future<void> _loadPrivacyData() async {
    setState(() => _isLoading = true);

    try {
      final isEnabled = await _locationService.isLocationSharingEnabled();
      final circles = await _circleService.getMyCircles();
      final location = await _locationService.getMyLocation();

      if (mounted) {
        setState(() {
          _isLocationSharingEnabled = isEnabled;
          _circles = circles;
          _myLocation = location;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load privacy data: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: PlatformAwareLoading())
          : RefreshIndicator(
              onRefresh: _loadPrivacyData,
              child: ListView(
                padding: EdgeInsets.all(LuminaSpacing.lg),
                children: [
                  // Privacy status card
                  _buildPrivacyStatusCard(),
                  SizedBox(height: LuminaSpacing.lg),

                  // Location sharing status
                  if (_isLocationSharingEnabled) ...[
                    _buildLocationStatusCard(),
                    SizedBox(height: LuminaSpacing.lg),
                  ],

                  // Circles section
                  _buildSectionHeader('Circles With Access'),
                  SizedBox(height: LuminaSpacing.sm),

                  if (_circles.isEmpty)
                    _buildEmptyCirclesCard()
                  else
                    ..._circles.map(_buildCircleCard),

                  SizedBox(height: LuminaSpacing.lg),

                  // Privacy principles
                  _buildPrivacyPrinciplesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildPrivacyStatusCard() {
    final color = _isLocationSharingEnabled
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    final textColor = _isLocationSharingEnabled
        ? Theme.of(context).colorScheme.onTertiaryContainer
        : Theme.of(context).colorScheme.onSurface;

    return Card(
      color: _isLocationSharingEnabled
          ? Theme.of(context).colorScheme.tertiaryContainer
          : null,
      child: Padding(
        padding: EdgeInsets.all(LuminaSpacing.md),
        child: Column(
          children: [
            Icon(
              _isLocationSharingEnabled
                  ? Icons.shield_outlined
                  : Icons.location_off_outlined,
              size: 48,
              color: color,
            ),
            SizedBox(height: LuminaSpacing.md),
            Text(
              _isLocationSharingEnabled
                  ? 'Location Sharing Active'
                  : 'Location Sharing Disabled',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LuminaSpacing.xs),
            Text(
              _isLocationSharingEnabled
                  ? 'Your location is visible to ${_circles.length} ${_circles.length == 1 ? 'circle' : 'circles'}'
                  : 'Your location is not being shared with anyone',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatusCard() {
    if (_myLocation == null) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(LuminaSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.location_searching,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(width: LuminaSpacing.md),
              const Expanded(
                child: Text('Waiting for first location update...'),
              ),
            ],
          ),
        ),
      );
    }

    final isFresh = _myLocation!.isFresh;
    final statusColor = isFresh
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.error;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(LuminaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFresh ? Icons.check_circle : Icons.warning,
                  color: statusColor,
                  size: 20,
                ),
                SizedBox(width: LuminaSpacing.sm),
                Text(
                  'Last Location Update',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: LuminaSpacing.sm),
            Text(
              _myLocation!.timeAgo,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: LuminaSpacing.xs),
            Text(
              'Accuracy: ${_myLocation!.accuracy.toStringAsFixed(0)}m',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEmptyCirclesCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(LuminaSpacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.group_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            SizedBox(height: LuminaSpacing.md),
            Text(
              'No Circles Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: LuminaSpacing.xs),
            Text(
              'Create or join a circle to start sharing your location',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleCard(Circle circle) {
    final memberCount = circle.memberIds.length;

    return Card(
      margin: EdgeInsets.only(bottom: LuminaSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: circle.iconColorParsed.withOpacity(0.2),
          child: Icon(
            Icons.group,
            color: circle.iconColorParsed,
          ),
        ),
        title: Text(
          circle.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$memberCount ${memberCount == 1 ? 'member' : 'members'} can see your location',
        ),
        trailing: Icon(
          Icons.visibility,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }

  Widget _buildPrivacyPrinciplesCard() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.all(LuminaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: LuminaSpacing.sm),
                Text(
                  'Privacy Principles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            SizedBox(height: LuminaSpacing.md),
            _buildPrincipleItem(
              Icons.lock_outline,
              'End-to-End Encryption',
              'Your location data is encrypted at all times',
            ),
            _buildPrincipleItem(
              Icons.visibility_off_outlined,
              'No Third-Party Sharing',
              'We never share or sell your data to advertisers',
            ),
            _buildPrincipleItem(
              Icons.delete_outline,
              'Automatic Cleanup',
              'Old location data is automatically deleted after 24 hours',
            ),
            _buildPrincipleItem(
              Icons.power_settings_new,
              'Full Control',
              'You can disable location sharing at any time',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrincipleItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: LuminaSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
}
