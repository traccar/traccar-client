import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/place_service.dart';
import 'package:luminalink/theme/spacing.dart';
import 'package:luminalink/widgets/widgets.dart';

/// Create or edit a place
///
/// Allows users to create new places or edit existing ones for a circle.
/// Includes a map picker for selecting the location and radius.
class CreatePlaceScreen extends StatefulWidget {
  final Circle circle;
  final Place? placeToEdit;

  const CreatePlaceScreen({
    super.key,
    required this.circle,
    this.placeToEdit,
  });

  @override
  State<CreatePlaceScreen> createState() => _CreatePlaceScreenState();
}

class _CreatePlaceScreenState extends State<CreatePlaceScreen> {
  final PlaceService _placeService = PlaceService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  GoogleMapController? _mapController;

  // Place properties
  LatLng? _selectedLocation;
  double _radius = 100.0; // Default 100 meters
  String _selectedIcon = 'place';
  String _selectedColor = '#F59E0B'; // Default amber
  bool _notifyOnEnter = true;
  bool _notifyOnExit = true;

  bool _isSaving = false;
  bool _isLoadingCurrentLocation = false;

  // Available icons for places
  final List<Map<String, dynamic>> _iconOptions = [
    {'name': 'place', 'icon': Icons.place, 'label': 'Place'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Home'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Work'},
    {'name': 'school', 'icon': Icons.school, 'label': 'School'},
    {'name': 'shopping', 'icon': Icons.shopping_bag, 'label': 'Shopping'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Restaurant'},
    {'name': 'gym', 'icon': Icons.fitness_center, 'label': 'Gym'},
    {'name': 'hospital', 'icon': Icons.local_hospital, 'label': 'Hospital'},
    {'name': 'park', 'icon': Icons.park, 'label': 'Park'},
  ];

  // Available colors
  final List<Color> _colorOptions = [
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFFF97316), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeForm() {
    if (widget.placeToEdit != null) {
      // Edit mode - populate with existing data
      final place = widget.placeToEdit!;
      _nameController.text = place.name;
      _descriptionController.text = place.description ?? '';
      _selectedLocation = LatLng(place.latitude, place.longitude);
      _radius = place.radius;
      _selectedIcon = place.icon ?? 'place';
      _selectedColor = place.color ?? '#F59E0B';
      _notifyOnEnter = place.notifyOnEnter;
      _notifyOnExit = place.notifyOnExit;
    } else {
      // Create mode - load current location
      _loadCurrentLocation();
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingCurrentLocation = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _isLoadingCurrentLocation = false;
        });

        // Move map camera to current location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_selectedLocation!, 15.0),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCurrentLocation = false);
        // Default to San Francisco if location fails
        _selectedLocation = const LatLng(37.7749, -122.4194);
      }
    }
  }

  Future<void> _savePlace() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.placeToEdit != null) {
        // Update existing place
        await _placeService.updatePlace(
          widget.placeToEdit!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          radius: _radius,
          icon: _selectedIcon,
          color: _selectedColor,
          notifyOnEnter: _notifyOnEnter,
          notifyOnExit: _notifyOnExit,
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Place updated successfully')),
          );
        }
      } else {
        // Create new place
        await _placeService.createPlace(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          circleId: widget.circle.id,
          latitude: _selectedLocation!.latitude,
          longitude: _selectedLocation!.longitude,
          radius: _radius,
          icon: _selectedIcon,
          color: _selectedColor,
          notifyOnEnter: _notifyOnEnter,
          notifyOnExit: _notifyOnExit,
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Place created successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save place: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.placeToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Place' : 'Create Place'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Map selector
              SizedBox(
                height: 300,
                child: _selectedLocation == null
                    ? const Center(child: PlatformAwareLoading())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation!,
                          zoom: 15.0,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: (position) {
                          setState(() {
                            _selectedLocation = position;
                          });
                        },
                        markers: _selectedLocation == null
                            ? {}
                            : {
                                Marker(
                                  markerId: const MarkerId('selected_location'),
                                  position: _selectedLocation!,
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueOrange,
                                  ),
                                ),
                              },
                        circles: _selectedLocation == null
                            ? {}
                            : {
                                Circle(
                                  circleId: const CircleId('geofence_radius'),
                                  center: _selectedLocation!,
                                  radius: _radius,
                                  fillColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  strokeColor: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 2,
                                ),
                              },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                      ),
              ),
              if (_isLoadingCurrentLocation)
                Container(
                  padding: EdgeInsets.all(LuminaSpacing.sm),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: LuminaSpacing.sm),
                      const Text('Loading current location...'),
                    ],
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(LuminaSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location hint
                    Container(
                      padding: EdgeInsets.all(LuminaSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                          LuminaSpacing.borderRadiusSm,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: LuminaSpacing.sm),
                          const Expanded(
                            child: Text(
                              'Tap the map to set the place location',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: LuminaSpacing.lg),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Place Name',
                        hintText: 'e.g., Home, Work, School',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: LuminaSpacing.md),

                    // Description field
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'e.g., Our family home',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: LuminaSpacing.lg),

                    // Radius slider
                    Text(
                      'Geofence Radius',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: LuminaSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _radius,
                            min: 50.0,
                            max: 500.0,
                            divisions: 9,
                            label: '${_radius.toInt()}m',
                            onChanged: (value) {
                              setState(() {
                                _radius = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: LuminaSpacing.sm),
                        Container(
                          width: 80,
                          padding: EdgeInsets.symmetric(
                            horizontal: LuminaSpacing.sm,
                            vertical: LuminaSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              LuminaSpacing.borderRadiusSm,
                            ),
                          ),
                          child: Text(
                            '${_radius.toInt()}m',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: LuminaSpacing.lg),

                    // Icon selector
                    Text(
                      'Icon',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: LuminaSpacing.sm),
                    Wrap(
                      spacing: LuminaSpacing.sm,
                      runSpacing: LuminaSpacing.sm,
                      children: _iconOptions.map((option) {
                        final isSelected = _selectedIcon == option['name'];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIcon = option['name'] as String;
                            });
                          },
                          borderRadius: BorderRadius.circular(
                            LuminaSpacing.borderRadiusSm,
                          ),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                LuminaSpacing.borderRadiusSm,
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  option['icon'] as IconData,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                  size: 24,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  option['label'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: LuminaSpacing.lg),

                    // Color selector
                    Text(
                      'Color',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: LuminaSpacing.sm),
                    Wrap(
                      spacing: LuminaSpacing.sm,
                      children: _colorOptions.map((color) {
                        final colorHex =
                            '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                        final isSelected = _selectedColor == colorHex;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedColor = colorHex;
                            });
                          },
                          borderRadius: BorderRadius.circular(
                            LuminaSpacing.borderRadiusFull,
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color:
                                          Theme.of(context).colorScheme.onSurface,
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: LuminaSpacing.lg),

                    // Notification settings
                    Text(
                      'Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: LuminaSpacing.sm),
                    SwitchListTile(
                      title: const Text('Notify when members arrive'),
                      subtitle: const Text('Send notifications when someone enters this place'),
                      value: _notifyOnEnter,
                      onChanged: (value) {
                        setState(() {
                          _notifyOnEnter = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: const Text('Notify when members leave'),
                      subtitle: const Text('Send notifications when someone exits this place'),
                      value: _notifyOnExit,
                      onChanged: (value) {
                        setState(() {
                          _notifyOnExit = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SizedBox(height: LuminaSpacing.xl),

                    // Save button
                    PlatformAwareButton(
                      text: _isSaving
                          ? (isEditMode ? 'Updating...' : 'Creating...')
                          : (isEditMode ? 'Update Place' : 'Create Place'),
                      onPressed: _isSaving ? null : _savePlace,
                      style: PlatformButtonStyle.filled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
