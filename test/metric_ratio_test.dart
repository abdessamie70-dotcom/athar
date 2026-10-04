import 'package:flutter_test/flutter_test.dart';
import 'package:athar/models/daily_metric_model.dart';

void main() {
  group('DailyMetricModel & Ratio Formula Tests', () {
    test('Ratio should be 0.0 when both lasting and transient times are 0', () {
      const metric = DailyMetricModel(
        metricId: 'user_2026-10-04',
        userId: 'user_1',
        date: '2026-10-04',
        lastingTimeMinutes: 0,
        transientTimeMinutes: 0,
      );

      expect(metric.lastingRatio, equals(0.0));
      expect(metric.transientRatio, equals(0.0));
    });

    test('Ratio should be 100.0% when lasting > 0 and transient is 0', () {
      const metric = DailyMetricModel(
        metricId: 'user_2026-10-04',
        userId: 'user_1',
        date: '2026-10-04',
        lastingTimeMinutes: 60,
        transientTimeMinutes: 0,
      );

      expect(metric.lastingRatio, equals(100.0));
      expect(metric.transientRatio, equals(0.0));
    });

    test('Ratio formula should correctly calculate: (lasting / (lasting + transient)) * 100', () {
      const metric = DailyMetricModel(
        metricId: 'user_2026-10-04',
        userId: 'user_1',
        date: '2026-10-04',
        lastingTimeMinutes: 45,
        transientTimeMinutes: 15,
      );

      // 45 / (45 + 15) = 45 / 60 = 0.75 -> 75%
      expect(metric.lastingRatio, equals(75.0));
      expect(metric.transientRatio, equals(25.0));
    });

    test('Serialization to and from JSON preserves all fields', () {
      const metric = DailyMetricModel(
        metricId: 'user_2026-10-04',
        userId: 'user_1',
        date: '2026-10-04',
        lastingTimeMinutes: 40,
        transientTimeMinutes: 20,
        completedTarget: true,
      );

      final jsonMap = metric.toJson();
      final reconstructed = DailyMetricModel.fromJson(jsonMap);

      expect(reconstructed.metricId, equals(metric.metricId));
      expect(reconstructed.userId, equals(metric.userId));
      expect(reconstructed.date, equals(metric.date));
      expect(reconstructed.lastingTimeMinutes, equals(metric.lastingTimeMinutes));
      expect(reconstructed.transientTimeMinutes, equals(metric.transientTimeMinutes));
      expect(reconstructed.completedTarget, isTrue);
    });
  });
}
