import '../util/json.dart';

class SavedPlace {
  final int? id;
  final String label;
  final String icon;
  final String name;
  final String? subtitle;
  final double lat;
  final double lng;

  const SavedPlace({
    this.id,
    required this.label,
    this.icon = 'pin',
    required this.name,
    this.subtitle,
    this.lat = 0,
    this.lng = 0,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> j) => SavedPlace(
        id: asIntOrNull(j['id']),
        label: asString(j['label']),
        icon: asString(j['icon'], 'pin'),
        name: asString(j['name']),
        subtitle: asStringOrNull(j['subtitle']),
        lat: asDouble(j['lat']),
        lng: asDouble(j['lng']),
      );
}
