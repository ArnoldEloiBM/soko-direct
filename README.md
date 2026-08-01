# Soko Direct 🌾

A mobile marketplace connecting farmers directly to buyers — built with Flutter and Firebase. Farmers list crops, buyers negotiate and pay through in-app escrow, and both sides rate each other after a completed transaction.

Built for [Mobile Application Development] final project, Group 21.

## Tech Stack

- **Frontend:** Flutter
- **State management:** BLoC / Cubit (`flutter_bloc`)
- **Backend:** Firebase (Firestore, Firebase Auth)
- **Architecture:** Clean Architecture (`presentation` / `domain` / `data` layers per feature)

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and `flutter doctor` passing
- A code editor (VS Code recommended, with the Flutter/Dart extensions)
- Access to the team's Firebase project (ask a team member to add you as Editor)

### Setup

1. Clone the repo:
   ```
   git clone https://github.com/ArnoldEloiBM/soko-direct.git
   cd soko-direct
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```

3. Firebase is already configured for this project (`lib/firebase_options.dart` is committed). If you're setting up a new platform target or your local Firebase CLI needs re-linking, run:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   and select the **sokodirect** project when prompted.

4. Run the app:
   ```
   flutter run
   ```
   For a quick check in the browser (not the graded target platform, but fast for development):
   ```
   flutter run -d chrome
   ```
   If Chrome fails to auto-launch, use:
   ```
   flutter run -d web-server
   ```
   then open the printed `localhost` URL manually.

   ⚠️ **Note:** the final submission and demo video must run on a real Android device or emulator — web/desktop builds are not accepted per the assignment rubric.

## Project Structure

```
lib/
├── main.dart              → app entry point, registers all Cubits/Blocs
├── app.dart                → root MaterialApp widget
│
├── core/
│   └── theme/               → app-wide theming (light/dark mode)
│
└── features/
    ├── auth/                 → registration, login, logout
    ├── listings/             → create/edit/delete crop listings
    ├── offers/                → buyer offers & negotiation
    ├── transactions/    → escrow, delivery confirmation
    ├── wallet/               → balance & top-up
    ├── ratings/               → post-transaction reviews
    └── onboarding/       → splash & role selection
```

Each feature follows the same internal pattern:
```
feature/
├── data/            → talks to Firestore (only layer that imports cloud_firestore)
├── domain/       → plain Dart models + repository contracts, no Firebase imports
└── presentation/ → Cubit/Bloc + screens
```

**Rule:** screens never call Firestore directly. Screen → Cubit → Repository → Firestore.

See [`ARCHITECTURE.md`](./ARCHITECTURE.md) for the full pattern explanation and a worked example.

## Team & Roles

| Feature | Owner |
|---|---|
| Splash / Language selection, Farmer Dashboard | Armstrong |
| Registration, Google Sign-In, Login/Logout | Samuel |
| Buyer Dashboard, Search/Filter, Make Offer/Negotiation | Tabitha / Dorcas |
| Create/Edit/Delete Listing | Arnold |
| Listing Detail, Rating/Review, Theme, SharedPreferences | Audric |
| Wallet, Transaction Confirmation | Dorian |

## Firestore Structure

Top-level collections:
- `offers` — buyer offers on listings (`buyerId`, `farmerId`, `listingId`, `pricePerKg`, `quantityKg`, `status`, `createdAt`)
- `wallets` — one document per user (`balance`, `provider`)
- `transactions` — created once an offer is accepted (`offerId`, `buyerId`, `farmerId`, `amount`, `escrowStatus`, `deliveryConfirmed`, `createdAt`)

## Testing

Run all tests with:
```
flutter test
```

## Known Limitations & Future Work

- Security rules are currently in test mode (open access) during active development — will be replaced with per-user restricted rules before final submission.
- Navigation between features is still being wired together as individual features are completed.
- [Add any other known gaps as the project progresses.]
