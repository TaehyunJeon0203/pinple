import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';

class LocationBlockedScreen extends ConsumerWidget {
  const LocationBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                '캠퍼스 근처에서만\n사용할 수 있습니다',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '${CampusConstants.name} 반경 ${(CampusConstants.radiusMeters / 1000).toStringAsFixed(0)}km 이내에서 이용해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(locationCheckProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('다시 확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
