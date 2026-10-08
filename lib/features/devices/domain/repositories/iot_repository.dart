import '../entities/device.dart';

abstract interface class IoTRepository {
  Future<List<Device>> getDevices();

  Stream<List<Device>> watchDevices();

  Stream<Device> watchDevice(String deviceId);

  Future<void> setLightState(String deviceId, LightState desiredState);
}
