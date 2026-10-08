import 'package:go_router/go_router.dart';
import '../../features/cameras/presentation/pages/cameras_pages.dart';
import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/areas/presentation/pages/areas_page.dart';
import '../../features/automations/presentation/pages/automations_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/devices/presentation/pages/area_detail_page.dart';
import '../../features/settings/presentation/pages/more_page.dart';

import 'app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // ============================================================
        // DASHBOARD
        // ============================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'dashboard',
              builder: (context, state) {
                return const DashboardPage();
              },
            ),
          ],
        ),

        // ============================================================
        // ÁREAS
        // ============================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/areas',
              name: 'areas',
              builder: (context, state) {
                return const AreasPage();
              },
              routes: [
                GoRoute(
                  path: ':areaId',
                  name: 'area-detail',
                  builder: (context, state) {
                    final areaId = state.pathParameters['areaId']!;

                    return AreaDetailPage(areaId: areaId);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cameras',
              name: 'cameras',
              builder: (context, state) {
                return const CamerasPage();
              },
            ),
          ],
        ),
        // ============================================================
        // AUTOMATIZACIONES
        // ============================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/automations',
              name: 'automations',
              builder: (context, state) {
                return const AutomationsPage();
              },
            ),
          ],
        ),

        // ============================================================
        // ALERTAS
        // ============================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/alerts',
              name: 'alerts',
              builder: (context, state) {
                return const AlertsPage();
              },
            ),
          ],
        ),

        // ============================================================
        // CONFIGURACIÓN / MÁS
        // ============================================================
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              name: 'more',
              builder: (context, state) {
                return const MorePage();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
