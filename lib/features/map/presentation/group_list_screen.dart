import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/distance.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/core/widgets/group_card.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/providers/group_provider.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(activeGroupsProvider);
    final positionAsync = ref.watch(currentPositionProvider);

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
            child: groupsAsync.when(
                loading: () => const Center(child: AppLoader()),
                error: (e, _) => EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: '모임을 불러올 수 없어요',
                  description: e.toString(),
                ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return const EmptyState(
                      icon: Icons.event_note_rounded,
                      title: '아직 열린 모임이 없어요',
                      description: '첫 번째 모임을 만들어보세요!',
                    );
                  }

                  final myLat = positionAsync.value?.latitude;
                  final myLng = positionAsync.value?.longitude;
                  final sorted = _sortByDistance(groups, myLat, myLng);

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      ref.invalidate(activeGroupsProvider);
                      ref.invalidate(currentPositionProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.xxl,
                      ),
                      itemCount: sorted.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, i) {
                        final entry = sorted[i];
                        return GroupCard(
                          group: entry.group,
                          distanceMeters: entry.distance,
                          onTap: () => context.push('/group/${entry.group.id}'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }

  List<_GroupWithDistance> _sortByDistance(
    List<GroupModel> groups,
    double? myLat,
    double? myLng,
  ) {
    final entries = groups.map((g) {
      final d = (myLat != null && myLng != null)
          ? distanceMeters(
              fromLat: myLat,
              fromLng: myLng,
              toLat: g.latitude,
              toLng: g.longitude,
            )
          : null;
      return _GroupWithDistance(group: g, distance: d);
    }).toList();

    entries.sort((a, b) {
      if (a.distance == null && b.distance == null) return 0;
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });

    return entries;
  }
}

class _GroupWithDistance {
  final GroupModel group;
  final double? distance;

  _GroupWithDistance({required this.group, this.distance});
}
