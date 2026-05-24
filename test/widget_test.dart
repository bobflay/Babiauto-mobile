import 'package:babiauto/i18n/strings.dart';
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
}
