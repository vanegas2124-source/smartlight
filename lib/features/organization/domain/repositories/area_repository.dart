import '../entities/organization.dart';

abstract interface class AreaRepository {
  Future<List<Area>> getAreas();
}
