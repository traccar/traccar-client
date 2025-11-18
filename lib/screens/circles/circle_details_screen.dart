import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luminalink/models/models.dart';
import 'package:luminalink/services/circle_service.dart';
import 'package:luminalink/services/auth_service.dart';
import 'package:luminalink/widgets/widgets.dart';
import 'package:luminalink/theme/spacing.dart';
import 'package:luminalink/theme/colors.dart';

/// Circle details screen - Shows circle information and members
///
/// Displays circle details, member list, invite code (if admin),
/// and provides actions like leaving or managing the circle.
class CircleDetailsScreen extends StatelessWidget {
  final String circleId;

  const CircleDetailsScreen({
    super.key,
    required this.circleId,
  });

  @override
  Widget build(BuildContext context) {
    final circleService = CircleService();
    final authService = AuthService();

    return StreamBuilder<Circle?>(
      stream: circleService.getCircleStream(circleId),
      builder: (context, circleSnapshot) {
        if (circleSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Circle Details')),
            body: const Center(child: PlatformAwareLoadingIndicator()),
          );
        }

        final circle = circleSnapshot.data;
        if (circle == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Circle Not Found')),
            body: const Center(child: Text('This circle no longer exists.')),
          );
        }

        final currentUserId = authService.currentUserId!;
        final isOwner = circle.isOwner(currentUserId);
        final isAdmin = circle.isAdmin(currentUserId);

        final iconColor = circle.iconColor != null
            ? Color(int.parse(circle.iconColor!.replaceFirst('#', '0xFF')))
            : Theme.of(context).colorScheme.primary;

        return Scaffold(
          appBar: AppBar(
            title: Text(circle.name),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // TODO: Navigate to circle settings screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Circle settings coming soon!'),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: ListView(
            children: [
              // Circle header
              Container(
                padding: EdgeInsets.all(LuminaSpacing.xl),
                color: iconColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: iconColor,
                        size: 50,
                      ),
                    ),
                    SizedBox(height: LuminaSpacing.md),
                    Text(
                      circle.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (circle.description != null) ...[
                      SizedBox(height: LuminaSpacing.xs),
                      Text(
                        circle.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    SizedBox(height: LuminaSpacing.sm),
                    Text(
                      '${circle.memberCount} ${circle.memberCount == 1 ? 'member' : 'members'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Invite code section (admin only)
              if (isAdmin && circle.inviteCodeEnabled && circle.inviteCode != null)
                _InviteCodeSection(
                  inviteCode: circle.inviteCode!,
                  circleId: circle.id,
                ),

              // Members section
              StreamBuilder<List<AppUser>>(
                stream: circleService.getCircleMembersStream(circleId),
                builder: (context, membersSnapshot) {
                  if (membersSnapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.all(LuminaSpacing.xl),
                      child: const Center(child: PlatformAwareLoadingIndicator()),
                    );
                  }

                  final members = membersSnapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(LuminaSpacing.md),
                        child: Text(
                          'Members',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      ...members.map((member) {
                        final isMemberOwner = circle.isOwner(member.uid);
                        final isMemberAdmin = circle.isAdmin(member.uid);
                        final isCurrentUser = member.uid == currentUserId;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: member.photoUrl != null
                                ? NetworkImage(member.photoUrl!)
                                : null,
                            child: member.photoUrl == null
                                ? Text(member.initials)
                                : null,
                          ),
                          title: Row(
                            children: [
                              Text(member.displayName),
                              if (isCurrentUser) ...[
                                SizedBox(width: LuminaSpacing.xs),
                                Text(
                                  '(You)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            isMemberOwner
                                ? 'Owner'
                                : isMemberAdmin
                                    ? 'Admin'
                                    : 'Member',
                          ),
                          trailing: isAdmin && !isMemberOwner && !isCurrentUser
                              ? PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'remove') {
                                      final confirm = await _showConfirmDialog(
                                        context,
                                        'Remove Member',
                                        'Are you sure you want to remove ${member.displayName} from this circle?',
                                      );
                                      if (confirm) {
                                        try {
                                          await circleService.removeMember(
                                            circleId,
                                            member.uid,
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${member.displayName} removed',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                                backgroundColor:
                                                    Theme.of(context).colorScheme.error,
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Text('Remove from circle'),
                                    ),
                                  ],
                                )
                              : null,
                        );
                      }),
                    ],
                  );
                },
              ),

              SizedBox(height: LuminaSpacing.xl),

              // Leave circle button
              if (!isOwner)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: LuminaSpacing.lg),
                  child: PlatformAwareButton(
                    text: 'Leave Circle',
                    onPressed: () async {
                      final confirm = await _showConfirmDialog(
                        context,
                        'Leave Circle',
                        'Are you sure you want to leave ${circle.name}?',
                      );
                      if (confirm) {
                        try {
                          await circleService.removeMember(circleId, currentUserId);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: PlatformButtonStyle.destructive,
                    isExpanded: true,
                  ),
                ),

              SizedBox(height: LuminaSpacing.xl),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await PlatformAwareDialog.show<bool>(
      context: context,
      title: title,
      content: message,
      actions: [
        PlatformDialogAction(
          text: 'Cancel',
          onPressed: () => Navigator.pop(context, false),
        ),
        PlatformDialogAction(
          text: 'Confirm',
          isDestructive: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    return result ?? false;
  }
}

class _InviteCodeSection extends StatelessWidget {
  final String inviteCode;
  final String circleId;

  const _InviteCodeSection({
    required this.inviteCode,
    required this.circleId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(LuminaSpacing.md),
      padding: EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.primaryContainerLight,
        borderRadius: BorderRadius.circular(LuminaSpacing.radiusMd),
        border: Border.all(
          color: LuminaColors.primaryLight.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.vpn_key,
                color: LuminaColors.primaryLight,
                size: 20,
              ),
              SizedBox(width: LuminaSpacing.sm),
              Text(
                'Invite Code',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          SizedBox(height: LuminaSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(LuminaSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(LuminaSpacing.radiusSm),
                  ),
                  child: Text(
                    inviteCode,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: LuminaSpacing.sm),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite code copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                tooltip: 'Copy',
              ),
            ],
          ),
          SizedBox(height: LuminaSpacing.sm),
          Text(
            'Share this code with people you want to invite to this circle.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }
}
