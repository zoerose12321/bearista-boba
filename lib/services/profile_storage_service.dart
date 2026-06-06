import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_profile.dart';

/// Local-only profile persistence (v0.1.57+).
class ProfileStorageService {
  static const profilesKey = 'bearista_profiles_v1';
  static const selectedProfileIdKey = 'bearista_selected_profile_id_v1';

  Future<List<PlayerProfile>> loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(profilesKey);
      if (raw == null || raw.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      final profiles = <PlayerProfile>[];
      for (final entry in decoded) {
        if (entry is! Map) {
          continue;
        }
        try {
          profiles.add(
            PlayerProfile.fromJson(Map<String, dynamic>.from(entry)),
          );
        } catch (_) {
          continue;
        }
      }
      return profiles;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfile(PlayerProfile profile) async {
    final profiles = await loadProfiles();
    final index = profiles.indexWhere((p) => p.profileId == profile.profileId);
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await _writeProfiles(profiles);
  }

  Future<void> deleteProfile(String profileId) async {
    final profiles = await loadProfiles()
      ..removeWhere((profile) => profile.profileId == profileId);
    await _writeProfiles(profiles);

    final selectedId = await getSelectedProfileId();
    if (selectedId == profileId) {
      await setSelectedProfileId(
        profiles.isEmpty ? null : profiles.first.profileId,
      );
    }
  }

  Future<String?> getSelectedProfileId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(selectedProfileIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> setSelectedProfileId(String? profileId) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileId == null) {
      await prefs.remove(selectedProfileIdKey);
      return;
    }
    await prefs.setString(selectedProfileIdKey, profileId);
  }

  Future<PlayerProfile?> loadSelectedProfile() async {
    final profiles = await loadProfiles();
    if (profiles.isEmpty) {
      return null;
    }

    final selectedId = await getSelectedProfileId();
    if (selectedId == null) {
      return profiles.first;
    }

    for (final profile in profiles) {
      if (profile.profileId == selectedId) {
        return profile;
      }
    }
    return profiles.first;
  }

  Future<void> _writeProfiles(List<PlayerProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(profiles.map((profile) => profile.toJson()).toList());
    await prefs.setString(profilesKey, encoded);
  }
}
