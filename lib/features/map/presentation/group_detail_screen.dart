import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/auth/providers/auth_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return groupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: AppLoader()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('모임')),
        body: Center(child: Text('오류: $e')),
      ),
      data: (group) {
        if (group == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('모임')),
            body: const Center(child: Text('모임을 찾을 수 없습니다')),
          );
        }

        final isOwner = currentUid == group.ownerId;
        final isMember = group.memberIds.contains(currentUid);
        final color = categoryColor(group.category);
        final icon = categoryIcon(group.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('모임'),
            actions: isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () =>
                          context.push('/group/${group.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _confirmDelete(context, ref, group),
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero section
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(icon: icon, color: color, size: 56),
                          const Spacer(),
                          Icon(
                            Icons.people_rounded,
                            size: 16,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${group.memberIds.length}/${group.maxMembers}명',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        group.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '만든 사람: ${group.ownerNickname}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.textSubtle,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            group.locationName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSubtle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.borderSubtle),

                // Description block
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionTitle(
                        title: '소개',
                        padding: const EdgeInsets.only(
                          top: AppSpacing.lg,
                          bottom: AppSpacing.md,
                        ),
                      ),
                      Text(
                        group.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),

                // Join requests (owner only)
                if (isOwner)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
                    child: _buildJoinRequests(context, ref),
                  ),

                // Bottom action area
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxxl,
                  ),
                  child: _buildActionButton(
                      context, ref, group, isOwner, isMember),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref,
      GroupModel group, bool isOwner, bool isMember) {
    if (isOwner) return const SizedBox.shrink();

    if (!isMember && !group.isFull) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showJoinDialog(context, ref, group),
          child: const Text('참여 신청'),
        ),
      );
    }

    if (isMember) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '참여 중',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.success),
          ),
        ],
      );
    }

    if (group.isFull) {
      return Center(
        child: Text(
          '인원이 가득 찼습니다',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSubtle),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildJoinRequests(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(joinRequestsProvider(groupId));

    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: '참여 신청 (${requests.length})',
              padding: const EdgeInsets.only(
                bottom: AppSpacing.md,
              ),
            ),
            ...requests.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border:
                          Border.all(color: AppColors.borderSubtle, width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.requesterNickname,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              if (req.message.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  req.message,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppColors.textSubtle),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _AcceptButton(
                              onPressed: () {
                                ref
                                    .read(groupRepositoryProvider)
                                    .acceptJoinRequest(
                                        req.id, groupId, req.requesterId);
                              },
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _RejectButton(
                              onPressed: () {
                                ref
                                    .read(groupRepositoryProvider)
                                    .rejectJoinRequest(req.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      },
    );
  }

  void _showJoinDialog(
      BuildContext context, WidgetRef ref, GroupModel group) {
    final messageController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('참여 신청'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: '한마디 남기기 (선택)',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userData = await ref
                  .read(authRepositoryProvider)
                  .getUserData(currentUser!.uid);
              final nickname = (userData?['displayName'] as String?) ??
                  currentUser.email ??
                  '';
              final request = JoinRequestModel(
                id: '',
                groupId: group.id,
                requesterId: currentUser.uid,
                requesterNickname: nickname,
                message: messageController.text.trim(),
                status: 'pending',
                createdAt: DateTime.now(),
              );
              await ref
                  .read(groupRepositoryProvider)
                  .sendJoinRequest(request);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('참여 신청을 보냈습니다')),
                );
              }
            },
            child: const Text('신청'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, GroupModel group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('모임 삭제'),
        content: const Text('정말 이 모임을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () async {
              await ref
                  .read(groupRepositoryProvider)
                  .deleteGroup(group.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AcceptButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const Icon(
            Icons.check_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RejectButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.textSubtle,
          ),
        ),
      ),
    );
  }
}
