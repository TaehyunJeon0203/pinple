import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('오류: $e')),
      ),
      data: (group) {
        if (group == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('모임을 찾을 수 없습니다')),
          );
        }

        final isOwner = currentUid == group.ownerId;
        final isMember = group.memberIds.contains(currentUid);

        return Scaffold(
          appBar: AppBar(
            title: const Text('모임 상세'),
            actions: isOwner
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          context.push('/group/${group.id}/edit'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, ref, group),
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & member count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(group.category),
                    ),
                    const Spacer(),
                    Icon(Icons.people, size: 20, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberIds.length}/${group.maxMembers}명',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  group.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(group.locationName,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text('만든 사람: ${group.ownerNickname}',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  group.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Join requests (owner only)
                if (isOwner) _buildJoinRequests(ref),

                // Action button
                if (!isOwner && !isMember && !group.isFull)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showJoinDialog(context, ref, group),
                      child: const Text('참여 신청'),
                    ),
                  ),
                if (isMember && !isOwner)
                  const Center(
                    child: Chip(
                      label: Text('참여 중'),
                      avatar: Icon(Icons.check_circle, size: 18),
                    ),
                  ),
                if (group.isFull && !isMember)
                  const Center(
                    child: Text(
                      '인원이 가득 찼습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJoinRequests(WidgetRef ref) {
    final requestsAsync = ref.watch(joinRequestsProvider(groupId));

    return requestsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (requests) {
        if (requests.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '참여 신청 (${requests.length})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...requests.map((req) => Card(
                  child: ListTile(
                    title: Text(req.requesterNickname),
                    subtitle:
                        req.message.isNotEmpty ? Text(req.message) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            ref
                                .read(groupRepositoryProvider)
                                .acceptJoinRequest(
                                    req.id, groupId, req.requesterId);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(groupRepositoryProvider)
                                .rejectJoinRequest(req.id);
                          },
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
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
              final request = JoinRequestModel(
                id: '',
                groupId: group.id,
                requesterId: currentUser!.uid,
                requesterNickname:
                    currentUser.displayName ?? currentUser.email ?? '',
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
