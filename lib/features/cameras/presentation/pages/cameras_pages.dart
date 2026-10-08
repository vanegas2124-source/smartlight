import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class CamerasPage extends StatefulWidget {
  const CamerasPage({super.key});

  static const background = Color(0xFF0B1118);
  static const surface = Color(0xFF121A24);
  static const surfaceLight = Color(0xFF17212D);
  static const border = Color(0xFF263241);

  static const amber = Color(0xFFFFB020);
  static const blue = Color(0xFF38BDF8);
  static const green = Color(0xFF22C55E);
  static const red = Color(0xFFFF4D61);
  static const muted = Color(0xFF8E9AAA);
  static const textPrimary = Color(0xFFF4EDE4);

  @override
  State<CamerasPage> createState() => _CamerasPageState();
}

class _CamerasPageState extends State<CamerasPage> {
  static const String _cameraViewType =
      'smartlight-tuya-camera-view';

  static bool _cameraViewRegistered = false;

  static web.HTMLIFrameElement? _cameraIframe;

  @override
  void initState() {
    super.initState();

    _registerCameraView();
  }

  // ============================================================
  // REGISTRO DEL VISOR WEBRTC
  // ============================================================

  void _registerCameraView() {
    if (_cameraViewRegistered) {
      return;
    }

    ui_web.platformViewRegistry.registerViewFactory(
      _cameraViewType,
      (int viewId) {
        final iframe = web.HTMLIFrameElement();

        iframe.src = 'http://localhost:3333';

        iframe.style
          ..border = '0'
          ..width = '100%'
          ..height = '100%'
          ..backgroundColor = '#080D13';

        iframe.setAttribute(
          'allow',
          'autoplay; microphone; camera; fullscreen',
        );

        iframe.setAttribute(
          'allowfullscreen',
          'true',
        );

        iframe.setAttribute(
          'loading',
          'eager',
        );

        _cameraIframe = iframe;

        return iframe;
      },
    );

    _cameraViewRegistered = true;
  }

  // ============================================================
  // RECONECTAR / RECARGAR CÁMARA
  // ============================================================

  void _reloadCamera() {
    final iframe = _cameraIframe;

    if (iframe == null) {
      return;
    }

    iframe.src =
        'http://localhost:3333/?reload=${DateTime.now().millisecondsSinceEpoch}';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Reconectando cámara OVO 2...',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAddCameraMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La vinculación de nuevas cámaras estará disponible próximamente.',
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CamerasPage.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            30,
            26,
            30,
            34,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // CABECERA
              // ==================================================

              _PageHeader(
                onAddCamera: _showAddCameraMessage,
              ),

              const SizedBox(height: 26),

              // ==================================================
              // MÉTRICAS
              // ==================================================

              const _MetricsSection(),

              const SizedBox(height: 34),

              // ==================================================
              // TÍTULO SECCIÓN
              // ==================================================

              const Row(
                children: [
                  Icon(
                    Icons.sensors_rounded,
                    size: 17,
                    color: CamerasPage.blue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'MONITOREO EN VIVO',
                    style: TextStyle(
                      color: CamerasPage.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.15,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 9),

              const Text(
                'Videovigilancia',
                style: TextStyle(
                  color: CamerasPage.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Supervisión en tiempo real de los dispositivos '
                'conectados a SmartLight.',
                style: TextStyle(
                  color: CamerasPage.muted,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CÁMARA
              // ==================================================

              _LiveCameraPanel(
                onReload: _reloadCamera,
              ),

              const SizedBox(height: 22),

              // ==================================================
              // INFORMACIÓN DE CONEXIÓN
              // ==================================================

              const _ConnectionDetails(),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// CABECERA PRINCIPAL
// ================================================================

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.onAddCamera,
  });

  final VoidCallback onAddCamera;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final compact =
            constraints.maxWidth < 760;

        final title = Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: CamerasPage.blue,
                ),
                SizedBox(width: 9),
                Text(
                  'VIDEOVIGILANCIA',
                  style: TextStyle(
                    color: CamerasPage.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              'Cámaras en tiempo real',
              style: TextStyle(
                color: CamerasPage.textPrimary,
                fontSize: 34,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Control y supervisión de dispositivos '
              'de videovigilancia conectados a la nube.',
              style: TextStyle(
                color: CamerasPage.muted,
                fontSize: 14,
              ),
            ),
          ],
        );

        final button =
            FilledButton.icon(
          style:
              FilledButton.styleFrom(
            backgroundColor:
                CamerasPage.amber,
            foregroundColor:
                Colors.black,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
          onPressed: onAddCamera,
          icon: const Icon(
            Icons.add_rounded,
            size: 19,
          ),
          label: const Text(
            'Agregar cámara',
            style: TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 18),
              button,
            ],
          );
        }

        return Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: title,
            ),
            const SizedBox(width: 24),
            button,
          ],
        );
      },
    );
  }
}

