import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_area_repository.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/area_repository.dart';

final areaRepositoryProvider = Provider<AreaRepository>(
  (ref) => MockAreaRepository(),
);

final areasProvider = FutureProvider<List<Area>>(
  (ref) => ref.watch(areaRepositoryProvider).getAreas(),
);
