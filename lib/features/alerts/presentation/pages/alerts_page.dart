import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../devices/domain/entities/device.dart';
import '../../../devices/presentation/providers/device_providers.dart';

enum _AlertFilter {
  all,
  critical,
  warning,
  reviewed,
}

class AlertsPage extends ConsumerStatefulWidget {
  const AlertsPage({super.key});

  @override
  ConsumerState<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends ConsumerState<AlertsPage> {
  _AlertFilter selectedFilter = _AlertFilter.all;

  final Set<String> reviewedAlerts = {};

  String _deviceKey(Device device) {
    return '${device.areaId}-${device.name}';
  }

  bool _isCritical(Device device) {
    return device.type == DeviceType.light;
  }

  void _toggleReviewed(Device device) {
    final key = _deviceKey(device);

    setState(() {
      if (reviewedAlerts.contains(key)) {
        reviewedAlerts.remove(key);
      } else {
        reviewedAlerts.add(key);
      }
    });
  }

  void _showDeviceDetails(Device device) {
    final critical = _isCritical(device);
    final reviewed = reviewedAlerts.contains(
      _deviceKey(device),
    );

    final color = critical
        ? const Color(0xFFFF4D5A)
        : const Color(0xFFFFB020);

    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF141A23),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 520,
            ),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withOpacity(.13),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          critical
                              ? Icons.lightbulb_outline_rounded
                              : Icons.sensors_rounded,
                          color: color,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.name,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              device.type.label,
                              style: const TextStyle(
                                color: Color(0xFF8F9AAA),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _DetailRow(
                    icon: Icons.wifi_off_rounded,
                    title: 'Estado',
                    value: device.connectionStatus.label,
                    color: const Color(0xFFFF4D5A),
                  ),

                  const SizedBox(height: 10),

                  _DetailRow(
                    icon: Icons.apartment_rounded,
                    title: 'Área',
                    value: 'Área ${device.areaId}',
                    color: const Color(0xFF38BDF8),
                  ),

                  const SizedBox(height: 10),

                  _DetailRow(
                    icon: Icons.warning_amber_rounded,
                    title: 'Severidad',
                    value: critical ? 'Crítica' : 'Advertencia',
                    color: color,
                  ),

                  const SizedBox(height: 10),

                  _DetailRow(
                    icon: Icons.fact_check_rounded,
                    title: 'Gestión',
                    value: reviewed ? 'Revisada' : 'Pendiente',
                    color: reviewed
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFFFB020),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.06),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: color.withOpacity(.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: color,
                          size: 20,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            critical
                                ? 'La luminaria no está respondiendo al sistema. Revisa alimentación, conectividad y comunicación con el módulo IoT.'
                                : 'El sensor no está enviando datos. Revisa conectividad y alimentación del dispositivo.',
                            style: const TextStyle(
                              color: Color(0xFFABB4C0),
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cerrar'),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _toggleReviewed(device);
                          },
                          icon: Icon(
                            reviewed
                                ? Icons.undo_rounded
                                : Icons.check_circle_outline_rounded,
                          ),
                          label: Text(
                            reviewed
                                ? 'Reabrir'
                                : 'Marcar revisada',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(devicesProvider);

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
            child: switch (devicesAsync) {
              AsyncData(:final value) => _buildContent(value),

              AsyncError(:final error) => _ErrorCard(
                  message:
                      'No fue posible cargar las alertas: $error',
                ),

              _ => const Padding(
                  padding: EdgeInsets.all(60),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    List<Device> devices,
  ) {
    final offline = devices
        .where(
          (device) => !device.isOnline,
        )
        .toList();

    final critical = offline
        .where(_isCritical)
        .toList();

    final warning = offline
        .where(
          (device) => !_isCritical(device),
        )
        .toList();

    final reviewed = offline
        .where(
          (device) => reviewedAlerts.contains(
            _deviceKey(device),
          ),
        )
        .toList();

    final pending = offline
        .where(
          (device) => !reviewedAlerts.contains(
            _deviceKey(device),
          ),
        )
        .toList();

    List<Device> visibleAlerts;

    switch (selectedFilter) {
      case _AlertFilter.critical:
        visibleAlerts = critical;
        break;

      case _AlertFilter.warning:
        visibleAlerts = warning;
        break;

      case _AlertFilter.reviewed:
        visibleAlerts = reviewed;
        break;

      case _AlertFilter.all:
        visibleAlerts = offline;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================================
        // HEADER
        // ==========================================================

        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: offline.isEmpty
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFFF4D5A),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: offline.isEmpty
                        ? const Color(0x8822C55E)
                        : const Color(0x88FF4D5A),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Text(
              'CENTRO DE INCIDENCIAS',
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
          'Alertas y eventos',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.3,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Supervisa incidencias, fallos de conectividad y dispositivos que requieren atención.',
          style: TextStyle(
            color: Color(0xFF9DA7B5),
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 28),

        // ==========================================================
        // MÉTRICAS
        // ==========================================================

        LayoutBuilder(
          builder: (context, constraints) {
            var columns = 1;

            if (constraints.maxWidth >= 1000) {
              columns = 4;
            } else if (constraints.maxWidth >= 620) {
              columns = 2;
            }

            return GridView.count(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio:
                  columns == 4 ? 2.0 : 2.2,
              children: [
                _MetricCard(
                  icon: Icons.warning_amber_rounded,
                  value: '${pending.length}',
                  title: 'Pendientes',
                  subtitle: 'Requieren atención',
                  color: pending.isEmpty
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFFF4D5A),
                ),

                _MetricCard(
                  icon: Icons.error_outline_rounded,
                  value: '${critical.length}',
                  title: 'Críticas',
                  subtitle: 'Luminarias afectadas',
                  color: const Color(0xFFFF4D5A),
                ),

                _MetricCard(
                  icon:
                      Icons.notification_important_outlined,
                  value: '${warning.length}',
                  title: 'Advertencias',
                  subtitle: 'Sensores afectados',
                  color: const Color(0xFFFFB020),
                ),

                _MetricCard(
                  icon: Icons.task_alt_rounded,
                  value: '${reviewed.length}',
                  title: 'Revisadas',
                  subtitle: 'Incidencias gestionadas',
                  color: const Color(0xFF22C55E),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // ==========================================================
        // ESTADO GENERAL
        // ==========================================================

        _SystemAlertStatus(
          devices: devices,
          offline: offline,
          pending: pending,
        ),

        const SizedBox(height: 34),

        // ==========================================================
        // HEADER INCIDENCIAS
        // ==========================================================

        LayoutBuilder(
          builder: (context, constraints) {
            final desktop =
                constraints.maxWidth >= 800;

            final title = const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'MONITOREO EN VIVO',
                  style: TextStyle(
                    color: Color(0xFFFF4D5A),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Incidencias detectadas',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Clasifica y gestiona los dispositivos que presentan problemas.',
                  style: TextStyle(
                    color: Color(0xFF8F9AAA),
                    fontSize: 12,
                  ),
                ),
              ],
            );

            final filters = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterButton(
                  label: 'Todas',
                  count: offline.length,
                  selected:
                      selectedFilter ==
                          _AlertFilter.all,
                  onTap: () {
                    setState(() {
                      selectedFilter =
                          _AlertFilter.all;
                    });
                  },
                ),

                _FilterButton(
                  label: 'Críticas',
                  count: critical.length,
                  selected:
                      selectedFilter ==
                          _AlertFilter.critical,
                  color: const Color(0xFFFF4D5A),
                  onTap: () {
                    setState(() {
                      selectedFilter =
                          _AlertFilter.critical;
                    });
                  },
                ),

                _FilterButton(
                  label: 'Advertencias',
                  count: warning.length,
                  selected:
                      selectedFilter ==
                          _AlertFilter.warning,
                  color: const Color(0xFFFFB020),
                  onTap: () {
                    setState(() {
                      selectedFilter =
                          _AlertFilter.warning;
                    });
                  },
                ),

                _FilterButton(
                  label: 'Revisadas',
                  count: reviewed.length,
                  selected:
                      selectedFilter ==
                          _AlertFilter.reviewed,
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    setState(() {
                      selectedFilter =
                          _AlertFilter.reviewed;
                    });
                  },
                ),
              ],
            );

            if (!desktop) {
              return Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(
                    height: 15,
                  ),
                  filters,
                ],
              );
            }

            return Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: title,
                ),
                filters,
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // ==========================================================
        // ALERTAS
        // ==========================================================

        if (offline.isEmpty)
          const _AllGoodCard()
        else if (visibleAlerts.isEmpty)
          const _NoAlertsFilterCard()
        else
          ...visibleAlerts.map(
            (device) {
              final reviewed =
                  reviewedAlerts.contains(
                _deviceKey(device),
              );

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: _AlertCard(
                  device: device,
                  critical:
                      _isCritical(device),
                  reviewed: reviewed,
                  onReview: () {
                    _toggleReviewed(device);
                  },
                  onDetails: () {
                    _showDeviceDetails(device);
                  },
                ),
              );
            },
          ),

        const SizedBox(height: 28),

        // ==========================================================
        // RESUMEN FINAL
        // ==========================================================

        LayoutBuilder(
          builder: (context, constraints) {
            final desktop =
                constraints.maxWidth >= 900;

            final connectivity = _InfoPanel(
              icon:
                  Icons.wifi_tethering_rounded,
              title: 'Conectividad general',
              label: 'INFRAESTRUCTURA',
              color: const Color(0xFF38BDF8),
              value:
                  '${devices.where((device) => device.isOnline).length} / ${devices.length}',
              description:
                  'dispositivos actualmente conectados',
            );

            final management = _InfoPanel(
              icon: Icons.fact_check_rounded,
              title: 'Gestión de incidencias',
              label: 'OPERACIÓN',
              color: const Color(0xFF22C55E),
              value:
                  '${reviewed.length} / ${offline.length}',
              description:
                  'alertas revisadas durante esta sesión',
            );

            if (!desktop) {
              return Column(
                children: [
                  connectivity,
                  const SizedBox(
                    height: 16,
                  ),
                  management,
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: connectivity,
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: management,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// ESTADO GENERAL
// ============================================================================

class _SystemAlertStatus
    extends StatelessWidget {
  const _SystemAlertStatus({
    required this.devices,
    required this.offline,
    required this.pending,
  });

  final List<Device> devices;
  final List<Device> offline;
  final List<Device> pending;

  @override
  Widget build(BuildContext context) {
    final online =
        devices.where((d) => d.isOnline).length;

    final health = devices.isEmpty
        ? 0
        : ((online / devices.length) * 100)
            .round();

    final healthy = offline.isEmpty;

    final color = healthy
        ? const Color(0xFF22C55E)
        : const Color(0xFFFF4D5A);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(.10),
            const Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color: color.withOpacity(.23),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop =
              constraints.maxWidth >= 700;

          final icon = Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: color.withOpacity(.13),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Icon(
              healthy
                  ? Icons.verified_rounded
                  : Icons.warning_amber_rounded,
              color: color,
              size: 30,
            ),
          );

          final info = Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                healthy
                    ? 'SISTEMA ESTABLE'
                    : 'ATENCIÓN REQUERIDA',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                healthy
                    ? 'No existen incidencias activas'
                    : '${pending.length} incidencia(s) pendientes',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                healthy
                    ? 'Todos los dispositivos están respondiendo correctamente.'
                    : '${offline.length} dispositivo(s) sin conexión requieren revisión.',
                style: const TextStyle(
                  color: Color(0xFF9DA7B5),
                  fontSize: 11,
                ),
              ),
            ],
          );

          final percent = Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '$health%',
                style: TextStyle(
                  color: color,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'salud del sistema',
                style: TextStyle(
                  color: Color(0xFF8F9AAA),
                  fontSize: 9,
                ),
              ),
            ],
          );

          if (!desktop) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(
                  height: 15,
                ),
                info,
                const SizedBox(
                  height: 16,
                ),
                percent,
              ],
            );
          }

