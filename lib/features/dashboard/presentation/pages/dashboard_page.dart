import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/metric_card.dart';
import '../../../devices/domain/entities/device.dart';
import '../../../devices/presentation/providers/device_providers.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final devicesAsync = ref.watch(devicesProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'SmartLight Enterprise',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Resumen operativo de la Sede Principal',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth >= 600 ? 1.65 : 1.25,
                children: [
                  MetricCard(
                    icon: Icons.lightbulb_rounded,
                    label: 'Luces encendidas',
                    value: '${summary.lightsOn} / ${summary.totalLights}',
                  ),
                  MetricCard(
                    icon: Icons.bolt_rounded,
                    label: 'Potencia estimada',
                    value: '${summary.currentPowerWatts.toStringAsFixed(0)} W',
                  ),
                  MetricCard(
                    icon: Icons.apartment_rounded,
                    label: 'Áreas activas',
                    value: '${summary.activeAreas}',
                  ),
                  MetricCard(
                    icon: Icons.warning_amber_rounded,
                    label: 'Dispositivos sin conexión',
                    value: '${summary.offlineDevices}',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            'Estado reciente',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          switch (devicesAsync) {
            AsyncData(:final value) => _RecentDevices(devices: value),
            AsyncError(:final error) => _MessageCard(
                icon: Icons.error_outline,
                text: 'No fue posible cargar los dispositivos: $error',
              ),
            _ => const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ),
              ),
          },
        ],
      ),
    );
  }
}

class _RecentDevices extends StatelessWidget {
  const _RecentDevices({required this.devices});

  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final recent = devices.take(5).toList();

    return Card(
      child: Column(
        children: [
          for (var index = 0; index < recent.length; index++) ...[
            ListTile(
              leading: Icon(_iconFor(recent[index].type)),
              title: Text(recent[index].name),
              subtitle: Text(
                '${recent[index].type.label} · '
                '${recent[index].connectionStatus.label}',
              ),
              trailing: recent[index].type == DeviceType.light
                  ? Text(recent[index].isLightOn ? 'ENCENDIDA' : 'APAGADA')
                  : null,
            ),
            if (index < recent.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(DeviceType type) => switch (type) {
        DeviceType.light => Icons.lightbulb_outline_rounded,
        DeviceType.pirSensor => Icons.directions_walk_rounded,
        DeviceType.luxSensor => Icons.wb_sunny_outlined,
        DeviceType.energyMeter => Icons.electric_meter_outlined,
      };
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}
