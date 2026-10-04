import '../../models/legacy_capsule_model.dart';

abstract class ILegacyCapsuleRepository {
  Future<List<LegacyCapsuleModel>> getCapsulesForUser(String userId);
  Future<LegacyCapsuleModel> addCapsule({
    required String userId,
    required String title,
    required String contentEncrypted,
    required CapsuleType type,
  });
  Future<void> deleteCapsule(String capsuleId);
}
