import 'dart:async';
import 'dart:math';

import '../../../features/devices/domain/entities/device.dart';

class MockIoTService {
  MockIoTService() : _devices = _buildSeedDevices() {
    _sensorTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _simulateSensorTick(),
    );
  }

  final StreamController<List<Device>> _controller =
      StreamController<List<Device>>.broadcast();
  final List<Device> _devices;
  final Random _random = Random();
  Timer? _sensorTimer;

  static const _areaIds = <String>[
    'area-recepcion',
    'area-oficina',
    'area-reuniones',
    'area-pasillo',
    'area-bodega',
    'area-cafeteria',
  ];

  Future<List<Device>> getDevices() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return List<Device>.unmodifiable(_devices);
  }

  Stream<List<Device>> watchDevices() async* {
    yield List<Device>.unmodifiable(_devices);
    yield* _controller.stream;
  }

  Stream<Device> watchDevice(String deviceId) async* {
    await for (final devices in watchDevices()) {
      final index = devices.indexWhere((device) => device.id == deviceId);
      if (index >= 0) yield devices[index];
    }
  }

  Future<void> setLightState(
    String deviceId,
    LightState desiredState,
  ) async {
    final index = _devices.indexWhere((device) => device.id == deviceId);
    if (index < 0) {
      throw StateError('Dispositivo no encontrado.');
    }

    final current = _devices[index];
    if (current.type != DeviceType.light) {
      throw StateError('El dispositivo no es una luz.');
    }
    if (!current.isOnline) {
      throw StateError('El dispositivo está desconectado.');
    }

    _devices[index] = current.copyWith(
      desiredState: desiredState,
      lastSeen: DateTime.now(),
    );
    _emit();

    await Future<void>.delayed(const Duration(milliseconds: 650));

    final pending = _devices[index];
    _devices[index] = pending.copyWith(
      reportedState: desiredState,
      lastSeen: DateTime.now(),
    );
    _emit();
  }

  void _simulateSensorTick() {
    var changed = false;

    for (var index = 0; index < _devices.length; index++) {
      final device = _devices[index];
      if (!device.isOnline) continue;

      if (device.type == DeviceType.pirSensor) {
        _devices[index] = device.copyWith(
          motionDetected: _random.nextInt(4) == 0,
          lastSeen: DateTime.now(),
        );
        changed = true;
      }

      if (device.type == DeviceType.luxSensor) {
        _devices[index] = device.copyWith(
          luxValue: 120 + _random.nextInt(430).toDouble(),
          lastSeen: DateTime.now(),
        );
        changed = true;
      }
    }

    if (changed) _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List<Device>.unmodifiable(_devices));
    }
  }

  void dispose() {
    _sensorTimer?.cancel();
    _sensorTimer = null;
    _controller.close();
  }

  static List<Device> _buildSeedDevices() {
    final now = DateTime.now();
    final devices = <Device>[];

    for (var index = 1; index <= 15; index++) {
      final areaId = _areaIds[(index - 1) % _areaIds.length];
      final online = index != 12;
      final on = index.isEven;

      devices.add(
        Device(
          id: 'light-${index.toString().padLeft(2, '0')}',
          name: 'Luz ${index.toString().padLeft(2, '0')}',
          type: DeviceType.light,
          areaId: areaId,
          connectionStatus:
              online ? ConnectionStatus.online : ConnectionStatus.offline,
          mode: index % 3 == 0 ? DeviceMode.automatic : DeviceMode.manual,
          desiredState: on ? LightState.on : LightState.off,
          reportedState: on ? LightState.on : LightState.off,
          powerWatts: index % 3 == 0 ? 12 : 18,
          energyKwh: 0.18 + (index * 0.025),
          lastSeen: now,
          firmwareVersion: '1.0.0',
        ),
      );
    }

    for (var index = 0; index < _areaIds.length; index++) {
      final number = index + 1;
      devices.add(
        Device(
          id: 'pir-${number.toString().padLeft(2, '0')}',
          name: 'PIR ${number.toString().padLeft(2, '0')}',
          type: DeviceType.pirSensor,
          areaId: _areaIds[index],
          connectionStatus: ConnectionStatus.online,
          mode: DeviceMode.automatic,
          desiredState: LightState.unknown,
          reportedState: LightState.unknown,
          powerWatts: 0.5,
          energyKwh: 0.01,
          lastSeen: now,
          firmwareVersion: '1.0.0',
          motionDetected: index.isEven,
        ),
      );

      devices.add(
        Device(
          id: 'lux-${number.toString().padLeft(2, '0')}',
          name: 'Lux ${number.toString().padLeft(2, '0')}',
          type: DeviceType.luxSensor,
          areaId: _areaIds[index],
          connectionStatus: index == 5
              ? ConnectionStatus.offline
              : ConnectionStatus.online,
          mode: DeviceMode.automatic,
          desiredState: LightState.unknown,
          reportedState: LightState.unknown,
          powerWatts: 0.3,
          energyKwh: 0.01,
          lastSeen: now,
          firmwareVersion: '1.0.0',
          luxValue: 170 + (index * 55),
        ),
      );
    }

    return devices;
  }
}
