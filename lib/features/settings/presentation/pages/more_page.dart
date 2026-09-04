import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_mode_controller.dart';

class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Text(
            'Más',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Modo oscuro'),
              subtitle: const Text('La preferencia se guarda localmente.'),
              value: themeMode == ThemeMode.dark,
              onChanged: (enabled) {
                ref.read(themeModeProvider.notifier).setDarkMode(enabled);
              },
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.business_outlined),
                  title: Text('Empresa Demo'),
                  subtitle: Text('Sede Principal'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.memory_rounded),
                  title: Text('IoT'),
                  subtitle: Text('MockIoTRepository activo'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('SmartLight Enterprise'),
                  subtitle: Text('Fase 2 · Base Flutter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
