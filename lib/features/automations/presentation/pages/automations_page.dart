import 'package:flutter/material.dart';

class AutomationsPage extends StatefulWidget {
  const AutomationsPage({super.key});

  @override
  State<AutomationsPage> createState() => _AutomationsPageState();
}

class _AutomationsPageState extends State<AutomationsPage> {
  final List<_AutomationRule> _rules = [
    _AutomationRule(
      id: '1',
      name: 'Iluminación nocturna',
      trigger: 'Horario',
      condition: '18:00 → 06:00',
      targetArea: 'Pasillo',
      action: 'Encender',
      intensity: 70,
      enabled: true,
      executions: 8,
      color: const Color(0xFFA78BFA),
      icon: Icons.nightlight_round,
    ),
    _AutomationRule(
      id: '2',
      name: 'Sala de reuniones',
      trigger: 'Movimiento detectado',
      condition: 'Presencia detectada',
      targetArea: 'Sala de reuniones',
      action: 'Encender',
      intensity: 100,
      enabled: true,
      executions: 4,
      color: const Color(0xFF38BDF8),
      icon: Icons.groups_2_rounded,
    ),
    _AutomationRule(
      id: '3',
      name: 'Modo ahorro energético',
      trigger: 'Sin actividad',
      condition: '15 min sin movimiento',
      targetArea: 'Oficina administrativa',
      action: 'Reducir iluminación',
      intensity: 30,
      enabled: false,
      executions: 0,
      color: const Color(0xFF22C55E),
      icon: Icons.energy_savings_leaf_rounded,
    ),
  ];

  int get activeRules =>
      _rules.where((rule) => rule.enabled).length;

  int get executions =>
      _rules.fold(0, (sum, rule) => sum + rule.executions);

  int get estimatedSaving =>
      (activeRules * 8).clamp(0, 40);

  // ===============================================================
  // CREAR AUTOMATIZACIÓN
  // ===============================================================

  Future<void> _openAutomationBuilder() async {
    final nameController = TextEditingController();

    String trigger = 'Movimiento detectado';
    String area = 'Recepción';
    String action = 'Encender';

    double intensity = 100;
    double luxThreshold = 30;
    double inactivityMinutes = 15;

    TimeOfDay startTime = const TimeOfDay(
      hour: 18,
      minute: 0,
    );

    TimeOfDay endTime = const TimeOfDay(
      hour: 6,
      minute: 0,
    );

    final created = await showDialog<_AutomationRule>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            String conditionText() {
              switch (trigger) {
                case 'Horario':
                  return '${_formatTime(startTime)} → ${_formatTime(endTime)}';

                case 'Luminosidad baja':
                  return 'Menor al ${luxThreshold.round()}%';

                case 'Sin actividad':
                  return '${inactivityMinutes.round()} min sin movimiento';

                case 'Movimiento detectado':
                default:
                  return 'Presencia detectada';
              }
            }

            final previewName =
                nameController.text.trim().isEmpty
                    ? 'Nueva automatización'
                    : nameController.text.trim();

            return Dialog(
              backgroundColor: const Color(0xFF141A23),
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 720,
                  maxHeight: 780,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // HEADER

                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFA78BFA,
                              ).withOpacity(.13),
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Color(0xFFA78BFA),
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nueva automatización',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Configura una regla inteligente paso a paso.',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF8F9AAA),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      // NOMBRE

