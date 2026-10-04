class DailyMetricModel {
  final String metricId;
  final String userId;
  final String date; // YYYY-MM-DD
  final int transientTimeMinutes;
  final int lastingTimeMinutes;
  final bool completedTarget;

  const DailyMetricModel({
    required this.metricId,
    required this.userId,
    required this.date,
    this.transientTimeMinutes = 0,
    this.lastingTimeMinutes = 0,
    this.completedTarget = false,
  });

  /// Computes real-time lasting investment ratio:
  /// Ratio = (Lasting Time / (Lasting Time + Transient Time)) * 100
  double get lastingRatio {
    final total = lastingTimeMinutes + transientTimeMinutes;
    if (total == 0) {
      return 0.0;
    }
    return (lastingTimeMinutes / total) * 100.0;
  }

  /// Transient time ratio:
  double get transientRatio {
    final total = lastingTimeMinutes + transientTimeMinutes;
    if (total == 0) {
      return 0.0;
    }
    return (transientTimeMinutes / total) * 100.0;
  }

  DailyMetricModel copyWith({
    String? metricId,
    String? userId,
    String? date,
    int? transientTimeMinutes,
    int? lastingTimeMinutes,
    bool? completedTarget,
  }) {
    return DailyMetricModel(
      metricId: metricId ?? this.metricId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      transientTimeMinutes: transientTimeMinutes ?? this.transientTimeMinutes,
      lastingTimeMinutes: lastingTimeMinutes ?? this.lastingTimeMinutes,
      completedTarget: completedTarget ?? this.completedTarget,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metricId': metricId,
      'userId': userId,
      'date': date,
      'transientTimeMinutes': transientTimeMinutes,
      'lastingTimeMinutes': lastingTimeMinutes,
      'completedTarget': completedTarget,
    };
  }

  factory DailyMetricModel.fromJson(Map<String, dynamic> json) {
    return DailyMetricModel(
      metricId: json['metricId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      date: json['date'] as String? ?? '',
      transientTimeMinutes: (json['transientTimeMinutes'] as num?)?.toInt() ?? 0,
      lastingTimeMinutes: (json['lastingTimeMinutes'] as num?)?.toInt() ?? 0,
      completedTarget: json['completedTarget'] as bool? ?? false,
    );
  }

  static String generateMetricId(String userId, String date) => '${userId}_$date';
}
