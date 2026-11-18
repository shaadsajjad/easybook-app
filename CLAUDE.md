# EasyBook App (Flutter)

## Project context
Mobile client for EasyBook, a service-booking app.
The backend is finished and deployed. The API contract is in ./docs/API.md. It is the single source of truth: never invent endpoints, fields, or behaviors that are not in it. If something is missing, ask.
Keep the code simple, readable, and easy to explain.
After finishing each step, summarize what was built and why. Do not build ahead of the step requested.
The approved plan for every step is in ./docs/PLAN.md.

## Git workflow
- Never run `git commit` or `git push`. The developer commits and pushes every step themselves.
- Before each step, create the step's branch (names are in docs/PLAN.md) from an up-to-date `main`.
- When a step is finished, leave the changes uncommitted, suggest a commit message, and stop until the developer says "continue".

## Tech stack
- Flutter + Dart (null safety), scaffolded with very_good_cli (flavors, very_good_analysis lints)
- State management: BLoC (flutter_bloc, bloc, equatable)
- Navigation: go_router
- Localization: easy_localization (languages: English `en` and Bengali `bn`)
- Networking: dio
- Secure storage: flutter_secure_storage (JWT only)
- DI: get_it
- Functional error handling: fpdart (`Either<Failure, T>`)
- JSON: json_annotation + json_serializable + build_runner
- Images: cached_network_image
- Formatting: intl
- Tests: bloc_test + mocktail
Ask before adding any dependency not listed here.

## Rules of engagement
- Minimal abstraction. No extra layers beyond data / domain / presentation, no generic base classes unless used three or more times.
- Always output complete files, not partial snippets or diffs.
- One feature per step, small meaningful commits (conventional: feat:, fix:, test:, docs:, chore:, refactor:).
- No hardcoded user-facing strings (use LocaleKeys), no hardcoded colors, text styles, spacing or URLs inside widgets.
- Keep `flutter analyze` clean (very_good_analysis). Run it before every commit.
- Prefer small widgets in their own files over giant build methods. Use `const` wherever possible.
- No secrets in the app. The AI provider key lives only on the backend.
- A step is not finished until it compiles, analyzes clean, its bloc/repository tests pass, and loading, empty, error and success states are handled for every screen it adds.

## Template cleanup (do this in step 2)
- Delete the sample counter feature (`lib/counter`, `test/counter`) and its references.
- Remove the template's ARB localization (`lib/l10n`, `l10n.yaml`, `generate: true`, `flutter_localizations` delegates tied to it) and replace it with easy_localization. Keep only what easy_localization needs.
- Keep the three flavors (development, staging, production) and `bootstrap.dart`.
- Set the app display name to "EasyBook" for the production flavor (and "EasyBook Dev" / "EasyBook Staging" for the others).

## Architecture: clean architecture, feature-first
Dependency rule: presentation -> domain <- data. Domain depends on nothing (pure Dart: no Flutter, no Dio, no json). Data implements domain contracts. Presentation talks only to domain use cases.

