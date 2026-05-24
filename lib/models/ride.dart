import '../util/json.dart';
import 'driver.dart';
import 'vehicle_class.dart';

enum RideStatus {
  searching,
  accepted,
  arriving,
  arrived,
  inProgress,
  completed,
  cancelled,
  unknown;

  static RideStatus fromApi(String? v) {
    switch (v) {
      case 'searching':
        return RideStatus.searching;
      case 'accepted':
        return RideStatus.accepted;
      case 'arriving':
        return RideStatus.arriving;
      case 'arrived':
        return RideStatus.arrived;
      case 'in_progress':
        return RideStatus.inProgress;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.unknown;
    }
  }

  bool get isActive => const {
        RideStatus.searching,
        RideStatus.accepted,
        RideStatus.arriving,
        RideStatus.arrived,
        RideStatus.inProgress,
      }.contains(this);
}

class RidePoint {
  final String name;
  final double lat;
  final double lng;
  const RidePoint({this.name = '', this.lat = 0, this.lng = 0});

  factory RidePoint.fromJson(Map<String, dynamic> j) => RidePoint(
        name: asString(j['name']),
        lat: asDouble(j['lat']),
        lng: asDouble(j['lng']),
      );
}

class Fare {
  final int baseFare;
  final int airportFee;
  final int tip;
  final int total;
  final String currency;
  const Fare({
    this.baseFare = 0,
    this.airportFee = 0,
    this.tip = 0,
    this.total = 0,
    this.currency = 'XOF',
  });

  factory Fare.fromJson(Map<String, dynamic> j) => Fare(
        baseFare: asInt(j['base_fare']),
        airportFee: asInt(j['airport_fee']),
        tip: asInt(j['tip']),
        total: asInt(j['total']),
        currency: asString(j['currency'], 'XOF'),
      );
}

class Ride {
  final int id;
  final RideStatus status;
  final String paymentType;
  final RidePoint pickup;
  final RidePoint dropoff;
  final double distanceKm;
  final int durationMinutes;
  final Fare fare;
  final VehicleClass? vehicleClass;
  final Driver? driver;
  final Map<String, dynamic>? tracking;
  final String? cancelReason;

  const Ride({
    required this.id,
    required this.status,
    this.paymentType = 'cash',
    this.pickup = const RidePoint(),
    this.dropoff = const RidePoint(),
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.fare = const Fare(),
    this.vehicleClass,
    this.driver,
    this.tracking,
    this.cancelReason,
  });

  factory Ride.fromJson(Map<String, dynamic> j) {
    final vc = j['vehicle_class'];
    final dr = j['driver'];
    return Ride(
      id: asInt(j['id']),
      status: RideStatus.fromApi(asStringOrNull(j['status'])),
      paymentType: asString(j['payment_type'], 'cash'),
      pickup: RidePoint.fromJson(asMap(j['pickup'])),
      dropoff: RidePoint.fromJson(asMap(j['dropoff'])),
      distanceKm: asDouble(j['distance_km']),
      durationMinutes: asInt(j['duration_minutes']),
      fare: Fare.fromJson(asMap(j['fare'])),
      vehicleClass: vc is Map ? VehicleClass.fromJson(Map<String, dynamic>.from(vc)) : null,
      driver: dr is Map ? Driver.fromJson(Map<String, dynamic>.from(dr)) : null,
      tracking: j['tracking'] is Map ? Map<String, dynamic>.from(j['tracking']) : null,
      cancelReason: asStringOrNull(j['cancel_reason']),
    );
  }
}

/// One row of `POST /rides/estimate` — a quote per vehicle class.
class FareQuote {
  final int vehicleClassId;
  final String slug;
  final String name;
  final int seats;
  final double distanceKm;
  final int durationMinutes;
  final int baseFare;
  final int airportFee;
  final int totalFare;
  final int driverEtaMinutes;
  final String currency;

  const FareQuote({
    required this.slug,
    required this.name,
    this.vehicleClassId = 0,
    this.seats = 0,
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.baseFare = 0,
    this.airportFee = 0,
    this.totalFare = 0,
    this.driverEtaMinutes = 0,
    this.currency = 'XOF',
  });

  factory FareQuote.fromJson(Map<String, dynamic> j) {
    final vc = asMap(j['vehicle_class']);
    return FareQuote(
      vehicleClassId: asInt(vc['id']),
      slug: asString(vc['slug']),
      name: asString(vc['name']),
      seats: asInt(vc['seats']),
      distanceKm: asDouble(j['distance_km']),
      durationMinutes: asInt(j['duration_minutes']),
      baseFare: asInt(j['base_fare']),
      airportFee: asInt(j['airport_fee']),
      totalFare: asInt(j['total_fare']),
      driverEtaMinutes: asInt(j['driver_eta_minutes']),
      currency: asString(j['currency'], 'XOF'),
    );
  }
}
