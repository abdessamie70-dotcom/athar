import '../../models/daily_metric_model.dart';

abstract class IDailyMetricsRepository {
  Future<DailyMetricModel> getMetricForDate(String userId, String dateString);
  Future<DailyMetricModel> logTransientTime(String userId, String dateString, int additionalMinutes);
  Future<DailyMetricModel> incrementLastingTime(String userId, String dateString, int additionalMinutes, int dailyTargetMinutes);
  Future<List<DailyMetricModel>> getRecentMetrics(String userId, {int days = 7});
}
