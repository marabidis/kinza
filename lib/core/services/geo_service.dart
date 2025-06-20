import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoService {
  Future<Position?> currentPosition() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      final req = await Geolocator.requestPermission();
      if (req == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Placemark?> reverse(double lat, double lng) async {
    final list = await placemarkFromCoordinates(lat, lng);
    return list.isNotEmpty ? list.first : null;
  }

  Future<List<Location>> forward(String query) => locationFromAddress(query);
}
