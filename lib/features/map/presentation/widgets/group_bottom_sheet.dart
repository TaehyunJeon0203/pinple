import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  group.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${group.memberIds.length}/${group.maxMembers}명',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            group.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                group.locationName,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            group.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
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
