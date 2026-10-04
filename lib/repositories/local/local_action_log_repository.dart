import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/action_log_model.dart';
import '../../services/local_storage_service.dart';
import '../interfaces/i_action_log_repository.dart';
import '../interfaces/i_daily_metrics_repository.dart';

class LocalActionLogRepository implements IActionLogRepository {
  final LocalStorageService _storage;
  final IDailyMetricsRepository _metricsRepository;
  final Uuid _uuid = const Uuid();

  LocalActionLogRepository(this._storage, this._metricsRepository);

  @override
  Future<List<ActionLogModel>> getActionsForUser(String userId, {int limit = 50}) async {
    final actions = _storage.getActionLogs();
    final userActions = actions.where((a) => a.userId == userId).toList();
    userActions.sort((a, b) => b.dateLogged.compareTo(a.dateLogged));
    return userActions.take(limit).toList();
  }

  @override
  Future<List<ActionLogModel>> getActionsForDate(String userId, DateTime date) async {
    final targetDateStr = DateFormat('yyyy-MM-dd').format(date);
    final actions = _storage.getActionLogs();
    return actions.where((a) {
      if (a.userId != userId) return false;
      final actionDateStr = DateFormat('yyyy-MM-dd').format(a.dateLogged);
      return actionDateStr == targetDateStr;
    }).toList();
  }

  @override
  Future<ActionLogModel> logAction({
    required String userId,
    required String title,
    required ActionCategory category,
    required int durationMinutes,
    String? notes,
    bool isPrivate = false,
    DateTime? dateLogged,
  }) async {
    // Validation per Section 5 of SPEC.md
    if (durationMinutes <= 0) {
      throw ArgumentError('Duration must be strictly greater than 0 minutes');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }

    final entryDate = dateLogged ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(entryDate);
    final user = _storage.getUser();

    final newAction = ActionLogModel(
      actionId: _uuid.v4(),
      userId: userId,
      title: title.trim(),
      category: category,
      durationMinutes: durationMinutes,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
      isPrivate: isPrivate,
      dateLogged: entryDate,
    );

    // Save action log
    final allActions = _storage.getActionLogs();
    allActions.add(newAction);
    await _storage.saveActionLogs(allActions);

    // Atomic/batch increment of daily lasting minutes in daily_metrics per Section 3.1
    await _metricsRepository.incrementLastingTime(
      userId,
      dateStr,
      durationMinutes,
      user.dailyTargetMinutes,
    );

    return newAction;
  }

  @override
  Future<void> deleteAction(String actionId) async {
    final allActions = _storage.getActionLogs();
    allActions.removeWhere((a) => a.actionId == actionId);
    await _storage.saveActionLogs(allActions);
  }
}
