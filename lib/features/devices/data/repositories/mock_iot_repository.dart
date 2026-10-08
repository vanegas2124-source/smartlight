import '../../../../infrastructure/iot/mock/mock_iot_service.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/iot_repository.dart';

class MockIoTRepository implements IoTRepository {
  MockIoTRepository(this._service);

  final MockIoTService _service;

  @override
  Future<List<Device>> getDevices() => _service.getDevices();

  @override
  Future<void> setLightState(String deviceId, LightState desiredState) {
    return _service.setLightState(deviceId, desiredState);
  }

  @override
  Stream<Device> watchDevice(String deviceId) {
    return _service.watchDevice(deviceId);
  }

  @override
  Stream<List<Device>> watchDevices() => _service.watchDevices();
}
