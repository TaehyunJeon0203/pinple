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
import 'package:pinple/features/map/presentation/map_screen.dart';
import 'package:pinple/features/profile/presentation/profile_screen.dart';

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
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const EmailVerifyScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (_, __) => const MapScreen(),
      ),
      GoRoute(
        path: '/group/create',
        builder: (_, __) => const GroupCreateScreen(),
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
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
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
