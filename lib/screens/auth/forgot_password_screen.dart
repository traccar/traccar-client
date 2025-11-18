import 'package:flutter/material.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/widgets/widgets.dart';

/// Forgot password screen for password recovery
///
/// Allows users to request a password reset email.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Icon(
            Icons.lock_reset,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'Forgot Your Password?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handlePasswordReset(),
          ),
          const SizedBox(height: 24),

          // Reset password button
          PlatformAwareButton(
            text: _isLoading ? 'Sending...' : 'Send Reset Link',
            onPressed: _isLoading ? null : _handlePasswordReset,
            style: PlatformButtonStyle.filled,
            isExpanded: true,
          ),
          const SizedBox(height: 16),

          // Back to login button
          PlatformAwareButton(
            text: 'Back to Login',
            onPressed: () => Navigator.pop(context),
            style: PlatformButtonStyle.text,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Icon(
          Icons.mark_email_read_outlined,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),

        // Success title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Success message
        Text(
          'We\'ve sent password reset instructions to:',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text.trim(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next Steps',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '1. Check your inbox (and spam folder)\n'
                '2. Click the reset link in the email\n'
                '3. Create a new password\n'
                '4. Sign in with your new password',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Back to login button
        PlatformAwareButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
          style: PlatformButtonStyle.filled,
          isExpanded: true,
        ),
        const SizedBox(height: 16),

        // Resend button
        PlatformAwareButton(
          text: 'Resend Email',
          onPressed: () {
            setState(() => _emailSent = false);
          },
          style: PlatformButtonStyle.text,
          isExpanded: true,
        ),
      ],
    );
  }
}
