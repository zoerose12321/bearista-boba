import '../data/starter_ingredients.dart';
import 'control_style.dart';
import 'custom_recipe.dart';
import 'player_character.dart';
import 'shop_game_state.dart';

/// Local player progress saved on device (v0.1.57+).
class PlayerProfile {
  PlayerProfile({
    required this.profileId,
    required this.profileName,
    required this.createdAt,
    required this.updatedAt,
    this.coins = 0,
    this.playerName = 'Bearista',
    this.fur = BearFur.honey,
    this.accent = BearAccent.peach,
    this.accessory = BearAccessory.none,
    this.equippedOutfitId = PlayerCharacter.starterOutfitId,
    this.equippedAccessoryId,
    this.selectedControlStyle = ControlStyle.arrows,
    Set<String>? ownedStoreItemIds,
    Set<String>? ownedFurnitureIds,
    Set<String>? unlockedIngredientIds,
    List<CustomRecipe>? customRecipes,
    this.helperBearUnlocked = false,
  })  : ownedStoreItemIds = ownedStoreItemIds ?? {},
        ownedFurnitureIds = ownedFurnitureIds ?? {},
        unlockedIngredientIds =
            unlockedIngredientIds ?? StarterIngredients.initialUnlocked(),
        customRecipes = customRecipes ?? [];

  final String profileId;
  String profileName;
  final DateTime createdAt;
  DateTime updatedAt;

  int coins;
  String playerName;
  BearFur fur;
  BearAccent accent;
  BearAccessory accessory;
  String equippedOutfitId;
  String? equippedAccessoryId;
  ControlStyle selectedControlStyle;
  final Set<String> ownedStoreItemIds;
  final Set<String> ownedFurnitureIds;
  final Set<String> unlockedIngredientIds;
  final List<CustomRecipe> customRecipes;
  bool helperBearUnlocked;

  static const maxProfileNameLength = 15;

  /// Trims whitespace and caps length for safe display/storage.
  static String normalizeProfileName(
    String raw, {
    String fallback = 'Bearista',
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return fallback;
    }
    if (trimmed.length <= maxProfileNameLength) {
      return trimmed;
    }
    return trimmed.substring(0, maxProfileNameLength);
  }

  static bool isValidProfileName(String raw) {
    final trimmed = raw.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxProfileNameLength;
  }

  /// Header title for [ShopWorldPage], e.g. "Zoe's Shop".
  String get shopTitle {
    final name = profileName.trim();
    if (name.isEmpty) {
      return 'Bearista\'s Shop';
    }
    return '$name\'s Shop';
  }

  static PlayerProfile createNew(String name) {
    final now = DateTime.now();
    return PlayerProfile(
      profileId: now.millisecondsSinceEpoch.toString(),
      profileName: normalizeProfileName(name),
      createdAt: now,
      updatedAt: now,
    );
  }

  void updateFrom({
    required PlayerCharacter player,
    required ShopGameState gameState,
    required ControlStyle controlStyle,
    required bool helperBearUnlocked,
  }) {
    updatedAt = DateTime.now();
    coins = gameState.coins;
    playerName = player.name;
    fur = player.fur;
    accent = player.accent;
    accessory = player.accessory;
    equippedOutfitId = player.equippedOutfitId;
    equippedAccessoryId = player.equippedAccessoryId;
    selectedControlStyle = controlStyle;
    this.helperBearUnlocked = helperBearUnlocked;

    ownedStoreItemIds
      ..clear()
      ..addAll(gameState.ownedStoreItemIds);
    ownedFurnitureIds
      ..clear()
      ..addAll(gameState.ownedFurnitureIds);
    unlockedIngredientIds
      ..clear()
      ..addAll(gameState.unlockedIngredientNames);
    customRecipes
      ..clear()
      ..addAll(gameState.customRecipes);
  }

  PlayerCharacter toPlayerCharacter() {
    return PlayerCharacter(
      name: playerName,
      fur: fur,
      accent: accent,
      accessory: accessory,
      equippedOutfitId: equippedOutfitId,
      equippedAccessoryId: equippedAccessoryId,
    );
  }