          return Row(
            children: [
              icon,
              const SizedBox(
                width: 17,
              ),
              Expanded(
                child: info,
              ),
              percent,
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// ALERT CARD
// ============================================================================

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.device,
    required this.critical,
    required this.reviewed,
    required this.onReview,
    required this.onDetails,
  });

  final Device device;
  final bool critical;
  final bool reviewed;

  final VoidCallback onReview;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final color = reviewed
        ? const Color(0xFF22C55E)
        : critical
            ? const Color(0xFFFF4D5A)
            : const Color(0xFFFFB020);

    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 220,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            color.withOpacity(.09),
            const Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(23),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop =
              constraints.maxWidth >= 760;

          final mainContent = Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(.13),
                  borderRadius:
                      BorderRadius.circular(17),
                ),
                child: Icon(
                  critical
                      ? Icons.lightbulb_outline_rounded
                      : Icons.sensors_rounded,
                  color: color,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 9,
                      runSpacing: 7,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${device.name} sin conexión',
                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        _SeverityBadge(
                          color: color,
                          text: reviewed
                              ? 'REVISADA'
                              : critical
                                  ? 'CRÍTICA'
                                  : 'ADVERTENCIA',
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      '${device.type.label} · ${device.connectionStatus.label}',
                      style: const TextStyle(
                        color:
                            Color(0xFF9DA7B5),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(
                      height: 11,
                    ),

                    Wrap(
                      spacing: 9,
                      runSpacing: 7,
                      children: [
                        _DetailTag(
                          icon:
                              Icons.apartment_rounded,
                          text:
                              'Área ${device.areaId}',
                        ),

                        const _DetailTag(
                          icon:
                              Icons.wifi_off_rounded,
                          text: 'Sin conexión',
                        ),

                        _DetailTag(
                          icon:
                              Icons.priority_high_rounded,
                          text: critical
                              ? 'Prioridad alta'
                              : 'Prioridad media',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onDetails,
                icon: const Icon(
                  Icons.visibility_outlined,
                  size: 17,
                ),
                label: const Text(
                  'Detalles',
                ),
              ),

              FilledButton.icon(
                onPressed: onReview,
                icon: Icon(
                  reviewed
                      ? Icons.undo_rounded
                      : Icons.check_rounded,
                  size: 17,
                ),
                label: Text(
                  reviewed
                      ? 'Reabrir'
                      : 'Revisada',
                ),
              ),
            ],
          );

          if (!desktop) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                mainContent,
                const SizedBox(
                  height: 16,
                ),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Expanded(
                child: mainContent,
              ),
              const SizedBox(
                width: 20,
              ),
              actions,
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// MÉTRICA
// ============================================================================

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
        borderRadius:
            BorderRadius.circular(20),
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
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        Color(0xFF8F9AAA),
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

// ============================================================================
// FILTRO
// ============================================================================

class _FilterButton
    extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.color =
        const Color(0xFFA78BFA),
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(30),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 180,
        ),
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(.14)
              : const Color(0xFF141A23),
          borderRadius:
              BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? color.withOpacity(.35)
                : const Color(0xFF27313D),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? color
                    : const Color(
                        0xFFAAB2BE,
                      ),
                fontSize: 10,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              width: 7,
            ),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(.18)
                    : const Color(
                        0xFF202833,
                      ),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected
                      ? color
                      : const Color(
                          0xFF8F9AAA,
                        ),
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BADGES
// ============================================================================

class _SeverityBadge
    extends StatelessWidget {
  const _SeverityBadge({
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius:
            BorderRadius.circular(20),
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

class _DetailTag extends StatelessWidget {
  const _DetailTag({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF202833),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: const Color(0xFF8F9AAA),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFADB5C0),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETALLE MODAL
// ============================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10161E),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 19,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color:
                        Color(0xFF8F9AAA),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w800,
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
// INFO PANEL
// ============================================================================

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.label,
    required this.color,
    required this.value,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String label;
  final Color color;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(
            width: 15,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color:
                        Color(0xFF8F9AAA),
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

// ============================================================================
// ESTADO CORRECTO
// ============================================================================

class _AllGoodCard
    extends StatelessWidget {
  const _AllGoodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(
              0xFF22C55E,
            ).withOpacity(.09),
            const Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(
            0xFF22C55E,
          ).withOpacity(.20),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor:
                Color(0x2222C55E),
            child: Icon(
              Icons.verified_rounded,
              color: Color(0xFF22C55E),
            ),
          ),

          SizedBox(
            width: 16,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin incidencias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  'Todos los dispositivos están conectados y funcionando correctamente.',
                  style: TextStyle(
                    color:
                        Color(0xFF9DA7B5),
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

class _NoAlertsFilterCard
    extends StatelessWidget {
  const _NoAlertsFilterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF222B36),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            color: Color(0xFF697586),
            size: 34,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'No hay alertas en este filtro',
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ],
      ),
    );
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFFFF4D5A,
        ).withOpacity(.08),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(
            0xFFFF4D5A,
          ).withOpacity(.22),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF4D5A),
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(message),
          ),
        ],
      ),
    );
  }
}