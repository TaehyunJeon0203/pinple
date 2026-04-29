import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/features/auth/presentation/email_verify_screen.dart';
import 'package:pinple/features/auth/presentation/login_screen.dart';
import 'package:pinple/features/auth/presentation/signup_screen.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/presentation/group_create_screen.dart';
import 'package:pinple/features/map/presentation/group_detail_screen.dart';
import 'package:pinple/features/map/presentation/group_list_screen.dart';
import 'package:pinple/features/map/presentation/map_screen.dart';
import 'package:pinple/features/profile/presentation/profile_screen.dart';
import 'package:pinple/features/shell/presentation/location_gate.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = authState.value;
      final isLoggedIn = user != null;
      final isEmailVerified = user?.emailVerified ?? false;
      final currentPath = state.matchedLocation;

      final authPaths = ['/login', '/signup'];
      final isOnAuthPage = authPaths.contains(currentPath);

      if (!isLoggedIn) {
        return isOnAuthPage ? null : '/login';
      }

      if (!isEmailVerified) {
        return currentPath == '/verify-email' ? null : '/verify-email';
      }

      if (isOnAuthPage || currentPath == '/verify-email') {
        return '/map';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, _) => const EmailVerifyScreen(),
      ),
      ShellRoute(
        builder: (_, _, child) => LocationGate(child: child),
        routes: [
          GoRoute(
            path: '/map',
            builder: (_, _) => const MapScreen(),
          ),
          GoRoute(
            path: '/list',
            builder: (_, _) => const GroupListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/group/create',
        builder: (_, _) => const GroupCreateScreen(),
      ),
      GoRoute(
        path: '/group/:id',
        builder: (_, state) => GroupDetailScreen(
          groupId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/group/:id/edit',
        builder: (_, state) => GroupCreateScreen(
          groupId: state.pathParameters['id'],
        ),
      ),
    ],
  );
});

class PinpleApp extends ConsumerWidget {
  const PinpleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Pinple',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
