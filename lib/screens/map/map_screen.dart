import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/services/location_service.dart';
import 'package:luminalink/theme/spacing.dart';

/// Map screen - Shows real-time locations of circle members
///
/// Displays a Google Map with the current user's location and the locations
/// of all members in their circles. Provides filtering and member info.
///
/// Setup Requirements:
/// - Add Google Maps API key to AndroidManifest.xml and Info.plist
/// - Enable Maps SDK for Android and iOS in Google Cloud Console
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final AuthService _authService = AuthService();
  final CircleService _circleService = CircleService();
  final LocationService _locationService = LocationService();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  // Filter state - track which circles are visible on the map
  final Set<String> _visibleCircleIds = {};

  // Current user location
  UserLocation? _myLocation;
  String? _currentUserId;

  // Map camera
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco default
    zoom: 12.0,
  );

  // Stream subscriptions
  StreamSubscription<List<Circle>>? _circlesSubscription;
  final Map<String, StreamSubscription<Map<String, UserLocation>>> _locationSubscriptions = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _circlesSubscription?.cancel();
    for (final subscription in _locationSubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }

  Future<void> _initializeMap() async {
    // Get current user
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    setState(() {
      _currentUserId = user.uid;
    });

    // Get user's location
    final myLocation = await _locationService.getMyLocation();
    if (myLocation != null && mounted) {
      setState(() {
        _myLocation = myLocation;
      });

      // Center map on user's location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(myLocation.latitude, myLocation.longitude),
          14.0,
        ),
      );
    }

    // Listen to circles and set up location subscriptions
    _circlesSubscription = _circleService.getMyCirclesStream().listen((circles) {
      // Initialize visible circles (all visible by default)
      if (_visibleCircleIds.isEmpty) {
        _visibleCircleIds.addAll(circles.map((c) => c.id));
      }

      // Set up location subscriptions for each circle
      for (final circle in circles) {
        if (!_locationSubscriptions.containsKey(circle.id)) {
          _locationSubscriptions[circle.id] = _locationService
              .getCircleMemberLocationsStream(circle.id)
              .listen((locations) {
            if (mounted) {
              _updateMarkers(circle, locations);
            }
          });
        }
      }

      // Clean up subscriptions for circles that no longer exist
      final circleIds = circles.map((c) => c.id).toSet();
      final idsToRemove = _locationSubscriptions.keys
          .where((id) => !circleIds.contains(id))
          .toList();
      for (final id in idsToRemove) {
        _locationSubscriptions[id]?.cancel();
        _locationSubscriptions.remove(id);
      }
    });
  }

  void _updateMarkers(Circle circle, Map<String, UserLocation> locations) {
    final newMarkers = <Marker>{};

    // Only show markers for visible circles
    if (!_visibleCircleIds.contains(circle.id)) {
      setState(() {
        // Remove markers from this circle
        _markers = _markers.where((marker) {
          return !marker.markerId.value.startsWith('${circle.id}_');
        }).toSet();
      });
      return;
    }

    // Add marker for each member location
    for (final entry in locations.entries) {
      final userId = entry.key;
      final location = entry.value;

      // Skip if location is stale (older than 1 hour)
      if (location.isStale) continue;

      // Skip current user (shown differently)
      if (userId == _currentUserId) continue;

      final marker = Marker(
        markerId: MarkerId('${circle.id}_$userId'),
        position: LatLng(location.latitude, location.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getHueForCircle(circle),
        ),
        infoWindow: InfoWindow(
          title: location.userId, // TODO: Fetch user display name
          snippet: '${location.timeAgo} • ${location.accuracy.toStringAsFixed(0)}m accuracy',
        ),
        onTap: () => _onMarkerTapped(userId, location),
      );

      newMarkers.add(marker);
    }

    // Add current user marker (blue)
    if (_myLocation != null) {
      final myMarker = Marker(
        markerId: const MarkerId('current_user'),
        position: LatLng(_myLocation!.latitude, _myLocation!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'You',
          snippet: 'Your current location',
        ),
      );
      newMarkers.add(myMarker);
    }

    setState(() {
      // Merge new markers with existing ones from other circles
      _markers = {
        ..._markers.where((marker) {
          // Keep markers from other circles
          return !marker.markerId.value.startsWith('${circle.id}_') &&
                 marker.markerId.value != 'current_user';
        }),
        ...newMarkers,
      };
    });
  }

  double _getHueForCircle(Circle circle) {
    // Convert circle color to HSV hue for marker color
    final color = circle.iconColorParsed;
    final hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue;
  }

  void _onMarkerTapped(String userId, UserLocation location) {
    // TODO: Show bottom sheet with member details
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildMemberInfoSheet(userId, location),
    );
  }

  Widget _buildMemberInfoSheet(String userId, UserLocation location) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(LuminaSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.person),
                ),
                SizedBox(width: LuminaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userId, // TODO: Fetch display name
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        location.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: LuminaSpacing.lg),
            _buildInfoRow(
              Icons.location_on,
              'Location',
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
            ),
            _buildInfoRow(
              Icons.speed,
              'Speed',
              location.speed != null
                  ? '${(location.speed! * 3.6).toStringAsFixed(1)} km/h'
                  : 'Unknown',
            ),
            _buildInfoRow(
              Icons.explore,
              'Accuracy',
              '±${location.accuracy.toStringAsFixed(0)}m',
            ),
            if (location.batteryLevel != null)
              _buildInfoRow(
                Icons.battery_std,
                'Battery',
                '${(location.batteryLevel! * 100).toStringAsFixed(0)}%',
              ),
            SizedBox(height: LuminaSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _centerMapOn(location);
                },
                icon: const Icon(Icons.center_focus_strong),
                label: const Text('Center on Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: LuminaSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: LuminaSpacing.sm),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _centerMapOn(UserLocation location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(location.latitude, location.longitude),
        16.0,
      ),
    );
  }

  void _centerOnMyLocation() {
    if (_myLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_myLocation!.latitude, _myLocation!.longitude),
          14.0,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available yet'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Circles',
            onPressed: _showCircleFilter,
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

          return Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: (controller) {
                  _mapController = controller;

                  // Center on user location if available
                  if (_myLocation != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(_myLocation!.latitude, _myLocation!.longitude),
                        14.0,
                      ),
                    );
                  }
                },
                markers: _markers,
                circles: _circles,
                myLocationEnabled: false, // We show custom marker instead
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                buildingsEnabled: true,
                trafficEnabled: false,
              ),

              // Floating info card at top
              Positioned(
                top: LuminaSpacing.sm,
                left: LuminaSpacing.md,
                right: LuminaSpacing.md,
                child: _buildInfoCard(circles),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnMyLocation,
        tooltip: 'Center on my location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildInfoCard(List<Circle> circles) {
    final visibleCirclesCount = circles
        .where((c) => _visibleCircleIds.contains(c.id))
        .length;
    final totalMembers = _markers.length;

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: LuminaSpacing.md,
          vertical: LuminaSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: LuminaSpacing.sm),
            Text(
              '$visibleCirclesCount ${visibleCirclesCount == 1 ? 'circle' : 'circles'} • $totalMembers ${totalMembers == 1 ? 'member' : 'members'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
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

  void _showCircleFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(LuminaSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Circles',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // Toggle all circles
                            setModalState(() {
                              if (_visibleCircleIds.isEmpty) {
                                // Show all
                                _circleService.getMyCircles().then((circles) {
                                  setState(() {
                                    _visibleCircleIds.addAll(circles.map((c) => c.id));
                                  });
                                  setModalState(() {});
                                });
                              } else {
                                // Hide all
                                setState(() {
                                  _visibleCircleIds.clear();
                                });
                              }
                            });
                          },
                          child: Text(
                            _visibleCircleIds.isEmpty ? 'Show All' : 'Hide All',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: LuminaSpacing.md),
                    StreamBuilder<List<Circle>>(
                      stream: _circleService.getMyCirclesStream(),
                      builder: (context, snapshot) {
                        final circles = snapshot.data ?? [];
                        return Column(
                          children: circles.map((circle) {
                            final isVisible = _visibleCircleIds.contains(circle.id);

                            return CheckboxListTile(
                              value: isVisible,
                              onChanged: (value) {
                                setModalState(() {
                                  setState(() {
                                    if (value == true) {
                                      _visibleCircleIds.add(circle.id);
                                    } else {
                                      _visibleCircleIds.remove(circle.id);
                                    }
                                  });
                                });

                                // Refresh markers
                                _locationService
                                    .getCircleMemberLocations(circle.id)
                                    .then((locations) {
                                  _updateMarkers(circle, locations);
                                });
                              },
                              title: Text(circle.name),
                              subtitle: Text('${circle.memberCount} members'),
                              secondary: Icon(
                                Icons.circle,
                                color: circle.iconColorParsed,
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
      },
    );
  }
}
