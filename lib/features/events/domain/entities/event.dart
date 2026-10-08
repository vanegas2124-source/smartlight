enum EventSource { user, automation, device, system }

class SmartLightEvent {
  const SmartLightEvent({
    required this.id,
    required this.type,
    required this.description,
    required this.source,
    required this.timestamp,
    this.userId,
    this.deviceId,
    this.areaId,
  });

  final String id;
  final String type;
  final String description;
  final EventSource source;
  final DateTime timestamp;
  final String? userId;
  final String? deviceId;
  final String? areaId;
}
