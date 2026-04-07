import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinple/features/location_gate/data/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final locationCheckProvider = FutureProvider<bool>((ref) {
  return ref.watch(locationRepositoryProvider).isWithinCampus();
});
