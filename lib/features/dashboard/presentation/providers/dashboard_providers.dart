import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../devices/domain/entities/device.dart';
import '../../../devices/presentation/providers/device_providers.dart';
import '../../../organization/domain/entities/organization.dart';
import '../../../organization/presentation/providers/area_providers.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalLights,
    required this.lightsOn,
    required this.activeAreas,
    required this.offlineDevices,
    required this.currentPowerWatts,
  });

  final int totalLights;
  final int lightsOn;
  final int activeAreas;
  final int offlineDevices;
  final double currentPowerWatts;
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final devicesAsync = ref.watch(devicesProvider);
  final areasAsync = ref.watch(areasProvider);

  final devices = switch (devicesAsync) {
    AsyncData(:final value) => value,
    _ => const <Device>[],
  };

  final areas = switch (areasAsync) {
    AsyncData(:final value) => value,
    _ => const <Area>[],
  };

  final lights = devices.where((device) => device.type == DeviceType.light);
  final lightsOn = lights.where((device) => device.isLightOn).length;
  final activeAreaIds = devices
      .where((device) => device.isOnline)
      .map((device) => device.areaId)
      .toSet();
  final power = lights
      .where((device) => device.isLightOn && device.isOnline)
      .fold<double>(0, (total, device) => total + device.powerWatts);

  return DashboardSummary(
    totalLights: lights.length,
    lightsOn: lightsOn,
    activeAreas: areas.where((area) => activeAreaIds.contains(area.id)).length,
    offlineDevices:
        devices.where((device) => !device.isOnline).length,
    currentPowerWatts: power,
  );
});
