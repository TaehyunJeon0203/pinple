import 'package:flutter/material.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/map/domain/group_model.dart';

class GroupBottomSheet extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onDetailTap;

  const GroupBottomSheet({
    super.key,
    required this.group,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = categoryColor(group.category);
    final icon = categoryIcon(group.category);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(icon: icon, color: color, size: 48),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CategoryChip(label: group.category, color: color),
                        const Spacer(),
                        Icon(
                          Icons.people_rounded,
                          size: 14,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${group.memberIds.length}/${group.maxMembers}명',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: AppColors.textSubtle),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      group.title,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 14,
                color: AppColors.textSubtle,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  group.locationName,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSubtle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            group.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDetailTap,
              child: const Text('자세히 보기'),
            ),
          ),
        ],
      ),
    );
  }
}
