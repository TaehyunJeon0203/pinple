import 'package:geolocator/geolocator.dart';
import 'package:pinple/core/constants/campus_constants.dart';

class LocationRepository {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스를 활성화해주세요');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 필요합니다');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('설정에서 위치 권한을 허용해주세요');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  bool isWithinCampusFor(Position position) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      CampusConstants.latitude,
      CampusConstants.longitude,
    );
    return distance <= CampusConstants.radiusMeters;
  }

  Future<bool> isWithinCampus() async {
    final position = await getCurrentPosition();
    return isWithinCampusFor(position);
  }
}
