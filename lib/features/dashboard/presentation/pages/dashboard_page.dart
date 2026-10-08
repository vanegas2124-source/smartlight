import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../devices/domain/entities/device.dart';
import '../../../devices/presentation/providers/device_providers.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  Future<void> _setAllLights(
    WidgetRef ref,
    List<Device> devices,
    bool enabled,
  ) async {
    final actions = ref.read(deviceActionsProvider);

    final lights = devices.where(
      (device) =>
          device.type == DeviceType.light &&
          device.isOnline,
    );

    for (final light in lights) {
      await actions.setPower(light, enabled);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(dashboardSummaryProvider);
    final devicesAsync = ref.watch(devicesProvider);

    final devices = switch (devicesAsync) {
      AsyncData(:final value) => value,
      _ => const <Device>[],
    };

    final onlineDevices =
        devices.where((device) => device.isOnline).length;

    final totalDevices = devices.length;

    final lightProgress = summary.totalLights == 0
        ? 0.0
        : summary.lightsOn / summary.totalLights;

    final networkProgress = totalDevices == 0
        ? 0.0
        : onlineDevices / totalDevices;

    final chartValues = devices
        .where((device) => device.type == DeviceType.light)
        .take(12)
        .map(
          (device) =>
              device.isLightOn ? device.powerWatts : 0.0,
        )
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          28,
          28,
          45,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1500,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // CABECERA
                // =====================================================

                _Header(
                  devices: devices,
                  onAllOn: () => _setAllLights(
                    ref,
                    devices,
                    true,
                  ),
                  onAllOff: () => _setAllLights(
                    ref,
                    devices,
                    false,
                  ),
                ),

                const SizedBox(height: 28),

                // =====================================================
                // TARJETAS PRINCIPALES
                // =====================================================

                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop =
                        constraints.maxWidth >= 950;

                    if (desktop) {
                      return SizedBox(
                        height: 365,
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _LightingHero(
                                lightsOn: summary.lightsOn,
                                totalLights:
                                    summary.totalLights,
                                progress: lightProgress,
                                power:
                                    summary.currentPowerWatts,
                                onAllOn: () =>
                                    _setAllLights(
                                  ref,
                                  devices,
                                  true,
                                ),
                                onAllOff: () =>
                                    _setAllLights(
                                  ref,
                                  devices,
                                  false,
                                ),
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              flex: 7,
                              child: _EnergyHero(
                                power:
                                    summary.currentPowerWatts,
                                chartValues: chartValues,
                                lightsOn: summary.lightsOn,
                                totalLights:
                                    summary.totalLights,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(
                          height: 365,
                          child: _LightingHero(
                            lightsOn: summary.lightsOn,
                            totalLights:
                                summary.totalLights,
                            progress: lightProgress,
                            power:
                                summary.currentPowerWatts,
                            onAllOn: () =>
                                _setAllLights(
                              ref,
                              devices,
                              true,
                            ),
                            onAllOff: () =>
                                _setAllLights(
                              ref,
                              devices,
                              false,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 365,
                          child: _EnergyHero(
                            power:
                                summary.currentPowerWatts,
                            chartValues: chartValues,
                            lightsOn: summary.lightsOn,
                            totalLights:
                                summary.totalLights,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 18),

                // =====================================================
                // MÉTRICAS PEQUEÑAS
                // =====================================================

                LayoutBuilder(
                  builder: (context, constraints) {
                    int columns = 1;

                    if (constraints.maxWidth >= 1050) {
                      columns = 4;
                    } else if (constraints.maxWidth >= 620) {
                      columns = 2;
                    }

                    return GridView.count(
                      crossAxisCount: columns,
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio:
                          columns == 4 ? 2.0 : 2.2,
                      children: [
                        _MiniMetric(
                          icon:
                              Icons.wifi_tethering_rounded,
                          value:
                              '$onlineDevices / $totalDevices',
                          title:
                              'Dispositivos conectados',
                          subtitle:
                              '${(networkProgress * 100).round()}% operativos',
                          color:
                              const Color(0xFF22C55E),
                        ),

                        _MiniMetric(
                          icon: Icons.apartment_rounded,
                          value:
                              '${summary.activeAreas}',
                          title: 'Áreas activas',
                          subtitle:
                              'Sede Principal',
                          color:
                              const Color(0xFF38BDF8),
                        ),

                        _MiniMetric(
                          icon: Icons
                              .warning_amber_rounded,
                          value:
                              '${summary.offlineDevices}',
                          title: 'Alertas',
                          subtitle:
                              summary.offlineDevices == 0
                                  ? 'Todo funciona correctamente'
                                  : 'Requieren revisión',
                          color:
                              summary.offlineDevices == 0
                                  ? const Color(
                                      0xFF22C55E,
                                    )
                                  : const Color(
                                      0xFFFF4D5A,
                                    ),
                        ),

                        _MiniMetric(
                          icon: Icons
                              .electric_bolt_rounded,
                          value:
                              '${summary.currentPowerWatts.toStringAsFixed(0)} W',
                          title: 'Carga actual',
                          subtitle:
                              'Consumo instantáneo',
                          color:
                              const Color(0xFFA78BFA),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 34),

                // =====================================================
                // DISPOSITIVOS
                // =====================================================

                const _SectionHeader(
                  label: 'OPERACIÓN EN VIVO',
                  title: 'Control de luminarias',
                  subtitle:
                      'Supervisa y controla rápidamente los dispositivos de iluminación.',
                ),

                const SizedBox(height: 16),

                switch (devicesAsync) {
                  AsyncData(:final value) => _DeviceGrid(
                      devices: value,
                      onChanged:
                          (device, enabled) async {
                        await ref
                            .read(deviceActionsProvider)
                            .setPower(
                              device,
                              enabled,
                            );
                      },
                    ),

                  AsyncError(:final error) => _ErrorCard(
                      message:
                          'No fue posible cargar los dispositivos: $error',
                    ),

                  _ => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                },

                const SizedBox(height: 30),

                // =====================================================
                // ESTADO GENERAL
                // =====================================================

                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop =
                        constraints.maxWidth >= 900;

                    if (desktop) {
                      return Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _NetworkCard(
                              online: onlineDevices,
                              total: totalDevices,
                              progress:
                                  networkProgress,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: _AlertCard(
                              offlineCount:
                                  summary.offlineDevices,
                              devices: devices,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _NetworkCard(
                          online: onlineDevices,
                          total: totalDevices,
                          progress:
                              networkProgress,
                        ),

                        const SizedBox(height: 16),

                        _AlertCard(
                          offlineCount:
                              summary.offlineDevices,
                          devices: devices,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  const _Header({
    required this.devices,
    required this.onAllOn,
    required this.onAllOff,
  });

  final List<Device> devices;
  final VoidCallback onAllOn;
  final VoidCallback onAllOff;

  @override
  Widget build(BuildContext context) {
    final canControl = devices.any(
      (device) =>
          device.type == DeviceType.light &&
          device.isOnline,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop =
            constraints.maxWidth >= 760;

        final title = Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x8822C55E),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Text(
                  'SMARTLIGHT CONTROL CENTER',
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

            Text(
              'Control inteligente\nde iluminación.',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    fontSize:
                        desktop ? 38 : 30,
                    height: 1.05,
                    letterSpacing: -1.4,
                    fontWeight:
                        FontWeight.w900,
                  ),
            ),

            const SizedBox(height: 10),

            Text(
              'Gestiona energía, conectividad y dispositivos desde una sola plataforma.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    color:
                        const Color(0xFF9DA7B5),
                  ),
            ),
          ],
        );

        final controls = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed:
                  canControl ? onAllOff : null,
              icon: const Icon(
                Icons.power_settings_new_rounded,
              ),
              label:
                  const Text('Apagar todas'),
            ),

            FilledButton.icon(
              onPressed:
                  canControl ? onAllOn : null,
              icon: const Icon(
                Icons.lightbulb_rounded,
              ),
              label:
                  const Text('Encender luces'),
            ),
          ],
        );

        if (!desktop) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 20),
              controls,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const SizedBox(width: 30),
            controls,
          ],
        );
      },
    );
  }
}

// ============================================================================
// ILUMINACIÓN HERO
// ============================================================================

class _LightingHero extends StatelessWidget {
  const _LightingHero({
    required this.lightsOn,
    required this.totalLights,
    required this.progress,
    required this.power,
    required this.onAllOn,
    required this.onAllOff,
  });

  final int lightsOn;
  final int totalLights;
  final double progress;
  final double power;

  final VoidCallback onAllOn;
  final VoidCallback onAllOff;

  @override
  Widget build(BuildContext context) {
    final percent =
        (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF211B11),
            Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(28),
        border: Border.all(
          color:
              const Color(0xFF493817),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFFFB020,
            ).withOpacity(.07),
            blurRadius: 38,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color: const Color(
                    0xFFFFB020,
                  ).withOpacity(.14),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFFFFB020),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ILUMINACIÓN',
                      style: TextStyle(
                        color: Color(0xFFFFB020),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Estado general',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Row(
              children: [
                _ProgressRing(
                  progress: progress,
                  color:
                      const Color(0xFFFFB020),
                  value: '$percent%',
                  label: 'activo',
                  size: 142,
                ),

                const SizedBox(width: 26),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$lightsOn de $totalLights',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontSize: 28,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'luces encendidas',
                        style: TextStyle(
                          color:
                              Color(0xFF9DA7B5),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color:
                                Color(0xFFFFB020),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${power.toStringAsFixed(0)} W',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'en uso',
                            style: TextStyle(
                              color:
                                  Color(0xFF9DA7B5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAllOff,
                  icon: const Icon(
                    Icons.power_settings_new,
                    size: 18,
                  ),
                  label: const Text('Apagar'),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: FilledButton.icon(
                  onPressed: onAllOn,
                  icon: const Icon(
                    Icons.lightbulb,
                    size: 18,
                  ),
                  label:
                      const Text('Encender'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ENERGÍA HERO
// ============================================================================

class _EnergyHero extends StatelessWidget {
  const _EnergyHero({
    required this.power,
    required this.chartValues,
    required this.lightsOn,
    required this.totalLights,
  });

  final double power;
  final List<double> chartValues;

  final int lightsOn;
  final int totalLights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF14222D),
            Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(28),
        border: Border.all(
          color:
              const Color(0xFF203A4C),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFF38BDF8)
                          .withOpacity(.13),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Color(0xFF38BDF8),
                  size: 25,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ENERGÍA',
                      style: TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      'Consumo en tiempo real',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    '${power.toStringAsFixed(0)} W',
                    style:
                        const TextStyle(
                      fontSize: 27,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'carga actual',
                    style:
                        TextStyle(
                      color:
                          Color(0xFF8F9AAA),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(18),
                color:
                    const Color(0xFF0E151D),
                border: Border.all(
                  color:
                      const Color(0xFF1D2C39),
                ),
              ),
              padding:
                  const EdgeInsets.fromLTRB(
                15,
                20,
                15,
                15,
              ),
              child: CustomPaint(
                painter: _ChartPainter(
                  points:
                      chartValues.isEmpty
                          ? const [
                              0,
                              0,
                              0,
                              0,
                              0,
                              0,
                            ]
                          : chartValues,
                ),
                child:
                    const SizedBox.expand(),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              _EnergyBottomInfo(
                title: 'Luces activas',
                value:
                    '$lightsOn / $totalLights',
                icon:
                    Icons.lightbulb_outline,
              ),

              const SizedBox(width: 28),

              _EnergyBottomInfo(
                title: 'Potencia',
                value:
                    '${power.toStringAsFixed(0)} W',
                icon:
                    Icons.electric_bolt,
              ),

              const Spacer(),

              const Text(
                'Distribución por luminaria',
                style: TextStyle(
                  color: Color(0xFF8F9AAA),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EnergyBottomInfo
    extends StatelessWidget {
  const _EnergyBottomInfo({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color:
              const Color(0xFF38BDF8),
        ),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color:
                    Color(0xFF8F9AAA),
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// MINI MÉTRICA
// ============================================================================

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
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
        color:
            const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFF222B36),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration:
                BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF8F9AAA),
                    fontSize: 10,
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

// ============================================================================
// TITULO SECCIÓN
// ============================================================================

class _SectionHeader
    extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: Color(0xFFFFB020),
            fontSize: 10,
            fontWeight:
                FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          style:
              const TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.w900,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style:
              const TextStyle(
            color:
                Color(0xFF8F9AAA),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// GRID DISPOSITIVOS
// ============================================================================

class _DeviceGrid extends StatelessWidget {
  const _DeviceGrid({
    required this.devices,
    required this.onChanged,
  });

  final List<Device> devices;

  final Future<void> Function(
    Device device,
    bool enabled,
  ) onChanged;

  @override
  Widget build(BuildContext context) {
    final lights = devices
        .where(
          (device) =>
              device.type ==
              DeviceType.light,
        )
        .take(6)
        .toList();

    if (lights.isEmpty) {
      return const _ErrorCard(
        message:
            'No hay luminarias registradas.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >=
            1100) {
          columns = 3;
        } else if (constraints.maxWidth >=
            700) {
          columns = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: lights.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio:
                columns == 1 ? 2.8 : 2.0,
          ),
          itemBuilder:
              (context, index) {
            final device =
                lights[index];

            return _DeviceCard(
              device: device,
              onChanged:
                  device.isOnline
                      ? (enabled) {
                          onChanged(
                            device,
                            enabled,
                          );
                        }
                      : null,
            );
          },
        );
      },
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.onChanged,
  });

  final Device device;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isOn =
        device.isLightOn;

    final online =
        device.isOnline;

    final statusColor = !online
        ? const Color(0xFFFF4D5A)
        : isOn
            ? const Color(0xFFFFB020)
            : const Color(0xFF22C55E);

    return AnimatedContainer(
      duration:
          const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isOn
            ? LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  const Color(
                    0xFFFFB020,
                  ).withOpacity(.09),
                  const Color(
                    0xFF141A23,
                  ),
                ],
              )
            : null,
        color: isOn
            ? null
            : const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: isOn
              ? const Color(0xFF493817)
              : const Color(0xFF222B36),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color:
                      statusColor.withOpacity(
                    .12,
                  ),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  isOn
                      ? Icons.lightbulb
                      : Icons
                          .lightbulb_outline,
                  color: statusColor,
                ),
              ),

              const Spacer(),

              Switch.adaptive(
                value: isOn,
                onChanged: onChanged,
              ),
            ],
          ),

          const Spacer(),

          Text(
            device.name,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(
                  color: online
                      ? const Color(
                          0xFF22C55E,
                        )
                      : const Color(
                          0xFFFF4D5A,
                        ),
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  device
                      .connectionStatus
                      .label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF8F9AAA),
                    fontSize: 11,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      statusColor.withOpacity(
                    .10,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '${device.powerWatts.toStringAsFixed(0)} W',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight:
                        FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// RED
// ============================================================================

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({
    required this.online,
    required this.total,
    required this.progress,
  });

  final int online;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 200,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              const Color(0xFF20352C),
        ),
      ),
      child: Row(
        children: [
          _ProgressRing(
            progress: progress,
            color:
                const Color(0xFF22C55E),
            value:
                '${(progress * 100).round()}%',
            label: 'online',
            size: 125,
          ),

          const SizedBox(width: 24),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'SALUD DE RED',
                  style:
                      TextStyle(
                    color:
                        Color(0xFF22C55E),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '$online de $total dispositivos',
                  style:
                      const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Conectividad general del ecosistema SmartLight.',
                  style:
                      TextStyle(
                    color:
                        Color(0xFF8F9AAA),
                    fontSize: 12,
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

// ============================================================================
// ALERTAS
// ============================================================================

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.offlineCount,
    required this.devices,
  });

  final int offlineCount;
  final List<Device> devices;

  @override
  Widget build(BuildContext context) {
    final offline = devices
        .where(
          (device) => !device.isOnline,
        )
        .take(3)
        .toList();

    final hasProblems =
        offlineCount > 0;

    final color = hasProblems
        ? const Color(0xFFFF4D5A)
        : const Color(0xFF22C55E);

    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 200,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            color.withOpacity(.08),
            const Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              color.withOpacity(.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(.13),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  hasProblems
                      ? Icons
                          .warning_amber_rounded
                      : Icons.verified_rounded,
                  color: color,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasProblems
                          ? 'Requiere atención'
                          : 'Todo funcionando',
                      style:
                          const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      hasProblems
                          ? '$offlineCount dispositivos sin conexión'
                          : 'No existen incidencias activas',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF8F9AAA),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          if (!hasProblems)
            const Text(
              'Todos los dispositivos reportan conectividad normal.',
              style: TextStyle(
                color:
                    Color(0xFFADB5C0),
                fontSize: 12,
              ),
            )
          else
            for (final device in offline)
              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xFFFF4D5A),
                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        '${device.name} · ${device.type.label}',
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontSize: 12,
                        ),
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

// ============================================================================
// PROGRESS RING
// ============================================================================

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.color,
    required this.value,
    required this.label,
    this.size = 140,
  });

  final double progress;
  final Color color;
  final String value;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final safeProgress =
        progress.clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: safeProgress,
            strokeWidth: 10,
            color: color,
            backgroundColor:
                color.withOpacity(.10),
            strokeCap: StrokeCap.round,
          ),

          Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  value,
                  style:
                      TextStyle(
                    fontSize:
                        size >= 130 ? 28 : 22,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  label,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF8F9AAA),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
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

// ============================================================================
// GRÁFICA
// ============================================================================

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.points,
  });

  final List<double> points;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final grid = Paint()
      ..color =
          const Color(0xFF293642)
              .withOpacity(.65)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y =
          size.height * i / 4;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        grid,
      );
    }

    if (points.length < 2) {
      return;
    }

    var maxValue = 0.0;

    for (final value in points) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) {
      maxValue = 1;
    }

    final step =
        size.width / (points.length - 1);

    final path = Path();
    final fill = Path();

    for (int i = 0;
        i < points.length;
        i++) {
      final x = i * step;

      final normalized =
          points[i] / maxValue;

      final y = size.height -
          (normalized *
              size.height *
              .72) -
          size.height * .12;

      if (i == 0) {
        path.moveTo(x, y);

        fill.moveTo(
          x,
          size.height,
        );

        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }

    fill.lineTo(
      size.width,
      size.height,
    );

    fill.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin:
            Alignment.topCenter,
        end:
            Alignment.bottomCenter,
        colors: [
          const Color(
            0xFF38BDF8,
          ).withOpacity(.25),
          const Color(
            0xFF38BDF8,
          ).withOpacity(.01),
        ],
      ).createShader(
        Offset.zero & size,
      );

    canvas.drawPath(
      fill,
      fillPaint,
    );

    final linePaint = Paint()
      ..color =
          const Color(0xFF38BDF8)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap =
          StrokeCap.round
      ..strokeJoin =
          StrokeJoin.round;

    canvas.drawPath(
      path,
      linePaint,
    );

    final pointPaint = Paint()
      ..color =
          const Color(0xFF38BDF8);

    for (int i = 0;
        i < points.length;
        i++) {
      final x = i * step;

      final normalized =
          points[i] / maxValue;

      final y = size.height -
          (normalized *
              size.height *
              .72) -
          size.height * .12;

      canvas.drawCircle(
        Offset(x, y),
        3.5,
        pointPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ChartPainter oldDelegate,
  ) {
    return oldDelegate.points != points;
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            const Color(0xFFFF4D5A)
                .withOpacity(.08),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              const Color(0xFFFF4D5A)
                  .withOpacity(.25),
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