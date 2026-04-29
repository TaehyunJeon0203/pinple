import 'package:flutter/material.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/core/utils/distance.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/map/domain/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final double? distanceMeters;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
    this.distanceMeters,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = categoryColor(group.category);
    final icon = categoryIcon(group.category);

    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Row(
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
                        if (distanceMeters != null)
                          Text(
                            formatDistance(distanceMeters!),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textSubtle,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      group.title,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            group.locationName,
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.people_rounded,
                          size: 14,
                          color: AppColors.textSubtle,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${group.memberIds.length}/${group.maxMembers}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
