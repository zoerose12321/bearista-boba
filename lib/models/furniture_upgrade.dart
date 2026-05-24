import 'package:flutter/material.dart';

class FurnitureUpgrade {
  const FurnitureUpgrade({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.placement,
  });

  final String id;
  final String name;
  final String emoji;
  final int cost;
  final Alignment placement;
}
