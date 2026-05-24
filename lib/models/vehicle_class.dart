import '../util/json.dart';

class VehiclePricing {
  final int bookingFee;
  final int perKm;
  final int perMinute;
  final int minFare;
  final String currency;

  const VehiclePricing({
    this.bookingFee = 0,
    this.perKm = 0,
    this.perMinute = 0,
    this.minFare = 0,
    this.currency = 'XOF',
  });

  factory VehiclePricing.fromJson(Map<String, dynamic> j) => VehiclePricing(
        bookingFee: asInt(j['booking_fee']),
        perKm: asInt(j['per_km']),
        perMinute: asInt(j['per_minute']),
        minFare: asInt(j['min_fare']),
        currency: asString(j['currency'], 'XOF'),
      );
}

class VehicleClass {
  final int id;
  final String slug;
  final String name;
  final String descriptionFr;
  final String descriptionEn;
  final int seats;
  final int etaMinutes;
  final VehiclePricing pricing;
  final int sortOrder;

  const VehicleClass({
    required this.id,
    required this.slug,
    required this.name,
    this.descriptionFr = '',
    this.descriptionEn = '',
    this.seats = 0,
    this.etaMinutes = 0,
    this.pricing = const VehiclePricing(),
    this.sortOrder = 0,
  });

  String description(bool isFr) => isFr ? descriptionFr : descriptionEn;

  factory VehicleClass.fromJson(Map<String, dynamic> j) {
    final desc = asMap(j['description']);
    return VehicleClass(
      id: asInt(j['id']),
      slug: asString(j['slug']),
      name: asString(j['name']),
      descriptionFr: asString(desc['fr']),
      descriptionEn: asString(desc['en']),
      seats: asInt(j['seats']),
      etaMinutes: asInt(j['eta_minutes']),
      pricing: VehiclePricing.fromJson(asMap(j['pricing'])),
      sortOrder: asInt(j['sort_order']),
    );
  }
}
