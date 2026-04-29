import 'package:flutter/material.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/core/widgets/group_card.dart';
import 'package:pinple/features/map/domain/group_model.dart';

void main() {
  runApp(const PinplePreview());
}

class PinplePreview extends StatelessWidget {
  const PinplePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinple Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _PreviewHome(),
    );
  }
}

GroupModel _mockGroup({
  required String id,
  required String title,
  required String category,
  required String location,
  int members = 3,
  int max = 6,
  String description = '함께 모여서 즐겁게 활동해요!',
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
    latitude: 36.85,
    longitude: 127.1515,
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
  ),
  _mockGroup(
    id: '2',
    title: '풋살 같이해요',
    category: '운동',
    location: '대운동장',
    members: 7,
    max: 10,
  ),
  _mockGroup(
    id: '3',
    title: '점심 밥약',
    category: '밥약',
    location: '학생식당 앞',
    members: 2,
    max: 4,
  ),
];

class _PreviewHome extends StatelessWidget {
  const _PreviewHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const PageHeader(
              title: 'Pinple Preview',
              subtitle: '디자인 미리보기 (Firebase/네이버맵 없이)',
            ),
            _navTile(context, '리스트 (거리순)', const _PreviewListScreen()),
            _navTile(context, '모임 상세', const _PreviewGroupDetail()),
            _navTile(context, '모임 상세 바텀시트', const _PreviewBottomSheetDemo()),
            _navTile(context, '마이', const _PreviewProfile()),
            _navTile(context, '위치 차단', const _PreviewLocationBlocked()),
            _navTile(context, '이메일 인증', const _PreviewEmailVerify()),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _navTile(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSubtle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewListScreen extends StatelessWidget {
  const _PreviewListScreen();

  @override
  Widget build(BuildContext context) {
    final distances = [180.0, 540.0, 1200.0];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: '주변 모임',
              subtitle: '가까운 순서로 보여드려요',
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewBottomSheetDemo extends StatelessWidget {
  const _PreviewBottomSheetDemo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: GroupCard(group: _mockGroups[0], distanceMeters: 180),
            ),
          ),
          child: const Text('바텀시트 열기'),
        ),
      ),
    );
  }
}

class _PreviewGroupDetail extends StatelessWidget {
  const _PreviewGroupDetail();

  @override
  Widget build(BuildContext context) {
    final group = _mockGroups[0];
    return Scaffold(
      appBar: AppBar(title: const Text('모임')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: GroupCard(group: group, distanceMeters: 180),
      ),
    );
  }
}

class _PreviewProfile extends StatelessWidget {
  const _PreviewProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: '마이'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                ),
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
              ...List.generate(_mockGroups.length, (i) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: GroupCard(group: _mockGroups[i]),
                );
              }),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewLocationBlocked extends StatelessWidget {
  const _PreviewLocationBlocked();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.location_off_rounded,
          title: '캠퍼스 근처에서만 사용할 수 있어요',
          description: '공주대학교 천안캠퍼스 반경 2km 이내에서 이용해주세요',
          action: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 확인'),
          ),
        ),
      ),
    );
  }
}

class _PreviewEmailVerify extends StatelessWidget {
  const _PreviewEmailVerify();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: IconBadge(
                icon: Icons.mark_email_unread_rounded,
                color: AppColors.primary,
                size: 72,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              '이메일을 확인해주세요',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '학교 이메일로 인증 메일을 보냈습니다.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSubtle,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('인증 완료 확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
