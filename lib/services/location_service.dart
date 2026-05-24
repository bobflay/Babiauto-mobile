import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Wraps device geolocation with permission handling. Returns `null` (rather
/// than throwing) whenever location is unavailable or denied, so callers can
/// fall back to a default position.
class LocationService {
  Future<LatLng?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
