import 'package:flutter/material.dart';

class AutomationsPage extends StatelessWidget {
  const AutomationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Automatizaciones',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          const Text('La base del módulo ya está reservada para la Fase 7.'),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 32),
                  SizedBox(height: 14),
                  Text(
                    'Constructor SI → CONDICIÓN → ENTONCES',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'En esta fase no ejecutamos reglas todavía. La entidad '
                    'Automation ya existe y el módulo queda desacoplado del IoT.',
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
