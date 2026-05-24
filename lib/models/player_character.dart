import 'package:flutter/material.dart';

import '../data/store_items.dart';

enum BearFur {
  honey('Honey', Color(0xFFE8B86D)),
  cocoa('Cocoa', Color(0xFF8B5E3C)),
  cream('Cream', Color(0xFFF5E6C8)),
  strawberry('Strawberry', Color(0xFFF4A7B9)),
  panda('Panda', Color(0xFFF7F7F7));

  const BearFur(this.label, this.color);

  final String label;
  final Color color;

  bool get isPanda => this == BearFur.panda;
}

enum BearAccent {
  peach('Peach', Color(0xFFE8A598)),
  mint('Mint', Color(0xFFB8D4A8)),
  lavender('Lavender', Color(0xFFC9B8E8)),
  sky('Sky', Color(0xFFA8D4F0)),
  rose('Rose', Color(0xFFF5A8C8));

  const BearAccent(this.label, this.color);

  final String label;
  final Color color;
}

enum BearAccessory {
  none('None', ''),
  bow('Bow', '🎀'),
  tinyHat('Tiny Hat', '🎩'),
  glasses('Glasses', '👓'),
  flower('Flower', '🌸');

  const BearAccessory(this.label, this.emoji);

  final String label;
  final String emoji;
}

class PlayerCharacter {
  PlayerCharacter({
    required this.name,
    required this.fur,
    required this.accent,
    this.accessory = BearAccessory.none,
    String? equippedOutfitId,
    this.equippedAccessoryId,
  }) : equippedOutfitId = equippedOutfitId ?? starterOutfitId;

  /// Default bearista look before any purchased outfit.
  static const starterOutfitId = 'starter_default';

  final String name;
  final BearFur fur;
  final BearAccent accent;

  /// Accessory chosen during character creation.
  final BearAccessory accessory;

  /// Currently worn outfit id (`starter_default` or a purchased apron id).
  String equippedOutfitId;

  /// Currently worn store accessory id, if any.
  String? equippedAccessoryId;

  Color get furColor => fur.color;
  Color get accentColor => accent.color;
  bool get isPanda => fur.isPanda;

  String get displayName => name.trim().isEmpty ? 'Bearista' : name.trim();

  bool get hasPurchasedOutfitEquipped =>
      equippedOutfitId != starterOutfitId;

  Color? get equippedApronColor {
    if (!hasPurchasedOutfitEquipped) {
      return null;
    }
    final item = storeItemById(equippedOutfitId);
    if (item?.apronColor == null) {
      return null;
    }
    return Color(item!.apronColor!);
  }

  BearAccessory get displayAccessory {
    if (equippedAccessoryId != null) {
      final item = storeItemById(equippedAccessoryId!);
      if (item?.accessoryKind != null) {
        return bearAccessoryForStoreId(item!.accessoryKind);
      }
    }
    return accessory;
  }

  bool isOutfitEquipped(String outfitId) => equippedOutfitId == outfitId;

  bool isAccessoryEquipped(String accessoryId) =>
      equippedAccessoryId == accessoryId;

  void equipOutfit(String outfitId) {
    equippedOutfitId = outfitId;
  }

  void equipAccessory(String accessoryId) {
    equippedAccessoryId = accessoryId;
  }

  void unequipStoreAccessory() {
    equippedAccessoryId = null;
  }
}