                      const _DialogSectionTitle(
                        number: '01',
                        title: 'Nombre de la regla',
                        color: Color(0xFFA78BFA),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: nameController,
                        onChanged: (_) {
                          setDialogState(() {});
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Ej. Luces automáticas recepción',
                          prefixIcon: const Icon(
                            Icons.edit_rounded,
                          ),
                          filled: true,
                          fillColor:
                              const Color(0xFF10161E),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide:
                                BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // SI

                      const _DialogSectionTitle(
                        number: '02',
                        title: 'SI ocurre...',
                        color: Color(0xFF38BDF8),
                      ),

                      const SizedBox(height: 10),

                      _SelectBox(
                        icon:
                            Icons.flash_on_rounded,
                        color:
                            const Color(0xFF38BDF8),
                        label: 'Disparador',
                        child:
                            DropdownButtonHideUnderline(
                          child:
                              DropdownButton<String>(
                            value: trigger,
                            isExpanded: true,
                            dropdownColor:
                                const Color(
                              0xFF18202B,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value:
                                    'Movimiento detectado',
                                child: Text(
                                  'Movimiento detectado',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Horario',
                                child: Text(
                                  'Horario',
                                ),
                              ),
                              DropdownMenuItem(
                                value:
                                    'Luminosidad baja',
                                child: Text(
                                  'Luminosidad baja',
                                ),
                              ),
                              DropdownMenuItem(
                                value:
                                    'Sin actividad',
                                child: Text(
                                  'Sin actividad',
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;

                              setDialogState(() {
                                trigger = value;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // CONFIGURACIÓN SEGÚN DISPARADOR

                      if (trigger == 'Horario')
                        Row(
                          children: [
                            Expanded(
                              child: _TimeSelector(
                                title:
                                    'Hora inicial',
                                value: _formatTime(
                                  startTime,
                                ),
                                onTap: () async {
                                  final result =
                                      await showTimePicker(
                                    context:
                                        dialogContext,
                                    initialTime:
                                        startTime,
                                  );

                                  if (result != null) {
                                    setDialogState(() {
                                      startTime =
                                          result;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TimeSelector(
                                title: 'Hora final',
                                value: _formatTime(
                                  endTime,
                                ),
                                onTap: () async {
                                  final result =
                                      await showTimePicker(
                                    context:
                                        dialogContext,
                                    initialTime:
                                        endTime,
                                  );

                                  if (result != null) {
                                    setDialogState(() {
                                      endTime = result;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                      if (trigger ==
                          'Luminosidad baja')
                        _SliderSelector(
                          icon:
                              Icons.wb_twilight_rounded,
                          title:
                              'Nivel máximo de luminosidad',
                          value:
                              '${luxThreshold.round()}%',
                          min: 5,
                          max: 80,
                          divisions: 15,
                          sliderValue:
                              luxThreshold,
                          color:
                              const Color(
                            0xFFA78BFA,
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              luxThreshold =
                                  value;
                            });
                          },
                        ),

                      if (trigger ==
                          'Sin actividad')
                        _SliderSelector(
                          icon: Icons
                              .timer_outlined,
                          title:
                              'Tiempo sin movimiento',
                          value:
                              '${inactivityMinutes.round()} min',
                          min: 5,
                          max: 60,
                          divisions: 11,
                          sliderValue:
                              inactivityMinutes,
                          color:
                              const Color(
                            0xFFA78BFA,
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              inactivityMinutes =
                                  value;
                            });
                          },
                        ),

                      if (trigger ==
                          'Movimiento detectado')
                        const _InformationBox(
                          icon: Icons
                              .directions_walk_rounded,
                          color:
                              Color(0xFF38BDF8),
                          title:
                              'Sensor de presencia',
                          text:
                              'La regla se ejecutará cuando un sensor PIR detecte movimiento.',
                        ),

                      const SizedBox(height: 24),

                      // ÁREA

                      const _DialogSectionTitle(
                        number: '03',
                        title: '¿Dónde?',
                        color: Color(0xFFFFB020),
                      ),

                      const SizedBox(height: 10),

                      _SelectBox(
                        icon:
                            Icons.apartment_rounded,
                        color:
                            const Color(0xFFFFB020),
                        label: 'Área',
                        child:
                            DropdownButtonHideUnderline(
                          child:
                              DropdownButton<String>(
                            value: area,
                            isExpanded: true,
                            dropdownColor:
                                const Color(
                              0xFF18202B,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Recepción',
                                child:
                                    Text('Recepción'),
                              ),
                              DropdownMenuItem(
                                value:
                                    'Oficina administrativa',
                                child: Text(
                                  'Oficina administrativa',
                                ),
                              ),
                              DropdownMenuItem(
                                value:
                                    'Sala de reuniones',
                                child: Text(
                                  'Sala de reuniones',
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Pasillo',
                                child:
                                    Text('Pasillo'),
                              ),
                              DropdownMenuItem(
                                value: 'Bodega',
                                child:
                                    Text('Bodega'),
                              ),
                              DropdownMenuItem(
                                value: 'Cafetería',
                                child:
                                    Text('Cafetería'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;

                              setDialogState(() {
                                area = value;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ACCIÓN

                      const _DialogSectionTitle(
                        number: '04',
                        title: 'ENTONCES...',
                        color: Color(0xFF22C55E),
                      ),

                      const SizedBox(height: 10),

                      _SelectBox(
                        icon:
                            Icons.lightbulb_rounded,
                        color:
                            const Color(0xFF22C55E),
                        label: 'Acción',
                        child:
                            DropdownButtonHideUnderline(
                          child:
                              DropdownButton<String>(
                            value: action,
                            isExpanded: true,
                            dropdownColor:
                                const Color(
                              0xFF18202B,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Encender',
                                child:
                                    Text('Encender'),
                              ),
                              DropdownMenuItem(
                                value: 'Apagar',
                                child:
                                    Text('Apagar'),
                              ),
                              DropdownMenuItem(
                                value:
                                    'Reducir iluminación',
                                child: Text(
                                  'Reducir iluminación',
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;

                              setDialogState(() {
                                action = value;

                                if (action ==
                                    'Apagar') {
                                  intensity = 0;
                                } else if (intensity ==
                                    0) {
                                  intensity = 100;
                                }
                              });
                            },
                          ),
                        ),
                      ),

                      if (action != 'Apagar') ...[
                        const SizedBox(height: 12),
                        _SliderSelector(
                          icon:
                              Icons.tune_rounded,
                          title:
                              'Intensidad',
                          value:
                              '${intensity.round()}%',
                          min: 10,
                          max: 100,
                          divisions: 9,
                          sliderValue:
                              intensity.clamp(
                            10,
                            100,
                          ),
                          color:
                              const Color(
                            0xFFFFB020,
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              intensity = value;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 26),

                      // PREVISUALIZACIÓN

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient:
                              const LinearGradient(
                            begin:
                                Alignment.topLeft,
                            end: Alignment
                                .bottomRight,
                            colors: [
                              Color(0xFF1E192A),
                              Color(0xFF10161E),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(
                              0xFFA78BFA,
                            ).withOpacity(.20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PREVISUALIZACIÓN',
                              style: TextStyle(
                                color:
                                    Color(
                                  0xFFA78BFA,
                                ),
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              previewName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _PreviewTag(
                                  color:
                                      const Color(
                                    0xFF38BDF8,
                                  ),
                                  text: trigger,
                                ),
                                _PreviewTag(
                                  color:
                                      const Color(
                                    0xFFA78BFA,
                                  ),
                                  text:
                                      conditionText(),
                                ),
                                _PreviewTag(
                                  color:
                                      const Color(
                                    0xFFFFB020,
                                  ),
                                  text: area,
                                ),
                                _PreviewTag(
                                  color:
                                      const Color(
                                    0xFF22C55E,
                                  ),
                                  text: action ==
                                          'Apagar'
                                      ? 'Apagar luces'
                                      : '$action · ${intensity.round()}%',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                );
                              },
                              child: const Text(
                                'Cancelar',
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child:
                                FilledButton.icon(
                              onPressed: () {
                                final name =
                                    nameController
                                            .text
                                            .trim();

                                if (name.isEmpty) {
                                  ScaffoldMessenger
                                          .of(
                                    dialogContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Escribe un nombre para la automatización.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final rule =
                                    _AutomationRule(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  name: name,
                                  trigger:
                                      trigger,
                                  condition:
                                      conditionText(),
                                  targetArea:
                                      area,
                                  action: action,
                                  intensity:
                                      action ==
                                              'Apagar'
                                          ? 0
                                          : intensity
                                              .round(),
                                  enabled: true,
                                  executions:
                                      0,
                                  color:
                                      _colorForTrigger(
                                    trigger,
                                  ),
                                  icon:
                                      _iconForTrigger(
                                    trigger,
                                  ),
                                );

                                Navigator.pop(
                                  dialogContext,
                                  rule,
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .check_rounded,
                              ),
                              label: const Text(
                                'Crear automatización',
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
      },
    );

    nameController.dispose();

    if (created != null && mounted) {
      setState(() {
        _rules.insert(0, created);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Automatización "${created.name}" creada correctamente.',
          ),
        ),
      );
    }
  }

  // ===============================================================
  // ELIMINAR
  // ===============================================================

  Future<void> _deleteRule(
    _AutomationRule rule,
  ) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF141A23),
          title: const Text(
            'Eliminar automatización',
          ),
          content: Text(
            '¿Quieres eliminar "${rule.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (delete == true) {
      setState(() {
        _rules.removeWhere(
          (item) => item.id == rule.id,
        );
      });
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          28,
          28,
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
                // HEADER

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
                                  0xFFA78BFA,
                                ),
                                shape:
                                    BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Color(
                                      0x88A78BFA,
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
                              'MOTOR DE AUTOMATIZACIÓN',
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

                        const Text(
                          'Automatizaciones',
                          style:
                              TextStyle(
                            fontSize: 38,
                            fontWeight:
                                FontWeight
                                    .w900,
                            letterSpacing:
                                -1.3,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        const Text(
                          'Crea reglas inteligentes para que la iluminación responda automáticamente.',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF9DA7B5,
                            ),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    );

                    final button =
                        FilledButton.icon(
                      onPressed:
                          _openAutomationBuilder,
                      icon: const Icon(
                        Icons.add_rounded,
                      ),
                      label: const Text(
                        'Nueva automatización',
                      ),
                    );

                    if (!desktop) {
                      return Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          title,
                          const SizedBox(
                            height: 18,
                          ),
                          button,
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
                        button,
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                // MÉTRICAS

                LayoutBuilder(
                  builder:
                      (context, constraints) {
                    var columns = 1;

                    if (constraints.maxWidth >=
                        1000) {
                      columns = 4;
                    } else if (constraints
                            .maxWidth >=
                        620) {
                      columns = 2;
                    }

                    return GridView.count(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          columns,
                      crossAxisSpacing:
                          14,
                      mainAxisSpacing:
                          14,
                      childAspectRatio:
                          columns == 4
                              ? 2.0
                              : 2.2,
                      children: [
                        _MetricCard(
                          icon: Icons
                              .auto_awesome_rounded,
                          value:
                              '$activeRules',
                          title:
                              'Reglas activas',
                          subtitle:
                              '${_rules.length} configuradas',
                          color:
                              const Color(
                            0xFFA78BFA,
                          ),
                        ),

                        _MetricCard(
                          icon: Icons
                              .schedule_rounded,
                          value:
                              '${_rules.where((rule) => rule.trigger == 'Horario').length}',
                          title:
                              'Programaciones',
                          subtitle:
                              'Basadas en horario',
                          color:
                              const Color(
                            0xFF38BDF8,
                          ),
                        ),

                        _MetricCard(
                          icon: Icons
                              .energy_savings_leaf_rounded,
                          value:
                              '$estimatedSaving%',
                          title:
                              'Ahorro estimado',
                          subtitle:
                              'Optimización energética',
                          color:
                              const Color(
                            0xFF22C55E,
                          ),
                        ),

                        _MetricCard(
                          icon: Icons
                              .bolt_rounded,
                          value:
                              '$executions',
                          title:
                              'Ejecuciones',
                          subtitle:
                              'Actividad acumulada',
                          color:
                              const Color(
                            0xFFFFB020,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // CONSTRUCTOR VISUAL

                const _BuilderHero(),

                const SizedBox(height: 34),

                const Text(
                  'REGLAS CONFIGURADAS',
                  style: TextStyle(
                    color:
                        Color(0xFFA78BFA),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Automatizaciones inteligentes',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),

                    Text(
                      '${_rules.length} reglas',
                      style: const TextStyle(
                        color:
                            Color(
                          0xFF8F9AAA,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                const Text(
                  'Activa, pausa o elimina reglas según las necesidades de la sede.',
                  style: TextStyle(
                    color:
                        Color(0xFF8F9AAA),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 18),

                if (_rules.isEmpty)
                  const _EmptyAutomations()
                else
                  ..._rules.map(
                    (rule) => Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),
                      child:
                          _AutomationCard(
                        rule: rule,
                        onToggle:
                            (enabled) {
                          setState(() {
                            rule.enabled =
                                enabled;
                          });
                        },
                        onDelete: () {
                          _deleteRule(
                            rule,
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                _BottomInfo(
                  rules: _rules,
                  saving:
                      estimatedSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(
    TimeOfDay time,
  ) {
    final hour =
        time.hour.toString().padLeft(
              2,
              '0',
            );

    final minute =
        time.minute.toString().padLeft(
              2,
              '0',
            );

    return '$hour:$minute';
  }

  static Color _colorForTrigger(
    String trigger,
  ) {
    switch (trigger) {
      case 'Horario':
        return const Color(0xFFA78BFA);

      case 'Movimiento detectado':
        return const Color(0xFF38BDF8);

      case 'Luminosidad baja':
        return const Color(0xFFFFB020);

      case 'Sin actividad':
        return const Color(0xFF22C55E);

      default:
        return const Color(0xFFA78BFA);
    }
  }

  static IconData _iconForTrigger(
    String trigger,
  ) {
    switch (trigger) {
      case 'Horario':
        return Icons.schedule_rounded;

      case 'Movimiento detectado':
        return Icons
            .directions_walk_rounded;

      case 'Luminosidad baja':
        return Icons
            .wb_twilight_rounded;

      case 'Sin actividad':
        return Icons
            .energy_savings_leaf_rounded;

      default:
        return Icons
            .auto_awesome_rounded;
    }
  }
}

// ==================================================================
// MODELO LOCAL
// ==================================================================

class _AutomationRule {
  _AutomationRule({
    required this.id,
    required this.name,
    required this.trigger,
    required this.condition,
    required this.targetArea,
    required this.action,
    required this.intensity,
    required this.enabled,
    required this.executions,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String trigger;
  final String condition;
  final String targetArea;
  final String action;
  final int intensity;

  bool enabled;

  final int executions;
  final Color color;
  final IconData icon;
}

// ==================================================================
// BUILDER HERO
// ==================================================================

class _BuilderHero
    extends StatelessWidget {
  const _BuilderHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF1E192A),
            Color(0xFF141A23),
          ],
        ),
        borderRadius:
            BorderRadius.circular(28),
        border: Border.all(
          color:
              const Color(0xFF3A3151),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFA78BFA,
                  ).withOpacity(.13),
                  borderRadius:
                      BorderRadius
                          .circular(
                    16,
                  ),
                ),
                child: const Icon(
                  Icons
                      .account_tree_rounded,
                  color:
                      Color(0xFFA78BFA),
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'LÓGICA SMARTLIGHT',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFFA78BFA,
                        ),
                        fontSize: 10,
                        fontWeight:
                            FontWeight
                                .w900,
                        letterSpacing:
                            1.3,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'SI → CONDICIÓN → ENTONCES',
                      style:
                          TextStyle(
                        fontSize: 21,
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

          LayoutBuilder(
            builder:
                (context, constraints) {
              final desktop =
                  constraints.maxWidth >=
                      850;

              const first =
                  _BuilderStep(
                number: '01',
                title: 'SI',
                text:
                    'Detectar un evento',
                helper:
                    'Movimiento, horario, luz...',
                icon: Icons
                    .sensors_rounded,
                color:
                    Color(0xFF38BDF8),
              );

              const second =
                  _BuilderStep(
                number: '02',
                title: 'DÓNDE',
                text:
                    'Elegir un área',
                helper:
                    'Recepción, pasillo...',
                icon: Icons
                    .apartment_rounded,
                color:
                    Color(0xFFA78BFA),
              );

              const third =
                  _BuilderStep(
                number: '03',
                title: 'ACCIÓN',
                text:
                    'Controlar iluminación',
                helper:
                    'Encender, apagar, reducir...',
                icon: Icons
                    .lightbulb_rounded,
                color:
                    Color(0xFFFFB020),
              );

              if (!desktop) {
                return const Column(
                  children: [
                    first,
                    SizedBox(
                      height: 10,
                    ),
                    second,
                    SizedBox(
                      height: 10,
                    ),
                    third,
                  ],
                );
              }

              return const Row(
                children: [
                  Expanded(
                    child: first,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Icon(
                      Icons
                          .arrow_forward_rounded,
                      color:
                          Color(
                        0xFF596475,
                      ),
                    ),
                  ),
                  Expanded(
                    child: second,
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Icon(
                      Icons
                          .arrow_forward_rounded,
                      color:
                          Color(
                        0xFF596475,
                      ),
                    ),
                  ),
                  Expanded(
                    child: third,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BuilderStep
    extends StatelessWidget {
  const _BuilderStep({
    required this.number,
    required this.title,
    required this.text,
    required this.helper,
    required this.icon,
    required this.color,
  });

  final String number;
  final String title;
  final String text;
  final String helper;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xFF10161E),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              color.withOpacity(.18),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(
                    .12,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                number,
                style:
                    TextStyle(
                  color:
                      color.withOpacity(
                    .70,
                  ),
                  fontSize: 22,
                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 17,
          ),
          Text(
            title,
            style:
                TextStyle(
              color: color,
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            text,
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            helper,
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

// ==================================================================
// AUTOMATION CARD
// ==================================================================

class _AutomationCard
    extends StatelessWidget {
  const _AutomationCard({
    required this.rule,
    required this.onToggle,
    required this.onDelete,
  });

  final _AutomationRule rule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final actionText =
        rule.action == 'Apagar'
            ? 'Apagar luces'
            : '${rule.action} · ${rule.intensity}%';

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 200,
      ),
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: rule.enabled
            ? LinearGradient(
                begin:
                    Alignment.centerLeft,
                end: Alignment
                    .centerRight,
                colors: [
                  rule.color
                      .withOpacity(.07),
                  const Color(
                    0xFF141A23,
                  ),
                ],
              )
            : null,
        color: rule.enabled
            ? null
            : const Color(
                0xFF141A23,
              ),
        borderRadius:
            BorderRadius.circular(23),
        border: Border.all(
          color: rule.enabled
              ? rule.color
                  .withOpacity(.28)
              : const Color(
                  0xFF222B36,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                BoxDecoration(
              color:
                  rule.color.withOpacity(
                .12,
              ),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: Icon(
              rule.icon,
              color: rule.color,
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
                  rule.name,
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
                  '${rule.trigger} en ${rule.targetArea}',
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF8F9AAA,
                    ),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _RuleTag(
                      icon: Icons
                          .flash_on_rounded,
                      text:
                          rule.trigger,
                      color:
                          rule.color,
                    ),
                    _RuleTag(
                      icon: Icons
                          .filter_alt_outlined,
                      text:
                          rule.condition,
                      color:
                          const Color(
                        0xFF38BDF8,
                      ),
                    ),
                    _RuleTag(
                      icon: Icons
                          .apartment_rounded,
                      text: rule
                          .targetArea,
                      color:
                          const Color(
                        0xFFA78BFA,
                      ),
                    ),
                    _RuleTag(
                      icon: Icons
                          .arrow_forward_rounded,
                      text:
                          actionText,
                      color:
                          const Color(
                        0xFFFFB020,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 11,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .history_rounded,
                      size: 13,
                      color:
                          Color(
                        0xFF697586,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '${rule.executions} ejecuciones',
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
              ],
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Column(
            children: [
              Switch.adaptive(
                value:
                    rule.enabled,
                onChanged:
                    onToggle,
              ),

              Text(
                rule.enabled
                    ? 'ACTIVA'
                    : 'PAUSADA',
                style:
                    TextStyle(
                  color: rule.enabled
                      ? const Color(
                          0xFF22C55E,
                        )
                      : const Color(
                          0xFF8F9AAA,
                        ),
                  fontSize: 8,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              IconButton(
                tooltip:
                    'Eliminar',
                onPressed:
                    onDelete,
                icon: const Icon(
                  Icons
                      .delete_outline_rounded,
                  color:
                      Color(
                    0xFFFF4D5A,
                  ),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// METRIC
// ==================================================================

class _MetricCard
    extends StatelessWidget {
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
      padding:
          const EdgeInsets.all(18),
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
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
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
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
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
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// RULE TAG
// ==================================================================

class _RuleTag
    extends StatelessWidget {
  const _RuleTag({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            color.withOpacity(.08),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              color.withOpacity(.12),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
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
                0xFFB8C0CC,
              ),
              fontSize: 9,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SELECT BOX
// ==================================================================

class _SelectBox
    extends StatelessWidget {
  const _SelectBox({
    required this.icon,
    required this.color,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final Color color;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF10161E),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              color.withOpacity(.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(.12),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
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
                  label,
                  style:
                      TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SLIDER
// ==================================================================

class _SliderSelector
    extends StatelessWidget {
  const _SliderSelector({
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.sliderValue,
    required this.color,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final double min;
  final double max;
  final int divisions;
  final double sliderValue;
  final Color color;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            const Color(0xFF10161E),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              color.withOpacity(.18),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 19,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
              Text(
                value,
                style:
                    TextStyle(
                  color: color,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: sliderValue,
            min: min,
            max: max,
            divisions:
                divisions,
            activeColor:
                color,
            onChanged:
                onChanged,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// TIME SELECTOR
// ==================================================================

class _TimeSelector
    extends StatelessWidget {
  const _TimeSelector({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color:
              const Color(0xFF10161E),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color:
                const Color(
              0xFFA78BFA,
            ).withOpacity(.18),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              color:
                  Color(
                0xFFA78BFA,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF8F9AAA,
                      ),
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    value,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// INFORMATION
// ==================================================================

class _InformationBox
    extends StatelessWidget {
  const _InformationBox({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            color.withOpacity(.06),
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color:
              color.withOpacity(.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  text,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF8F9AAA,
                    ),
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

// ==================================================================
// DIALOG TITLE
// ==================================================================

class _DialogSectionTitle
    extends StatelessWidget {
  const _DialogSectionTitle({
    required this.number,
    required this.title,
    required this.color,
  });

  final String number;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color:
                color.withOpacity(.10),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          child: Text(
            number,
            style:
                TextStyle(
              color: color,
              fontSize: 9,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Text(
          title,
          style:
              const TextStyle(
            fontSize: 14,
            fontWeight:
                FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// PREVIEW TAG
// ==================================================================

class _PreviewTag
    extends StatelessWidget {
  const _PreviewTag({
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
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color:
            color.withOpacity(.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style:
            TextStyle(
          color: color,
          fontSize: 9,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }
}

// ==================================================================
// BOTTOM INFO
// ==================================================================

class _BottomInfo
    extends StatelessWidget {
  const _BottomInfo({
    required this.rules,
    required this.saving,
  });

  final List<_AutomationRule> rules;
  final int saving;

  @override
  Widget build(BuildContext context) {
    final active =
        rules.where((rule) => rule.enabled).length;

    return LayoutBuilder(
      builder:
          (context, constraints) {
        final desktop =
            constraints.maxWidth >=
                850;

        final performance =
            _InfoPanel(
          icon: Icons
              .energy_savings_leaf_rounded,
          color:
              const Color(
            0xFF22C55E,
          ),
          label: 'RENDIMIENTO',
          title:
              'Impacto energético',
          lines: [
            'Ahorro estimado · $saving%',
            'Reglas activas · $active',
            'Cobertura · ${rules.isEmpty ? 0 : ((active / rules.length) * 100).round()}%',
          ],
        );

        final engine =
            _InfoPanel(
          icon: Icons
              .hub_rounded,
          color:
              const Color(
            0xFFA78BFA,
          ),
          label: 'MOTOR',
          title:
              'Estado de automatización',
          lines: [
            '${rules.length} reglas configuradas',
            '$active reglas habilitadas',
            'Constructor visual activo',
          ],
        );

        if (!desktop) {
          return Column(
            children: [
              performance,
              const SizedBox(
                height: 16,
              ),
              engine,
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child:
                  performance,
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: engine,
            ),
          ],
        );
      },
    );
  }
}

class _InfoPanel
    extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.color,
    required this.label,
    required this.title,
    required this.lines,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color:
            const Color(
          0xFF141A23,
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              color.withOpacity(.18),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color:
                      color.withOpacity(
                    .12,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:
                        TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          ...lines.map(
            (line) => Padding(
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
                        BoxDecoration(
                      color: color,
                      shape:
                          BoxShape.circle,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    line,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF9DA7B5,
                      ),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// EMPTY
// ==================================================================

class _EmptyAutomations
    extends StatelessWidget {
  const _EmptyAutomations();

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color:
            const Color(
          0xFF141A23,
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              const Color(
            0xFF222B36,
          ),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons
                .auto_awesome_rounded,
            color:
                Color(
              0xFFA78BFA,
            ),
            size: 38,
          ),
          SizedBox(
            height: 12,
          ),
          Text(
            'No hay automatizaciones',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text(
            'Usa "Nueva automatización" para crear la primera regla.',
            style:
                TextStyle(
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