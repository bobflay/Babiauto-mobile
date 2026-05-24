import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/nearby_driver.dart';
import '../models/payment_method.dart';
import '../models/place.dart';
import '../models/ride.dart';
import '../models/saved_place.dart';
import '../models/user.dart';
import '../models/vehicle_class.dart';
import '../util/json.dart';
import 'api_config.dart';
import 'api_exception.dart';

class AuthResult {
  final User user;
  final String token;
  const AuthResult(this.user, this.token);
}

/// Thin typed client over the Babiauto REST API (Laravel + Sanctum).
class BabiautoApi {
  BabiautoApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _client;
  final String _baseUrl;
  String? token;

  Map<String, String> _headers({bool auth = false}) => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (auth && token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('$_baseUrl/$path');
    if (query == null) return base;
    return base.replace(queryParameters: {
      for (final e in query.entries)
        if (e.value != null) e.key: e.value.toString(),
    });
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    bool auth = false,
  }) async {
    final uri = _uri(path, query);
    final request = http.Request(method, uri)..headers.addAll(_headers(auth: auth));
    if (body != null) request.body = jsonEncode(body);

    http.StreamedResponse streamed;
    try {
      streamed = await _client.send(request).timeout(ApiConfig.timeout);
    } catch (e) {
      throw ApiException('Réseau indisponible : $e');
    }

    final response = await http.Response.fromStream(streamed);
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final map = decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
    throw ApiException(
      (map['message'] ?? 'Erreur ${response.statusCode}').toString(),
      statusCode: response.statusCode,
      errors: map['errors'] is Map ? Map<String, dynamic>.from(map['errors']) : null,
    );
  }

  /// Unwrap Laravel's `{ "data": ... }` resource envelope when present.
  static dynamic _data(dynamic body) =>
      (body is Map && body.containsKey('data')) ? body['data'] : body;

  List<Map<String, dynamic>> _list(dynamic body) {
    final data = _data(body);
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String language = 'fr',
  }) async {
    final body = await _send('POST', 'auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'phone': ?phone,
      'language': language,
      'device_name': 'babiauto-flutter',
    });
    return _authResult(body);
  }

  Future<AuthResult> login(String email, String password) async {
    final body = await _send('POST', 'auth/login', body: {
      'email': email,
      'password': password,
      'device_name': 'babiauto-flutter',
    });
    return _authResult(body);
  }

  AuthResult _authResult(dynamic body) {
    final map = Map<String, dynamic>.from(body as Map);
    final tok = map['token'].toString();
    token = tok;
    return AuthResult(User.fromJson(Map<String, dynamic>.from(map['user'])), tok);
  }

  Future<void> logout() async {
    await _send('POST', 'auth/logout', auth: true);
    token = null;
  }

  Future<User> me() async => User.fromJson(Map<String, dynamic>.from(_data(
        await _send('GET', 'auth/me', auth: true),
      )));

  // ── Profile ─────────────────────────────────────────────────────────────────
  Future<User> profile() async => User.fromJson(Map<String, dynamic>.from(_data(
        await _send('GET', 'profile', auth: true),
      )));

  Future<User> updateProfile({String? name, String? phone, String? language, String? avatarInitial}) async {
    final body = await _send('PATCH', 'profile', auth: true, body: {
      'name': ?name,
      'phone': ?phone,
      'language': ?language,
      'avatar_initial': ?avatarInitial,
    });
    return User.fromJson(Map<String, dynamic>.from(_data(body)));
  }

  // ── Catalogue ───────────────────────────────────────────────────────────────
  Future<List<VehicleClass>> vehicleClasses() async =>
      _list(await _send('GET', 'vehicle-classes')).map(VehicleClass.fromJson).toList();

  Future<List<Place>> places({String? query, int limit = 20}) async => _list(
        await _send('GET', 'places', query: {'q': query, 'limit': limit}),
      ).map(Place.fromJson).toList();

  Future<List<FareQuote>> estimate({
    required Place pickup,
    required Place dropoff,
    bool? isAirport,
  }) async {
    final body = await _send('POST', 'rides/estimate', body: {
      'pickup': {'lat': pickup.lat, 'lng': pickup.lng},
      'dropoff': {'lat': dropoff.lat, 'lng': dropoff.lng},
      'is_airport': ?isAirport,
    });
    return _list(body).map(FareQuote.fromJson).toList();
  }

  /// Live nearby cars around a point (public; positions only). Polled by the
  /// home map. `meta.simulated` flags backend demo mode.
  Future<NearbyDriversResult> nearbyDrivers({
    required double lat,
    required double lng,
    String? vehicleClass,
    int? limit,
  }) async {
    final body = await _send('GET', 'drivers/nearby', query: {
      'lat': lat,
      'lng': lng,
      'vehicle_class': vehicleClass,
      'limit': limit,
    });
    final drivers = _list(body).map(NearbyDriver.fromJson).toList();
    final meta = (body is Map && body['meta'] is Map) ? Map<String, dynamic>.from(body['meta']) : const {};
    return NearbyDriversResult(drivers, simulated: asBool(meta['simulated']));
  }

  // ── Rides ─────────────────────────────────────────────────────────────────
  Future<List<Ride>> rides() async =>
      _list(await _send('GET', 'rides', auth: true)).map(Ride.fromJson).toList();

  Future<Ride> requestRide({
    required String vehicleClassSlug,
    required String paymentType,
    required Place pickup,
    required Place dropoff,
    bool? isAirport,
  }) async {
    final body = await _send('POST', 'rides', auth: true, body: {
      'vehicle_class': vehicleClassSlug,
      'payment_type': paymentType,
      'pickup': {'name': pickup.name, 'lat': pickup.lat, 'lng': pickup.lng},
      'dropoff': {'name': dropoff.name, 'lat': dropoff.lat, 'lng': dropoff.lng},
      'is_airport': ?isAirport,
    });
    return Ride.fromJson(Map<String, dynamic>.from(_data(body)));
  }

  Future<Ride> ride(int id) async =>
      Ride.fromJson(Map<String, dynamic>.from(_data(await _send('GET', 'rides/$id', auth: true))));

  Future<Map<String, dynamic>> tracking(int id) async {
    final body = await _send('GET', 'rides/$id/tracking', auth: true);
    return body is Map ? Map<String, dynamic>.from(body) : {};
  }

  Future<Ride> cancelRide(int id, {String? reason}) async => Ride.fromJson(
        Map<String, dynamic>.from(_data(
          await _send('POST', 'rides/$id/cancel', auth: true, body: {'reason': ?reason}),
        )),
      );

  Future<Ride> rateRide(int id, {required int stars, int tip = 0, String? comment}) async =>
      Ride.fromJson(Map<String, dynamic>.from(_data(
        await _send('POST', 'rides/$id/rate', auth: true, body: {
          'stars': stars,
          if (tip > 0) 'tip': tip,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }),
      )));

  // ── Driver / dispatch lifecycle (used to drive a ride end-to-end) ───────────
  Future<Ride> _lifecycle(int id, String action) async => Ride.fromJson(
        Map<String, dynamic>.from(_data(await _send('POST', 'rides/$id/$action', auth: true))),
      );

  Future<Ride> driverArriving(int id) => _lifecycle(id, 'arriving');
  Future<Ride> driverArrived(int id) => _lifecycle(id, 'arrived');
  Future<Ride> startTrip(int id) => _lifecycle(id, 'start');
  Future<Ride> completeTrip(int id) => _lifecycle(id, 'complete');

  // ── Saved places ────────────────────────────────────────────────────────────
  Future<List<SavedPlace>> savedPlaces() async =>
      _list(await _send('GET', 'saved-places', auth: true)).map(SavedPlace.fromJson).toList();

  Future<SavedPlace> addSavedPlace({
    required String label,
    required String icon,
    required String name,
    String? subtitle,
    required double lat,
    required double lng,
  }) async {
    final body = await _send('POST', 'saved-places', auth: true, body: {
      'label': label,
      'icon': icon,
      'name': name,
      'subtitle': ?subtitle,
      'lat': lat,
      'lng': lng,
    });
    return SavedPlace.fromJson(Map<String, dynamic>.from(_data(body)));
  }

  Future<void> deleteSavedPlace(int id) async => _send('DELETE', 'saved-places/$id', auth: true);

  // ── Payment methods ───────────────────────────────────────────────────────────
  Future<List<PaymentMethod>> paymentMethods() async =>
      _list(await _send('GET', 'payment-methods', auth: true)).map(PaymentMethod.fromJson).toList();

  Future<PaymentMethod> addPaymentMethod({
    required String type,
    String? provider,
    String? last4,
    bool isDefault = false,
  }) async {
    final body = await _send('POST', 'payment-methods', auth: true, body: {
      'type': type,
      'provider': ?provider,
      'last4': ?last4,
      'is_default': isDefault,
    });
    return PaymentMethod.fromJson(Map<String, dynamic>.from(_data(body)));
  }

  Future<void> deletePaymentMethod(int id) async => _send('DELETE', 'payment-methods/$id', auth: true);

  void close() => _client.close();
}