  ShopGameState toShopGameState() {
    final state = ShopGameState();
    state.coins = coins;
    state.ownedStoreItemIds.addAll(ownedStoreItemIds);
    state.ownedFurnitureIds.addAll(ownedFurnitureIds);
    state.unlockedIngredientNames
      ..clear()
      ..addAll(
        unlockedIngredientIds.isEmpty
            ? StarterIngredients.initialUnlocked()
            : unlockedIngredientIds,
      );
    for (final recipe in customRecipes) {
      state.addCustomRecipe(recipe);
    }
    return state;
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'profileName': profileName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coins': coins,
      'playerName': playerName,
      'fur': fur.name,
      'accent': accent.name,
      'accessory': accessory.name,
      'equippedOutfitId': equippedOutfitId,
      'equippedAccessoryId': equippedAccessoryId,
      'selectedControlStyle': selectedControlStyle.name,
      'ownedStoreItemIds': ownedStoreItemIds.toList(),
      'ownedFurnitureIds': ownedFurnitureIds.toList(),
      'unlockedIngredientIds': unlockedIngredientIds.toList(),
      'customRecipes': customRecipes
          .map(
            (recipe) => {
              'id': recipe.id,
              'name': recipe.name,
              'ingredients': recipe.ingredients,
            },
          )
          .toList(),
      'helperBearUnlocked': helperBearUnlocked,
    };
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      profileId: _readString(json, 'profileId') ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      profileName: normalizeProfileName(
        _readString(json, 'profileName') ?? 'Bearista',
      ),
      createdAt: _readDateTime(json, 'createdAt') ?? DateTime.now(),
      updatedAt: _readDateTime(json, 'updatedAt') ?? DateTime.now(),
      coins: _readInt(json, 'coins'),
      playerName: _readString(json, 'playerName') ?? 'Bearista',
      fur: _parseEnum(
        _readString(json, 'fur'),
        BearFur.values,
        BearFur.honey,
      ),
      accent: _parseEnum(
        _readString(json, 'accent'),
        BearAccent.values,
        BearAccent.peach,
      ),
      accessory: _parseEnum(
        _readString(json, 'accessory'),
        BearAccessory.values,
        BearAccessory.none,
      ),
      equippedOutfitId:
          _readString(json, 'equippedOutfitId') ??
              PlayerCharacter.starterOutfitId,
      equippedAccessoryId: _readString(json, 'equippedAccessoryId'),
      selectedControlStyle: _parseEnum(
        _readString(json, 'selectedControlStyle'),
        ControlStyle.values,
        ControlStyle.arrows,
      ),
      ownedStoreItemIds: _readStringSet(json, 'ownedStoreItemIds'),
      ownedFurnitureIds: _readStringSet(json, 'ownedFurnitureIds'),
      unlockedIngredientIds: _readStringSet(json, 'unlockedIngredientIds')
          .isEmpty
          ? StarterIngredients.initialUnlocked()
          : _readStringSet(json, 'unlockedIngredientIds'),
      customRecipes: _readCustomRecipes(json),
      helperBearUnlocked: json['helperBearUnlocked'] == true,
    );
  }

  static String? _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }

  static DateTime? _readDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static Set<String> _readStringSet(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is List) {
      return value.whereType<String>().toSet();
    }
    return {};
  }

  static List<CustomRecipe> _readCustomRecipes(Map<String, dynamic> json) {
    final value = json['customRecipes'];
    if (value is! List) {
      return [];
    }

    final recipes = <CustomRecipe>[];
    for (final entry in value) {
      if (entry is! Map) {
        continue;
      }
      final id = entry['id'];
      final name = entry['name'];
      final ingredients = entry['ingredients'];
      if (id is! String || name is! String || ingredients is! List) {
        continue;
      }
      final parsedIngredients = ingredients.whereType<String>().toList();
      if (parsedIngredients.isEmpty) {
        continue;
      }
      recipes.add(
        CustomRecipe(
          id: id,
          name: name,
          ingredients: parsedIngredients,
        ),
      );
    }
    return recipes;
  }

  static T _parseEnum<T extends Enum>(
    String? raw,
    List<T> values,
    T fallback,
  ) {
    if (raw == null) {
      return fallback;
    }
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }
    return fallback;
  }
}
