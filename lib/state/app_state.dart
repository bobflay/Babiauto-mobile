import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_config.dart';
import '../api/api_exception.dart';
import '../api/babiauto_api.dart';
import '../data/demo_data.dart';
import '../i18n/strings.dart';
import '../models/place.dart';
import '../models/ride.dart';
import '../models/user.dart';
import '../models/vehicle_class.dart';
import '../services/geo_service.dart';
import '../services/location_service.dart';

/// The 8-step demo flow, mirroring the prototype's state machine.
enum FlowStep { splash, home, search, vehicles, finding, arriving, ontrip, complete }

class AppState extends ChangeNotifier {
  AppState({BabiautoApi? api, LocationService? location, GeoService? geo})
      : _api = api ?? BabiautoApi(),
        _location = location ?? LocationService(),
        _geo = geo ?? GeoService();

  final BabiautoApi _api;
  final LocationService _location;
  final GeoService _geo;
  static const _tokenKey = 'babiauto_token';

  // ── Locale & theme ──────────────────────────────────────────────────────────
  Lang _lang = Lang.fr;
  bool _darkMap = false;
  Lang get lang => _lang;
  bool get darkMap => _darkMap;
  Strings get t => Strings(_lang);

  void setLang(Lang l) {
    if (_lang == l) return;
    _lang = l;
    notifyListeners();
  }

  void toggleDarkMap() {
    _darkMap = !_darkMap;
    notifyListeners();
  }

  // ── Connectivity / session ────────────────────────────────────────────────
  bool _online = false;
  User? _user;
  bool get online => _online;
  User? get user => _user;
  String get riderName => _user?.firstName ?? 'Koffi';

  // ── Catalogue ─────────────────────────────────────────────────────────────
  List<VehicleClass> _vehicleClasses = DemoData.vehicleClasses;
  List<VehicleClass> get vehicleClasses => _vehicleClasses;

  // ── Flow / selections ───────────────────────────────────────────────────────
  FlowStep _step = FlowStep.splash;
  FlowStep get step => _step;

  Place _pickup = DemoData.pickup;
  Place get pickup => _pickup;
  Place? _destination;
  Place? get destination => _destination;

  LatLng? _currentLatLng;
  LatLng? get currentLatLng => _currentLatLng;
  bool _locating = false;
  bool get locating => _locating;
  LatLng get pickupLatLng => LatLng(_pickup.lat, _pickup.lng);
  LatLng? get destinationLatLng =>
      _destination == null ? null : LatLng(_destination!.lat, _destination!.lng);

  List<LatLng> _route = [];
  List<LatLng> get routePoints => _route;

  String _vehicleSlug = 'confort';
  String _paymentType = 'mobile';
  String get vehicleSlug => _vehicleSlug;
  String get paymentType => _paymentType;

  List<FareQuote> _quotes = [];
  List<FareQuote> get quotes => _quotes;

  Ride? _ride;
  Ride? get ride => _ride;

  void go(FlowStep step) {
    _step = step;
    notifyListeners();
  }

  void setVehicle(String slug) {
    _vehicleSlug = slug;
    notifyListeners();
  }

  void setPayment(String type) {
    _paymentType = type;
    notifyListeners();
  }

  void setDestination(Place place) {
    _destination = place;
    notifyListeners();
  }

  /// Pick a destination, jump to the vehicle picker, and (re)load fare quotes
  /// plus the driving route from the rider's real position.
  void chooseDestination(Place place) {
    _destination = place;
    _quotes = [];
    _route = [];
    go(FlowStep.vehicles);
    loadQuotes();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final dest = _destination;
    if (dest == null) return;
    _route = await _geo.route(pickupLatLng, LatLng(dest.lat, dest.lng));
    notifyListeners();
  }

  /// Per-class price for the vehicle picker (quote total, else demo price).
  int priceFor(String slug) {
    for (final q in _quotes) {
      if (q.slug == slug) return q.totalFare;
    }
    return DemoData.demoPrice(slug);
  }

  /// Per-class driver ETA (quote value, else the class default).
  int etaFor(String slug) {
    for (final q in _quotes) {
      if (q.slug == slug) return q.driverEtaMinutes;
    }
    return _vehicleClasses
        .firstWhere((v) => v.slug == slug, orElse: () => DemoData.vehicleClasses.first)
        .etaMinutes;
  }

  /// Currently selected quote (or a synthesized demo quote).
  FareQuote? get selectedQuote {
    for (final q in _quotes) {
      if (q.slug == _vehicleSlug) return q;
    }
    return null;
  }

  /// Price of the selected ride, falling back to the prototype's demo prices.
  int get selectedPrice => selectedQuote?.totalFare ?? DemoData.demoPrice(_vehicleSlug);

