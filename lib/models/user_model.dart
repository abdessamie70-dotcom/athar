class UserPreferences {
  final bool darkMode;
  final String? reminderTime;

  const UserPreferences({
    this.darkMode = false,
    this.reminderTime,
  });

  UserPreferences copyWith({
    bool? darkMode,
    String? reminderTime,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'reminderTime': reminderTime,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String?,
    );
  }
}

class UserModel {
  final String userId;
  final String name;
  final String email;
  final int dailyTargetMinutes;
  final DateTime createdAt;
  final UserPreferences preferences;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.dailyTargetMinutes = 30,
    required this.createdAt,
    this.preferences = const UserPreferences(),
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    int? dailyTargetMinutes,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'dailyTargetMinutes': dailyTargetMinutes,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences.toJson(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String? ?? 'default_user',
      name: json['name'] as String? ?? 'عبدالله',
      email: json['email'] as String? ?? 'user@athar.app',
      dailyTargetMinutes: (json['dailyTargetMinutes'] as num?)?.toInt() ?? 30,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : const UserPreferences(),
    );
  }
}
