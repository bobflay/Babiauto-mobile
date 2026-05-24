import '../models/driver.dart';
import '../models/payment_method.dart';
import '../models/place.dart';
import '../models/ride.dart';
import '../models/saved_place.dart';
import '../models/vehicle_class.dart';

/// Seed data ported from the prototype (`screens.jsx`). Used as a graceful
/// fallback so the full flow is demoable when no API host is reachable.
class DemoData {
  DemoData._();

  /// The rider's current location ("Cocody · Riviera Golf" in every screen).
  static const Place pickup = Place(
    name: 'Cocody · Riviera Golf',
    subtitle: 'Cocody',
    lat: 5.3560,
    lng: -3.9870,
    icon: 'pin',
  );

  static const List<VehicleClass> vehicleClasses = [
    VehicleClass(
      id: 1, slug: 'mini', name: 'Babi Mini', seats: 3, etaMinutes: 3, sortOrder: 1,
      descriptionFr: 'Économique', descriptionEn: 'Affordable',
      pricing: VehiclePricing(bookingFee: 200, perKm: 110, perMinute: 25, minFare: 1000),
    ),
    VehicleClass(
      id: 2, slug: 'confort', name: 'Babi Confort', seats: 4, etaMinutes: 4, sortOrder: 2,
      descriptionFr: 'Berline · clim', descriptionEn: 'Sedan · AC',
      pricing: VehiclePricing(bookingFee: 300, perKm: 150, perMinute: 35, minFare: 1500),
    ),
    VehicleClass(
      id: 3, slug: 'xl', name: 'Babi XL', seats: 6, etaMinutes: 6, sortOrder: 3,
      descriptionFr: 'Groupe · SUV', descriptionEn: 'Group · SUV',
      pricing: VehiclePricing(bookingFee: 500, perKm: 230, perMinute: 50, minFare: 2500),
    ),
    VehicleClass(
      id: 4, slug: 'moto', name: 'Babi Moto', seats: 1, etaMinutes: 2, sortOrder: 4,
      descriptionFr: 'Rapide', descriptionEn: 'Quickest',
      pricing: VehiclePricing(bookingFee: 150, perKm: 90, perMinute: 18, minFare: 700),
    ),
  ];

  /// Fixed demo fares per class (matching the prototype's price tags).
  static const Map<String, int> _demoPrice = {
    'mini': 1800,
    'confort': 2500,
    'xl': 3800,
    'moto': 1200,
  };

  static const List<Place> places = [
    Place(name: 'Aéroport Félix-Houphouët-Boigny', subtitle: 'Port-Bouët • 14.2 km', icon: 'plane', lat: 5.2614, lng: -3.9263, isAirport: true),
    Place(name: 'CHU de Cocody', subtitle: 'Cocody • Boulevard de France', icon: 'pin', lat: 5.3470, lng: -3.9870),
    Place(name: 'Marché de Treichville', subtitle: 'Treichville • Av. 21', icon: 'pin', lat: 5.2940, lng: -3.9930),
    Place(name: 'Palais de la Culture', subtitle: 'Treichville • Boulevard de Marseille', icon: 'pin', lat: 5.3000, lng: -3.9960),
    Place(name: 'Sofitel Hôtel Ivoire', subtitle: 'Cocody • Bd Hassan II', icon: 'star', lat: 5.3300, lng: -4.0080),
    Place(name: 'PlaYce Marcory', subtitle: 'Marcory • Bd Valéry Giscard d\'Estaing', icon: 'shop', lat: 5.2870, lng: -3.9820),
  ];

  static const List<SavedPlace> savedPlaces = [
    SavedPlace(id: 1, label: 'Maison', icon: 'home', name: 'Cocody · Riviera 3', subtitle: 'Cocody · Riviera 3', lat: 5.3590, lng: -3.9810),
    SavedPlace(id: 2, label: 'Bureau', icon: 'work', name: 'Plateau · Av. Chardy', subtitle: 'Plateau · Av. Chardy', lat: 5.3210, lng: -4.0190),
  ];

  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(id: 1, type: 'cash', label: 'Espèces', isDefault: false),
    PaymentMethod(id: 2, type: 'mobile', label: 'Mobile Money', provider: 'Orange', isDefault: true),
    PaymentMethod(id: 3, type: 'card', label: 'Carte', provider: 'Visa', last4: '4127', isDefault: false),
  ];

  /// A few past trips for the ride-history screen when offline.
  static final List<Ride> rideHistory = [
    Ride(
      id: 1042,
      status: RideStatus.completed,
      paymentType: 'mobile',
      pickup: const RidePoint(name: 'Cocody · Riviera Golf', lat: 5.356, lng: -3.987),
      dropoff: const RidePoint(name: 'Aéroport Félix-Houphouët-Boigny', lat: 5.2614, lng: -3.9263),
      distanceKm: 14.2,
      durationMinutes: 26,
      fare: const Fare(baseFare: 2100, airportFee: 400, tip: 200, total: 2700),
      vehicleClass: vehicleClasses[1],
      driver: driver,
    ),
    Ride(
      id: 1031,
      status: RideStatus.completed,
      paymentType: 'cash',
      pickup: const RidePoint(name: 'Plateau · Av. Chardy', lat: 5.321, lng: -4.019),
      dropoff: const RidePoint(name: 'PlaYce Marcory', lat: 5.287, lng: -3.982),
      distanceKm: 6.4,
      durationMinutes: 18,
      fare: const Fare(baseFare: 1800, total: 1800),
      vehicleClass: vehicleClasses[0],
      driver: driver,
    ),
    Ride(
      id: 1024,
      status: RideStatus.cancelled,
      paymentType: 'card',
      pickup: const RidePoint(name: 'Cocody · Riviera 3', lat: 5.359, lng: -3.981),
      dropoff: const RidePoint(name: 'Sofitel Hôtel Ivoire', lat: 5.330, lng: -4.008),
      distanceKm: 4.1,
      durationMinutes: 12,
      fare: const Fare(baseFare: 2500, total: 2500),
      vehicleClass: vehicleClasses[2],
    ),
  ];

  static const Driver driver = Driver(
    id: 1,
    name: 'Kouassi A.',
    avatarInitial: 'K',
    phone: '+225 07 ••• ••• 12',
    rating: 4.92,
    tripsCount: 1847,
    carMake: 'Suzuki Alto',
    carColorFr: 'gris',
    carColorEn: 'grey',
    plate: '2347 BG 01',
  );

  static int demoPrice(String slug) => _demoPrice[slug] ?? 2500;

  /// Build estimate-style quotes locally for a chosen destination.
  static List<FareQuote> quotes(Place dropoff) {
    final airport = dropoff.isAirport;
    final fee = airport ? 400 : 0;
    final distance = airport ? 14.2 : 6.4;
    return vehicleClasses.map((vc) {
      final total = demoPrice(vc.slug);
      return FareQuote(
        vehicleClassId: vc.id,
        slug: vc.slug,
        name: vc.name,
        seats: vc.seats,
        distanceKm: distance,
        durationMinutes: airport ? 26 : 14,
        baseFare: total - fee,
        airportFee: fee,
        totalFare: total,
        driverEtaMinutes: vc.etaMinutes,
      );
    }).toList();
  }
}