  VehicleClass get selectedVehicleClass => _vehicleClasses.firstWhere(
        (v) => v.slug == _vehicleSlug,
        orElse: () => DemoData.vehicleClasses.firstWhere((v) => v.slug == _vehicleSlug,
            orElse: () => DemoData.vehicleClasses[1]),
      );

  // ── Bootstrap ─────────────────────────────────────────────────────────────
  /// Best-effort: restore session, load catalogue, attempt silent demo login.
  /// Never throws; on failure the app runs against bundled demo data.
  Future<void> bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_tokenKey);
      if (saved != null) {
        _api.token = saved;
        try {
          _user = await _api.me();
          _online = true;
        } catch (_) {
          _api.token = null;
          await prefs.remove(_tokenKey);
        }
      }

      if (!_online) {
        try {
          final res = await _api.login(ApiConfig.demoEmail, ApiConfig.demoPassword);
          _user = res.user;
          _online = true;
          await prefs.setString(_tokenKey, res.token);
        } catch (_) {/* stay offline */}
      }

      try {
        final classes = await _api.vehicleClasses();
        if (classes.isNotEmpty) _vehicleClasses = classes;
      } catch (_) {/* keep demo classes */}

      if (_user != null) {
        _lang = _user!.language == 'en' ? Lang.en : Lang.fr;
      }
    } catch (_) {/* fully offline */}
    notifyListeners();

    // Ask for the rider's real position (browser/OS prompt). Best-effort.
    await detectLocation();
  }

  // ── Place search ────────────────────────────────────────────────────────────
  Future<List<Place>> searchPlaces(String query) async {
    try {
      final results = await _api.places(query: query.isEmpty ? null : query);
      if (results.isNotEmpty || _online) return results;
    } catch (_) {/* fall through to demo */}
    final q = query.toLowerCase();
    return DemoData.places
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .toList();
  }

  // ── Quotes ────────────────────────────────────────────────────────────────
  Future<void> loadQuotes() async {
    final dest = _destination;
    if (dest == null) {
      _quotes = [];
      return;
    }
    try {
      final remote = await _api.estimate(pickup: pickup, dropoff: dest, isAirport: dest.isAirport);
      _quotes = remote.isNotEmpty ? remote : DemoData.quotes(dest);
    } catch (_) {
      _quotes = DemoData.quotes(dest);
    }
    notifyListeners();
  }

  // ── Ride lifecycle ──────────────────────────────────────────────────────────
  Future<void> confirmRide() async {
    final dest = _destination;
    if (dest != null && _online) {
      try {
        _ride = await _api.requestRide(
          vehicleClassSlug: _vehicleSlug,
          paymentType: _paymentType,
          pickup: pickup,
          dropoff: dest,
          isAirport: dest.isAirport,
        );
      } on ApiException {
        _ride = null;
      }
    }
    go(FlowStep.finding);
  }

  /// Advance a real ride server-side when one exists; ignored when offline.
  Future<void> driverArriving() => _lifecycle((id) => _api.driverArriving(id));
  Future<void> driverArrived() => _lifecycle((id) => _api.driverArrived(id));
  Future<void> startTrip() => _lifecycle((id) => _api.startTrip(id));
  Future<void> completeTrip() => _lifecycle((id) => _api.completeTrip(id));

  Future<void> _lifecycle(Future<Ride> Function(int id) call) async {
    final r = _ride;
    if (r == null || !_online) return;
    try {
      _ride = await call(r.id);
      notifyListeners();
    } catch (_) {/* best-effort */}
  }

  Future<void> submitRating(int stars, int tip) async {
    final r = _ride;
    if (r != null && _online) {
      try {
        await _api.rateRide(r.id, stars: stars, tip: tip);
      } catch (_) {/* best-effort */}
    }
    resetFlow();
    go(FlowStep.home);
  }

  void resetFlow() {
    _destination = null;
    _quotes = [];
    _route = [];
    _ride = null;
  }

  // ── Geolocation ─────────────────────────────────────────────────────────────
  /// Detect the rider's real position and use it as the pickup, with a
  /// best-effort reverse-geocoded label. No-op when location is unavailable.
  Future<void> detectLocation() async {
    _locating = true;
    notifyListeners();
    try {
      final pos = await _location.current();
      if (pos == null) return;
      _currentLatLng = pos;

      var label = _lang == Lang.fr ? 'Position actuelle' : 'Current location';
      final reversed = await _geo.reverseLabel(pos, language: _lang.name);
      if (reversed != null && reversed.isNotEmpty) label = reversed;

      _pickup = Place(name: label, subtitle: label, lat: pos.latitude, lng: pos.longitude);
    } finally {
      _locating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _api.close();
    _geo.close();
    super.dispose();
  }
}
