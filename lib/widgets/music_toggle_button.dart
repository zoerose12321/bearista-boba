import 'package:flutter/material.dart';

import '../services/music_service.dart';

/// Simple on/off control for background music.
class MusicToggleButton extends StatelessWidget {
  const MusicToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final music = MusicService.instance;

    return ListenableBuilder(
      listenable: music,
      builder: (context, _) {
        final enabled = music.isMusicEnabled;
        return IconButton(
          onPressed: () => music.toggleMusic(),
          tooltip: enabled ? 'Turn music off' : 'Turn music on',
          icon: Icon(
            enabled ? Icons.music_note_rounded : Icons.music_off_rounded,
            color: enabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.45),
          ),
        );
      },
    );
  }
}