```
lib/
├── main_development.dart / main_staging.dart / main_production.dart
├── bootstrap.dart
├── app/
│   ├── app.dart                   (MaterialApp.router, theme, localization, global blocs)
│   └── shell/                     (bottom navigation shell scaffold)
├── core/
│   ├── config/
│   │   ├── env.dart               (per-environment constants, see "Environment setup")
│   │   ├── flavor.dart            (enum Flavor { development, staging, production })
│   │   └── app_config.dart        (immutable: flavor + baseUrl, registered in get_it)
│   ├── constants/
│   │   ├── api_endpoints.dart     (relative paths only, no base URL)
│   │   ├── app_constants.dart     (timeouts, page size, limits, password rules, business timezone label)
│   │   └── storage_keys.dart
│   ├── di/
│   │   └── injection.dart         (get_it registrations, grouped by feature)
│   ├── error/
│   │   ├── failures.dart          (sealed Failure hierarchy)
│   │   └── exceptions.dart        (data-layer exceptions mapped to failures in repositories)
│   ├── network/
│   │   ├── dio_client.dart        (Dio factory using AppConfig.baseUrl and timeouts)
│   │   ├── auth_interceptor.dart  (adds Bearer token; reports 401 on protected routes)
│   │   ├── error_mapper.dart      (DioException + API error envelope -> Failure)
│   │   └── api_envelope.dart      (helpers to read { success, data, message, meta, errors })
│   ├── storage/
│   │   └── token_storage.dart     (flutter_secure_storage wrapper: read/save/clear token)
│   ├── router/
│   │   ├── app_router.dart        (GoRouter config, redirect logic)
│   │   ├── app_routes.dart        (route names and paths as constants)
│   │   └── go_router_refresh_stream.dart
│   ├── theme/
│   │   ├── app_theme.dart         (light + dark ThemeData, Material 3, component themes)
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_spacing.dart       (spacing, radius, elevation, breakpoints)
│   │   └── status_colors.dart     (appointment status -> color mapping)
│   ├── localization/
│   │   └── locale_keys.g.dart     (generated by easy_localization, committed)
│   ├── utils/
│   │   ├── date_formatter.dart    (UTC -> local display, yyyy-MM-dd for availability)
│   │   ├── price_formatter.dart   (string "500.00" -> display with ৳)
│   │   ├── validators.dart        (email, password, name, phone rules matching the API)
│   │   └── extensions.dart
│   └── widgets/                   (shared reusable widgets, no feature logic)
│       ├── app_button.dart
│       ├── app_text_field.dart
│       ├── loading_view.dart
│       ├── error_view.dart        (message + retry button)
│       ├── empty_view.dart
│       ├── app_network_image.dart
│       ├── status_chip.dart
│       └── section_header.dart
└── features/
    ├── auth/                      (splash/session check, register, login, logout)
    ├── services/                  (list, search/filter, categories, detail, availability)
    ├── appointments/              (create, my bookings, detail, cancel)
    ├── profile/                   (view, edit, change password)
    └── ai_assistant/              (chat)
```

Each feature has the same internal layout:
```
features/<feature>/
├── data/
│   ├── datasources/     <feature>_remote_data_source.dart (Dio calls only, throws exceptions)
│   ├── models/          json_serializable models, fromJson/toJson, toEntity()
│   └── repositories/    <feature>_repository_impl.dart (catches exceptions, returns Either<Failure, T>)
├── domain/
│   ├── entities/        plain Equatable classes (pure Dart)
│   ├── repositories/    abstract <feature>_repository.dart
│   └── usecases/        one small class per action, callable: `call(params)`
└── presentation/
    ├── bloc/            <feature>_bloc/cubit, _event, _state
    ├── pages/           full screens (routed)
    └── widgets/         widgets used only by this feature
```
Tests mirror this layout under `test/`.

## Environment setup (flavors)
- Use the very_good_cli flavors. Each `main_<flavor>.dart` builds an `AppConfig` for its flavor and passes it to `bootstrap`.
- `core/config/env.dart` holds the per-environment constants. The base URL appears in exactly ONE place in the whole codebase:
```dart
abstract final class Env {
  // Production API (Render). Includes the /api/v1 prefix.
  static const String productionBaseUrl = 'https://easybook-api-d89z.onrender.com/api/v1';

  // For now all flavors use the production API.
  // To use a local backend later, change only these values:
  //   Android emulator: http://10.0.2.2:4000/api/v1
  //   iOS simulator:    http://localhost:4000/api/v1
  static const String developmentBaseUrl = productionBaseUrl;
  static const String stagingBaseUrl = productionBaseUrl;
}
```
- `ApiEndpoints` holds relative paths only (`/auth/login`, `/services`, `/appointments/{id}/cancel`, ...), never a full URL.
- Dio gets `baseUrl` from `AppConfig` through get_it. No widget, bloc or repository ever sees a URL.
- Release APK: `flutter build apk --release --flavor production --target lib/main_production.dart`
- Verify `android.permission.INTERNET` is in the MAIN AndroidManifest so the release build can reach the API.

## Networking and error handling
- Timeouts: connect 60s and receive 60s, because the production server sleeps when idle and the first request can take 30-50 seconds. The AI chat call may override receive timeout to about 30s.
- On app start (splash), fire `GET /health` in the background to wake the server, and show a friendly "Waking up the server..." hint if it takes longer than a few seconds.
- All API responses use `{ success, data?, message?, meta?, errors? }`. Parse them in `api_envelope.dart`, not in widgets.
- Map every failure into a sealed `Failure` carrying a user-showable `message`:
  - `ValidationFailure` (422): carries `fieldErrors: Map<String, List<String>>` so forms show messages under the right field
  - `UnauthorizedFailure` (401)
  - `NotFoundFailure` (404), `ConflictFailure` (409), `RateLimitFailure` (429)
  - `ServiceUnavailableFailure` (502/503, used by AI chat)
  - `NetworkFailure` (no connection, timeout), `ServerFailure` (500 and unknown)
