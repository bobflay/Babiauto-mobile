import '../util/json.dart';
import 'vehicle_class.dart';

class Driver {
  final int id;
  final String name;
  final String avatarInitial;
  final String? phone;
  final double rating;
  final int tripsCount;
  final String carMake;
  final String carColorFr;
  final String carColorEn;
  final String plate;
  final VehicleClass? vehicleClass;

  const Driver({
    required this.id,
    required this.name,
    this.avatarInitial = '',
    this.phone,
    this.rating = 0,
    this.tripsCount = 0,
    this.carMake = '',
    this.carColorFr = '',
    this.carColorEn = '',
    this.plate = '',
    this.vehicleClass,
  });

  String carColor(bool isFr) => isFr ? carColorFr : carColorEn;

  factory Driver.fromJson(Map<String, dynamic> j) {
    final vehicle = asMap(j['vehicle']);
    final color = asMap(vehicle['color']);
    final classJson = vehicle['class'];
    return Driver(
      id: asInt(j['id']),
      name: asString(j['name']),
      avatarInitial: asString(j['avatar_initial']),
      phone: asStringOrNull(j['phone']),
      rating: asDouble(j['rating']),
      tripsCount: asInt(j['trips_count']),
      carMake: asString(vehicle['make']),
      carColorFr: asString(color['fr']),
      carColorEn: asString(color['en']),
      plate: asString(vehicle['plate']),
      vehicleClass: classJson is Map
          ? VehicleClass.fromJson(Map<String, dynamic>.from(classJson))
          : null,
    );
  }
}
