import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../infrastructure/iot/mock/mock_iot_service.dart';
import '../../data/repositories/mock_iot_repository.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/iot_repository.dart';

final mockIoTServiceProvider = Provider<MockIoTService>((ref) {
  final service = MockIoTService();
  ref.onDispose(service.dispose);
  return service;
});

final iotRepositoryProvider = Provider<IoTRepository>(
  (ref) => MockIoTRepository(ref.watch(mockIoTServiceProvider)),
);

final devicesProvider = StreamProvider<List<Device>>(
  (ref) => ref.watch(iotRepositoryProvider).watchDevices(),
);

final deviceActionsProvider = Provider<DeviceActions>(
  (ref) => DeviceActions(ref.watch(iotRepositoryProvider)),
);

class DeviceActions {
  DeviceActions(this._repository);

  final IoTRepository _repository;

  Future<void> setPower(Device device, bool enabled) {
    return _repository.setLightState(
      device.id,
      enabled ? LightState.on : LightState.off,
    );
  }
}
