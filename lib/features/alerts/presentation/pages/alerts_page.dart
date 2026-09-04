import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../devices/domain/entities/device.dart';
import '../../../devices/presentation/providers/device_providers.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertas',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            const Text('Vista preliminar basada en el simulador IoT.'),
            const SizedBox(height: 20),
            Expanded(
              child: switch (devicesAsync) {
                AsyncData(:final value) => _AlertList(devices: value),
                AsyncError(:final error) => Center(
                    child: Text('Error al cargar alertas: $error'),
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

class _AlertList extends StatelessWidget {
  const _AlertList({required this.devices});

  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final offline = devices.where((device) => !device.isOnline).toList();

    if (offline.isEmpty) {
      return const Center(child: Text('No hay alertas activas.'));
    }

    return ListView.separated(
      itemCount: offline.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final device = offline[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber_rounded),
            title: Text('${device.name} sin conexión'),
            subtitle: Text(
              '${device.type.label} · ${device.connectionStatus.label}',
            ),
            trailing: const Text('ABIERTA'),
          ),
        );
      },
    );
  }
}
