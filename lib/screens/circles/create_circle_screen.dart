import 'package:flutter/material.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/widgets/widgets.dart';
import 'package:luminalink/theme/spacing.dart';
import 'package:luminalink/theme/colors.dart';

/// Create circle screen - Form to create a new circle
///
/// Allows users to specify circle name, description, and settings
/// like invite code and member limit.
class CreateCircleScreen extends StatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  State<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends State<CreateCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _circleService = CircleService();

  bool _isCreating = false;
  bool _enableInviteCode = true;
  int _maxMembers = -1; // -1 = unlimited

  String? _selectedColor;
  final List<String> _colorOptions = [
    '#F59E0B', // Amber (primary)
    '#14B8A6', // Teal
    '#8B5CF6', // Violet
    '#0284C7', // Sky
    '#16A34A', // Green
    '#DC2626', // Red
    '#EA580C', // Orange
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      await _circleService.createCircle(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        iconColor: _selectedColor,
        enableInviteCode: _enableInviteCode,
        maxMembers: _maxMembers,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Circle "${_nameController.text}" created!'),
            backgroundColor: LuminaColors.successLight,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
        title: const Text('Create Circle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(LuminaSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Circle Name',
                  hintText: 'Family, Close Friends, etc.',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a circle name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: LuminaSpacing.md),

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'What is this circle for?',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: LuminaSpacing.lg),

              // Color picker
              Text(
                'Circle Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: LuminaSpacing.sm),
              Wrap(
                spacing: LuminaSpacing.sm,
                runSpacing: LuminaSpacing.sm,
                children: _colorOptions.map((color) {
                  final colorValue = Color(int.parse(color.replaceFirst('#', '0xFF')));
                  final isSelected = _selectedColor == color;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedColor = color);
                    },
                    borderRadius: BorderRadius.circular(LuminaSpacing.radiusCircular),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorValue.withOpacity(isSelected ? 1.0 : 0.3),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: colorValue,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: LuminaSpacing.lg),

              // Enable invite code switch
              PlatformAwareSwitchListTile(
                title: const Text('Enable Invite Code'),
                subtitle: const Text('Allow others to join with a code'),
                value: _enableInviteCode,
                onChanged: (value) {
                  setState(() => _enableInviteCode = value);
                },
              ),
              SizedBox(height: LuminaSpacing.md),

              // Member limit
              Text(
                'Member Limit',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: LuminaSpacing.sm),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: -1,
                    label: Text('Unlimited'),
                  ),
                  ButtonSegment(
                    value: 5,
                    label: Text('5'),
                  ),
                  ButtonSegment(
                    value: 10,
                    label: Text('10'),
                  ),
                  ButtonSegment(
                    value: 20,
                    label: Text('20'),
                  ),
                ],
                selected: {_maxMembers},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() => _maxMembers = newSelection.first);
                },
              ),
              SizedBox(height: LuminaSpacing.xl),

              // Info card
              Container(
                padding: EdgeInsets.all(LuminaSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: LuminaSpacing.sm),
                    Expanded(
                      child: Text(
                        'You will be the owner and admin of this circle. You can invite members and manage settings anytime.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: LuminaSpacing.xl),

              // Create button
              PlatformAwareButton(
                text: _isCreating ? 'Creating...' : 'Create Circle',
                onPressed: _isCreating ? null : _handleCreate,
                style: PlatformButtonStyle.filled,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
