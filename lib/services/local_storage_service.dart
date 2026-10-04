import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/action_log_model.dart';
import '../models/daily_metric_model.dart';
import '../models/initiative_model.dart';
import '../models/legacy_capsule_model.dart';

class LocalStorageService {
  static const String _userKey = 'athar_user';
  static const String _actionsKey = 'athar_actions';
  static const String _metricsKey = 'athar_daily_metrics';
  static const String _capsulesKey = 'athar_capsules';
  static const String _initiativesKey = 'athar_initiatives';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._initDefaultsIfNeeded();
    return service;
  }

  Future<void> _initDefaultsIfNeeded() async {
    // 1. Initialize default user if missing
    if (!_prefs.containsKey(_userKey)) {
      final defaultUser = UserModel(
        userId: 'local_user_1',
        name: 'عبدالله الساعي',
        email: 'user@athar.app',
        dailyTargetMinutes: 30,
        createdAt: DateTime.now(),
        preferences: const UserPreferences(darkMode: false),
      );
      await saveUser(defaultUser);
    }

    // 2. Initialize default seed initiatives if missing
    if (!_prefs.containsKey(_initiativesKey)) {
      try {
        final jsonString = await rootBundle.loadString('assets/data/seed_initiatives.json');
        final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
        final initiatives = list.map((e) => InitiativeModel.fromJson(e as Map<String, dynamic>)).toList();
        await saveInitiatives(initiatives);
      } catch (_) {
        // Fallback hardcoded if asset loading in test environment
        final fallback = [
          const InitiativeModel(
            initiativeId: 'init_01',
            category: 'knowledge',
            title: 'توثيق حل تقني مفتوح المصدر',
            description: 'كتابة شرح مبسط أو مقال تقني يحل مشكلة واجهتك أثناء العمل ونشره مجاناً لينتفع به غيرك.',
            estimatedCost: EstimatedCost.zeroCost,
            tags: ['تقنية', 'علم_نافع', 'برمجة'],
          ),
          const InitiativeModel(
            initiativeId: 'init_02',
            category: 'sadaqah',
            title: 'سقيا ماء أو صيانة مبرد مسجد',
            description: 'توفير عبوات ماء نظيفة أو فحص وصيانة دورية لبراد مياه في مكان عام أو مسجد بالحي.',
            estimatedCost: EstimatedCost.lowCost,
            tags: ['خدمة_مجتمعية', 'صدقة_جارية', 'ميداني'],
          ),
          const InitiativeModel(
            initiativeId: 'init_03',
            category: 'service',
            title: 'وقف كتاب أو مصحف للمطالعة العامة',
            description: 'إهداء نسخة مصحف برسم واضح أو كتاب علمي نافع لمكتبة عامة أو زاوية قراءة.',
            estimatedCost: EstimatedCost.lowCost,
            tags: ['تعليم', 'وقف', 'كتب'],
          ),
        ];
        await saveInitiatives(fallback);
      }
    }
  }

  // --- USER ---
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, json.encode(user.toJson()));
  }

  UserModel getUser() {
    final raw = _prefs.getString(_userKey);
    if (raw == null) {
      return UserModel(
        userId: 'local_user_1',
        name: 'عبدالله الساعي',
        email: 'user@athar.app',
        dailyTargetMinutes: 30,
        createdAt: DateTime.now(),
      );
    }
    return UserModel.fromJson(json.decode(raw) as Map<String, dynamic>);
  }

  // --- ACTIONS LOG ---
  Future<void> saveActionLogs(List<ActionLogModel> actions) async {
    final rawList = actions.map((a) => a.toJson()).toList();
    await _prefs.setString(_actionsKey, json.encode(rawList));
  }

  List<ActionLogModel> getActionLogs() {
    final raw = _prefs.getString(_actionsKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = json.decode(raw) as List<dynamic>;
      return list.map((e) => ActionLogModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- DAILY METRICS ---
  Future<void> saveDailyMetrics(Map<String, DailyMetricModel> metrics) async {
    final map = metrics.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString(_metricsKey, json.encode(map));
  }

  Map<String, DailyMetricModel> getDailyMetrics() {
    final raw = _prefs.getString(_metricsKey);
    if (raw == null) return {};
    try {
      final Map<String, dynamic> map = json.decode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, DailyMetricModel.fromJson(v as Map<String, dynamic>)));
    } catch (_) {
      return {};
    }
  }

  // --- INITIATIVES ---
  Future<void> saveInitiatives(List<InitiativeModel> initiatives) async {
    final rawList = initiatives.map((i) => i.toJson()).toList();
    await _prefs.setString(_initiativesKey, json.encode(rawList));
  }

  List<InitiativeModel> getInitiatives() {
    final raw = _prefs.getString(_initiativesKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = json.decode(raw) as List<dynamic>;
      return list.map((e) => InitiativeModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // --- CAPSULES ---
  Future<void> saveCapsules(List<LegacyCapsuleModel> capsules) async {
    final rawList = capsules.map((c) => c.toJson()).toList();
    await _prefs.setString(_capsulesKey, json.encode(rawList));
  }

  List<LegacyCapsuleModel> getCapsules() {
    final raw = _prefs.getString(_capsulesKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = json.decode(raw) as List<dynamic>;
      return list.map((e) => LegacyCapsuleModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
