enum ActionCategory {
  continuousKnowledge('continuous_knowledge', 'علم نافع'),
  ongoingCharity('ongoing_charity', 'صدقة جارية'),
  goodDeed('good_deed', 'عمل صالح');

  final String key;
  final String label;
  const ActionCategory(this.key, this.label);

  static ActionCategory fromKey(String key) {
    switch (key) {
      case 'continuous_knowledge':
        return ActionCategory.continuousKnowledge;
      case 'ongoing_charity':
        return ActionCategory.ongoingCharity;
      case 'good_deed':
      default:
        return ActionCategory.goodDeed;
    }
  }
}

class ActionLogModel {
  final String actionId;
  final String userId;
  final String title;
  final ActionCategory category;
  final int durationMinutes;
  final String? notes;
  final bool isPrivate;
  final DateTime dateLogged;

  const ActionLogModel({
    required this.actionId,
    required this.userId,
    required this.title,
    required this.category,
    required this.durationMinutes,
    this.notes,
    this.isPrivate = false,
    required this.dateLogged,
  });

  ActionLogModel copyWith({
    String? actionId,
    String? userId,
    String? title,
    ActionCategory? category,
    int? durationMinutes,
    String? notes,
    bool? isPrivate,
    DateTime? dateLogged,
  }) {
    return ActionLogModel(
      actionId: actionId ?? this.actionId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      isPrivate: isPrivate ?? this.isPrivate,
      dateLogged: dateLogged ?? this.dateLogged,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actionId': actionId,
      'userId': userId,
      'title': title,
      'category': category.key,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'isPrivate': isPrivate,
      'dateLogged': dateLogged.toIso8601String(),
    };
  }

  factory ActionLogModel.fromJson(Map<String, dynamic> json) {
    return ActionLogModel(
      actionId: json['actionId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: ActionCategory.fromKey(json['category'] as String? ?? 'good_deed'),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      dateLogged: json['dateLogged'] != null
          ? DateTime.tryParse(json['dateLogged'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
