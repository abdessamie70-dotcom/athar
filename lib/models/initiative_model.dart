enum EstimatedCost {
  zeroCost('zero_cost', 'بدون تكلفة (جهد/وقت)'),
  lowCost('low_cost', 'تكلفة يسيرة'),
  highCost('high_cost', 'مشروع استثماري/وقفي');

  final String key;
  final String label;
  const EstimatedCost(this.key, this.label);

  static EstimatedCost fromKey(String key) {
    switch (key) {
      case 'zero_cost':
        return EstimatedCost.zeroCost;
      case 'low_cost':
        return EstimatedCost.lowCost;
      case 'high_cost':
        return EstimatedCost.highCost;
      default:
        return EstimatedCost.zeroCost;
    }
  }
}

class InitiativeModel {
  final String initiativeId;
  final String category; // 'knowledge', 'sadaqah', 'service'
  final String title;
  final String description;
  final EstimatedCost estimatedCost;
  final List<String> tags;

  const InitiativeModel({
    required this.initiativeId,
    required this.category,
    required this.title,
    required this.description,
    required this.estimatedCost,
    this.tags = const [],
  });

  String get categoryArabicLabel {
    switch (category) {
      case 'knowledge':
        return 'علم نافع';
      case 'sadaqah':
        return 'صدقة جارية';
      case 'service':
        return 'خدمة مجتمعية';
      default:
        return category;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'initiativeId': initiativeId,
      'category': category,
      'title': title,
      'description': description,
      'estimatedCost': estimatedCost.key,
      'tags': tags,
    };
  }

  factory InitiativeModel.fromJson(Map<String, dynamic> json) {
    return InitiativeModel(
      initiativeId: json['initiativeId'] as String? ?? '',
      category: json['category'] as String? ?? 'knowledge',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      estimatedCost: EstimatedCost.fromKey(json['estimatedCost'] as String? ?? 'zero_cost'),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
