import 'package:flutter/material.dart';

/// Draggable virtual Joy-Con joystick for continuous café movement (v0.1.49+).
class JoyConControl extends StatefulWidget {
  const JoyConControl({
    super.key,
    required this.onDirectionChanged,
  });

  /// Called when drag direction changes. Pass (0, 0) when centered/released.
  final void Function(int deltaCol, int deltaRow) onDirectionChanged;

  @override
  State<JoyConControl> createState() => JoyConControlState();
}

class JoyConControlState extends State<JoyConControl> {
  static const padWidth = 92.0;
  static const padHeight = 168.0;
  static const knobSize = 46.0;
  static const maxKnobRadius = 26.0;
  static const deadZoneFraction = 0.2;

  Offset _knobOffset = Offset.zero;
  int _lastDeltaCol = 0;
  int _lastDeltaRow = 0;

  double get _deadZoneRadius => maxKnobRadius * deadZoneFraction;

  @override
  void dispose() {
    _notifyDirection(Offset.zero);
    super.dispose();
  }

  void resetKnob() {
    if (_knobOffset == Offset.zero && _lastDeltaCol == 0 && _lastDeltaRow == 0) {
      return;
    }
    setState(() {
      _knobOffset = Offset.zero;
    });
    _notifyDirection(Offset.zero);
  }

  Offset _clampOffset(Offset offset) {
    final distance = offset.distance;
    if (distance <= maxKnobRadius) {
      return offset;
    }
    return Offset.fromDirection(offset.direction, maxKnobRadius);
  }

  void _notifyDirection(Offset offset) {
    int deltaCol = 0;
    int deltaRow = 0;

    if (offset.distance >= _deadZoneRadius) {
      if (offset.dx.abs() >= offset.dy.abs()) {
        deltaCol = offset.dx > 0 ? 1 : -1;
      } else {
        deltaRow = offset.dy > 0 ? 1 : -1;
      }
    }

    if (deltaCol == _lastDeltaCol && deltaRow == _lastDeltaRow) {
      return;
    }

    _lastDeltaCol = deltaCol;
    _lastDeltaRow = deltaRow;
    widget.onDirectionChanged(deltaCol, deltaRow);
  }

  void _updateKnob(Offset localPosition) {
    final center = Offset(padWidth / 2, padHeight / 2);
    final offset = _clampOffset(localPosition - center);
    setState(() {
      _knobOffset = offset;
    });
    _notifyDirection(offset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shellColor = theme.colorScheme.secondary.withValues(alpha: 0.42);
    final accentColor = theme.colorScheme.secondary;

    return SizedBox(
      key: const Key('joycon_control'),
      width: padWidth,
      height: padHeight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) => _updateKnob(details.localPosition),
        onPanUpdate: (details) => _updateKnob(details.localPosition),
        onPanEnd: (_) => resetKnob(),
        onPanCancel: () => resetKnob(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: shellColor,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: padWidth / 2 - knobSize / 2 + _knobOffset.dx,
                top: padHeight / 2 - knobSize / 2 + _knobOffset.dy,
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.65),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
