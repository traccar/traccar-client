import 'package:flutter/material.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/theme/spacing.dart';

/// Map screen - Shows real-time locations of circle members
///
/// Displays a map with the current user's location and the locations
/// of all members in their circles. Provides quick access to circle info.
///
/// Note: Google Maps integration requires additional setup:
/// - Add API key to AndroidManifest.xml and Info.plist
/// - Enable Maps SDK for Android and iOS in Google Cloud Console
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _authService = AuthService();
  final _circleService = CircleService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Circles',
            onPressed: () {
              _showCircleFilter();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Circle>>(
        stream: _circleService.getMyCirclesStream(),
        builder: (context, circlesSnapshot) {
          if (circlesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final circles = circlesSnapshot.data ?? [];

          if (circles.isEmpty) {
            return _buildEmptyState();
          }

          // TODO: Integrate Google Maps
          // For now, show a placeholder with member list
          return _buildPlaceholderMap(circles);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Center map on current user location
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Centering on your location...'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: LuminaSpacing.lg),
            Text(
              'No Circles Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: LuminaSpacing.sm),
            Text(
              'Create or join a circle to see member locations on the map.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderMap(List<Circle> circles) {
    return Column(
      children: [
        // Map placeholder
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: LuminaSpacing.md),
                  Text(
                    'Google Maps Integration',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  SizedBox(height: LuminaSpacing.sm),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: LuminaSpacing.xl),
                    child: Text(
                      'Map will show real-time locations of ${circles.length} ${circles.length == 1 ? 'circle' : 'circles'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Circle list at bottom
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(LuminaSpacing.sm),
            itemCount: circles.length,
            itemBuilder: (context, index) {
              final circle = circles[index];
              final iconColor = circle.iconColor != null
                  ? Color(int.parse(circle.iconColor!.replaceFirst('#', '0xFF')))
                  : Theme.of(context).colorScheme.primary;

              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: LuminaSpacing.sm,
                  vertical: LuminaSpacing.xs,
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                  title: Text(circle.name),
                  subtitle: Text('${circle.memberCount} members'),
                  trailing: Icon(
                    Icons.visibility,
                    color: iconColor,
                  ),
                  dense: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCircleFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(LuminaSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Circles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: LuminaSpacing.md),
                StreamBuilder<List<Circle>>(
                  stream: _circleService.getMyCirclesStream(),
                  builder: (context, snapshot) {
                    final circles = snapshot.data ?? [];
                    return Column(
                      children: circles.map((circle) {
                        final iconColor = circle.iconColor != null
                            ? Color(int.parse(circle.iconColor!.replaceFirst('#', '0xFF')))
                            : Theme.of(context).colorScheme.primary;

                        return CheckboxListTile(
                          value: true, // TODO: Implement filter state
                          onChanged: (value) {
                            // TODO: Implement filter toggling
                          },
                          title: Text(circle.name),
                          secondary: Icon(
                            Icons.circle,
                            color: iconColor,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
