import 'package:flutter/material.dart';

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
  const PlayerCharacter({
    required this.name,
    required this.fur,
    required this.accent,
    this.accessory = BearAccessory.none,
  });

  final String name;
  final BearFur fur;
  final BearAccent accent;
  final BearAccessory accessory;

  Color get furColor => fur.color;
  Color get accentColor => accent.color;
  bool get isPanda => fur.isPanda;

  String get displayName => name.trim().isEmpty ? 'Bearista' : name.trim();
}
