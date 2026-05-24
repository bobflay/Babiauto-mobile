/// French / English copy, ported verbatim from the design `screens.jsx` (FR/EN).
enum Lang { fr, en }

class Strings {
  final Lang lang;
  const Strings(this.lang);

  bool get isFr => lang == Lang.fr;
  T _p<T>(T fr, T en) => isFr ? fr : en;

  String get greet => _p('Bonjour', 'Hi');
  String get whereTo => _p('Où allez-vous ?', 'Where to?');
  String get pickup => _p('Lieu de prise en charge', 'Pickup location');
  String get destination => _p('Destination', 'Destination');
  String get saved => _p('Lieux enregistrés', 'Saved places');
  String get recent => _p('Récents', 'Recent');
  String get home => _p('Maison', 'Home');
  String get work => _p('Bureau', 'Work');
  String get schedule => _p('Planifier', 'Schedule');
  String get now => _p('Maintenant', 'Now');
  String get cancel => _p('Annuler', 'Cancel');
  String get confirm => _p('Confirmer', 'Confirm');
  String get next => _p('Suivant', 'Next');
  String get carryOn => _p('Continuer', 'Continue');
  String get searching => _p('Recherche d\'un chauffeur', 'Finding a driver');
  String get searchingSub => _p('Patientez quelques instants…', 'Hang tight for a moment…');
  String get arriving => _p('Votre chauffeur arrive', 'Your driver is on the way');
  String get onTrip => _p('En route vers votre destination', 'On the way to your destination');
  String get trip => _p('Trajet', 'Trip');
  String get arrived => _p('Vous êtes arrivé', 'You\'ve arrived');
  String get rate => _p('Notez votre chauffeur', 'Rate your driver');
  String get rateSub => _p('Comment s\'est passé votre trajet avec', 'How was your trip with');
  String get payCash => _p('Espèces', 'Cash');
  String get payMobile => _p('Mobile Money', 'Mobile Money');
  String get payCard => _p('Carte', 'Card');
  String get promo => _p('Code promo', 'Promo code');
  String get call => _p('Appeler', 'Call');
  String get message => _p('Message', 'Message');
  String get share => _p('Partager', 'Share');
  String get safety => _p('Sécurité', 'Safety');
  String get min => _p('min', 'min');
  String get away => _p('d\'éloignement', 'away');
  String get arrivedDriver => _p('Votre chauffeur est arrivé', 'Your driver has arrived');
  String get plate => _p('Plaque', 'Plate');
  String get vehicleClass => _p('Choisir une voiture', 'Choose a ride');
  String get total => _p('Total', 'Total');
  String get paymentMethod => _p('Mode de paiement', 'Payment method');
  String get tipDriver => _p('Pourboire au chauffeur', 'Tip your driver');
  String get thanks => _p('Merci d\'avoir voyagé avec Babiauto', 'Thanks for riding with Babiauto');
  String get submit => _p('Envoyer', 'Submit');
  String get estimateArrival => _p('Arrivée estimée', 'Arrives');
  String get driverArrives => _p('Arrivée du chauffeur', 'Driver arrives');
  String get toDestination => _p('Arrivée à destination', 'Drop-off');
  String get letsGo => _p('C\'est parti', 'Let\'s go');
  String get welcome => _p('Bienvenue à bord', 'Welcome aboard');
  String get tagline => _p('Votre trajet, à votre rythme.', 'Your ride, your pace.');

  // A few extra strings the live app needs beyond the static prototype.
  String get tapToContinue => _p('appuyer pour continuer', 'tap to continue');
  String get suggest => _p('Suggérer', 'Suggest');
  String get add => _p('Ajouter', 'Add');
  String get noResults => _p('Aucun résultat', 'No results');
  String get distance => _p('Distance', 'Distance');
  String get driverEta => _p('ETA chauffeur', 'Driver ETA');
  String get nowLabel => _p('maintenant', 'now');
  String get arrival => _p('arrivée', 'arrival');
  String get trips => _p('trajets', 'trips');
  String get paidWith => _p('Payé en', 'Paid with');
  String get baseFare => _p('Tarif de base', 'Base fare');
  String get airportFee => _p('Frais d\'aéroport', 'Airport fee');
  String get noTip => _p('Aucun', 'None');
  String get fcfa => 'F CFA';

  String greetName(String name) => '$greet $name 👋';
}
