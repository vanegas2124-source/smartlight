import '../../domain/entities/organization.dart';
import '../../domain/repositories/area_repository.dart';

class MockAreaRepository implements AreaRepository {
  static const areas = <Area>[
    Area(
      id: 'area-recepcion',
      floorId: 'floor-01',
      name: 'Recepción',
      description: 'Acceso principal y sala de espera.',
    ),
    Area(
      id: 'area-oficina',
      floorId: 'floor-01',
      name: 'Oficina administrativa',
      description: 'Zona de trabajo administrativo.',
    ),
    Area(
      id: 'area-reuniones',
      floorId: 'floor-01',
      name: 'Sala de reuniones',
      description: 'Sala para reuniones y videoconferencias.',
    ),
    Area(
      id: 'area-pasillo',
      floorId: 'floor-01',
      name: 'Pasillo',
      description: 'Circulación principal del piso.',
    ),
    Area(
      id: 'area-bodega',
      floorId: 'floor-01',
      name: 'Bodega',
      description: 'Almacenamiento y logística.',
    ),
    Area(
      id: 'area-cafeteria',
      floorId: 'floor-01',
      name: 'Cafetería',
      description: 'Zona de descanso y alimentación.',
    ),
  ];

  @override
  Future<List<Area>> getAreas() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return areas;
  }
}
