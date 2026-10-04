import 'package:uuid/uuid.dart';
import '../../models/legacy_capsule_model.dart';
import '../../services/local_storage_service.dart';
import '../interfaces/i_legacy_capsule_repository.dart';

class LocalLegacyCapsuleRepository implements ILegacyCapsuleRepository {
  final LocalStorageService _storage;
  final Uuid _uuid = const Uuid();

  LocalLegacyCapsuleRepository(this._storage);

  @override
  Future<List<LegacyCapsuleModel>> getCapsulesForUser(String userId) async {
    final capsules = _storage.getCapsules();
    final userCapsules = capsules.where((c) => c.userId == userId).toList();
    userCapsules.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return userCapsules;
  }

  @override
  Future<LegacyCapsuleModel> addCapsule({
    required String userId,
    required String title,
    required String contentEncrypted,
    required CapsuleType type,
  }) async {
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (contentEncrypted.trim().isEmpty) {
      throw ArgumentError('Encrypted content cannot be empty');
    }

    final newCapsule = LegacyCapsuleModel(
      capsuleId: _uuid.v4(),
      userId: userId,
      title: title.trim(),
      contentEncrypted: contentEncrypted.trim(),
      type: type,
      updatedAt: DateTime.now(),
    );

    final allCapsules = _storage.getCapsules();
    allCapsules.add(newCapsule);
    await _storage.saveCapsules(allCapsules);

    return newCapsule;
  }

  @override
  Future<void> deleteCapsule(String capsuleId) async {
    final allCapsules = _storage.getCapsules();
    allCapsules.removeWhere((c) => c.capsuleId == capsuleId);
    await _storage.saveCapsules(allCapsules);
  }
}
