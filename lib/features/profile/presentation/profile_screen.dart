import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(title: const Text('마이페이지')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: userDataAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('정보를 불러올 수 없습니다'),
                  data: (data) => Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        child: Text(
                          (data?['displayName'] ?? '?')[0],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data?['displayName'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data?['email'] ?? '',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // My groups
            const Text(
              '내 모임',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            myGroupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('모임을 불러올 수 없습니다'),
              data: (groups) {
                if (groups.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        '참여 중인 모임이 없습니다',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groups.length,
                  itemBuilder: (_, i) {
                    final group = groups[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(group.category[0]),
                        ),
                        title: Text(group.title),
                        subtitle: Text(
                          '${group.memberIds.length}/${group.maxMembers}명 · ${group.locationName}',
                        ),
                        onTap: () => context.push('/group/${group.id}'),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('로그아웃'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
