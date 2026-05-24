# Babiauto — Mobile App

A Flutter rider app for **Babiauto**, a ride-hailing service set in Abidjan,
Côte d'Ivoire (F CFA pricing, French/English). It consumes the
[Babiauto REST API](https://github.com/bobflay/Babiauto) (Laravel + Sanctum)
and implements the 8-screen flow from the Babiauto design handoff:

> Splash → Home → Search → Vehicle → Finding driver → Driver arriving → On trip → Complete + rate

Runs on **web**, Android and iOS from a single codebase.

## Run

```bash
flutter pub get

# Web
flutter run -d chrome

# Mobile
flutter run            # with an emulator/device attached
```

### Point it at an API

The app talks to `/api/v1` of the Babiauto backend. The host is configurable;
it defaults to `http://localhost:8000/api/v1`.

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://your-host/api/v1
```

When no backend is reachable the app **falls back to bundled demo data**
(the same catalogue, places and driver as the design), so the full flow is
demoable offline. With a backend running, it performs real calls: silent demo
login, vehicle-class catalogue, place search, fare estimate, ride request,
driver lifecycle and rating.

Other defines: `DEMO_EMAIL`, `DEMO_PASSWORD` (default `koffi@babiauto.ci` /
`password`, the seeded rider).

## Build

```bash
flutter build web --no-tree-shake-icons
flutter build apk        # Android
```

## Deploy (GitHub Pages)

`.github/workflows/deploy-pages.yml` builds and publishes the web app on push.
One-time: **Settings → Pages → Source = GitHub Actions**.

To point the hosted site at a real backend, add repository variables
(**Settings → Secrets and variables → Actions**):

| Name | Kind | Example |
|------|------|---------|
| `API_BASE_URL` | variable | `https://api.babiauto.ci/api/v1` |
| `DEMO_EMAIL` | variable | `koffi@babiauto.ci` |
| `DEMO_PASSWORD` | secret | `password` |

The backend must be served over **HTTPS** and allow **CORS** from
`https://<owner>.github.io`. When `API_BASE_URL` is unset the site runs against
the bundled demo data.

## Layout

```
lib/
  api/          # BabiautoApi HTTP client + config + exceptions
  models/       # VehicleClass, Place, Ride, Driver, User, …
  state/        # AppState (ChangeNotifier): flow + API + demo fallback
  data/         # DemoData (offline catalogue/places/driver)
  i18n/         # FR / EN strings
  theme/        # palette + Manrope / Space Grotesk typography
  widgets/      # BabiMap, icons, vehicle art, sheets, chips, CTAs
  screens/      # the 8 flow screens + FlowShell
```

## Tests

```bash
flutter test
```
