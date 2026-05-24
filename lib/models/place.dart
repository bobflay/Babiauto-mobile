import '../util/json.dart';

class Place {
  final int? id;
  final String name;
  final String subtitle;
  final String icon;
  final String? neighborhood;
  final double lat;
  final double lng;
  final bool isAirport;

  const Place({
    this.id,
    required this.name,
    this.subtitle = '',
    this.icon = 'pin',
    this.neighborhood,
    this.lat = 0,
    this.lng = 0,
    this.isAirport = false,
  });

  factory Place.fromJson(Map<String, dynamic> j) => Place(
        id: asIntOrNull(j['id']),
        name: asString(j['name']),
        subtitle: asString(j['subtitle']),
        icon: asString(j['icon'], 'pin'),
        neighborhood: asStringOrNull(j['neighborhood']),
        lat: asDouble(j['lat']),
        lng: asDouble(j['lng']),
        isAirport: asBool(j['is_airport']),
      );

  Map<String, dynamic> toPointJson() => {'name': name, 'lat': lat, 'lng': lng};
}
