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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 45),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38BDF8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x8838BDF8),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'GESTIÓN DE ESPACIOS',
                      style: TextStyle(
                        color: Color(0xFF8F9AAA),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'Áreas inteligentes',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.3,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Supervisa iluminación, consumo y conectividad de cada espacio de la sede.',
                  style: TextStyle(
                    color: Color(0xFF9DA7B5),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                switch (areasAsync) {
                  AsyncData(:final value) => _AreasDashboard(
                      areas: value,
                      devices: devices,
                    ),
                  AsyncError(:final error) => _ErrorCard(
                      message: 'No fue posible cargar las áreas: $error',
                    ),
                  _ => const Padding(
                      padding: EdgeInsets.all(50),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AreasDashboard extends StatelessWidget {
  const _AreasDashboard({
    required this.areas,
    required this.devices,
  });

  final List<Area> areas;
  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final lights = devices
        .where((device) => device.type == DeviceType.light)
        .toList();

    final lightsOn = lights
        .where(
          (device) => device.isOnline && device.isLightOn,
        )
        .length;

    final onlineDevices =
        devices.where((device) => device.isOnline).length;

    final power = lights
        .where(
          (device) => device.isOnline && device.isLightOn,
        )
        .fold<double>(
          0,
          (sum, device) => sum + device.powerWatts,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            var columns = 1;

            if (constraints.maxWidth >= 1050) {
              columns = 4;
            } else if (constraints.maxWidth >= 650) {
              columns = 2;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: columns == 4 ? 2.0 : 2.2,
              children: [
                _TopMetric(
                  icon: Icons.apartment_rounded,
                  value: '${areas.length}',
                  title: 'Áreas registradas',
                  subtitle: 'Sede Principal',
                  color: const Color(0xFF38BDF8),
                ),
                _TopMetric(
                  icon: Icons.lightbulb_rounded,
                  value: '$lightsOn / ${lights.length}',
                  title: 'Iluminación',
                  subtitle: 'Luces encendidas',
                  color: const Color(0xFFFFB020),
                ),
                _TopMetric(
                  icon: Icons.wifi_tethering_rounded,
                  value: '$onlineDevices / ${devices.length}',
                  title: 'Conectividad',
                  subtitle: 'Dispositivos online',
                  color: const Color(0xFF22C55E),
                ),
                _TopMetric(
                  icon: Icons.electric_bolt_rounded,
                  value: '${power.toStringAsFixed(0)} W',
                  title: 'Carga actual',
                  subtitle: 'Consumo de iluminación',
                  color: const Color(0xFFA78BFA),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 34),

        const Text(
          'MAPA OPERATIVO',
          style: TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Espacios de la sede',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Cada tarjeta muestra el estado actual de iluminación, sensores y consumo.',
          style: TextStyle(
            color: Color(0xFF8F9AAA),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 18),

        if (areas.isEmpty)
          const _EmptyAreas()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              var columns = 1;

              if (constraints.maxWidth >= 1050) {
                columns = 3;
              } else if (constraints.maxWidth >= 680) {
                columns = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: areas.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,

                  // ALTURA FIJA PARA EVITAR EL OVERFLOW AMARILLO
                  mainAxisExtent: 330,
                ),
                itemBuilder: (context, index) {
                  final area = areas[index];

                  final areaDevices = devices
                      .where(
                        (device) => device.areaId == area.id,
                      )
                      .toList();

                  return _AreaCard(
                    area: area,
                    devices: areaDevices,
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.area,
    required this.devices,
  });

  final Area area;
  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final lights = devices
        .where((device) => device.type == DeviceType.light)
        .toList();

    final sensors = devices
        .where((device) => device.type != DeviceType.light)
        .toList();

    final lightsOn = lights
        .where(
          (device) => device.isLightOn && device.isOnline,
        )
        .length;

    final online =
        devices.where((device) => device.isOnline).length;

    final offline = devices.length - online;

    final power = lights
        .where(
          (device) => device.isLightOn && device.isOnline,
        )
        .fold<double>(
          0,
          (sum, device) => sum + device.powerWatts,
        );

    final progress =
        lights.isEmpty ? 0.0 : lightsOn / lights.length;

    final percent = (progress * 100).round();

    final active = lightsOn > 0;
    final hasProblem = offline > 0;

    final mainColor = hasProblem
        ? const Color(0xFFFF4D5A)
        : active
            ? const Color(0xFFFFB020)
            : const Color(0xFF38BDF8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => context.go('/areas/${area.id}'),
        child: Ink(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFB020).withOpacity(.09),
                      const Color(0xFF141A23),
                    ],
                  )
                : null,
            color: active ? null : const Color(0xFF141A23),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: hasProblem
                  ? const Color(0xFF5A2830)
                  : active
                      ? const Color(0xFF493817)
                      : const Color(0xFF24303D),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: mainColor.withOpacity(.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconForArea(area.name),
                      color: mainColor,
                      size: 25,
                    ),
                  ),

                  const Spacer(),

                  _StatusBadge(
                    color: mainColor,
                    text: hasProblem
                        ? '$offline OFFLINE'
                        : active
                            ? 'ILUMINADA'
                            : 'EN ESPERA',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                area.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                area.description.isNotEmpty
                    ? area.description
                    : 'Área operativa · Sede Principal',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8F9AAA),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _AreaValue(
                      value: '$lightsOn/${lights.length}',
                      label: 'Luces',
                      color: const Color(0xFFFFB020),
                    ),
                  ),
                  Expanded(
                    child: _AreaValue(
                      value: '${sensors.length}',
                      label: 'Sensores',
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                  Expanded(
                    child: _AreaValue(
                      value: '${power.toStringAsFixed(0)}W',
                      label: 'Consumo',
                      color: const Color(0xFFA78BFA),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Iluminación',
                              style: TextStyle(
                                color: Color(0xFF8F9AAA),
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$percent%',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            color: mainColor,
                            backgroundColor:
                                mainColor.withOpacity(.10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF202833),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFFD0D5DC),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForArea(String name) {
    final lower = name.toLowerCase();

    if (lower.contains('reun')) {
      return Icons.groups_2_rounded;
    }

    if (lower.contains('recep')) {
      return Icons.countertops_rounded;
    }

    if (lower.contains('oficina')) {
      return Icons.business_center_rounded;
    }

    if (lower.contains('pasillo')) {
      return Icons.directions_walk_rounded;
    }

    if (lower.contains('bodega')) {
      return Icons.inventory_2_rounded;
    }

    if (lower.contains('cafeter')) {
      return Icons.restaurant_rounded;
    }

    return Icons.meeting_room_rounded;
  }
}

class _TopMetric extends StatelessWidget {
  const _TopMetric({
    required this.icon,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141A23),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222B36),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8F9AAA),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaValue extends StatelessWidget {
  const _AreaValue({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F9AAA),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    );
  }
}

class _EmptyAreas extends StatelessWidget {
  const _EmptyAreas();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
        color: const Color(0xFF141A23),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.apartment_rounded,
            size: 40,
            color: Color(0xFF38BDF8),
          ),
          SizedBox(height: 12),
          Text(
            'No hay áreas registradas',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D5A).withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF4D5A).withOpacity(.22),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF4D5A),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
    );
  }
}