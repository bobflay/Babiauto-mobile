import 'package:babiauto/data/demo_data.dart';
import 'package:babiauto/i18n/strings.dart';
import 'package:babiauto/screens/complete_screen.dart';
import 'package:babiauto/screens/home_screen.dart';
import 'package:babiauto/screens/search_screen.dart';
import 'package:babiauto/screens/vehicle_screen.dart';
import 'package:babiauto/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const t = Strings(Lang.fr);

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.build(), home: Scaffold(body: child));

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('HomeScreen builds', (tester) async {
    await tester.pumpWidget(_wrap(HomeScreen(
      t: t,
      dark: false,
      riderName: 'Koffi',
      onSearch: () {},
      onSavedPick: () {},
    )));
    await tester.pump();
    expect(find.text('Où allez-vous ?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SearchScreen builds and lists demo places', (tester) async {
    await tester.pumpWidget(_wrap(SearchScreen(
      t: t,
      onBack: () {},
      onPick: (_) {},
      search: (q) async => DemoData.places,
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('CHU de Cocody'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('VehicleScreen builds with classes', (tester) async {
    await tester.pumpWidget(_wrap(VehicleScreen(
      t: t,
      dark: false,
      destName: 'Aéroport Félix-Houphouët-Boigny',
      classes: DemoData.vehicleClasses,
      priceFor: DemoData.demoPrice,
      etaFor: (s) => 4,
      selected: 'confort',
      payment: 'mobile',
      confirmPrice: 2500,
      onPick: (_) {},
      onPayChange: (_) {},
      onBack: () {},
      onConfirm: () {},
    )));
    await tester.pump();
    expect(find.text('Babi Confort'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CompleteScreen builds and enables submit after rating', (tester) async {
    await tester.pumpWidget(_wrap(CompleteScreen(
      t: t,
      driver: DemoData.driver,
      paymentType: 'mobile',
      baseFare: 2100,
      airportFee: 400,
      distanceKm: 14.2,
      durationMinutes: 26,
      onDone: (_, _) {},
    )));
    await tester.pump();
    expect(find.text('Kouassi A.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
