import 'package:flutter/material.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/place_service.dart';
import 'package:luminalink/theme/spacing.dart';
import 'package:luminalink/widgets/widgets.dart';
import 'package:luminalink/screens/places/create_place_screen.dart';

/// Places list screen for a circle
///
/// Shows all geofenced places (Home, School, Work, etc.) for a circle
/// with the ability to add, edit, and delete places.
class PlacesListScreen extends StatefulWidget {
  final Circle circle;

  const PlacesListScreen({
    super.key,
    required this.circle,
  });

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  final PlaceService _placeService = PlaceService();

  Future<void> _deletePlace(Place place) async {
    final confirmed = await PlatformAwareDialog.show<bool>(
      context: context,
      title: 'Delete Place?',
      content: 'Are you sure you want to delete "${place.name}"? '
          'This will remove the place for all circle members.',
      actions: [
        PlatformDialogAction(
          text: 'Cancel',
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, false),
        ),
        PlatformDialogAction(
          text: 'Delete',
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );

    if (confirmed == true) {
      try {
        await _placeService.deletePlace(place.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${place.name}" deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete place: ${e.toString()}'),
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
        title: Text('${widget.circle.name} Places'),
      ),
      body: StreamBuilder<List<Place>>(
        stream: _placeService.getCirclePlacesStream(widget.circle.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PlatformAwareLoading());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(LuminaSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(height: LuminaSpacing.md),
                    Text(
                      'Failed to load places',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: LuminaSpacing.sm),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final places = snapshot.data ?? [];

          if (places.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(LuminaSpacing.md),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return _buildPlaceCard(place);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePlaceScreen(circle: widget.circle),
            ),
          );
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Add Place'),
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
              Icons.location_city_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            SizedBox(height: LuminaSpacing.lg),
            Text(
              'No Places Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: LuminaSpacing.sm),
            Text(
              'Add important locations like Home, School, or Work to receive '
              'alerts when circle members arrive or leave.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LuminaSpacing.xl),
            FilledButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePlaceScreen(circle: widget.circle),
                  ),
                );
              },
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add Your First Place'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place) {
    // Parse color or use default
    Color placeColor;
    try {
      placeColor = place.color != null && place.color!.isNotEmpty
          ? Color(int.parse(place.color!.replaceFirst('#', '0xFF')))
          : Theme.of(context).colorScheme.primary;
    } catch (e) {
      placeColor = Theme.of(context).colorScheme.primary;
    }

    // Determine icon
    final icon = _getIconForPlace(place.icon);

    return Card(
      margin: EdgeInsets.only(bottom: LuminaSpacing.md),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePlaceScreen(
                circle: widget.circle,
                placeToEdit: place,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(LuminaSpacing.borderRadiusMd),
        child: Padding(
          padding: EdgeInsets.all(LuminaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: placeColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: placeColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: LuminaSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (place.description != null && place.description!.isNotEmpty)
                          Text(
                            place.description!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => _deletePlace(place),
                    tooltip: 'Delete place',
                  ),
                ],
              ),
              SizedBox(height: LuminaSpacing.sm),
              Divider(height: 1),
              SizedBox(height: LuminaSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(width: LuminaSpacing.xs),
                  Expanded(
                    child: Text(
                      '${place.latitude.toStringAsFixed(5)}, ${place.longitude.toStringAsFixed(5)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: LuminaSpacing.sm,
                      vertical: LuminaSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: placeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(LuminaSpacing.borderRadiusSm),
                    ),
                    child: Text(
                      '${place.radius.toStringAsFixed(0)}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: placeColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: LuminaSpacing.xs),
              Row(
                children: [
                  if (place.notifyOnEnter) ...[
                    Icon(
                      Icons.login,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    SizedBox(width: LuminaSpacing.xxs),
                    Text(
                      'Arrive',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: LuminaSpacing.sm),
                  ],
                  if (place.notifyOnExit) ...[
                    Icon(
                      Icons.logout,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    SizedBox(width: LuminaSpacing.xxs),
                    Text(
                      'Leave',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (!place.notifyOnEnter && !place.notifyOnExit) ...[
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                    SizedBox(width: LuminaSpacing.xxs),
                    Text(
                      'No notifications',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4),
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForPlace(String? iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_bag;
      case 'restaurant':
        return Icons.restaurant;
      case 'gym':
        return Icons.fitness_center;
      case 'hospital':
        return Icons.local_hospital;
      case 'park':
        return Icons.park;
      default:
        return Icons.place;
    }
  }
}
