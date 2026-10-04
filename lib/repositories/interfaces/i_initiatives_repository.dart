import '../../models/initiative_model.dart';

abstract class IInitiativesRepository {
  Future<List<InitiativeModel>> getAllInitiatives();
  Future<List<InitiativeModel>> filterInitiatives({String? category, EstimatedCost? maxCost});
}
