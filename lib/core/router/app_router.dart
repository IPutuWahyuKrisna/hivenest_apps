import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
// Register dinonaktifkan: pendaftaran akun tidak tersedia dari aplikasi.
// import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/hive/presentation/pages/add_hive_page.dart';
import '../../features/hive/presentation/pages/edit_hive_page.dart';
import '../../features/hive/presentation/pages/hive_detail_page.dart';
import '../../features/hive/domain/entities/hive_detail.dart';
import '../../features/map/presentation/pages/map_page.dart';
import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    // Register dinonaktifkan: akun dibuat dari sisi admin/backend.
    // GoRoute(
    //   path: '/register',
    //   builder: (context, state) => const RegisterPage(),
    // ),
    GoRoute(
      path: '/add-hive',
      builder: (context, state) => const AddHivePage(),
    ),
    GoRoute(
      path: '/edit-hive/:id',
      builder: (context, state) => EditHivePage(
        detail: state.extra as HiveDetail,
      ),
    ),
    GoRoute(
      path: '/hive/:id',
      builder: (context, state) =>
          HiveDetailPage(hiveId: state.pathParameters['id']!),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedule',
              builder: (context, state) => const SchedulePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
