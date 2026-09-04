enum ScheduleTargetType { device, area }

class Schedule {
  const Schedule({
    required this.id,
    required this.name,
    required this.targetType,
    required this.targetId,
    required this.turnOnMinuteOfDay,
    required this.turnOffMinuteOfDay,
    required this.weekdays,
    required this.enabled,
  });

  final String id;
  final String name;
  final ScheduleTargetType targetType;
  final String targetId;
  final int turnOnMinuteOfDay;
  final int turnOffMinuteOfDay;
  final Set<int> weekdays;
  final bool enabled;
}
