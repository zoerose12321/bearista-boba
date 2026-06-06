import 'package:flutter/material.dart';

import '../models/player_profile.dart';

class ProfileSelectorCard extends StatelessWidget {
  const ProfileSelectorCard({
    super.key,
    required this.profiles,
    required this.selectedProfile,
    required this.onSelectProfile,
    required this.onCreateProfile,
    required this.onDeleteProfile,
  });

  final List<PlayerProfile> profiles;
  final PlayerProfile? selectedProfile;
  final ValueChanged<PlayerProfile> onSelectProfile;
  final VoidCallback onCreateProfile;
  final ValueChanged<PlayerProfile> onDeleteProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = selectedProfile;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '🐻',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected?.profileName ?? 'No profile yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (selected != null)
                        Text(
                          '🪙 ${selected.coins} coins saved',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        )
                      else
                        Text(
                          'Create a profile to save your progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (profiles.length > 1)
                  PopupMenuButton<PlayerProfile>(
                    key: const Key('switch_profile_menu'),
                    tooltip: 'Switch profile',
                    onSelected: onSelectProfile,
                    itemBuilder: (context) {
                      return profiles
                          .map(
                            (profile) => PopupMenuItem<PlayerProfile>(
                              value: profile,
                              child: Text(profile.profileName),
                            ),
                          )
                          .toList();
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.swap_horiz, size: 18),
                        SizedBox(width: 6),
                        Text('Switch'),
                      ],
                    ),
                  ),
                OutlinedButton.icon(
                  key: const Key('create_profile_button'),
                  onPressed: onCreateProfile,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create Profile'),
                ),
                if (selected != null && profiles.length > 1)
                  OutlinedButton.icon(
                    key: const Key('delete_profile_button'),
                    onPressed: () => onDeleteProfile(selected),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
