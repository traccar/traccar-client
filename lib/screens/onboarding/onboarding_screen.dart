import 'package:flutter/material.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/widgets/widgets.dart';
import 'package:luminalink/theme/spacing.dart';

/// Onboarding screen for new users
///
/// Introduces key features and privacy principles before allowing
/// access to the main app. This ensures users understand how
/// LuminaLink protects their privacy.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  int _currentPage = 0;
  bool _isCompleting = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.family_restroom_rounded,
      title: 'Welcome to LuminaLink',
      description:
          'Stay connected with your family and friends through safe, private location sharing.',
      color: const Color(0xFFF59E0B), // Amber
    ),
    OnboardingPage(
      icon: Icons.privacy_tip_outlined,
      title: 'Privacy First, Always',
      description:
          'Your location is encrypted and only shared with people you choose. We never sell your data to third parties.',
      color: const Color(0xFF14B8A6), // Teal
    ),
    OnboardingPage(
      icon: Icons.groups_rounded,
      title: 'Create Private Circles',
      description:
          'Organize your contacts into circles like "Family" or "Close Friends". Each circle has its own privacy settings.',
      color: const Color(0xFF8B5CF6), // Violet
    ),
    OnboardingPage(
      icon: Icons.place_outlined,
      title: 'Place Alerts',
      description:
          'Get notified when family members arrive or leave important places like home, school, or work.',
      color: const Color(0xFF0284C7), // Sky
    ),
    OnboardingPage(
      icon: Icons.battery_saver_outlined,
      title: 'Battery Optimized',
      description:
          'Smart location tracking uses minimal battery while keeping you connected to your circle.',
      color: const Color(0xFF16A34A), // Green
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isCompleting = true);

    try {
      await _authService.completeOnboarding();
      // Navigation handled by AuthWrapper stream
    } catch (e) {
      if (mounted) {
        setState(() => _isCompleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (_currentPage < _pages.length - 1)
              Padding(
                padding: EdgeInsets.all(LuminaSpacing.md),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        _pages.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Skip'),
                  ),
                ),
              )
            else
              SizedBox(height: LuminaSpacing.xl + LuminaSpacing.md),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: LuminaSpacing.xxs),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: LuminaSpacing.lg),

            // Navigation buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: LuminaSpacing.lg),
              child: Row(
                children: [
                  // Back button
                  if (_currentPage > 0)
                    Expanded(
                      child: PlatformAwareButton(
                        text: 'Back',
                        onPressed: _previousPage,
                        style: PlatformButtonStyle.outlined,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),

                  SizedBox(width: LuminaSpacing.md),

                  // Next/Get Started button
                  Expanded(
                    flex: 2,
                    child: PlatformAwareButton(
                      text: _isCompleting
                          ? 'Starting...'
                          : (_currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next'),
                      onPressed: _isCompleting ? null : _nextPage,
                      style: PlatformButtonStyle.filled,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: LuminaSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: LuminaSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          SizedBox(height: LuminaSpacing.xl),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: LuminaSpacing.md),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
