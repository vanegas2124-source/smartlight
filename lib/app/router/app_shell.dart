import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _navigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF080C12),
                    border: Border(right: BorderSide(color: Color(0xFF1E2632))),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 26),

                        // LOGO
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: Row(
                            children: [
                              _Logo(),
                              SizedBox(width: 13),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SmartLight',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'ENTERPRISE',
                                    style: TextStyle(
                                      color: Color(0xFFFFB020),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 38),

                        _NavItem(
                          icon: Icons.dashboard_rounded,
                          label: 'Dashboard',
                          selected: navigationShell.currentIndex == 0,
                          onTap: () => _navigate(0),
                        ),

                        _NavItem(
                          icon: Icons.apartment_rounded,
                          label: 'Áreas',
                          selected: navigationShell.currentIndex == 1,
                          onTap: () => _navigate(1),
                        ),
                        _NavItem(
                          icon: Icons.videocam_rounded,
                          label: 'Cámaras',
                          selected: navigationShell.currentIndex == 2,
                          onTap: () => _navigate(2),
                        ),
                        _NavItem(
                          icon: Icons.auto_awesome_rounded,
                          label: 'Automatizaciones',
                          selected: navigationShell.currentIndex == 3,
                          onTap: () => _navigate(3),
                        ),

                        _NavItem(
                          icon: Icons.notifications_rounded,
                          label: 'Alertas',
                          selected: navigationShell.currentIndex == 4,
                          onTap: () => _navigate(4),
                        ),

                        _NavItem(
                          icon: Icons.settings_rounded,
                          label: 'Configuración',
                          selected: navigationShell.currentIndex == 5,
                          onTap: () => _navigate(5),
                        ),

                        const Spacer(),

                        // ESTADO INFERIOR
                        Container(
                          margin: const EdgeInsets.all(18),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111821),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFF202A36)),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF143B2A),
                                child: Icon(
                                  Icons.business_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sede Principal',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 7,
                                          color: Color(0xFF22C55E),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Sistema conectado',
                                          style: TextStyle(
                                            color: Color(0xFF8F9AAA),
                                            fontSize: 11,
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
                      ],
                    ),
                  ),
                ),

                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        // Solo celular
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _navigate,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Inicio',
              ),
              NavigationDestination(
                icon: Icon(Icons.apartment_outlined),
                selectedIcon: Icon(Icons.apartment_rounded),
                label: 'Áreas',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome_rounded),
                label: 'Automat.',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded),
                selectedIcon: Icon(Icons.notifications_rounded),
                label: 'Alertas',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Más',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA800), Color(0xFFFFD65A)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB020).withOpacity(.25),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, size: 28, color: Colors.black),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: selected
            ? const Color(0xFFFFB020).withOpacity(.13)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? const Color(0xFFFFB020)
                      : const Color(0xFF8994A5),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFFA6AFBC),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB020),
                      shape: BoxShape.circle,
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
