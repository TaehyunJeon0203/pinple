import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/location_gate/presentation/location_blocked_screen.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationCheck = ref.watch(locationCheckProvider);

    return locationCheck.when(
      loading: () => const Scaffold(
        body: Center(child: AppLoader()),
      ),
      error: (error, _) => Scaffold(
        body: SafeArea(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: '위치를 확인할 수 없어요',
            description: error.toString().replaceFirst('Exception: ', ''),
            action: ElevatedButton(
              onPressed: () => ref.invalidate(currentPositionProvider),
              child: const Text('다시 시도'),
            ),
          ),
        ),
      ),
      data: (isWithin) {
        if (!isWithin) return const LocationBlockedScreen();
        return _buildShell(context);
      },
    );
  }

  Widget _buildShell(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map_rounded),
              label: '지도',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded),
              activeIcon: Icon(Icons.list_rounded),
              label: '리스트',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}
