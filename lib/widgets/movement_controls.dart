import 'package:flutter/material.dart';

import '../models/control_style.dart';
import 'joy_con_control.dart';
import 'shop_decoration.dart';

/// Movement controls for ShopWorldPage — arrow D-pad or Joy-Con joystick.
class MovementControls extends StatelessWidget {
  const MovementControls({
    super.key,
    required this.style,
    required this.onMove,
    required this.onJoyConDirection,
    this.joyConKey,
  });

  final ControlStyle style;
  final void Function(int deltaCol, int deltaRow) onMove;
  final void Function(int deltaCol, int deltaRow) onJoyConDirection;
  final GlobalKey<JoyConControlState>? joyConKey;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ControlStyle.arrows:
        return ShopDpad(onMove: onMove);
      case ControlStyle.joyCon:
        return JoyConControl(
          key: joyConKey,
          onDirectionChanged: onJoyConDirection,
        );
    }
  }
}
