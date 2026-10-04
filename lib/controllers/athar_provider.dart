import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';
import '../models/action_log_model.dart';
import '../models/daily_metric_model.dart';
import '../models/initiative_model.dart';
import '../models/legacy_capsule_model.dart';
import '../repositories/interfaces/i_action_log_repository.dart';
import '../repositories/interfaces/i_daily_metrics_repository.dart';
import '../repositories/interfaces/i_initiatives_repository.dart';
import '../repositories/interfaces/i_legacy_capsule_repository.dart';
import '../services/encryption_service.dart';
import '../services/local_storage_service.dart';
import '../services/home_widget_service.dart';

class AtharProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final IActionLogRepository _actionLogRepo;
  final IDailyMetricsRepository _metricsRepo;
  final IInitiativesRepository _initiativesRepo;
  final ILegacyCapsuleRepository _capsuleRepo;

  UserModel _user;
  DailyMetricModel _todayMetric;
  List<ActionLogModel> _recentActions = [];
  List<InitiativeModel> _initiatives = [];
  List<LegacyCapsuleModel> _capsules = [];

  // Capsule Security State
  bool _isCapsuleUnlocked = false;
  String? _capsulePassphrase;
  final Map<String, String> _decryptedCapsuleCache = {};

  bool _isLoading = false;
  String? _errorMessage;

  AtharProvider({
    required LocalStorageService storage,
    required IActionLogRepository actionLogRepo,
    required IDailyMetricsRepository metricsRepo,
    required IInitiativesRepository initiativesRepo,
    required ILegacyCapsuleRepository capsuleRepo,
  })  : _storage = storage,
        _actionLogRepo = actionLogRepo,
        _metricsRepo = metricsRepo,
        _initiativesRepo = initiativesRepo,
        _capsuleRepo = capsuleRepo,
        _user = storage.getUser(),
        _todayMetric = DailyMetricModel(
          metricId: 'init',
          userId: storage.getUser().userId,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );

  // Getters
  UserModel get user => _user;
  DailyMetricModel get todayMetric => _todayMetric;
  List<ActionLogModel> get recentActions => List.unmodifiable(_recentActions);
  List<InitiativeModel> get initiatives => List.unmodifiable(_initiatives);
  List<LegacyCapsuleModel> get capsules => List.unmodifiable(_capsules);
  bool get isCapsuleUnlocked => _isCapsuleUnlocked;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get todayDateStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  double get todayLastingProgress {
    if (_user.dailyTargetMinutes <= 0) return 0.0;
    final progress = _todayMetric.lastingTimeMinutes / _user.dailyTargetMinutes;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Initial load of all data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = _storage.getUser();
      await refreshTodayMetric();
      await refreshRecentActions();
      await refreshInitiatives();
      await refreshCapsules();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTodayMetric() async {
    _todayMetric = await _metricsRepo.getMetricForDate(_user.userId, todayDateStr);
    notifyListeners();
    // Synchronize native Home Screen Widget with updated lasting minutes
    HomeWidgetService.updateWidgetData(lastingMinutes: _todayMetric.lastingTimeMinutes);
  }

  Future<void> refreshRecentActions() async {
    _recentActions = await _actionLogRepo.getActionsForUser(_user.userId, limit: 30);
    notifyListeners();
  }

  Future<void> refreshInitiatives() async {
    _initiatives = await _initiativesRepo.getAllInitiatives();
    notifyListeners();
  }

  Future<void> filterInitiatives({String? category, EstimatedCost? maxCost}) async {
    _initiatives = await _initiativesRepo.filterInitiatives(
      category: category,
      maxCost: maxCost,
    );
    notifyListeners();
  }

  Future<void> refreshCapsules() async {
    _capsules = await _capsuleRepo.getCapsulesForUser(_user.userId);
    if (_isCapsuleUnlocked && _capsulePassphrase != null) {
      _decryptAllWithPassphrase(_capsulePassphrase!);
    }
    notifyListeners();
  }

  // --- ACTIONS LOGIC ---
  Future<bool> logAction({
    required String title,
    required ActionCategory category,
    required int durationMinutes,
    String? notes,
    bool isPrivate = false,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _actionLogRepo.logAction(
        userId: _user.userId,
        title: title,
        category: category,
        durationMinutes: durationMinutes,
        notes: notes,
        isPrivate: isPrivate,
        dateLogged: DateTime.now(),
      );

      // Refresh both metric and actions
      await refreshTodayMetric();
      await refreshRecentActions();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAction(String actionId) async {
    await _actionLogRepo.deleteAction(actionId);
    await refreshRecentActions();
  }

  // --- TRANSIENT TIME LOGIC ---
  Future<bool> logTransientTime(int additionalMinutes) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _metricsRepo.logTransientTime(_user.userId, todayDateStr, additionalMinutes);
      await refreshTodayMetric();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- USER SETTINGS ---
  Future<void> updateDailyTarget(int newTargetMinutes) async {
    if (newTargetMinutes < 5) return;
    _user = _user.copyWith(dailyTargetMinutes: newTargetMinutes);
    await _storage.saveUser(_user);
    await refreshTodayMetric();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool enabled) async {
    _user = _user.copyWith(
      preferences: _user.preferences.copyWith(darkMode: enabled),
    );
    await _storage.saveUser(_user);
    notifyListeners();
  }

  // --- CAPSULE SECURITY ---
  bool unlockCapsule(String passphrase) {
    if (passphrase.trim().isEmpty) return false;

    // Verify passphrase if there are existing capsules
    if (_capsules.isNotEmpty) {
      // Try to decrypt the first capsule
      final sample = _capsules.first;
      final decrypted = EncryptionService.tryDecrypt(sample.contentEncrypted, passphrase);
      if (decrypted == null) {
        return false; // Wrong passphrase
      }
    }

    _isCapsuleUnlocked = true;
    _capsulePassphrase = passphrase;
    _decryptAllWithPassphrase(passphrase);
    notifyListeners();
    return true;
  }

  void lockCapsule() {
    _isCapsuleUnlocked = false;
    _capsulePassphrase = null;
    _decryptedCapsuleCache.clear();
    notifyListeners();
  }

  void _decryptAllWithPassphrase(String passphrase) {
    _decryptedCapsuleCache.clear();
    for (final c in _capsules) {
      final text = EncryptionService.tryDecrypt(c.contentEncrypted, passphrase);
      if (text != null) {
        _decryptedCapsuleCache[c.capsuleId] = text;
      }
    }
  }

  String? getDecryptedContent(String capsuleId) {
    return _decryptedCapsuleCache[capsuleId];
  }

  Future<bool> addCapsuleEntry({
    required String title,
    required String plainContent,
    required CapsuleType type,
    required String passphrase,
  }) async {
    try {
      final encrypted = EncryptionService.encryptText(plainContent, passphrase);
      final newCapsule = await _capsuleRepo.addCapsule(
        userId: _user.userId,
        title: title,
        contentEncrypted: encrypted,
        type: type,
      );

      _decryptedCapsuleCache[newCapsule.capsuleId] = plainContent;
      await refreshCapsules();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  Future<void> deleteCapsule(String capsuleId) async {
    await _capsuleRepo.deleteCapsule(capsuleId);
    _decryptedCapsuleCache.remove(capsuleId);
    await refreshCapsules();
  }
}
