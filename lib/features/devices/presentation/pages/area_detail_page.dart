import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../organization/domain/entities/organization.dart';
import '../../../organization/presentation/providers/area_providers.dart';
import '../../domain/entities/device.dart';
import '../providers/device_providers.dart';

class AreaDetailPage extends ConsumerWidget {
  const AreaDetailPage({required this.areaId, super.key});

  final String areaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areasProvider);
    final devicesAsync = ref.watch(devicesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle del área'),
      ),
      body: switch (areasAsync) {
        AsyncData(:final value) => _buildArea(
            context,
            ref,
            value,
            devicesAsync,
          ),
        AsyncError(:final error) => Center(
            child: Text('No fue posible cargar el área: $error'),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildArea(
    BuildContext context,
    WidgetRef ref,
    List<Area> areas,
    AsyncValue<List<Device>> devicesAsync,
  ) {
    final matching = areas.where((area) => area.id == areaId).toList();
    if (matching.isEmpty) {
      return const Center(child: Text('Área no encontrada.'));
    }

    final area = matching.first;

    return switch (devicesAsync) {
      AsyncData(:final value) => _AreaContent(
          area: area,
          devices: value.where((device) => device.areaId == areaId).toList(),
          onSetPower: (device, enabled) async {
            try {
              await ref.read(deviceActionsProvider).setPower(device, enabled);
            } catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.toString())),
              );
            }
          },
        ),
      AsyncError(:final error) => Center(
          child: Text('No fue posible cargar dispositivos: $error'),
        ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _AreaContent extends StatelessWidget {
  const _AreaContent({
    required this.area,
    required this.devices,
    required this.onSetPower,
  });

  final Area area;
  final List<Device> devices;
  final Future<void> Function(Device device, bool enabled) onSetPower;

  @override
  Widget build(BuildContext context) {
    final lights = devices.where((d) => d.type == DeviceType.light).toList();
    final sensors = devices.where((d) => d.type != DeviceType.light).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          area.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(area.description),
        const SizedBox(height: 24),
        Text(
          'Iluminación',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        if (lights.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Text('No hay luces registradas en esta área.'),
            ),
          )
        else
          for (final light in lights)
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  light.isLightOn
                      ? Icons.lightbulb_rounded
                      : Icons.lightbulb_outline_rounded,
                ),
                title: Text(light.name),
                subtitle: Text(_lightSubtitle(light)),
                value: light.desiredState == LightState.on,
                onChanged: light.isOnline
                    ? (enabled) => onSetPower(light, enabled)
                    : null,
              ),
            ),
        const SizedBox(height: 24),
        Text(
          'Sensores',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        for (final sensor in sensors)
          Card(
            child: ListTile(
              leading: Icon(_sensorIcon(sensor.type)),
              title: Text(sensor.name),
              subtitle: Text(sensor.connectionStatus.label),
              trailing: Text(
                _sensorValue(sensor),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
      ],
    );
  }

  static String _lightSubtitle(Device light) {
    if (!light.isOnline) return 'Desconectada';
    if (light.isCommandPending) {
      return 'Esperando confirmación · ${light.mode.label}';
    }
    return '${light.isLightOn ? 'Encendida' : 'Apagada'} · ${light.mode.label}';
  }

  static IconData _sensorIcon(DeviceType type) => switch (type) {
        DeviceType.pirSensor => Icons.directions_walk_rounded,
        DeviceType.luxSensor => Icons.wb_sunny_outlined,
        DeviceType.energyMeter => Icons.electric_meter_outlined,
        DeviceType.light => Icons.lightbulb_outline_rounded,
      };

  static String _sensorValue(Device sensor) => switch (sensor.type) {
        DeviceType.pirSensor => sensor.motionDetected == true
            ? 'Movimiento'
            : 'Sin movimiento',
        DeviceType.luxSensor => sensor.luxValue == null
            ? '-- lux'
            : '${sensor.luxValue!.toStringAsFixed(0)} lux',
        DeviceType.energyMeter => '${sensor.powerWatts.toStringAsFixed(0)} W',
        DeviceType.light => '',
      };
}
