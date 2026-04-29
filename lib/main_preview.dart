import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/core/widgets/group_card.dart';
import 'package:pinple/features/map/domain/group_model.dart';

void main() {
  runApp(const PinplePreviewApp());
}

class PinplePreviewApp extends StatelessWidget {
  const PinplePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pinple Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/map',
  routes: [
    GoRoute(path: '/map', builder: (_, _) => const _PreviewMapHome()),
    GoRoute(path: '/list', builder: (_, _) => const _PreviewListScreen()),
    GoRoute(path: '/profile', builder: (_, _) => const _PreviewProfile()),
  ],
);

GroupModel _mockGroup({
  required String id,
  required String title,
  required String category,
  required String location,
  int members = 3,
  int max = 6,
  String description = '함께 모여서 즐겁게 활동해요!',
  required double lat,
  required double lng,
}) {
  return GroupModel(
    id: id,
    title: title,
    description: description,
    category: category,
    maxMembers: max,
    memberIds: List.generate(members, (i) => 'u$i'),
    ownerId: 'u0',
    ownerNickname: '코딩왕',
    latitude: lat,
    longitude: lng,
    locationName: location,
    createdAt: DateTime.now(),
  );
}

final _mockGroups = [
  _mockGroup(
    id: '1',
    title: '알고리즘 스터디',
    category: '스터디',
    location: '공대 3호관 스터디룸',
    description: '매주 수요일 저녁 7시에 모여서 백준/프로그래머스 풀어요.',
    lat: 36.8500,
    lng: 127.1515,
  ),
  _mockGroup(
    id: '2',
    title: '풋살 같이해요',
    category: '운동',
    location: '대운동장',
    members: 7,
    max: 10,
    lat: 36.8505,
    lng: 127.1520,
  ),
  _mockGroup(
    id: '3',
    title: '점심 밥약',
    category: '밥약',
    location: '학생식당 앞',
    members: 2,
    max: 4,
    lat: 36.8512,
    lng: 127.1530,
  ),
];

// ─── Map home (with drawer + hamburger + FAB) ───
class _PreviewMapHome extends StatelessWidget {
  const _PreviewMapHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _PreviewDrawer(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map placeholder (gray with grid)
          const _MapPlaceholder(),
          // Sample pins
          const Positioned(
            top: 220,
            left: 80,
            child: _PreviewPin(label: '알고리즘 스터디', category: '스터디'),
          ),
          const Positioned(
            top: 340,
            left: 220,
            child: _PreviewPin(label: '풋살 같이해요', category: '운동'),
          ),
          const Positioned(
            top: 280,
            left: 30,
            child: _PreviewPin(label: '점심 밥약', category: '밥약'),
          ),
          // Hamburger top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.lg,
            child: Builder(
              builder: (context) => _CircleIconButton(
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          // List toggle top-right
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.lg,
            child: _CircleIconButton(
              icon: Icons.list_rounded,
              onTap: () => context.push('/list'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          '모임 만들기',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8EBEE),
      child: Stack(
        children: [
          // Grid pattern
          for (int i = 0; i < 20; i++)
            Positioned(
              top: i * 50.0,
              left: 0,
              right: 0,
              child: Container(height: 1, color: const Color(0xFFD8DDE2)),
            ),
          for (int i = 0; i < 10; i++)
            Positioned(
              left: i * 50.0,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: const Color(0xFFD8DDE2)),
            ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 48, color: Color(0xFF8B95A1)),
                SizedBox(height: 8),
                Text(
                  '네이버 지도 영역',
                  style: TextStyle(
                    color: Color(0xFF8B95A1),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '(키 발급 후 실제 지도 표시)',
                  style: TextStyle(color: Color(0xFFB0B8C1), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPin extends StatelessWidget {
  final String label;
  final String category;

  const _PreviewPin({required this.label, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        Icon(Icons.location_on_rounded, color: color, size: 32),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: AppColors.textStrong),
        ),
      ),
    );
  }
}

// ─── Drawer ───
class _PreviewDrawer extends StatelessWidget {
  const _PreviewDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bg,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      '홍',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '홍길동',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textStrong,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'name@smail.kongju.ac.kr',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSubtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: AppSpacing.sm),
            _DrawerItem(
              icon: Icons.list_rounded,
              label: '주변 모임',
              onTap: () {
                Navigator.pop(context);
                context.push('/list');
              },
            ),
            _DrawerItem(
              icon: Icons.person_rounded,
              label: '내 정보',
              onTap: () {
                Navigator.pop(context);
                context.push('/profile');
              },
            ),
            const Spacer(),
            const Divider(color: AppColors.borderSubtle, height: 1),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: '로그아웃',
              destructive: true,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textStrong;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: AppSpacing.lg),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List screen ───
class _PreviewListScreen extends StatelessWidget {
  const _PreviewListScreen();

  @override
  Widget build(BuildContext context) {
    final distances = [180.0, 540.0, 1200.0];
    return Scaffold(
      appBar: AppBar(title: const Text('주변 모임')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Text(
              '가까운 순서로 보여드려요',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSubtle,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              itemCount: _mockGroups.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => GroupCard(
                group: _mockGroups[i],
                distanceMeters: distances[i],
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile ───
class _PreviewProfile extends StatelessWidget {
  const _PreviewProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.borderSubtle,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primarySoft,
                      child: Text(
                        '홍',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '홍길동',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'name@smail.kongju.ac.kr',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SectionTitle(title: '내 모임'),
            ..._mockGroups.map(
              (g) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: GroupCard(group: g),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}
