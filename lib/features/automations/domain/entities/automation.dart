enum AutomationTriggerType {
  motionDetected,
  noMotion,
  luxLevel,
  time,
  day,
}

enum ComparisonOperator { greaterThan, lessThan, equals }

enum AutomationActionType {
  turnDeviceOn,
  turnDeviceOff,
  turnAreaOn,
  turnAreaOff,
}

class AutomationCondition {
  const AutomationCondition({
    required this.field,
    required this.operator,
    required this.value,
  });

  final String field;
  final ComparisonOperator operator;
  final Object value;
}

class AutomationAction {
  const AutomationAction({
    required this.type,
    required this.targetId,
    this.durationMinutes,
  });

  final AutomationActionType type;
  final String targetId;
  final int? durationMinutes;
}

class Automation {
  const Automation({
    required this.id,
    required this.name,
    required this.enabled,
    required this.triggerType,
    required this.conditions,
    required this.actions,
  });

  final String id;
  final String name;
  final bool enabled;
  final AutomationTriggerType triggerType;
  final List<AutomationCondition> conditions;
  final List<AutomationAction> actions;
}
