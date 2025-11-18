import 'package:flutter/material.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/widgets/widgets.dart';
import 'package:luminalink/theme/spacing.dart';
import 'package:luminalink/theme/colors.dart';

/// Join circle screen - Enter invite code to join a circle
///
/// Allows users to join existing circles by entering a 6-character
/// alphanumeric invite code.
class JoinCircleScreen extends StatefulWidget {
  const JoinCircleScreen({super.key});

  @override
  State<JoinCircleScreen> createState() => _JoinCircleScreenState();
}

class _JoinCircleScreenState extends State<JoinCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _circleService = CircleService();

  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isJoining = true);

    try {
      final circle = await _circleService.joinCircleWithCode(
        _codeController.text.trim().toUpperCase(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined circle "${circle.name}"!'),
            backgroundColor: LuminaColors.successLight,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
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
        title: const Text('Join Circle'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(LuminaSpacing.xl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: LuminaSpacing.lg),

              // Title
              Text(
                'Join a Circle',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: LuminaSpacing.sm),

              // Description
              Text(
                'Enter the 6-character invite code shared by the circle owner.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: LuminaSpacing.xl),

              // Invite code field
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Invite Code',
                  hintText: 'ABC123',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an invite code';
                  }
                  if (value.trim().length != 6) {
                    return 'Invite code must be 6 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleJoin(),
                onChanged: (value) {
                  // Auto-uppercase as user types
                  if (value != value.toUpperCase()) {
                    _codeController.value = _codeController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(
                        offset: value.length,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: LuminaSpacing.xl),

              // Join button
              PlatformAwareButton(
                text: _isJoining ? 'Joining...' : 'Join Circle',
                onPressed: _isJoining ? null : _handleJoin,
                style: PlatformButtonStyle.filled,
                isExpanded: true,
              ),
              SizedBox(height: LuminaSpacing.xl),

              // Info card
              Container(
                padding: EdgeInsets.all(LuminaSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: LuminaSpacing.sm),
                        Text(
                          'How to get an invite code?',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    SizedBox(height: LuminaSpacing.sm),
                    Text(
                      '1. Ask a circle member or owner for their invite code\n'
                      '2. They can find it in Circle Settings\n'
                      '3. Enter the 6-character code above',
                      style: Theme.of(context).textTheme.bodySmall,
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
