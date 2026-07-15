# ai-crypto-chat
An AI-powered cryptocurrency companion app built with Clean Architecture, BLoC, Riverpod, CoinGecko API, and Gemini AI
# CryptoAI — AI-Powered Crypto Chat & Market Tracker

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-State%20Management-blueviolet?style=for-the-badge)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-1B2A4A?style=for-the-badge)
![Clean Architecture](https://img.shields.io/badge/Clean-Architecture-378ADD?style=for-the-badge)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Gemini](https://img.shields.io/badge/Gemini-AI-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

A production-grade Flutter application combining real-time cryptocurrency market data with an AI-powered chat assistant scoped to crypto and blockchain topics. Built with Clean Architecture, hybrid state management (BLoC + Riverpod), offline-first data caching, and Google Gemini for conversational AI.

Built by **Adeyemi Fortune Adeboye** ([@Fortune_Dev](https://youtube.com/@Fortune_Dev)) — Flutter developer & Software Engineering student at Obafemi Awolowo University, Nigeria.

---

## Features

- **Live crypto market tracker** — top 50 coins by market cap, live prices, 24h change, sourced from the CoinGecko API
- **AI crypto assistant** — powered by Google Gemini, scoped via a system prompt to only discuss cryptocurrency, blockchain, DeFi, and Web3 topics
- **Google Sign-In authentication** — persistent, cross-device identity via Firebase Auth
- **Offline-first architecture** — Hive local caching with automatic fallback when the network is unavailable, for both market data and chat history
- **Cross-device chat sync** — conversation history synced via Cloud Firestore, scoped per authenticated user
- **Coin detail view** — price, market cap, and 24h performance for any individual coin

---

## Architecture

This project follows **Clean Architecture** with strict separation into three layers:

```
lib/
├── core/                    # Cross-cutting concerns
│   ├── constants/           # App-wide colors, strings, constants
│   ├── di/                  # Dependency injection (get_it)
│   ├── error/                # Failure types (Either-based error handling)
│   ├── router/               # (reserved — see Architecture Decisions)
│   └── theme/                # App-wide ThemeData
│
├── domain/                  # Pure business logic — zero framework dependencies
│   ├── entities/              # CryptoCoin, ChatMessage, AppUser
│   ├── repositories/          # Abstract contracts (interfaces)
│   └── usecases/              # One class per action, injectable & testable
│
├── data/                    # Implementation details
│   ├── models/                 # JSON/Firestore/Hive serialization (extends entities)
│   ├── datasources/            # Remote (Dio, Firestore, Gemini) & local (Hive) sources
│   └── repositories/           # Concrete repository implementations
│
└── presentation/             # UI layer
    ├── bloc/                    # ChatBloc — event-driven chat orchestration
    ├── providers/                # Riverpod providers — crypto data & auth state
    ├── pages/                    # Full screens
    └── widgets/                  # Reusable UI components
```

### Why Clean Architecture?

Every dependency points **inward**, toward `domain/`. The domain layer has zero knowledge of Flutter, Firebase, Dio, or Hive — it only depends on pure Dart and two framework-agnostic packages (`equatable` for value equality, `fpdart` for functional error handling). This means:

- Any data source (CoinGecko → a different API, Firestore → a custom backend) can be swapped without touching business logic
- Every use case and repository is independently unit-testable via mocked dependencies (`mocktail`)
- The codebase stays legible as it grows — a new contributor can predict where any given piece of logic lives

### Why hybrid state management (BLoC + Riverpod)?

- **BLoC** powers the chat feature, where interactions are event-driven and involve multi-step orchestration (construct message → persist → call AI → persist reply → emit state). BLoC's explicit event→state model gives a clear, testable audit trail for this kind of sequential flow.
- **Riverpod** powers crypto data and auth state — simpler, read-heavy flows (fetch, cache, display) where `FutureProvider`/`StreamProvider` reduce boilerplate significantly compared to BLoC.

### Error handling: `Either<Failure, T>`

Rather than throwing exceptions across layer boundaries, every repository method returns `Either<Failure, T>` (via the `fpdart` package). `Left` represents a typed failure (`ServerFailure`, `CacheFailure`, `NetworkFailure`); `Right` represents success. This makes failure handling explicit and compiler-enforced at every call site, rather than relying on documentation or `try/catch` blocks that are easy to forget.

Data sources themselves still use plain exceptions internally (simpler, standard Dart) — the **repository layer is the boundary** where exceptions are caught and converted into typed `Either` results for everything above it.

### Offline-first caching strategy

Both the crypto and chat repositories follow the same pattern:
1. Attempt the remote call (API / Firestore)
2. On success, cache the result locally (Hive) and return it
3. On failure, fall back to the local cache if available
4. If both remote and cache fail, return a typed `Failure`

This means the app remains usable — showing the last-known data — even when offline.

---

## Tech Stack

| Category | Technology |
|---|---|
| Language | Dart |
| Framework | Flutter |
| State Management | `flutter_bloc` (chat), `flutter_riverpod` (crypto, auth) |
| Architecture | Clean Architecture, Dependency Injection (`get_it`) |
| Error Handling | `fpdart` (`Either<Failure, T>`) |
| Networking | `dio` (CoinGecko REST API) |
| AI | Google Gemini API (`google_generative_ai`), model: `gemini-3.1-flash-lite` |
| Backend | Firebase (Auth, Firestore) |
| Local Storage | `hive_flutter` |
| Auth | Google Sign-In via Firebase Auth |
| Testing | `flutter_test`, `mocktail`, `bloc_test` |
| CI/CD | GitHub Actions |

---

## Getting Started

### Prerequisites

- Flutter SDK (^3.11.3)
- A Firebase project with **Authentication** (Google provider) and **Firestore** enabled
- A Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/thefortune-tech/ai-crypto-chat.git
   cd ai-crypto-chat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Select your Firebase project and target platforms. This generates `lib/firebase_options.dart`.

4. **Set up environment variables**

   Create a `.env` file in the project root:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```
   This file is git-ignored and must never be committed.

5. **Enable Google Sign-In on web** (if targeting web)

   Add your OAuth Web Client ID (found under Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration) to `web/index.html`:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
   ```
   Also register your local origin (e.g., `http://localhost:5000`) under **Authorized JavaScript origins** in [Google Cloud Console](https://console.cloud.google.com) → APIs & Services → Credentials, and enable the **People API** for your project.

6. **Run the app**
   ```bash
   flutter run
   ```

### Running tests

```bash
flutter test
```

---

## Testing

The project includes unit and BLoC tests covering the core business logic:

- **Use case tests** — verify each use case correctly delegates to its repository and propagates `Either<Failure, T>` results
- **Repository tests** — verify the offline-first fallback logic (remote → cache → typed failure), including the edge case where both the remote call and the cache read fail
- **BLoC tests** — verify `ChatBloc` emits the correct state sequence for history loading and history clearing

Run with:
```bash
flutter test
```

---

## Building a Release APK

To generate an installable Android APK:

```bash
flutter build apk --release
```

The output APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

For a smaller, split-per-architecture build (recommended for distribution, since it produces separate smaller APKs per CPU architecture instead of one large universal APK):

```bash
flutter build apk --release --split-per-abi
```

This produces three APKs (`app-armeabi-v7a-release.apk`, `app-arm64-v8a-release.apk`, `app-x86_64-release.apk`) under the same output directory — most modern Android devices should use the `arm64-v8a` build.

> **Note:** Ensure `.env` exists locally with a valid `GEMINI_API_KEY` before building — the key is bundled as an asset at build time and is required for the AI chat feature to function in the release build.

---

## Architecture Decisions & Known Trade-offs

Being transparent about deliberate simplifications and open items, rather than presenting the project as more complete than it is:

- **Navigation**: `go_router` is listed as a dependency but the app currently uses `Navigator.push` and a simple `AuthGate` widget for conditional routing. The app's navigation graph (sign-in → home → coin detail) is small enough that `go_router`'s declarative routing, deep-linking, and URL-based navigation didn't justify the added complexity at this stage.
- **`NetworkFailure`** is defined in the failure hierarchy but not currently distinguished from `ServerFailure` in practice — this would require a dedicated connectivity-check utility (e.g., via `connectivity_plus`) to detect "no internet" specifically, rather than a generic server/API failure.
- **Cache expiry** (`AppConstants.cacheExpiryMinutes`) and **chat history limits** (`AppConstants.maxChatHistory`) are defined as constants but not yet enforced — cached data is currently only refreshed on explicit user action (pull-to-refresh) or app restart, and chat history has no hard cap.
- **`SaveMessageUseCase`** currently requires both the local (Hive) and remote (Firestore) writes to succeed for an overall success result. A more fully offline-first design would treat a successful local save as sufficient, with a background sync/retry mechanism reconciling Firestore later — this was scoped out for simplicity at this stage.
- **`ChatBloc`**'s multi-step message-sending flow (`ChatMessageSent`) does not yet have a dedicated `bloc_test` — the existing BLoC tests cover history loading and clearing; the send flow is covered indirectly through manual testing and its constituent use case tests.

---

## Other Projects in This Portfolio

- **[Job Tracker](https://github.com/thefortune-tech/job-tracker)** — Clean Architecture job application tracker with hybrid BLoC/Riverpod state management, 14 passing tests, CI/CD
- **ScientIQ** — Production-grade scientific calculator with Clean Architecture, `get_it` DI, and functional error handling via `fpdart`/`Either`

---

## Author

**Adeyemi Fortune Adeboye**
Flutter Developer · Software Engineering Student, Obafemi Awolowo University
YouTube: [@Fortune_Dev](https://youtube.com/@Fortune_Dev)
GitHub: [@thefortune-tech](https://github.com/thefortune-tech)

---

## License

This project is for portfolio and educational purposes.