import 'package:flutter/material.dart';

import '../services/music_service.dart';
import 'character_creator_page.dart';
import '../widgets/music_toggle_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: const Padding(
                padding: EdgeInsets.only(top: 4, right: 4),
                child: MusicToggleButton(),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🧋',
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bearista Boba',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A cozy boba shop game',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    FilledButton(
                      onPressed: () {
                        MusicService.instance.startMusic();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const CharacterCreatorPage(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                        child: Text('Start'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
