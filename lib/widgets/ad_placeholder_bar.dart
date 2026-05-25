import 'package:flutter/material.dart';

/// Reserved strip at the bottom of [ShopWorldPage] for a future banner ad.
///
/// Swap this widget for a real banner/ad widget when integrating an ad SDK.
class AdPlaceholderBar extends StatelessWidget {
  const AdPlaceholderBar({super.key});

  /// Minimum strip height excluding device bottom safe-area inset.
  static const contentHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      left: false,
      right: false,
      child: Container(
        width: double.infinity,
        height: contentHeight,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.06),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'Future banner space',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
