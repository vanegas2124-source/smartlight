enum DeviceType { light, pirSensor, luxSensor, energyMeter }

enum ConnectionStatus { online, offline, connecting, error, unknown }

enum DeviceMode { manual, automatic, scheduled }

enum LightState { on, off, unknown }

extension DeviceTypeLabel on DeviceType {
  String get label => switch (this) {
    DeviceType.light => 'Luz',
    DeviceType.pirSensor => 'Sensor PIR',
    DeviceType.luxSensor => 'Sensor de luminosidad',
    DeviceType.energyMeter => 'Medidor de energía',
  };
}

extension ConnectionStatusLabel on ConnectionStatus {
  String get label => switch (this) {
    ConnectionStatus.online => 'En línea',
    ConnectionStatus.offline => 'Desconectado',
    ConnectionStatus.connecting => 'Conectando',
    ConnectionStatus.error => 'Error',
    ConnectionStatus.unknown => 'Desconocido',
  };
}

extension DeviceModeLabel on DeviceMode {
  String get label => switch (this) {
    DeviceMode.manual => 'Manual',
    DeviceMode.automatic => 'Automático',
    DeviceMode.scheduled => 'Programado',
  };
}

class Device {
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.areaId,
    required this.connectionStatus,
    required this.mode,
    required this.desiredState,
    required this.reportedState,
    required this.powerWatts,
    required this.energyKwh,
    required this.lastSeen,
    required this.firmwareVersion,
    this.motionDetected,
    this.luxValue,
  });

  final String id;
  final String name;
  final DeviceType type;
  final String areaId;
  final ConnectionStatus connectionStatus;
  final DeviceMode mode;
  final LightState desiredState;
  final LightState reportedState;
  final double powerWatts;
  final double energyKwh;
  final DateTime lastSeen;
  final String firmwareVersion;
  final bool? motionDetected;
  final double? luxValue;

  bool get isOnline => connectionStatus == ConnectionStatus.online;
  bool get isLightOn => reportedState == LightState.on;
  bool get isCommandPending => desiredState != reportedState;

  Device copyWith({
    String? name,
    DeviceType? type,
    String? areaId,
    ConnectionStatus? connectionStatus,
    DeviceMode? mode,
    LightState? desiredState,
    LightState? reportedState,
    double? powerWatts,
    double? energyKwh,
    DateTime? lastSeen,
    String? firmwareVersion,
    bool? motionDetected,
    double? luxValue,
  }) {
    return Device(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      areaId: areaId ?? this.areaId,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      mode: mode ?? this.mode,
      desiredState: desiredState ?? this.desiredState,
      reportedState: reportedState ?? this.reportedState,
      powerWatts: powerWatts ?? this.powerWatts,
      energyKwh: energyKwh ?? this.energyKwh,
      lastSeen: lastSeen ?? this.lastSeen,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      motionDetected: motionDetected ?? this.motionDetected,
      luxValue: luxValue ?? this.luxValue,
    );
  }
}
