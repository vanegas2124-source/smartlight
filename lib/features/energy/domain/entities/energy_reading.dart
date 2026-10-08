class EnergyReading {
  const EnergyReading({
    required this.id,
    required this.deviceId,
    required this.areaId,
    required this.timestamp,
    required this.powerWatts,
    required this.energyKwh,
  });

  final String id;
  final String deviceId;
  final String areaId;
  final DateTime timestamp;
  final double powerWatts;
  final double energyKwh;
}
