import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';

/// Card widget displaying user information.
/// Used in match lists and search results.
class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final List<String>? highlightedSkills;

  const UserCard({
    super.key,
    required this.user,
    required this.onTap,
    this.highlightedSkills,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Photo
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // User Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'Unnamed User',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (user.bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.bio,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Skills Chips
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (user.skillsToTeach.isNotEmpty)
                          _buildSkillChip(
                            context,
                            user.skillsToTeach.first,
                            Colors.green,
                            "Teaches",
                          ),
                        if (user.skillsToLearn.isNotEmpty)
                          _buildSkillChip(
                            context,
                            user.skillsToLearn.first,
                            Colors.blue,
                            "Learns",
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a styled skill chip
  Widget _buildSkillChip(
      BuildContext context, String skill, Color color, String label) {
    final theme = Theme.of(context);
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(
        skill.length > 14 ? '${skill.substring(0, 14)}…' : skill,
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
      backgroundColor: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
