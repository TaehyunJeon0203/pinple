import 'package:geolocator/geolocator.dart';

double distanceMeters({
  required double fromLat,
  required double fromLng,
  required double toLat,
  required double toLng,
}) {
  return Geolocator.distanceBetween(fromLat, fromLng, toLat, toLng);
}

String formatDistance(double meters) {
  if (meters < 0) return '';
  if (meters < 1000) return '${meters.round()}m';
  final km = meters / 1000;
  if (km < 10) return '${km.toStringAsFixed(1)}km';
  return '${km.round()}km';
}
