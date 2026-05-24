import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Free, key-less geo helpers: road routing via OSRM and reverse geocoding via
/// Nominatim. Both are best-effort with graceful fallbacks.
class GeoService {
  GeoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 8);

  /// Driving route geometry between two points. Falls back to a straight line.
  Future<List<LatLng>> route(LatLng from, LatLng to) async {
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final routes = json['routes'];
        if (routes is List && routes.isNotEmpty) {
          final coords = routes[0]['geometry']['coordinates'] as List;
          final points = coords
              .map((p) => LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble()))
              .toList();
          if (points.length >= 2) return points;
        }
      }
    } catch (_) {/* fall through */}
    return [from, to];
  }

  /// Human label for a coordinate, e.g. "Cocody · Abidjan". Null on failure.
  Future<String?> reverseLabel(LatLng point, {String language = 'fr'}) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2'
        '&lat=${point.latitude}&lon=${point.longitude}&zoom=16&accept-language=$language',
      );
      // User-Agent is dropped by browsers on web (the browser UA is used);
      // it satisfies Nominatim's policy on mobile/desktop.
      final res = await _client.get(uri, headers: {'User-Agent': 'babiauto-flutter/1.0'}).timeout(_timeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final addr = json['address'];
        if (addr is Map) {
          final hood = addr['suburb'] ??
              addr['neighbourhood'] ??
              addr['quarter'] ??
              addr['city_district'] ??
              addr['residential'] ??
              addr['road'];
          final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['municipality'] ?? addr['state'];
          if (hood != null && city != null) return '$hood · $city';
          if (hood != null) return hood.toString();
          if (city != null) return city.toString();
        }
        final display = json['display_name'];
        if (display is String && display.isNotEmpty) return display.split(',').first.trim();
      }
    } catch (_) {/* fall through */}
    return null;
  }

  void close() => _client.close();
}
