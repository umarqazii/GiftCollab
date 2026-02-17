# Gift Collab

**Simple. Smart. Fun.**

Gift Collab is a Flutter mobile app that helps people create events, build gift registries, and collaborate on gifts. Event creators can invite guests, add gift ideas with target amounts, and guests can contribute money toward gifts—all in one place.

---

## What It Does

- **Event management** — Create events (e.g. weddings, birthdays), set date and location, add a cover image, and generate an invitation code.
- **Gift registries** — For each event, add gifts with a target price. Guests see a list of gifts and can contribute any amount toward one or more items.
- **Invitations & joining** — Invite by email or share a code. Guests can view **Invitations** and **Joined** events from the home tabs.
- **Contributions** — Contribute toward gifts with optional messages. Payments are handled via **Stripe**.
- **Roles** — On first use after login, you choose **Event Management** (create/manage events and registries) or **Seller Management** (for future seller-focused features). The choice is stored and used across the app.

---

## Features

| Feature | Description |
|--------|-------------|
| **Splash & auth** | App opens on a splash screen, then routes to **Login** or **Role selection** based on auth state. |
| **Google Sign-In** | Sign in with Google; user profile is synced to Firestore. |
| **Role selection** | Two options: Event Management and Seller Management. Stored in local preferences. |
| **Home tabs** | **My Events** (events you created), **Invitations** (pending), **Joined** (events you joined). |
| **Create event** | Form for title, description, date, location, cover image (with image picker). Generates invitation code. |
| **Event details** | View event info and open its **Gift Registry**. |
| **Gift registry** | List of gifts with target amount and progress. Admins can add gifts; anyone can contribute. |
| **Add gift** | Name, price, category, image (e.g. via Cloudinary). |
| **Contribute** | Contribute an amount toward a gift; optional message. Uses Stripe for payment. |
| **Logout** | Logout from the app bar; auth state listener redirects to login. |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | [Flutter](https://flutter.dev/) (Dart SDK ^3.10.1) |
| **State & routing** | [GetX](https://pub.dev/packages/get) (reactive state, dependency injection, GetPage routing) |
| **Backend & auth** | [Firebase](https://firebase.google.com/) — [Core](https://pub.dev/packages/firebase_core), [Auth](https://pub.dev/packages/firebase_auth), [Cloud Firestore](https://pub.dev/packages/cloud_firestore), [Cloud Functions](https://pub.dev/packages/cloud_functions) |
| **Sign-in** | [Google Sign-In](https://pub.dev/packages/google_sign_in) |
| **Payments** | [Stripe](https://pub.dev/packages/flutter_stripe) (Flutter Stripe SDK) |
| **Images** | [Image Picker](https://pub.dev/packages/image_picker), [Cloudinary](https://pub.dev/packages/cloudinary_public), [Cached Network Image](https://pub.dev/packages/cached_network_image) |
| **Local storage** | [SharedPreferences](https://pub.dev/packages/shared_preferences) (tokens, user role) |
| **UI** | Material Design, [Google Fonts](https://pub.dev/packages/google_fonts), [google_nav_bar](https://pub.dev/packages/google_nav_bar) |
| **Other** | [UUID](https://pub.dev/packages/uuid), [Intl](https://pub.dev/packages/intl), [flutter_native_splash](https://pub.dev/packages/flutter_native_splash), [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) |

---

## Project Structure

```
lib/
├── core/                 # Constants (colors, assets, roles), network, errors
├── data/
│   ├── models/           # EventModel, GiftModel, ContributionModel, UserModel
│   └── services/         # AuthService, StorageService
├── modules/
│   ├── splash/           # Splash screen & routing by auth status
│   ├── login/            # Google Sign-In
│   ├── role_selection/   # Event vs Seller role choice
│   ├── event_home/        # Event home: Bottom nav My Events, Invitations, Joined
│   ├── my_events/        # Events created by user, FAB → Create Event
│   ├── invited_events/   # Events user is invited to
│   ├── joined_events/    # Events user has joined
│   ├── create_event/     # Create event form
│   ├── event_details_screen/
│   ├── gift_registry/    # Gifts for an event, add/contribute
│   ├── add_gift/         # Add gift to registry
│   └── ...
├── routes/               # GetX app_routes (GetPage list, route names)
├── widgets/              # CustomButton, AppTextField, etc.
├── firebase_options.dart # Generated Firebase config
└── main.dart
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (SDK ^3.10.1)
- Firebase project with Auth (Google provider) and Firestore enabled
- Stripe account and publishable key
- (Optional) Cloudinary for image uploads

### Setup

1. **Clone and install**
   ```bash
   git clone https://github.com/umarqazii/GiftCollab.git
   cd GiftCollab
   flutter pub get
   ```

2. **Firebase**
   - Create a Firebase project and add Android/iOS (and optionally macOS) apps.
   - Download and replace `lib/firebase_options.dart` (e.g. via FlutterFire CLI: `flutterfire configure`).
   - Enable **Authentication** → Google, and **Firestore Database**.

3. **Stripe**
   - In `lib/main.dart`, set your Stripe publishable key (or move it to env/constants):
   ```dart
   Stripe.publishableKey = 'pk_test_...'; // or pk_live_...
   ```

4. **Run**
   ```bash
   flutter run
   ```

---

## License

Private project — not published to pub.dev (`publish_to: 'none'` in `pubspec.yaml`).
