import 'package:flutter/material.dart';

import '../models/control_style.dart';
import '../models/player_profile.dart';
import '../services/profile_storage_service.dart';
import '../widgets/music_toggle_button.dart';
import '../widgets/profile_selector_card.dart';
import 'shop_world_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileStorageService _profileStorage = ProfileStorageService();

  List<PlayerProfile> _profiles = [];
  PlayerProfile? _selectedProfile;
  ControlStyle _controlStyle = ControlStyle.arrows;
  bool _loadingProfiles = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _profileStorage.loadProfiles();
    PlayerProfile? selected;

    if (profiles.isEmpty) {
      final defaultProfile = PlayerProfile.createNew('Bearista');
      await _profileStorage.saveProfile(defaultProfile);
      await _profileStorage.setSelectedProfileId(defaultProfile.profileId);
      profiles.add(defaultProfile);
      selected = defaultProfile;
    } else {
      selected = await _profileStorage.loadSelectedProfile();
      if (selected != null &&
          !profiles.any((profile) => profile.profileId == selected!.profileId)) {
        selected = profiles.first;
      }
      selected ??= profiles.first;
      await _profileStorage.setSelectedProfileId(selected.profileId);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _profiles = profiles;
      _selectedProfile = selected;
      _controlStyle = selected?.selectedControlStyle ?? ControlStyle.arrows;
      _loadingProfiles = false;
    });
  }

  Future<void> _selectProfile(PlayerProfile profile) async {
    await _profileStorage.setSelectedProfileId(profile.profileId);
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedProfile = profile;
      _controlStyle = profile.selectedControlStyle;
    });
  }

  Future<void> _saveControlStyleToProfile(ControlStyle style) async {
    final profile = _selectedProfile;
    if (profile == null) {
      return;
    }
    profile.selectedControlStyle = style;
    profile.updatedAt = DateTime.now();
    await _profileStorage.saveProfile(profile);
  }

  void _selectControlStyle(ControlStyle style) {
    setState(() {
      _controlStyle = style;
    });
    _saveControlStyleToProfile(style);
  }

  Future<void> _createProfile() async {
    final name = await _showProfileNameDialog(
      title: 'Create Profile',
      hint: 'Player name',
      confirmLabel: 'Create',
      initialName: 'Bearista',
    );
    if (name == null || !mounted) {
      return;
    }

    final profile = PlayerProfile.createNew(name);
    await _profileStorage.saveProfile(profile);
    await _profileStorage.setSelectedProfileId(profile.profileId);

    if (!mounted) {
      return;
    }

    setState(() {
      _profiles = [..._profiles, profile];
      _selectedProfile = profile;
      _controlStyle = profile.selectedControlStyle;
    });
  }

  Future<void> _deleteProfile(PlayerProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete profile?'),
          content: Text(
            'Delete "${profile.profileName}" and all saved progress? '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _profileStorage.deleteProfile(profile.profileId);
    final profiles = await _profileStorage.loadProfiles();

    if (profiles.isEmpty) {
      final defaultProfile = PlayerProfile.createNew('Bearista');
      await _profileStorage.saveProfile(defaultProfile);
      await _profileStorage.setSelectedProfileId(defaultProfile.profileId);
      profiles.add(defaultProfile);
    }

    final selected = await _profileStorage.loadSelectedProfile();

    if (!mounted) {
      return;
    }

    setState(() {
      _profiles = profiles;
      _selectedProfile = selected;
      _controlStyle = selected?.selectedControlStyle ?? ControlStyle.arrows;
    });
  }

  Future<String?> _showProfileNameDialog({
    required String title,
    required String hint,
    required String confirmLabel,
    required String initialName,
  }) async {
    final controller = TextEditingController(text: initialName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            key: const Key('profile_name_field'),
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: hint,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) =>
                Navigator.of(context).pop(controller.text.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (result == null || result.isEmpty) {
      return null;
    }
    return result;
  }

  void _startGame() {
    final profile = _selectedProfile;
    if (profile == null) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ShopWorldPage(
          profile: profile,
          profileStorage: _profileStorage,
          player: profile.toPlayerCharacter(),
          gameState: profile.toShopGameState(),
          controlStyle: _controlStyle,
        ),
      ),
    ).then((_) => _refreshSelectedProfile());
  }

  Future<void> _refreshSelectedProfile() async {
    final profiles = await _profileStorage.loadProfiles();
    final selected = await _profileStorage.loadSelectedProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _profiles = profiles;
      _selectedProfile = selected;
      if (selected != null) {
        _controlStyle = selected.selectedControlStyle;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canStart = _selectedProfile != null && !_loadingProfiles;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 40, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final stackedHeader = constraints.maxWidth < 360;

                  if (stackedHeader) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: MusicToggleButton(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ControlStyleSelector(
                          selected: _controlStyle,
                          onSelected: _selectControlStyle,
                        ),
                      ],
                    );
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth.clamp(0, 480),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: _ControlStyleSelector(
                                selected: _controlStyle,
                                onSelected: _selectControlStyle,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 12, top: 2),
                            child: MusicToggleButton(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
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
                          'Run your cozy boba café',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap your bear in the café to customize',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_loadingProfiles)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          )
                        else
                          ProfileSelectorCard(
                            profiles: _profiles,
                            selectedProfile: _selectedProfile,
                            onSelectProfile: _selectProfile,
                            onCreateProfile: _createProfile,
                            onDeleteProfile: _deleteProfile,
                          ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: canStart ? _startGame : null,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 4,
                            ),
                            child: Text('Start'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlStyleSelector extends StatelessWidget {
  const _ControlStyleSelector({
    required this.selected,
    required this.onSelected,
  });

  final ControlStyle selected;
  final ValueChanged<ControlStyle> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Movement controls',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ControlStyleOption(
                key: const Key('control_style_arrows'),
                label: 'Arrows',
                isSelected: selected == ControlStyle.arrows,
                onTap: () => onSelected(ControlStyle.arrows),
              ),
              const SizedBox(width: 4),
              _ControlStyleOption(
                key: const Key('control_style_joycon'),
                label: 'Joy-Con',
                isSelected: selected == ControlStyle.joyCon,
                onTap: () => onSelected(ControlStyle.joyCon),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlStyleOption extends StatelessWidget {
  const _ControlStyleOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primary.withValues(alpha: 0.22)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF5C4A42),
            ),
          ),
        ),
      ),
    );
  }
}
