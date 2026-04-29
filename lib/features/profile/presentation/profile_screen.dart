import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/core/widgets/group_card.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final userDataAsync = ref.watch(userDataProvider(user.uid));
    final myGroupsAsync = ref.watch(myGroupsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('내 정보')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

              // User card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: userDataAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                      child: AppLoader(),
                    ),
                  ),
                  error: (e, _) => Text(
                    '정보를 불러올 수 없습니다',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSubtle,
                        ),
                  ),
                  data: (data) {
                    final displayName = data?['displayName'] as String? ?? '';
                    final email = data?['email'] as String? ?? '';
                    final initial =
                        displayName.isNotEmpty ? displayName[0] : '?';
                    return Container(
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
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primarySoft,
                            child: Text(
                              initial,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  email,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              const SectionTitle(title: '내 모임'),

              // My groups list
              myGroupsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                  child: Center(child: AppLoader()),
                ),
                error: (e, _) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Text(
                    '모임을 불러올 수 없습니다',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSubtle,
                        ),
                  ),
                ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return const EmptyState(
                      icon: Icons.event_note_rounded,
                      title: '참여 중인 모임이 없어요',
                      description: '주변 모임 탭에서 마음에 드는 모임에 참여해보세요',
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: groups.length,
                      separatorBuilder: (_, idx) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, i) {
                        final g = groups[i];
                        return GroupCard(
                          group: g,
                          onTap: () => context.push('/group/${g.id}'),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Logout button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('로그아웃'),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
