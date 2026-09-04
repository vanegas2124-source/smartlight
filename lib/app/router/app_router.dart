import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/alerts/presentation/pages/alerts_page.dart';
import '../../features/areas/presentation/pages/areas_page.dart';
import '../../features/automations/presentation/pages/automations_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/devices/presentation/pages/area_detail_page.dart';
import '../../features/settings/presentation/pages/more_page.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _areasNavigatorKey = GlobalKey<NavigatorState>();
final _automationsNavigatorKey = GlobalKey<NavigatorState>();
final _alertsNavigatorKey = GlobalKey<NavigatorState>();
final _moreNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/dashboard',
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _dashboardNavigatorKey,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _areasNavigatorKey,
          routes: [
            GoRoute(
              path: '/areas',
              builder: (context, state) => const AreasPage(),
              routes: [
                GoRoute(
                  path: ':areaId',
                  builder: (context, state) => AreaDetailPage(
                    areaId: state.pathParameters['areaId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _automationsNavigatorKey,
          routes: [
            GoRoute(
              path: '/automations',
              builder: (context, state) => const AutomationsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _alertsNavigatorKey,
          routes: [
            GoRoute(
              path: '/alerts',
              builder: (context, state) => const AlertsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _moreNavigatorKey,
          routes: [
            GoRoute(
              path: '/more',
              builder: (context, state) => const MorePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
