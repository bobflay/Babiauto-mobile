import 'package:latlong2/latlong.dart';

import '../util/json.dart';

/// A live nearby car position from `GET /drivers/nearby` (positions only —
/// no driver identity, safe to show before a ride is requested).
class NearbyDriver {
  final int id;
  final String vehicleClass;
  final double lat;
  final double lng;
  final double heading; // compass bearing, 0=N, 90=E, 180=S, 270=W
  final double distanceKm;
  final int etaMinutes;
  final bool simulated;

  const NearbyDriver({
    required this.id,
    required this.vehicleClass,
    required this.lat,
    required this.lng,
    this.heading = 0,
    this.distanceKm = 0,
    this.etaMinutes = 0,
    this.simulated = false,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory NearbyDriver.fromJson(Map<String, dynamic> j) => NearbyDriver(
        id: asInt(j['id']),
        vehicleClass: asString(j['vehicle_class']),
        lat: asDouble(j['lat']),
        lng: asDouble(j['lng']),
        heading: asDouble(j['heading']),
        distanceKm: asDouble(j['distance_km']),
        etaMinutes: asInt(j['eta_minutes']),
        simulated: asBool(j['simulated']),
      );
}

class NearbyDriversResult {
  final List<NearbyDriver> drivers;
  final bool simulated;
  const NearbyDriversResult(this.drivers, {this.simulated = false});

  static const empty = NearbyDriversResult([]);
}
