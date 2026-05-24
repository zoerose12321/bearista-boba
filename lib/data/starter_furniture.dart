import 'package:flutter/material.dart';

import '../models/furniture_upgrade.dart';

const starterFurniture = [
  FurnitureUpgrade(
    id: 'cozy_table',
    name: 'Cozy Table',
    emoji: '🪵',
    cost: 20,
    placement: Alignment(-0.75, 0.55),
  ),
  FurnitureUpgrade(
    id: 'flower_vase',
    name: 'Flower Vase',
    emoji: '🌸',
    cost: 30,
    placement: Alignment(0.85, -0.65),
  ),
  FurnitureUpgrade(
    id: 'pastel_rug',
    name: 'Pastel Rug',
    emoji: '🧶',
    cost: 40,
    placement: Alignment(0.0, 0.75),
  ),
  FurnitureUpgrade(
    id: 'boba_wall_sign',
    name: 'Boba Wall Sign',
    emoji: '🧋',
    cost: 50,
    placement: Alignment(0.0, -0.85),
  ),
  FurnitureUpgrade(
    id: 'comfy_chair',
    name: 'Comfy Chair',
    emoji: '🪑',
    cost: 60,
    placement: Alignment(-0.85, 0.0),
  ),
];
