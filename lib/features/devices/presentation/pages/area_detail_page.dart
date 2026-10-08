import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../organization/domain/entities/organization.dart';
import '../../../organization/presentation/providers/area_providers.dart';
import '../../domain/entities/device.dart';
import '../providers/device_providers.dart';

class AreaDetailPage extends ConsumerWidget {
  const AreaDetailPage({
    required this.areaId,
    super.key,
  });

  final String areaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areasProvider);
    final devicesAsync = ref.watch(devicesProvider);

    return SafeArea(
      child: switch (areasAsync) {
        AsyncData(:final value) => _buildArea(
            context,
            ref,
            value,
            devicesAsync,
          ),
        AsyncError(:final error) => Center(
            child: Text(
              'No fue posible cargar el área: $error',
            ),
          ),
        _ => const Center(
            child: CircularProgressIndicator(),
          ),
      },
    );
  }

  Widget _buildArea(
    BuildContext context,
    WidgetRef ref,
    List<Area> areas,
    AsyncValue<List<Device>> devicesAsync,
  ) {
    final matching = areas
        .where(
          (area) => area.id == areaId,
        )
        .toList();

    if (matching.isEmpty) {
      return const Center(
        child: Text('Área no encontrada.'),
      );
    }

    final area = matching.first;

    return switch (devicesAsync) {
      AsyncData(:final value) => _AreaContent(
          area: area,
          devices: value
              .where(
                (device) =>
                    device.areaId == areaId,
              )
              .toList(),
          onSetPower: (device, enabled) async {
            try {
              await ref
                  .read(deviceActionsProvider)
                  .setPower(
                    device,
                    enabled,
                  );
            } catch (error) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    error.toString(),
                  ),
                ),
              );
            }
          },
        ),

      AsyncError(:final error) => Center(
          child: Text(
            'No fue posible cargar dispositivos: $error',
          ),
        ),

      _ => const Center(
          child: CircularProgressIndicator(),
        ),
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

  final Future<void> Function(
    Device device,
    bool enabled,
  ) onSetPower;

  @override
  Widget build(BuildContext context) {
    final lights = devices
        .where(
          (device) =>
              device.type ==
              DeviceType.light,
        )
        .toList();

    final sensors = devices
        .where(
          (device) =>
              device.type !=
              DeviceType.light,
        )
        .toList();

    final onlineLights = lights
        .where(
          (device) =>
              device.isOnline,
        )
        .toList();

    final lightsOn = lights
        .where(
          (device) =>
              device.isOnline &&
              device.isLightOn,
        )
        .length;

    final offline =
        devices
            .where(
              (device) =>
                  !device.isOnline,
            )
            .length;

    final power = lights
        .where(
          (device) =>
              device.isOnline &&
              device.isLightOn,
        )
        .fold<double>(
          0,
          (sum, device) =>
              sum + device.powerWatts,
        );

    final energy = devices.fold<double>(
      0,
      (sum, device) =>
          sum + device.energyKwh,
    );

    final progress =
        lights.isEmpty
            ? 0.0
            : lightsOn / lights.length;

    Device? pirSensor;
    Device? luxSensor;

    for (final sensor in sensors) {
      if (sensor.type ==
              DeviceType.pirSensor &&
          pirSensor == null) {
        pirSensor = sensor;
      }

      if (sensor.type ==
              DeviceType.luxSensor &&
          luxSensor == null) {
        luxSensor = sensor;
      }
    }

    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        28,
        24,
        28,
        45,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1500,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =================================================
              // VOLVER
              // =================================================

              InkWell(
                borderRadius:
                    BorderRadius.circular(12),
                onTap: () => context.pop(),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .arrow_back_rounded,
                        size: 19,
                        color:
                            Color(
                          0xFF9DA7B5,
                        ),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Volver a áreas',
                        style: TextStyle(
                          color:
                              Color(
                            0xFF9DA7B5,
                          ),
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // HEADER
              // =================================================

              LayoutBuilder(
                builder:
                    (context, constraints) {
                  final desktop =
                      constraints.maxWidth >=
                          760;

                  final title = Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration:
                                const BoxDecoration(
                              color:
                                  Color(
                                0xFF38BDF8,
                              ),
                              shape:
                                  BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Color(
                                    0x8838BDF8,
                                  ),
                                  blurRadius:
                                      10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text(
                            'CONTROL DE ÁREA',
                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF8F9AAA,
                              ),
                              fontSize:
                                  11,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              letterSpacing:
                                  1.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        area.name,
                        style:
                            const TextStyle(
                          fontSize: 38,
                          fontWeight:
                              FontWeight
                                  .w900,
                          letterSpacing:
                              -1.2,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Text(
                        area.description,
                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF9DA7B5,
                          ),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  );

                  final status =
                      _AreaStatusBadge(
                    offline: offline,
                    active:
                        lightsOn > 0,
                  );

                  if (!desktop) {
                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        title,
                        const SizedBox(
                          height: 16,
                        ),
                        status,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Expanded(
                        child: title,
                      ),
                      status,
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // =================================================
              // DOS PANELES PRINCIPALES
              // =================================================

              LayoutBuilder(
                builder:
                    (context, constraints) {
                  final desktop =
                      constraints.maxWidth >=
                          900;

                  final illumination =
                      _IlluminationPanel(
                    lightsOn: lightsOn,
                    totalLights:
                        lights.length,
                    progress: progress,
                    power: power,
                    onlineLights:
                        onlineLights,
                    onSetPower:
                        onSetPower,
                  );

                  final environment =
                      _EnvironmentPanel(
                    pirSensor: pirSensor,
                    luxSensor: luxSensor,
                    sensorCount:
                        sensors.length,
                    offlineCount:
                        offline,
                    energy: energy,
                  );

                  if (!desktop) {
                    return Column(
                      children: [
                        illumination,
                        const SizedBox(
                          height: 16,
                        ),
                        environment,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Expanded(
                        child:
                            illumination,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child:
                            environment,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 34),

              // =================================================
              // LUCES
              // =================================================

              const _SectionTitle(
                label:
                    'ILUMINACIÓN INTELIGENTE',
                title:
                    'Control de luminarias',
                subtitle:
                    'Gestiona individualmente cada punto de luz del área.',
                color:
                    Color(0xFFFFB020),
              ),

              const SizedBox(height: 16),

              if (lights.isEmpty)
                const _EmptyCard(
                  icon: Icons
                      .lightbulb_outline,
                  title:
                      'No hay luminarias',
                  subtitle:
                      'Esta área no tiene luces registradas.',
                )
              else
                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    var columns = 1;

                    if (constraints
                            .maxWidth >=
                        1050) {
                      columns = 3;
                    } else if (constraints
                            .maxWidth >=
                        680) {
                      columns = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          lights.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            columns,
                        crossAxisSpacing:
                            14,
                        mainAxisSpacing:
                            14,
                        mainAxisExtent:
                            205,
                      ),
                      itemBuilder:
                          (context, index) {
                        final light =
                            lights[index];

                        return _LightCard(
                          light: light,
                          onChanged:
                              light.isOnline
                                  ? (enabled) {
                                      onSetPower(
                                        light,
                                        enabled,
                                      );
                                    }
                                  : null,
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 34),

              // =================================================
              // SENSORES
              // =================================================

              const _SectionTitle(
                label:
                    'TELEMETRÍA EN VIVO',
                title: 'Sensores',
                subtitle:
                    'Lecturas ambientales y estado de conectividad del área.',
                color:
                    Color(0xFF38BDF8),
              ),

              const SizedBox(height: 16),

              if (sensors.isEmpty)
                const _EmptyCard(
                  icon:
                      Icons.sensors_off,
                  title:
                      'No hay sensores',
                  subtitle:
                      'Esta área no tiene sensores registrados.',
                )
              else
                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    var columns = 1;

                    if (constraints
                            .maxWidth >=
                        1050) {
                      columns = 3;
                    } else if (constraints
                            .maxWidth >=
                        680) {
                      columns = 2;
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount:
                          sensors.length,
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            columns,
                        crossAxisSpacing:
                            14,
                        mainAxisSpacing:
                            14,
                        mainAxisExtent:
                            190,
                      ),
                      itemBuilder:
                          (context, index) {
                        return _SensorCard(
                          sensor:
                              sensors[index],
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ESTADO DEL ÁREA
// ================================================================

class _AreaStatusBadge extends StatelessWidget {
  const _AreaStatusBadge({
    required this.offline,
    required this.active,
  });

  final int offline;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = offline > 0
        ? const Color(0xFFFF4D5A)
        : active
            ? const Color(0xFFFFB020)
            : const Color(0xFF22C55E);

    final text = offline > 0
        ? '$offline DISPOSITIVO(S) OFFLINE'
        : active
            ? 'ILUMINACIÓN ACTIVA'
            : 'SISTEMA OPERATIVO';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color:
              color.withOpacity(.20),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PANEL ILUMINACIÓN
// ================================================================

class _IlluminationPanel
    extends StatelessWidget {
  const _IlluminationPanel({
    required this.lightsOn,
    required this.totalLights,
    required this.progress,
    required this.power,
    required this.onlineLights,
    required this.onSetPower,
  });

  final int lightsOn;
  final int totalLights;
  final double progress;
  final double power;

  final List<Device> onlineLights;

  final Future<void> Function(
    Device device,
    bool enabled,
  ) onSetPower;

  Future<void> _setAll(
    bool enabled,
  ) async {
    for (final light
        in onlineLights) {
      await onSetPower(
        light,
        enabled,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent =
        (progress * 100).round();

    return Container(
      padding:
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF211B11),
            Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color:
              const Color(0xFF493817),
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
                      const Color(
                    0xFFFFB020,
                  ).withOpacity(.13),
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
                child: const Icon(
                  Icons
                      .lightbulb_rounded,
                  color:
                      Color(
                    0xFFFFB020,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'ILUMINACIÓN',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFFFFB020,
                        ),
                        fontSize: 10,
                        fontWeight:
                            FontWeight
                                .w900,
                        letterSpacing:
                            1.2,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Estado general',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          Row(
            children: [
              _ProgressRing(
                value:
                    progress,
                text:
                    '$percent%',
                color:
                    const Color(
                  0xFFFFB020,
                ),
              ),

              const SizedBox(
                width: 24,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      '$lightsOn de $totalLights',
                      style:
                          const TextStyle(
                        fontSize: 25,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    const Text(
                      'luces encendidas',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF8F9AAA,
                        ),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .electric_bolt_rounded,
                          color:
                              Color(
                            0xFFFFB020,
                          ),
                          size: 18,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${power.toStringAsFixed(0)} W',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                        const Text(
                          ' en uso',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF8F9AAA,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed:
                      onlineLights
                              .isEmpty
                          ? null
                          : () =>
                              _setAll(
                                false,
                              ),
                  icon: const Icon(
                    Icons
                        .power_settings_new_rounded,
                    size: 18,
                  ),
                  label:
                      const Text(
                    'Apagar todas',
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    FilledButton.icon(
                  onPressed:
                      onlineLights
                              .isEmpty
                          ? null
                          : () =>
                              _setAll(
                                true,
                              ),
                  icon: const Icon(
                    Icons
                        .lightbulb_rounded,
                    size: 18,
                  ),
                  label:
                      const Text(
                    'Encender',
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

// ================================================================
// PANEL AMBIENTAL
// ================================================================

class _EnvironmentPanel
    extends StatelessWidget {
  const _EnvironmentPanel({
    required this.pirSensor,
    required this.luxSensor,
    required this.sensorCount,
    required this.offlineCount,
    required this.energy,
  });

  final Device? pirSensor;
  final Device? luxSensor;
  final int sensorCount;
  final int offlineCount;
  final double energy;

  @override
  Widget build(BuildContext context) {
    final lux =
        luxSensor?.luxValue;

    final motion =
        pirSensor?.motionDetected ==
            true;

    return Container(
      padding:
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF14222D),
            Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
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
                      const Color(
                    0xFF38BDF8,
                  ).withOpacity(.13),
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
                child: const Icon(
                  Icons
                      .sensors_rounded,
                  color:
                      Color(
                    0xFF38BDF8,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'AMBIENTE',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF38BDF8,
                        ),
                        fontSize: 10,
                        fontWeight:
                            FontWeight
                                .w900,
                        letterSpacing:
                            1.2,
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      'Lecturas en vivo',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _EnvironmentValue(
                  icon: Icons
                      .wb_sunny_rounded,
                  color:
                      const Color(
                    0xFFFFB020,
                  ),
                  value: lux == null
                      ? '--'
                      : '${lux.toStringAsFixed(0)} lux',
                  label:
                      'Luminosidad',
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _EnvironmentValue(
                  icon: Icons
                      .directions_walk_rounded,
                  color: motion
                      ? const Color(
                          0xFF22C55E,
                        )
                      : const Color(
                          0xFFA78BFA,
                        ),
                  value: motion
                      ? 'Detectado'
                      : 'Sin movimiento',
                  label:
                      'Presencia',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _EnvironmentValue(
                  icon: Icons
                      .sensors_rounded,
                  color:
                      const Color(
                    0xFF38BDF8,
                  ),
                  value:
                      '$sensorCount',
                  label:
                      'Sensores',
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child:
                    _EnvironmentValue(
                  icon: Icons
                      .energy_savings_leaf_rounded,
                  color:
                      const Color(
                    0xFF22C55E,
                  ),
                  value:
                      '${energy.toStringAsFixed(2)} kWh',
                  label:
                      'Energía acumulada',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Container(
            width:
                double.infinity,
            padding:
                const EdgeInsets
                    .all(
              13,
            ),
            decoration:
                BoxDecoration(
              color:
                  offlineCount > 0
                      ? const Color(
                          0xFFFF4D5A,
                        ).withOpacity(
                          .08,
                        )
                      : const Color(
                          0xFF22C55E,
                        ).withOpacity(
                          .08,
                        ),
              borderRadius:
                  BorderRadius
                      .circular(
                14,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  offlineCount > 0
                      ? Icons
                          .warning_amber_rounded
                      : Icons
                          .verified_rounded,
                  color:
                      offlineCount > 0
                          ? const Color(
                              0xFFFF4D5A,
                            )
                          : const Color(
                              0xFF22C55E,
                            ),
                  size: 18,
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(
                    offlineCount > 0
                        ? '$offlineCount dispositivo(s) requieren atención'
                        : 'Todos los dispositivos están conectados',
                    style:
                        const TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight
                              .w700,
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

class _EnvironmentValue
    extends StatelessWidget {
  const _EnvironmentValue({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFF10161E),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFF202A36),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(
            height: 11,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            label,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF8F9AAA,
              ),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// LUZ
// ================================================================

class _LightCard
    extends StatelessWidget {
  const _LightCard({
    required this.light,
    required this.onChanged,
  });

  final Device light;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final desiredOn =
        light.desiredState ==
            LightState.on;

    final actualOn =
        light.isLightOn;

    final online =
        light.isOnline;

    final color = !online
        ? const Color(0xFFFF4D5A)
        : actualOn
            ? const Color(0xFFFFB020)
            : const Color(0xFF22C55E);

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 250,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: actualOn
            ? LinearGradient(
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  const Color(
                    0xFFFFB020,
                  ).withOpacity(.08),
                  const Color(
                    0xFF141A23,
                  ),
                ],
              )
            : null,
        color: actualOn
            ? null
            : const Color(
                0xFF141A23,
              ),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: !online
              ? const Color(
                  0xFF5A2830,
                )
              : actualOn
                  ? const Color(
                      0xFF493817,
                    )
                  : const Color(
                      0xFF222B36,
                    ),
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
                      color.withOpacity(
                    .12,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
                child: Icon(
                  actualOn
                      ? Icons
                          .lightbulb_rounded
                      : Icons
                          .lightbulb_outline_rounded,
                  color: color,
                ),
              ),

              const Spacer(),

              Switch.adaptive(
                value:
                    desiredOn,
                onChanged:
                    onChanged,
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            light.name,
            style:
                const TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            _lightStatus(
              light,
            ),
            style:
                const TextStyle(
              color:
                  Color(
                0xFF8F9AAA,
              ),
              fontSize: 11,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              _SmallInfo(
                icon: Icons
                    .tune_rounded,
                text:
                    light.mode.label,
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(
                    .10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),
                child: Text(
                  actualOn
                      ? '${light.powerWatts.toStringAsFixed(0)} W'
                      : '0 W',
                  style:
                      TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _lightStatus(
    Device light,
  ) {
    if (!light.isOnline) {
      return 'Desconectada';
    }

    if (light.isCommandPending) {
      return 'Esperando confirmación...';
    }

    return light.isLightOn
        ? 'Encendida · En línea'
        : 'Apagada · En línea';
  }
}

// ================================================================
// SENSOR
// ================================================================

class _SensorCard
    extends StatelessWidget {
  const _SensorCard({
    required this.sensor,
  });

  final Device sensor;

  @override
  Widget build(BuildContext context) {
    final online =
        sensor.isOnline;

    final color = !online
        ? const Color(0xFFFF4D5A)
        : _colorFor(
            sensor.type,
          );

    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: online
              ? const Color(
                  0xFF222B36,
                )
              : const Color(
                  0xFF5A2830,
                ),
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
                      color.withOpacity(
                    .12,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    15,
                  ),
                ),
                child: Icon(
                  _iconFor(
                    sensor.type,
                  ),
                  color: color,
                ),
              ),

              const Spacer(),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(
                    .10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),
                child: Text(
                  online
                      ? 'ONLINE'
                      : 'OFFLINE',
                  style:
                      TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight:
                        FontWeight
                            .w900,
                    letterSpacing:
                        .5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            sensor.name,
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w900,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            sensor.type.label,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF8F9AAA,
              ),
              fontSize: 10,
            ),
          ),

          const Spacer(),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  _valueFor(
                    sensor,
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
              ),

              _SmallInfo(
                icon:
                    Icons.circle,
                text: sensor
                    .connectionStatus
                    .label,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(
    DeviceType type,
  ) =>
      switch (type) {
        DeviceType.pirSensor =>
          Icons.directions_walk_rounded,
        DeviceType.luxSensor =>
          Icons.wb_sunny_rounded,
        DeviceType.energyMeter =>
          Icons.electric_meter_rounded,
        DeviceType.light =>
          Icons.lightbulb_rounded,
      };

  Color _colorFor(
    DeviceType type,
  ) =>
      switch (type) {
        DeviceType.pirSensor =>
          const Color(0xFFA78BFA),
        DeviceType.luxSensor =>
          const Color(0xFFFFB020),
        DeviceType.energyMeter =>
          const Color(0xFF38BDF8),
        DeviceType.light =>
          const Color(0xFFFFB020),
      };

  String _valueFor(
    Device sensor,
  ) =>
      switch (sensor.type) {
        DeviceType.pirSensor =>
          sensor.motionDetected == true
              ? 'Movimiento'
              : 'Sin movimiento',
        DeviceType.luxSensor =>
          sensor.luxValue == null
              ? '-- lux'
              : '${sensor.luxValue!.toStringAsFixed(0)} lux',
        DeviceType.energyMeter =>
          '${sensor.powerWatts.toStringAsFixed(0)} W',
        DeviceType.light => '',
      };
}

// ================================================================
// TÍTULOS
// ================================================================

class _SectionTitle
    extends StatelessWidget {
  const _SectionTitle({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String label;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              TextStyle(
            color: color,
            fontSize: 10,
            fontWeight:
                FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.w900,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          subtitle,
          style:
              const TextStyle(
            color:
                Color(
              0xFF8F9AAA,
            ),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// CÍRCULO
// ================================================================

class _ProgressRing
    extends StatelessWidget {
  const _ProgressRing({
    required this.value,
    required this.text,
    required this.color,
  });

  final double value;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      height: 122,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value
                .clamp(
                  0.0,
                  1.0,
                )
                .toDouble(),
            strokeWidth: 9,
            strokeCap:
                StrokeCap.round,
            color: color,
            backgroundColor:
                color.withOpacity(
              .10,
            ),
          ),

          Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  text,
                  style:
                      const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight
                            .w900,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                const Text(
                  'activo',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFF8F9AAA,
                    ),
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

// ================================================================
// INFO PEQUEÑA
// ================================================================

class _SmallInfo
    extends StatelessWidget {
  const _SmallInfo({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11,
          color:
              const Color(
            0xFF697586,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style:
              const TextStyle(
            color:
                Color(
              0xFF8F9AAA,
            ),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// VACÍO
// ================================================================

class _EmptyCard
    extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color:
            const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              const Color(0xFF222B36),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color:
                const Color(
              0xFF697586,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            subtitle,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF8F9AAA,
              ),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}