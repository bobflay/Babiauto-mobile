import 'package:babiauto/i18n/strings.dart';
import 'package:babiauto/models/nearby_driver.dart';
import 'package:babiauto/models/ride.dart';
import 'package:babiauto/util/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('groupThousands formats with French-style grouping', () {
    // Uses a narrow no-break space (U+202F), matching toLocaleString('fr-FR').
    expect(groupThousands(1847), '1 847');
    expect(groupThousands(2500), '2 500');
    expect(groupThousands(900), '900');
  });

  test('RideStatus maps API strings', () {
    expect(RideStatus.fromApi('in_progress'), RideStatus.inProgress);
    expect(RideStatus.fromApi('searching').isActive, isTrue);
    expect(RideStatus.fromApi('completed').isActive, isFalse);
  });

  test('Strings switch by language', () {
    expect(const Strings(Lang.fr).whereTo, 'Où allez-vous ?');
    expect(const Strings(Lang.en).whereTo, 'Where to?');
  });

  test('NearbyDriver parses /drivers/nearby item', () {
    final d = NearbyDriver.fromJson({
      'id': 5,
      'vehicle_class': 'xl',
      'lat': 5.3525,
      'lng': -3.97858,
      'heading': 202.5,
      'distance_km': 0.42,
      'eta_minutes': 2,
      'simulated': true,
    });
    expect(d.id, 5);
    expect(d.vehicleClass, 'xl');
    expect(d.heading, 202.5);
    expect(d.etaMinutes, 2);
    expect(d.latLng.latitude, 5.3525);
    expect(d.latLng.longitude, -3.97858);
  });
}