// ================================================================
// MÉTRICAS
// ================================================================

class _MetricsSection extends StatelessWidget {
  const _MetricsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final width =
            constraints.maxWidth;

        int columns;

        if (width >= 1100) {
          columns = 4;
        } else if (width >= 620) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 14.0;

        final cardWidth =
            (width -
                    ((columns - 1) *
                        spacing)) /
                columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child:
                  const _MetricCard(
                icon:
                    Icons.videocam_rounded,
                iconColor:
                    CamerasPage.blue,
                value: '1',
                title: 'Cámara activa',
                subtitle:
                    'Dispositivo físico',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child:
                  const _MetricCard(
                icon:
                    Icons.wifi_rounded,
                iconColor:
                    CamerasPage.green,
                value: 'Online',
                title: 'Estado',
                subtitle:
                    'Conectada a Tuya',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child:
                  const _MetricCard(
                icon:
                    Icons.cloud_done_rounded,
                iconColor:
                    CamerasPage.green,
                value: 'Tuya',
                title: 'Cloud',
                subtitle:
                    'IoT Platform',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child:
                  const _MetricCard(
                icon:
                    Icons.swap_calls_rounded,
                iconColor:
                    CamerasPage.amber,
                value: 'WebRTC',
                title: 'Streaming',
                subtitle:
                    'Baja latencia',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard
    extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;
  final String subtitle;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 112,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: CamerasPage.surface,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: CamerasPage.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color:
                  iconColor.withValues(
                alpha: .12,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
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
                    color:
                        CamerasPage
                            .textPrimary,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
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
                    color: Colors.white,
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
                        CamerasPage.muted,
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

// ================================================================
// PANEL PRINCIPAL DE LA CÁMARA
// ================================================================

class _LiveCameraPanel
    extends StatelessWidget {
  const _LiveCameraPanel({
    required this.onReload,
  });

  final VoidCallback onReload;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CamerasPage.surface,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: CamerasPage.border,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: .18,
            ),
            blurRadius: 25,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        children: [
          // ==================================================
          // CABECERA
          // ==================================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            color:
                CamerasPage.surfaceLight,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(
                    color:
                        CamerasPage.blue
                            .withValues(
                      alpha: .12,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(11),
                  ),
                  child: const Icon(
                    Icons
                        .camera_indoor_rounded,
                    color:
                        CamerasPage.blue,
                    size: 22,
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
                        'OVO 2 · Cámara Interior',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 15,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Sede principal  •  Tuya Cloud',
                        style:
                            TextStyle(
                          color:
                              CamerasPage
                                  .muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // ==============================================
                // RECONECTAR
                // ==============================================

                Tooltip(
                  message:
                      'Reconectar cámara',
                  child: IconButton(
                    onPressed:
                        onReload,
                    style:
                        IconButton.styleFrom(
                      backgroundColor:
                          Colors.white
                              .withValues(
                        alpha: .04,
                      ),
                    ),
                    icon:
                        const Icon(
                      Icons
                          .refresh_rounded,
                      color:
                          Colors.white70,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                // ==============================================
                // EN VIVO
                // ==============================================

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        CamerasPage.green
                            .withValues(
                      alpha: .11,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(20),
                    border:
                        Border.all(
                      color:
                          CamerasPage.green
                              .withValues(
                        alpha: .25,
                      ),
                    ),
                  ),
                  child:
                      const Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 7,
                        color:
                            CamerasPage
                                .green,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        'EN VIVO',
                        style:
                            TextStyle(
                          color:
                              CamerasPage
                                  .green,
                          fontSize: 10,
                          fontWeight:
                              FontWeight
                                  .w800,
                          letterSpacing:
                              .5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // VIDEO 16:9
          // ==================================================

          Container(
            width: double.infinity,
            color:
                const Color(
              0xFF05090E,
            ),
            alignment:
                Alignment.center,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1180,
              ),
              child:
                  const AspectRatio(
                aspectRatio: 16 / 9,
                child:
                    HtmlElementView(
                  viewType:
                      'smartlight-tuya-camera-view',
                ),
              ),
            ),
          ),

          // ==================================================
          // BARRA DE ESTADO
          // ==================================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 13,
            ),
            color:
                CamerasPage.surfaceLight,
            child: const Wrap(
              spacing: 18,
              runSpacing: 10,
              crossAxisAlignment:
                  WrapCrossAlignment.center,
              children: [
                _StatusItem(
                  icon:
                      Icons.lock_rounded,
                  iconColor:
                      CamerasPage.green,
                  text:
                      'Conexión segura',
                ),
                _StatusItem(
                  icon:
                      Icons.swap_calls_rounded,
                  iconColor:
                      CamerasPage.amber,
                  text: 'WebRTC',
                ),
                _StatusItem(
                  icon:
                      Icons.hd_rounded,
                  iconColor:
                      CamerasPage.blue,
                  text: '640 × 360',
                ),
                _StatusItem(
                  icon:
                      Icons.cloud_done_rounded,
                  iconColor:
                      CamerasPage.green,
                  text: 'Tuya Cloud',
                ),
                _StatusItem(
                  icon:
                      Icons.bolt_rounded,
                  iconColor:
                      CamerasPage.amber,
                  text:
                      'Tiempo real',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem
    extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style:
              const TextStyle(
            color:
                CamerasPage.muted,
            fontSize: 11,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ================================================================
// INFORMACIÓN TÉCNICA
// ================================================================

class _ConnectionDetails
    extends StatelessWidget {
  const _ConnectionDetails();

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final compact =
            constraints.maxWidth <
                720;

        final items = const [
          _TechnicalItem(
            icon:
                Icons.cloud_rounded,
            title: 'Plataforma',
            value: 'Tuya IoT',
            color:
                CamerasPage.blue,
          ),
          _TechnicalItem(
            icon:
                Icons.swap_calls_rounded,
            title: 'Protocolo',
            value: 'WebRTC',
            color:
                CamerasPage.amber,
          ),
          _TechnicalItem(
            icon:
                Icons
                    .camera_indoor_rounded,
            title: 'Dispositivo',
            value: 'OVO 2',
            color:
                CamerasPage.blue,
          ),
          _TechnicalItem(
            icon:
                Icons
                    .check_circle_rounded,
            title: 'Estado',
            value: 'Conectada',
            color:
                CamerasPage.green,
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (
                final item
                in items
              )
                SizedBox(
                  width:
                      (constraints
                                  .maxWidth -
                              12) /
                          2,
                  child: item,
                ),
            ],
          );
        }

        return Row(
          children: [
            for (
              int i = 0;
              i <
                  items.length;
              i++
            ) ...[
              Expanded(
                child:
                    items[i],
              ),
              if (
                i <
                    items.length -
                        1
              )
                const SizedBox(
                  width: 12,
                ),
            ],
          ],
        );
      },
    );
  }
}

class _TechnicalItem
    extends StatelessWidget {
  const _TechnicalItem({
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color:
            CamerasPage.surface,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              CamerasPage.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  color.withValues(
                alpha: .11,
              ),
              borderRadius:
                  BorderRadius
                      .circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color:
                        CamerasPage
                            .muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 13,
                    fontWeight:
                        FontWeight
                            .w700,
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