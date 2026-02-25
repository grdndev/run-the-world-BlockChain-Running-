import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/home/screens/dashboard_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/ranking/screens/ranking_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/land/screens/land_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/ranking',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: RankingScreen()),
        ),
        GoRoute(
          path: '/map',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MapScreen()),
        ),
        GoRoute(
          path: '/lands',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LandScreen()),
        ),
        GoRoute(
          path: '/wallet',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WalletScreen()),
        ),
      ],
    ),
  ],
);
