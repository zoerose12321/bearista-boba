import 'package:flutter/material.dart';

import '../models/online_cafe_session.dart';

class HostCafeCard extends StatelessWidget {
  const HostCafeCard({
    super.key,
    required this.session,
    required this.onCopyCode,
    required this.onCloseCafe,
    this.compact = false,
  });

  final OnlineCafeSession session;
  final VoidCallback onCopyCode;
  final VoidCallback onCloseCafe;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Your café is online!',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5C4A42),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Code: ${session.joinCode}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share this code with a friend.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          if (session.visitorCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${session.visitorCount} visitor${session.visitorCount == 1 ? '' : 's'} joined',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5C4A42),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('copy_cafe_code'),
                onPressed: onCopyCode,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy Code'),
              ),
              OutlinedButton.icon(
                key: const Key('close_online_cafe'),
                onPressed: onCloseCafe,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Close Online Café'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
