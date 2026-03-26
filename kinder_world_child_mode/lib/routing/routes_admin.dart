import 'package:go_router/go_router.dart';

import 'package:kinder_world/features/admin/auth/admin_login_screen.dart';
import 'package:kinder_world/features/admin/dashboard/admin_dashboard_screen.dart';
import 'package:kinder_world/features/admin/shared/admin_access_denied_screen.dart';

import 'route_paths.dart';

List<RouteBase> buildAdminRoutes() {
  return [
    GoRoute(
      path: Routes.adminLogin,
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: Routes.adminDashboard,
      builder: (context, state) =>
          const AdminDashboardScreen(activePath: Routes.adminDashboard),
    ),
    GoRoute(
      path: Routes.adminUsers,
      builder: (context, state) =>
          const AdminDashboardScreen(activePath: Routes.adminUsers),
    ),
    GoRoute(
      path: '${Routes.adminUsers}/:userId',
      builder: (context, state) => AdminDashboardScreen(
        activePath: '${Routes.adminUsers}/${state.pathParameters['userId']}',
      ),
    ),
    GoRoute(
      path: Routes.adminChildren,
      builder: (context, state) =>
          const AdminDashboardScreen(activePath: Routes.adminChildren),
    ),
    GoRoute(
      path: '${Routes.adminChildren}/:childId',
      builder: (context, state) => AdminDashboardScreen(
        activePath:
            '${Routes.adminChildren}/${state.pathParameters['childId']}',
      ),
    ),
    GoRoute(
      path: Routes.adminContent,
      redirect: (context, state) => Routes.adminDashboard,
    ),
    GoRoute(
      path: Routes.adminReports,
      redirect: (context, state) => Routes.adminDashboard,
    ),
    GoRoute(
      path: Routes.adminSupport,
      builder: (context, state) =>
          const AdminDashboardScreen(activePath: Routes.adminSupport),
    ),
    GoRoute(
      path: Routes.adminSubscriptions,
      redirect: (context, state) => Routes.adminDashboard,
    ),
    GoRoute(
      path: Routes.adminAdmins,
      redirect: (context, state) => Routes.adminDashboard,
    ),
    GoRoute(
      path: Routes.adminAudit,
      builder: (context, state) =>
          const AdminDashboardScreen(activePath: Routes.adminAudit),
    ),
    GoRoute(
      path: Routes.adminSettings,
      redirect: (context, state) => Routes.adminDashboard,
    ),
    GoRoute(
      path: Routes.adminAccessDenied,
      builder: (context, state) => const AdminAccessDeniedScreen(),
    ),
  ];
}