- Show the API's `message` to the user as is (it is already friendly). Use LocaleKeys only for the app's own texts.
- 401 handling: if a PROTECTED request returns 401, clear the stored token and send the user to the login screen. A 401 from `POST /auth/login` is a normal "wrong credentials" error and must NOT log anyone out. Implement this once in `auth_interceptor.dart` + AuthBloc, not per screen.
- Never log tokens, passwords or full response bodies. Debug logging only in the development flavor.

## Domain rules from the API (docs/API.md) that the UI must respect
- Time: the API sends UTC ISO 8601. Always `DateTime.parse(...).toLocal()` for display. When sending, use `toUtc().toIso8601String()`. For booking, send `startTime` exactly as received from the availability response. The availability `date` param is a plain `yyyy-MM-dd` built from the picked calendar day (not a UTC conversion).
- Price is a STRING with two decimals in BDT (e.g. "500.00"). Entities hold it as `double` (parsed in the model); display through `price_formatter.dart`.
- Booking flow: list services -> detail -> pick date -> availability -> POST appointment -> confirmation -> My Bookings. Disable slots with `available: false`. Disable the Book button while the request is in flight. On 409, show the message and reload availability.
- Appointment statuses: PENDING, CONFIRMED, CANCELLED, COMPLETED. Only PENDING can be cancelled: show the Cancel button only then, and confirm with a dialog first.
- My Bookings has two tabs: Upcoming (`?type=upcoming`) and Past (`?type=past`).
- Services list: pagination (`page`, `limit`, `meta.totalPages`), debounced search (about 300 ms), category chips from `/services/categories`, a featured section (`?featured=true`), and filter by price range.
- Email cannot be changed (read-only on the profile). Password rules: 8-72 characters, at least one letter and one number. Validate on the client with the same rules.
- AI chat: keep the conversation in the chat bloc state, send previous turns as `history` (oldest first, last 10 is enough), limit input to 500 characters, show a typing indicator, show `suggestedServices` as tappable chips that open the service detail, and handle 429/502/503 with a retry bubble.
- Logout has no endpoint: delete the stored token and reset blocs.
- Persistent session: on splash, if a token exists call `GET /users/me`. 200 -> home, 401 -> clear token and go to login.

## State management (BLoC)
- Use `Cubit` for simple state, `Bloc` with events where events add clarity (auth, services list with search/pagination).
- States use Equatable and a clear shape: a status enum (`initial, loading, success, failure`) plus the data and an optional `Failure`, with `copyWith`. Keep states immutable.
- Blocs depend only on use cases (never on repositories, Dio, or storage directly).
- Provide blocs with `BlocProvider` at the lowest sensible level (page level for page state; app level only for auth). Create them through get_it.
- Use `BlocBuilder` for UI and `BlocListener` for one-off effects (snackbars, navigation). Use `buildWhen` / `listenWhen` to avoid needless rebuilds.
- Every screen handles: loading (skeleton or spinner), empty (EmptyView), error (ErrorView with retry), success.

## Navigation (go_router)
- All paths and names live in `app_routes.dart`. No string literals in widgets.
- Routes: `/splash`, `/login`, `/register`, a bottom-navigation shell (StatefulShellRoute) with Home `/home`, My Bookings `/bookings`, Assistant `/assistant`, Profile `/profile`, plus `/services/:id`, `/services/:id/book`, `/bookings/:id`, `/booking-confirmation`, `/profile/edit`, `/profile/change-password`.
- `redirect` is driven by the AuthBloc state through a refresh listenable: unauthenticated users go to `/login`, authenticated users never see `/login` or `/register`, and `/splash` resolves the session.
- Pass ids (not whole objects) through routes and load by id, or use `extra` only for optimistic display.

## Localization (easy_localization)
- Languages: `en` (default and fallback) and `bn`. Files: `assets/translations/en.json`, `assets/translations/bn.json`, registered in pubspec assets. Add `ios/Runner/Info.plist` CFBundleLocalizations (en, bn).
- Wrap the app with `EasyLocalization`, set supported locales and fallback, and add the delegates to `MaterialApp.router`.
- Use generated keys everywhere: `LocaleKeys.auth_login_title.tr()`. Generate with:
  `dart run easy_localization:generate -S assets/translations -O lib/core/localization -o locale_keys.g.dart -f keys`
