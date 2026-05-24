import 'package:latlong2/latlong.dart';

const _distance = Distance();

/// Interpolate a point a fraction [t] (0..1) along a polyline, weighted by the
/// real geographic length of each segment.
LatLng pointAlongRoute(List<LatLng> points, double t) {
  if (points.isEmpty) return const LatLng(0, 0);
  if (points.length == 1 || t <= 0) return points.first;
  if (t >= 1) return points.last;

  final segments = <double>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final len = _distance(points[i], points[i + 1]);
    segments.add(len);
    total += len;
  }
  if (total == 0) return points.first;

  final target = t * total;
  var acc = 0.0;
  for (var i = 0; i < segments.length; i++) {
    if (acc + segments[i] >= target) {
      final f = segments[i] == 0 ? 0.0 : (target - acc) / segments[i];
      return LatLng(
        points[i].latitude + (points[i + 1].latitude - points[i].latitude) * f,
        points[i].longitude + (points[i + 1].longitude - points[i].longitude) * f,
      );
    }
    acc += segments[i];
  }
  return points.last;
}
