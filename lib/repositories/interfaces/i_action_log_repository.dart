import '../../models/action_log_model.dart';

abstract class IActionLogRepository {
  Future<List<ActionLogModel>> getActionsForUser(String userId, {int limit = 50});
  Future<List<ActionLogModel>> getActionsForDate(String userId, DateTime date);
  Future<ActionLogModel> logAction({
    required String userId,
    required String title,
    required ActionCategory category,
    required int durationMinutes,
    String? notes,
    bool isPrivate = false,
    DateTime? dateLogged,
  });
  Future<void> deleteAction(String actionId);
}
