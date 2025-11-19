import 'package:flutter/material.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/screens/circles/create_circle_screen.dart';
import 'package:luminalink/screens/circles/join_circle_screen.dart';
import 'package:luminalink/screens/circles/circle_details_screen.dart';
import 'package:luminalink/widgets/widgets.dart';
import 'package:luminalink/theme/spacing.dart';

/// Circles screen - Shows list of user's circles
///
/// Displays all circles the user belongs to and provides actions
/// to create new circles or join existing ones via invite code.
class CirclesScreen extends StatelessWidget {
  const CirclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final circleService = CircleService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Circle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateCircleScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Circle>>(
        stream: circleService.getMyCirclesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PlatformAwareLoadingIndicator());
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
                      'Failed to load circles',
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

          final circles = snapshot.data ?? [];

          if (circles.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: EdgeInsets.all(LuminaSpacing.md),
            itemCount: circles.length,
            itemBuilder: (context, index) {
              final circle = circles[index];
              return _CircleCard(
                circle: circle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CircleDetailsScreen(circleId: circle.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const JoinCircleScreen(),
            ),
          );
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Join Circle'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
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
              'Create a circle to start sharing your location with family and friends.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: LuminaSpacing.xl),
            PlatformAwareButton(
              text: 'Create Your First Circle',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCircleScreen(),
                  ),
                );
              },
              style: PlatformButtonStyle.filled,
              icon: Icons.add,
            ),
            SizedBox(height: LuminaSpacing.md),
            PlatformAwareButton(
              text: 'Join with Invite Code',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinCircleScreen(),
                  ),
                );
              },
              style: PlatformButtonStyle.outlined,
              icon: Icons.qr_code_scanner,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  final Circle circle;
  final VoidCallback onTap;

  const _CircleCard({
    required this.circle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = circle.iconColor != null
        ? Color(int.parse(circle.iconColor!.replaceFirst('#', '0xFF')))
        : Theme.of(context).colorScheme.primary;

    return Card(
      margin: EdgeInsets.only(bottom: LuminaSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(LuminaSpacing.md),
          child: Row(
            children: [
              // Circle icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: iconColor,
                  size: 28,
                ),
              ),
              SizedBox(width: LuminaSpacing.md),

              // Circle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      circle.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (circle.description != null) ...[
                      SizedBox(height: LuminaSpacing.xxs),
                      Text(
                        circle.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: LuminaSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: LuminaSpacing.xxs),
                        Text(
                          '${circle.memberCount} ${circle.memberCount == 1 ? 'member' : 'members'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
