import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_mode_controller.dart';
import '../../../devices/domain/entities/device.dart';
import '../../../devices/presentation/providers/device_providers.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeModeProvider);

    final devicesAsync =
        ref.watch(devicesProvider);

    final devices = switch (devicesAsync) {
      AsyncData(:final value) => value,
      _ => const <Device>[],
    };

    final online =
        devices.where((device) => device.isOnline).length;

    final isDark =
        themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                Theme.of(context).brightness ==
                    Brightness.dark);

    return SafeArea(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(28, 28, 28, 45),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: 1500),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          const BoxDecoration(
                        color:
                            Color(0xFFFFB020),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Color(0x88FFB020),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CONFIGURACIÓN DEL SISTEMA',
                      style: TextStyle(
                        color:
                            Color(0xFF8F9AAA),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                const Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Administra preferencias, organización e infraestructura de SmartLight.',
                  style: TextStyle(
                    color:
                        Color(0xFF9DA7B5),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                // HERO
                LayoutBuilder(
                  builder: (context, constraints) {
                    final desktop =
                        constraints.maxWidth >= 900;

                    final organization =
                        const _OrganizationCard();

                    final system =
                        _SystemStatusCard(
                      online: online,
                      total: devices.length,
                    );

                    if (!desktop) {
                      return Column(
                        children: [
                          organization,
                          const SizedBox(
                            height: 16,
                          ),
                          system,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(
                          child:
                              _OrganizationCard(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: system),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 30),

                const Text(
                  'PREFERENCIAS',
                  style: TextStyle(
                    color:
                        Color(0xFFFFB020),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Experiencia de usuario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 16),

                _SettingsCard(
                  children: [
                    _SettingRow(
                      icon:
                          Icons.dark_mode_rounded,
                      color:
                          const Color(0xFFA78BFA),
                      title: 'Modo oscuro',
                      subtitle:
                          'Utilizar interfaz oscura en SmartLight.',
                      trailing:
                          Switch.adaptive(
                        value: isDark,
                        onChanged: (enabled) {
                          ref
                              .read(
                                themeModeProvider
                                    .notifier,
                              )
                              .setDarkMode(
                                enabled,
                              );
                        },
                      ),
                    ),

                    const _SettingsDivider(),

                    const _SettingRow(
                      icon:
                          Icons.language_rounded,
                      color:
                          Color(0xFF38BDF8),
                      title: 'Idioma',
                      subtitle:
                          'Español (Colombia)',
                      trailing: _ValueBadge(
                        value: 'ES-CO',
                      ),
                    ),

                    const _SettingsDivider(),

                    const _SettingRow(
                      icon: Icons
                          .notifications_active_rounded,
                      color:
                          Color(0xFFFFB020),
                      title: 'Notificaciones',
                      subtitle:
                          'Alertas de conectividad y dispositivos.',
                      trailing: _ValueBadge(
                        value: 'ACTIVAS',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'INFRAESTRUCTURA',
                  style: TextStyle(
                    color:
                        Color(0xFF38BDF8),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'IoT y plataforma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 16),

                LayoutBuilder(
                  builder: (context, constraints) {
                    var columns = 1;

                    if (constraints.maxWidth >=
                        1000) {
                      columns = 3;
                    } else if (constraints
                            .maxWidth >=
                        650) {
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
                          columns == 3 ? 1.7 : 1.8,
                      children: [
                        _TechCard(
                          icon:
                              Icons.memory_rounded,
                          title:
                              'Motor IoT',
                          value:
                              'MockIoTRepository',
                          description:
                              'Simulador activo para dispositivos y telemetría.',
                          status:
                              'CONECTADO',
                          color:
                              const Color(
                            0xFF22C55E,
                          ),
                        ),

                        const _TechCard(
                          icon:
                              Icons.storage_rounded,
                          title:
                              'Persistencia',
                          value:
                              'Shared Preferences',
                          description:
                              'Configuración local del dispositivo.',
                          status: 'ACTIVA',
                          color:
                              Color(0xFF38BDF8),
                        ),

                        const _TechCard(
                          icon:
                              Icons.code_rounded,
                          title:
                              'Aplicación',
                          value:
                              'SmartLight Enterprise',
                          description:
                              'Plataforma empresarial de iluminación IoT.',
                          status: 'FLUTTER',
                          color:
                              Color(0xFFFFB020),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: const Row(
                    children: [
                      Icon(
                        Icons
                            .verified_user_rounded,
                        color:
                            Color(0xFF22C55E),
                      ),

                      SizedBox(width: 13),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'SmartLight Enterprise',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Sistema de gestión inteligente de iluminación · Plataforma Flutter',
                              style: TextStyle(
                                color:
                                    Color(
                                  0xFF8F9AAA,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _ValueBadge(
                        value: 'ONLINE',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganizationCard
    extends StatelessWidget {
  const _OrganizationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(24),
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
            BorderRadius.circular(26),
        border: Border.all(
          color:
              const Color(0xFF493817),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFFFB020)
                      .withOpacity(.13),
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Color(0xFFFFB020),
              size: 34,
            ),
          ),

          const SizedBox(width: 20),

          const Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ORGANIZACIÓN',
                  style: TextStyle(
                    color:
                        Color(0xFFFFB020),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Empresa Demo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sede Principal',
                  style: TextStyle(
                    color:
                        Color(0xFF9DA7B5),
                    fontSize: 13,
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

class _SystemStatusCard
    extends StatelessWidget {
  const _SystemStatusCard({
    required this.online,
    required this.total,
  });

  final int online;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent =
        total == 0 ? 0 : ((online / total) * 100).round();

    return Container(
      constraints:
          const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            const Color(0xFF141A23),
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color:
              const Color(0xFF20352C),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color:
                  const Color(0xFF22C55E)
                      .withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_tethering_rounded,
              color: Color(0xFF22C55E),
              size: 32,
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTADO DEL SISTEMA',
                  style: TextStyle(
                    color:
                        Color(0xFF22C55E),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '$percent% operativo',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '$online de $total dispositivos conectados',
                  style: const TextStyle(
                    color:
                        Color(0xFF9DA7B5),
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

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: children,
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color:
                        Color(0xFF8F9AAA),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          trailing,
        ],
      ),
    );
  }
}

class _SettingsDivider
    extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 76,
      endIndent: 18,
      color: Color(0xFF222B36),
    );
  }
}

class _TechCard extends StatelessWidget {
  const _TechCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    required this.status,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final String description;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(.12),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),

              const Spacer(),

              _ValueBadge(
                value: status,
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8F9AAA),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8F9AAA),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF22C55E).withOpacity(.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF22C55E),
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    );
  }
}