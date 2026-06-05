import '../models/active_customer_visit.dart';
import '../models/helper_npc_state.dart';

/// Selection and movement helpers for the café NPC helper bear.
class HelperNpcService {
  const HelperNpcService._();

  static const walkStepScale = 0.65;
  static const arriveRangeInSteps = 5.0;
  static const standOffsetX = -0.04;
  static const standOffsetY = 0.05;

  static ActiveCustomerVisit? pickReadyVisit({
    required List<ActiveCustomerVisit> visits,
    required HelperNpcState helper,
    required int? playerTalkSlot,
    required double helperNormX,
    required double helperNormY,
    required double Function(ActiveCustomerVisit visit) visitNormX,
    required double Function(ActiveCustomerVisit visit) visitNormY,
    required double horizontalStep,
    required double verticalStep,
  }) {
    ActiveCustomerVisit? nearest;
    var bestDistance = double.infinity;

    for (final visit in visits) {
      if (!visit.canTalk) {
        continue;
      }
      if (playerTalkSlot == visit.slotIndex) {
        continue;
      }
      if (helper.isHandlingSlot(visit.slotIndex)) {
        continue;
      }

      final distance = _distanceBetween(
        helperNormX,
        helperNormY,
        visitNormX(visit),
        visitNormY(visit),
        horizontalStep,
        verticalStep,
      );
      if (distance >= bestDistance) {
        continue;
      }

      bestDistance = distance;
      nearest = visit;
    }

    return nearest;
  }

  static double _distanceBetween(
    double fromX,
    double fromY,
    double toX,
    double toY,
    double horizontalStep,
    double verticalStep,
  ) {
    final dx = (fromX - toX).abs() / horizontalStep;
    final dy = (fromY - toY).abs() / verticalStep;
    return dx + dy;
  }

  static bool isNearTarget({
    required double helperNormX,
    required double helperNormY,
    required double targetNormX,
    required double targetNormY,
    required double horizontalStep,
    required double verticalStep,
    double rangeInSteps = arriveRangeInSteps,
  }) {
    return _distanceBetween(
          helperNormX,
          helperNormY,
          targetNormX,
          targetNormY,
          horizontalStep,
          verticalStep,
        ) <=
        rangeInSteps;
  }

  static ({double x, double y}) stepToward({
    required double fromX,
    required double fromY,
    required double toX,
    required double toY,
    required double horizontalStep,
    required double verticalStep,
    required double minX,
    required double maxX,
    required double minY,
    required double maxY,
  }) {
    var nextX = fromX;
    var nextY = fromY;
    final dx = toX - fromX;
    final dy = toY - fromY;

    if (dx.abs() >= dy.abs()) {
      nextX += dx.sign * horizontalStep * walkStepScale;
    } else {
      nextY += dy.sign * verticalStep * walkStepScale;
    }

    return (
      x: nextX.clamp(minX, maxX),
      y: nextY.clamp(minY, maxY),
    );
  }
}
