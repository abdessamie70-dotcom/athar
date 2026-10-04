import '../../models/daily_metric_model.dart';
import '../../services/local_storage_service.dart';
import '../interfaces/i_daily_metrics_repository.dart';

class LocalDailyMetricsRepository implements IDailyMetricsRepository {
  final LocalStorageService _storage;

  LocalDailyMetricsRepository(this._storage);

  @override
  Future<DailyMetricModel> getMetricForDate(String userId, String dateString) async {
    final metricsMap = _storage.getDailyMetrics();
    final metricId = DailyMetricModel.generateMetricId(userId, dateString);

    if (metricsMap.containsKey(metricId)) {
      return metricsMap[metricId]!;
    }

    final newMetric = DailyMetricModel(
      metricId: metricId,
      userId: userId,
      date: dateString,
      transientTimeMinutes: 0,
      lastingTimeMinutes: 0,
      completedTarget: false,
    );
    metricsMap[metricId] = newMetric;
    await _storage.saveDailyMetrics(metricsMap);
    return newMetric;
  }

  @override
  Future<DailyMetricModel> logTransientTime(String userId, String dateString, int additionalMinutes) async {
    if (additionalMinutes <= 0) {
      throw ArgumentError('Minutes must be strictly positive');
    }

    final current = await getMetricForDate(userId, dateString);
    final user = _storage.getUser();

    final updated = current.copyWith(
      transientTimeMinutes: current.transientTimeMinutes + additionalMinutes,
      completedTarget: current.lastingTimeMinutes >= user.dailyTargetMinutes,
    );

    final metricsMap = _storage.getDailyMetrics();
    metricsMap[updated.metricId] = updated;
    await _storage.saveDailyMetrics(metricsMap);

    return updated;
  }

  @override
  Future<DailyMetricModel> incrementLastingTime(
    String userId,
    String dateString,
    int additionalMinutes,
    int dailyTargetMinutes,
  ) async {
    if (additionalMinutes <= 0) {
      throw ArgumentError('Minutes must be strictly positive');
    }

    final current = await getMetricForDate(userId, dateString);
    final newLasting = current.lastingTimeMinutes + additionalMinutes;

    final updated = current.copyWith(
      lastingTimeMinutes: newLasting,
      completedTarget: newLasting >= dailyTargetMinutes,
    );

    final metricsMap = _storage.getDailyMetrics();
    metricsMap[updated.metricId] = updated;
    await _storage.saveDailyMetrics(metricsMap);

    return updated;
  }

  @override
  Future<List<DailyMetricModel>> getRecentMetrics(String userId, {int days = 7}) async {
    final metricsMap = _storage.getDailyMetrics();
    final userMetrics = metricsMap.values.where((m) => m.userId == userId).toList();
    userMetrics.sort((a, b) => b.date.compareTo(a.date));
    return userMetrics.take(days).toList();
  }
}
