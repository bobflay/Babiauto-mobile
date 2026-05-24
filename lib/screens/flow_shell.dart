import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/demo_data.dart';
import '../models/driver.dart';
import '../models/place.dart';
import '../state/app_state.dart';
import '../widgets/device_frame.dart';
import 'arriving_screen.dart';
import 'complete_screen.dart';
import 'finding_screen.dart';
import 'home_screen.dart';
import 'on_trip_screen.dart';
import 'search_screen.dart';
import 'splash_screen.dart';
import 'vehicle_screen.dart';

/// Drives the 8-step flow off [AppState.step], mirroring the prototype's
/// state machine, wrapped in the responsive [DeviceFrame].
class FlowShell extends StatelessWidget {
  const FlowShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      backgroundColor: const Color(0xFF1F1B17),
      body: DeviceFrame(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOut,
          transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
          child: KeyedSubtree(
            key: ValueKey(app.step),
            child: _screenFor(context, app),
          ),
        ),
      ),
    );
  }

  Driver get _driver => DemoData.driver;

  Driver _activeDriver(AppState app) => app.ride?.driver ?? _driver;

  Widget _screenFor(BuildContext context, AppState app) {
    final t = app.t;
    switch (app.step) {
      case FlowStep.splash:
        return SplashScreen(t: t, onNext: () => app.go(FlowStep.home));

      case FlowStep.home:
        return HomeScreen(
          t: t,
          dark: app.darkMap,
          riderName: app.riderName,
          center: app.pickupLatLng,
          locationLabel: app.pickup.name,
          locating: app.locating,
          onSearch: () => app.go(FlowStep.search),
          onSavedPick: () => app.chooseDestination(_bureau),
          onRecenter: app.detectLocation,
        );

      case FlowStep.search:
        return SearchScreen(
          t: t,
          pickupName: app.pickup.name,
          onBack: () => app.go(FlowStep.home),
          onPick: app.chooseDestination,
          search: app.searchPlaces,
        );

      case FlowStep.vehicles:
        return VehicleScreen(
          t: t,
          dark: app.darkMap,
          destName: app.destination?.name ?? 'Aéroport Félix-Houphouët-Boigny',
          pickupName: app.pickup.name,
          pickupLatLng: app.pickupLatLng,
          dropLatLng: app.destinationLatLng ?? app.pickupLatLng,
          route: app.routePoints,
          classes: app.vehicleClasses,
          priceFor: app.priceFor,
          etaFor: app.etaFor,
          selected: app.vehicleSlug,
          payment: app.paymentType,
          confirmPrice: app.selectedPrice,
          onPick: app.setVehicle,
          onPayChange: app.setPayment,
          onBack: () => app.go(FlowStep.home),
          onConfirm: app.confirmRide,
        );

      case FlowStep.finding:
        final q = app.selectedQuote;
        return FindingScreen(
          t: t,
          dark: app.darkMap,
          center: app.pickupLatLng,
          distanceKm: q?.distanceKm ?? app.ride?.distanceKm ?? 14.2,
          durationMinutes: q?.durationMinutes ?? app.ride?.durationMinutes ?? 28,
          driverEtaMinutes: q?.driverEtaMinutes ?? app.etaFor(app.vehicleSlug),
          onArrived: () {
            app.driverArriving();
            app.go(FlowStep.arriving);
          },
          onCancel: () {
            app.resetFlow();
            app.go(FlowStep.home);
          },
        );

      case FlowStep.arriving:
        return ArrivingScreen(
          t: t,
          dark: app.darkMap,
          driver: _activeDriver(app),
          pickup: app.pickupLatLng,
          onStartTrip: () {
            app.startTrip();
            app.go(FlowStep.ontrip);
          },
          onCancel: () {
            app.resetFlow();
            app.go(FlowStep.home);
          },
        );

      case FlowStep.ontrip:
        return OnTripScreen(
          t: t,
          dark: app.darkMap,
          driver: _activeDriver(app),
          pickup: app.pickupLatLng,
          dropoff: app.destinationLatLng ?? app.pickupLatLng,
          route: app.routePoints,
          originLabel: app.pickup.name,
          destLabel: app.destination?.name ?? _shortDest(app.destination),
          onComplete: () {
            app.completeTrip();
            app.go(FlowStep.complete);
          },
        );

      case FlowStep.complete:
        final q = app.selectedQuote;
        final ride = app.ride;
        final base = ride?.fare.baseFare ?? q?.baseFare ?? (app.selectedPrice - 400);
        final airport = ride?.fare.airportFee ?? q?.airportFee ?? 400;
        return CompleteScreen(
          t: t,
          driver: _activeDriver(app),
          paymentType: app.paymentType,
          pickupName: app.pickup.name,
          destName: app.destination?.name ?? 'Aéroport Félix-Houphouët-Boigny',
          baseFare: base,
          airportFee: airport,
          distanceKm: ride?.distanceKm ?? q?.distanceKm ?? 14.2,
          durationMinutes: ride?.durationMinutes ?? q?.durationMinutes ?? 26,
          onDone: (stars, tip) => app.submitRating(stars, tip),
        );
    }
  }

  static String _shortDest(Place? p) {
    if (p == null) return 'Aéroport FHB';
    final n = p.name;
    return n.contains('Aéroport') ? 'Aéroport FHB' : n;
  }

  /// The "Bureau" saved place used by the Home quick-pick.
  static const Place _bureau = Place(
    name: 'Plateau · Av. Chardy',
    subtitle: 'Bureau',
    lat: 5.3210,
    lng: -4.0190,
  );
}