- Group keys by feature (`auth.`, `services.`, `appointments.`, `profile.`, `assistant.`, `common.`, `errors.`). Use named arguments for dynamic values.
- Provide a language switcher in Profile. Persist the choice (easy_localization does this by default).
- Server messages are English and shown as received.
- Dates and numbers use `intl` with the active locale.

## Theme and design system
- Material 3, `ColorScheme.fromSeed`, with light and dark themes (follow the system by default).
- `app_colors.dart`, `app_text_styles.dart` and `app_spacing.dart` are the only places that define raw values. Widgets read from `Theme.of(context)` and the spacing/radius tokens.
- Define component themes centrally: AppBar, ElevatedButton/FilledButton, OutlinedButton, InputDecoration, Card, Chip, NavigationBar, SnackBar, Dialog.
- Status colors come from `status_colors.dart` (PENDING, CONFIRMED, CANCELLED, COMPLETED), always paired with a text label, never color alone.
- Responsive: use `LayoutBuilder`/`MediaQuery` and max-width constraints so tablets look right; never fixed pixel layouts; support text scaling without overflow; use `SafeArea` and keyboard-aware scrolling on forms.
- Reusable widgets live in `core/widgets`. If the same UI appears twice, extract it.
- Accessibility basics: tap targets of at least 48dp, semantic labels on icon buttons, sufficient contrast.

## Code quality and best practices
- Naming: files in snake_case, one public class per file, suffix by role (`_bloc`, `_state`, `_event`, `_repository`, `_repository_impl`, `_remote_data_source`, `_model`, `_page`).
- Models use json_serializable; run `dart run build_runner build --delete-conflicting-outputs`. Models convert to entities with `toEntity()`; entities never know about JSON.
- No business logic in widgets. No `BuildContext` use across async gaps without a mounted check.
- Prefer `final`, `const`, and sealed classes; avoid `dynamic` and force-unwraps (`!`).
- Handle every `Either` explicitly. Do not swallow errors.
- Dispose controllers, timers and subscriptions.
- Debounce search; cancel stale requests where it matters.

## Testing
- Use `bloc_test` + `mocktail`.
- Required: tests for every Bloc/Cubit (success, failure and key transitions), tests for repository implementations (success, each failure mapping), and tests for `validators.dart`, `price_formatter.dart` and `date_formatter.dart`.
- A few widget tests for shared widgets and the login form are a plus if time allows.
- Run with `very_good test --coverage`. Keep `flutter analyze` at zero issues.

## Demo data
Demo account (seeded on the backend): demo@example.com / Demo1234. It has bookings in all four statuses, so every My Bookings state can be shown.

## Deliverables
- Working Android APK: `flutter build apk --release --flavor production --target lib/main_production.dart` (and a note in the README on where to download it).
- README.md: overview, screenshots of the main screens, architecture (folder tree and the dependency rule), tech choices and why, flavors and environment setup, how to run, build the APK, run tests, the backend repo link, demo credentials, and the demo video link.
- Meaningful commit history.

## Build order (do ONE step at a time, then stop and summarize)
Every step from 3 onward ends with: analyzer clean, tests passing, loading/empty/error/success states handled, one commit.
1. Plan: propose the file list per step, the Failure hierarchy, the route table, and the BLoC state shapes. Wait for approval.
2. Foundation: template cleanup, env/flavors/AppConfig, constants, theme, localization setup (en + bn), shared widgets, Dio client + interceptor + error mapping, token storage, get_it, router skeleton with placeholder pages, app shell with bottom navigation. Commit.
3. Auth: splash with session check and server wake-up, register, login, logout, AuthBloc, redirect logic, 401 handling. Commit.
4. Services: home (featured + list), search, category chips, price filter, pagination, service detail. Commit.
5. Booking: date picker, availability slots, create appointment, 409 handling, confirmation screen. Commit.
6. My Bookings: Upcoming/Past tabs, detail screen, cancel (PENDING only, with confirm dialog). Commit.
7. Profile: view, edit (name, phone), change password, language switcher, logout. Commit.
8. AI assistant: chat screen, typing indicator, suggested service chips, error/retry bubbles. Commit.
9. Polish: empty/error/loading consistency, dark mode check, text scaling and small-screen check, accessibility pass, Bengali translation review. Commit.
10. Release: build the production APK, README with screenshots, final analyze and test run. Commit.
