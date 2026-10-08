enum AlertSeverity { info, warning, critical }

enum AlertStatus { open, resolved }

class SmartLightAlert {
  const SmartLightAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.deviceId,
    this.areaId,
    this.resolvedAt,
  });

  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertStatus status;
  final DateTime createdAt;
  final String? deviceId;
  final String? areaId;
  final DateTime? resolvedAt;
}
