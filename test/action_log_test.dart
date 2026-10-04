import 'package:flutter_test/flutter_test.dart';
import 'package:athar/models/action_log_model.dart';
import 'package:athar/models/daily_metric_model.dart';
import 'package:athar/repositories/interfaces/i_daily_metrics_repository.dart';
import 'package:athar/repositories/local/local_action_log_repository.dart';
import 'package:athar/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDailyMetricsRepository implements IDailyMetricsRepository {
  int totalLastingMinutes = 0;

  @override
  Future<DailyMetricModel> getMetricForDate(String userId, String dateString) async {
    return DailyMetricModel(
      metricId: '${userId}_$dateString',
      userId: userId,
      date: dateString,
      lastingTimeMinutes: totalLastingMinutes,
    );
  }

  @override
  Future<DailyMetricModel> incrementLastingTime(
    String userId,
    String dateString,
    int additionalMinutes,
    int dailyTargetMinutes,
  ) async {
    totalLastingMinutes += additionalMinutes;
    return DailyMetricModel(
      metricId: '${userId}_$dateString',
      userId: userId,
      date: dateString,
      lastingTimeMinutes: totalLastingMinutes,
      completedTarget: totalLastingMinutes >= dailyTargetMinutes,
    );
  }

  @override
  Future<DailyMetricModel> logTransientTime(String userId, String dateString, int additionalMinutes) async {
    throw UnimplementedError();
  }

  @override
  Future<List<DailyMetricModel>> getRecentMetrics(String userId, {int days = 7}) async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActionLogRepository Tests', () {
    late LocalStorageService storage;
    late MockDailyMetricsRepository mockMetricsRepo;
    late LocalActionLogRepository actionRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      mockMetricsRepo = MockDailyMetricsRepository();
      actionRepo = LocalActionLogRepository(storage, mockMetricsRepo);
    });

    test('should reject logging action with 0 or negative duration (Section 5)', () async {
      expect(
        () => actionRepo.logAction(
          userId: 'u1',
          title: 'عمل صالح',
          category: ActionCategory.goodDeed,
          durationMinutes: 0,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => actionRepo.logAction(
          userId: 'u1',
          title: 'عمل صالح',
          category: ActionCategory.goodDeed,
          durationMinutes: -10,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('logging action must trigger atomic increment of lasting minutes in daily_metrics', () async {
      expect(mockMetricsRepo.totalLastingMinutes, equals(0));

      final action = await actionRepo.logAction(
        userId: 'u1',
        title: 'مدارسة علم نافع',
        category: ActionCategory.continuousKnowledge,
        durationMinutes: 45,
      );

      expect(action.title, equals('مدارسة علم نافع'));
      expect(action.durationMinutes, equals(45));
      expect(mockMetricsRepo.totalLastingMinutes, equals(45));

      final actions = await actionRepo.getActionsForUser('u1');
      expect(actions.length, equals(1));
      expect(actions.first.actionId, equals(action.actionId));
    });
  });
}
