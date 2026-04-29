import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/widgets/app_widgets.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';

class LocationBlockedScreen extends ConsumerWidget {
  const LocationBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: EmptyState(
          icon: Icons.location_off_rounded,
          title: '캠퍼스 근처에서만 사용할 수 있어요',
          description:
              '${CampusConstants.name} 반경 ${(CampusConstants.radiusMeters / 1000).toStringAsFixed(0)}km 이내에서 이용해주세요',
          action: ElevatedButton.icon(
            onPressed: () => ref.invalidate(currentPositionProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('다시 확인'),
          ),
        ),
      ),
    );
  }
}
