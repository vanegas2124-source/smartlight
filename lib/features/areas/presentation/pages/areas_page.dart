import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../devices/domain/entities/device.dart';
import '../../../devices/presentation/providers/device_providers.dart';
import '../../../organization/domain/entities/organization.dart';
import '../../../organization/presentation/providers/area_providers.dart';

class AreasPage extends ConsumerWidget {
  const AreasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areasProvider);
    final devicesAsync = ref.watch(devicesProvider);

    final devices = switch (devicesAsync) {
      AsyncData(:final value) => value,
      _ => const <Device>[],
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Áreas',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            const Text('Selecciona un área para ver luces y sensores.'),
            const SizedBox(height: 20),
            Expanded(
              child: switch (areasAsync) {
                AsyncData(:final value) => _AreaList(
                    areas: value,
                    devices: devices,
                  ),
                AsyncError(:final error) => Center(
                    child: Text('Error al cargar áreas: $error'),
                  ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaList extends StatelessWidget {
  const _AreaList({required this.areas, required this.devices});

  final List<Area> areas;
  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    if (areas.isEmpty) {
      return const Center(child: Text('No hay áreas registradas.'));
    }

    return ListView.separated(
      itemCount: areas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final area = areas[index];
        final areaDevices =
            devices.where((device) => device.areaId == area.id).toList();
        final lights = areaDevices
            .where((device) => device.type == DeviceType.light)
            .toList();
        final on = lights.where((device) => device.isLightOn).length;
        final watts = lights
            .where((device) => device.isLightOn && device.isOnline)
            .fold<double>(0, (sum, device) => sum + device.powerWatts);

        return Card(
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            leading: const CircleAvatar(
              child: Icon(Icons.meeting_room_outlined),
            ),
            title: Text(
              area.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${lights.length} luces · $on encendidas · '
              '${watts.toStringAsFixed(0)} W',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go('/areas/${area.id}'),
          ),
        );
      },
    );
  }
}
