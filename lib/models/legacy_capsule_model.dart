enum CapsuleType {
  advice('advice', 'نصيحة وخبرة'),
  will('will', 'وصية شرعية/شخصية'),
  reflection('reflection', 'تأمل وبصيرة');

  final String key;
  final String label;
  const CapsuleType(this.key, this.label);

  static CapsuleType fromKey(String key) {
    switch (key) {
      case 'advice':
        return CapsuleType.advice;
      case 'will':
        return CapsuleType.will;
      case 'reflection':
      default:
        return CapsuleType.reflection;
    }
  }
}

class LegacyCapsuleModel {
  final String capsuleId;
  final String userId;
  final String title;
  final String contentEncrypted; // AES-256 encrypted base64 string
  final CapsuleType type;
  final DateTime updatedAt;

  const LegacyCapsuleModel({
    required this.capsuleId,
    required this.userId,
    required this.title,
    required this.contentEncrypted,
    required this.type,
    required this.updatedAt,
  });

  LegacyCapsuleModel copyWith({
    String? capsuleId,
    String? userId,
    String? title,
    String? contentEncrypted,
    CapsuleType? type,
    DateTime? updatedAt,
  }) {
    return LegacyCapsuleModel(
      capsuleId: capsuleId ?? this.capsuleId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      contentEncrypted: contentEncrypted ?? this.contentEncrypted,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capsuleId': capsuleId,
      'userId': userId,
      'title': title,
      'contentEncrypted': contentEncrypted,
      'type': type.key,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LegacyCapsuleModel.fromJson(Map<String, dynamic> json) {
    return LegacyCapsuleModel(
      capsuleId: json['capsuleId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      contentEncrypted: json['contentEncrypted'] as String? ?? '',
      type: CapsuleType.fromKey(json['type'] as String? ?? 'reflection'),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
