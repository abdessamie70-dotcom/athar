import '../../models/initiative_model.dart';
import '../../services/local_storage_service.dart';
import '../interfaces/i_initiatives_repository.dart';

class LocalInitiativesRepository implements IInitiativesRepository {
  final LocalStorageService _storage;

  LocalInitiativesRepository(this._storage);

  @override
  Future<List<InitiativeModel>> getAllInitiatives() async {
    return _storage.getInitiatives();
  }

  @override
  Future<List<InitiativeModel>> filterInitiatives({String? category, EstimatedCost? maxCost}) async {
    final list = _storage.getInitiatives();
    return list.where((item) {
      if (category != null && category.isNotEmpty && item.category != category) {
        return false;
      }
      if (maxCost != null && item.estimatedCost != maxCost) {
        return false;
      }
      return true;
    }).toList();
  }
}
