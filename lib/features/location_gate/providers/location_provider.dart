import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pinple/features/location_gate/data/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final currentPositionProvider = FutureProvider<Position>((ref) {
  return ref.watch(locationRepositoryProvider).getCurrentPosition();
});

final locationCheckProvider = FutureProvider<bool>((ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  return ref.read(locationRepositoryProvider).isWithinCampusFor(position);
});
