# EasyBook App: Build Plan

This is the step 1 plan from CLAUDE.md. It lists, per step: the branch, the files, the Failure hierarchy,
the route table, the BLoC state shapes and the design direction (including the app logo).

## 0. Toolchain notes (found in the scaffold)

- Flutter 3.47.5 / Dart 3.13. The lints require Dart 3.13 constructor syntax (`const new(...)`), applied with `dart fix`.
- Material library: the template imported `package:material_ui/material_ui.dart`, but go_router, easy_localization
  and flutter_localizations all use the SDK's `package:flutter/material.dart`. Two Material libraries mean two
  different `MaterialApp`/`Theme` types (broken page transitions and missing localizations), so the app uses
  `package:flutter/material.dart` everywhere and `material_ui` was removed from pubspec.
- Kotlin was bumped from 2.2.10 to 2.2.20 (the minimum this Flutter version accepts for Android builds).
- `bloc_lint` is in the template. We keep it: `dart run bloc_tools:bloc lint .` must also stay clean.
- No image tool is needed for the logo: a small Python script (`tool/generate_icons.py`, Pillow) draws the icon
  and writes every Android and iOS icon size. No new Dart dependency (flutter_launcher_icons is not needed).

## 1. Branches (one per step)

The developer commits and pushes each branch. Each new branch starts from an up-to-date `main`.

| Step | Branch | Suggested commit |
|---|---|---|
| 1 | `docs/plan` | `docs: add project rules, API contract and build plan` |
| 2 | `feature/foundation` | `chore: foundation (flavors, theme, l10n, network, router, shell, app icon)` |
| 3 | `feature/auth` | `feat: auth (splash, login, register, logout, session restore)` |
| 4 | `feature/services` | `feat: services (home, search, filters, pagination, detail)` |
| 5 | `feature/booking` | `feat: booking (date, availability slots, create, confirmation)` |
| 6 | `feature/my-bookings` | `feat: my bookings (tabs, detail, cancel)` |
| 7 | `feature/profile` | `feat: profile (view, edit, change password, language, logout)` |
| 8 | `feature/ai-assistant` | `feat: AI assistant chat` |
| 9 | `chore/polish` | `chore: polish states, dark mode, a11y, Bengali review` |
| 10 | `chore/release` | `docs: README, screenshots, release APK` |

## 2. Design direction ("awesome and lucrative")

**Mood:** premium, calm, trustworthy. Lots of white space, big rounded cards, soft shadows, one vivid
gradient used sparingly for hero areas and primary buttons.

**Palette** (all in `app_colors.dart`)

| Token | Light | Dark | Use |
|---|---|---|---|
| `brandIndigo` (seed) | `#4F46E5` | same seed | ColorScheme.fromSeed |
| `brandViolet` | `#7C3AED` | `#8B5CF6` | gradient end |
| `accentCoral` | `#FF6B5A` | `#FF8A7A` | price tags, the logo's check, highlights |
| `surface` | `#F7F7FB` | `#0F1020` | page background |
| `card` | `#FFFFFF` | `#1A1B2E` | cards |
| status PENDING | amber `#F59E0B` | | chip + label |
| status CONFIRMED | indigo `#4F46E5` | | chip + label |
| status COMPLETED | green `#10B981` | | chip + label |
| status CANCELLED | slate `#94A3B8` | | chip + label |

**Brand gradient:** `#4F46E5 -> #7C3AED`, top-left to bottom-right. Used on: splash, login header,
home greeting header, primary button, logo.

**Typography:** Material 3 scale with tighter, bolder headlines (w700/w800, slight negative letter spacing)
and comfortable body text. Default font is the platform font (Roboto / SF), which also renders Bengali
correctly. (A bundled font like Plus Jakarta Sans is optional, see Open questions.)

**Shapes and spacing:** 4-pt grid (`xs 4, sm 8, md 12, lg 16, xl 24, xxl 32`), radius `sm 10, md 16, lg 24`,
pill-shaped chips and buttons, 52dp tall buttons and inputs.

**Signature UI pieces**
- Gradient header on Home with greeting ("Good morning, Ayesha"), a floating search bar overlapping it.
- Featured carousel: large image cards with a dark bottom gradient, name, duration and a coral price pill.
- Service grid/list cards with `Hero` image animation into the detail page.
- Detail page: collapsing `SliverAppBar` image, info chips (duration, category), sticky bottom "Book now" bar with price.
- Booking: horizontal 14-day date strip (day name + number), slot grid of pill buttons (selected = gradient,
  unavailable = faded with strike), sticky confirm bar.
- Confirmation: animated check in a gradient circle, ticket-style summary card.
- My Bookings: segmented tabs, ticket-style cards with a date block on the left and a status chip.
- Assistant: chat bubbles (user = gradient, assistant = card), three-dot typing animation, suggestion chips.
- Skeleton loaders (a small in-house shimmer widget, no dependency) instead of plain spinners on lists.
- Light and dark themes, following the system.

**App logo:** a rounded-square (squircle) icon filled with the brand gradient. Inside, a white calendar
(two binder rings on top) and a bold coral check mark where the date grid would be: "booked, easy".
Each flavor has its own background so test installs are easy to tell apart: production indigo -> violet,
staging dark slate, development teal -> green. Generated at 1024px by `tool/generate_icons.py`, written to:
- Android: `mipmap-*/ic_launcher.png` + adaptive icon (gradient background, vector foreground, themed-icon monochrome)
  and the launch screen (brand color + glyph)
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` (full-bleed, no transparency, as Apple requires)
- iOS launch screen (brand color + glyph). Inside the app the logo is drawn in code (`core/widgets/app_logo.dart`),
  so no image asset is needed.

## 3. Failure hierarchy (`core/error/failures.dart`)

```dart
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;           // user-showable (API message, or a localized fallback)
}
final class ValidationFailure extends Failure {        // 422
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
  final Map<String, List<String>> fieldErrors;         // "email" -> ["Enter a valid email address"]
}
final class UnauthorizedFailure extends Failure { ... }       // 401
final class NotFoundFailure extends Failure { ... }           // 404
final class ConflictFailure extends Failure { ... }           // 409
final class RateLimitFailure extends Failure { ... }          // 429
final class ServiceUnavailableFailure extends Failure { ... } // 502 / 503
final class NetworkFailure extends Failure { ... }            // no connection, timeouts
final class ServerFailure extends Failure { ... }             // 500, 400, 413, unknown
```

Data layer: data sources throw a single `ApiException(statusCode, message, fieldErrors)` or `NetworkException`
(`core/error/exceptions.dart`). `error_mapper.dart` turns a `DioException` into one of those, and each repository
converts them with one shared `mapExceptionToFailure()` function (so the mapping is written once and tested once).

401 flow: `AuthInterceptor` adds `Authorization: Bearer <token>`. When a response is 401 and the request was NOT
`/auth/login` or `/auth/register`, it clears the token and calls an `onUnauthorized` callback that AuthBloc listens to
(`AuthSessionExpired` event). The router redirect then sends the user to `/login`.

## 4. Route table (`core/router/app_routes.dart`)

| Name | Path | Screen | Access |
|---|---|---|---|
| splash | `/splash` | SplashPage (session check + server wake-up) | always |
| login | `/login` | LoginPage | guests only |
| register | `/register` | RegisterPage | guests only |
| home (shell tab 0) | `/home` | HomePage (featured + list + search + filters) | signed in |
| bookings (shell tab 1) | `/bookings` | MyBookingsPage (Upcoming / Past) | signed in |
| assistant (shell tab 2) | `/assistant` | AssistantPage | signed in |
| profile (shell tab 3) | `/profile` | ProfilePage | signed in |
| serviceDetail | `/services/:id` | ServiceDetailPage | signed in |
| bookService | `/services/:id/book` | BookingPage (dates + slots) | signed in |
| bookingConfirmation | `/booking-confirmation` | BookingConfirmationPage (`extra`: created Appointment) | signed in |
| bookingDetail | `/bookings/:id` | BookingDetailPage | signed in |
| editProfile | `/profile/edit` | EditProfilePage | signed in |
| changePassword | `/profile/change-password` | ChangePasswordPage | signed in |

Redirect rules (driven by `AuthBloc` through `GoRouterRefreshStream`):
- status `unknown` -> stay on `/splash`
- `unauthenticated` and not on login/register -> `/login`
- `authenticated` and on splash/login/register -> `/home`

Detail routes are full-screen (pushed above the shell, no bottom bar). The confirmation page gets the created
appointment through `extra`; if `extra` is missing (e.g. deep link) it redirects to `/bookings`.

## 5. BLoC state shapes

Shared: `enum Status { initial, loading, success, failure }` lives in each state file only where it is used
(no generic base class).

| Bloc / Cubit | Scope | State |
|---|---|---|
| `AuthBloc` | app | `AuthState { AuthStatus status (unknown, authenticated, unauthenticated), User? user }`. Events: `AuthSessionRequested`, `AuthLoggedIn(user)`, `AuthLogoutRequested`, `AuthSessionExpired`, `AuthUserUpdated(user)` |
| `SplashCubit` | page | `{ bool showWakeUpHint }` (true after 4 s without a health reply) |
| `LoginCubit` | page | `{ FormStatus status, Failure? failure }` (field errors come from `ValidationFailure`) |
| `RegisterCubit` | page | same shape as LoginCubit |
| `ServicesBloc` | page | `{ Status status, List<Service> services, int page, int totalPages, bool isLoadingMore, ServiceFilter filter (search, category, minPrice, maxPrice), Failure? failure }` + `hasMore` getter. Events: `ServicesStarted`, `ServicesSearchChanged` (debounced 300 ms with a stream transformer), `ServicesCategorySelected`, `ServicesPriceRangeChanged`, `ServicesNextPageRequested`, `ServicesRefreshed` |
| `FeaturedServicesCubit` | page | `{ Status status, List<Service> services, Failure? failure }` |
| `CategoriesCubit` | page | `{ Status status, List<String> categories, Failure? failure }` |
| `ServiceDetailCubit` | page | `{ Status status, Service? service, Failure? failure }` |
| `BookingCubit` | page | `{ DateTime selectedDate, Status availabilityStatus, Availability? availability, TimeSlot? selectedSlot, String notes, SubmitStatus submitStatus (idle, submitting, success, failure), Appointment? created, Failure? failure }`. On 409: show message, clear slot, reload availability |
| `MyBookingsCubit` (one per tab, `type` param) | page | `{ Status status, List<Appointment> appointments, Failure? failure }` |
| `BookingDetailCubit` | page | `{ Status status, Appointment? appointment, bool isCancelling, Failure? failure }` |
| `ProfileCubit` / `EditProfileCubit` / `ChangePasswordCubit` | page | `{ FormStatus status, Failure? failure }` (profile data comes from `AuthBloc.user`, updated with `AuthUserUpdated`) |
| `ChatBloc` | page (kept alive in the shell branch) | `{ List<ChatMessage> messages, bool isTyping, Failure? failure, String? lastFailedMessage }`. `ChatMessage { role (user, assistant, error), text, List<SuggestedService> suggestions }`. Events: `ChatMessageSent`, `ChatRetried` |

## 6. Files per step

### Step 2: Foundation (`feature/foundation`)
- Delete: `lib/counter`, `test/counter`, `lib/l10n`, `l10n.yaml`, `generate: true`
- `pubspec.yaml` (add the approved packages, `assets/translations/`, `assets/images/`)
- `lib/main_*.dart`, `lib/bootstrap.dart` (AppConfig, `EasyLocalization.ensureInitialized`, get_it setup)
- `lib/app/app.dart`, `lib/app/shell/app_shell.dart`
- `lib/core/config/{env,flavor,app_config}.dart`
- `lib/core/constants/{api_endpoints,app_constants,storage_keys}.dart`
- `lib/core/di/injection.dart`
- `lib/core/error/{failures,exceptions}.dart`
- `lib/core/network/{dio_client,auth_interceptor,error_mapper,api_envelope}.dart`
- `lib/core/storage/token_storage.dart`
- `lib/core/router/{app_router,app_routes,go_router_refresh_stream}.dart` + placeholder pages
- `lib/core/theme/{app_theme,app_colors,app_text_styles,app_spacing,status_colors,app_gradients}.dart`
- `lib/core/localization/locale_keys.g.dart`, `assets/translations/{en,bn}.json`
- `lib/core/utils/{date_formatter,price_formatter,validators,extensions}.dart`
- `lib/core/widgets/{app_button,app_text_field,loading_view,skeleton,error_view,empty_view,app_network_image,status_chip,section_header,app_logo}.dart`
- App names per flavor (Android `build.gradle.kts` resValue, iOS xcconfig `FLAVOR_APP_NAME`), INTERNET permission in the main manifest, `CFBundleLocalizations` en/bn
- `tool/generate_icons.py` + generated icons, `assets/images/logo.png`
- Tests: `validators`, `price_formatter`, `date_formatter`, `error_mapper`, `api_envelope`, `token_storage`, `auth_interceptor`, shared widgets smoke tests

### Step 3: Auth (`feature/auth`)
- `features/auth/data/{datasources/auth_remote_data_source, models/user_model, models/auth_result_model, repositories/auth_repository_impl}.dart`
- `features/auth/domain/{entities/user, entities/auth_result, repositories/auth_repository, usecases/{login,register,get_current_user,logout,wake_server,watch_session_expired}}.dart`
- `features/auth/presentation/bloc/{auth_bloc,auth_event,auth_state, login_cubit/state, register_cubit/state, splash_cubit/state}.dart`
- `features/auth/presentation/pages/{splash_page,login_page,register_page}.dart`
- `features/auth/presentation/widgets/{auth_header,login_form,register_form,password_field}.dart`
- Tests: repository impl, AuthBloc, LoginCubit, RegisterCubit, SplashCubit, login form widget test

### Step 4: Services (`feature/services`)
- data: `services_remote_data_source`, `service_model`, `paginated_services_model`, `services_repository_impl`
- domain: `service`, `paginated_services`, `service_filter`, repository, usecases `get_services`, `get_featured_services`, `get_categories`, `get_service_by_id`
- presentation: `services_bloc`, `featured_services_cubit`, `categories_cubit`, `service_detail_cubit`;
  pages `home_page`, `service_detail_page`; widgets `home_header`, `search_bar`, `category_chips`,
  `price_filter_sheet`, `featured_carousel`, `featured_service_card`, `service_card`, `service_card_skeleton`,
  `service_info_chips`, `book_now_bar`
- Tests: repository impl + all four blocs/cubits (search debounce, pagination, filters)

### Step 5: Booking (`feature/booking`)
- services feature: `availability`, `time_slot` entities, `availability_model`, usecase `get_availability`
- appointments feature: `appointments_remote_data_source`, `appointment_model`, `service_summary_model`,
  `appointments_repository_impl`, entities `appointment`, `service_summary`, `appointment_status`,
  usecase `create_appointment`
- presentation: `booking_cubit`; pages `booking_page`, `booking_confirmation_page`; widgets `date_strip`,
  `slot_grid`, `slot_chip`, `booking_summary_bar`, `ticket_card`
- Tests: repository impls, BookingCubit (409 reload, in-flight guard)

### Step 6: My Bookings (`feature/my-bookings`)
- usecases `get_appointments`, `get_appointment_by_id`, `cancel_appointment`
- presentation: `my_bookings_cubit`, `booking_detail_cubit`; pages `my_bookings_page`, `booking_detail_page`;
  widgets `booking_card`, `booking_list`, `cancel_booking_dialog`
- Tests: cubits, repository additions

### Step 7: Profile (`feature/profile`)
- data/domain: `profile_remote_data_source`, `profile_repository_impl`, usecases `update_profile`, `change_password`
- presentation: `edit_profile_cubit`, `change_password_cubit`; pages `profile_page`, `edit_profile_page`,
  `change_password_page`; widgets `profile_header`, `profile_menu_tile`, `language_sheet`, `logout_dialog`
- Tests: cubits, repository impl

### Step 8: AI assistant (`feature/ai-assistant`)
- data/domain: `chat_remote_data_source` (30 s receive timeout), `chat_reply_model`, `chat_repository_impl`,
  entities `chat_message`, `chat_reply`, `suggested_service`, usecase `send_chat_message`
- presentation: `chat_bloc`; page `assistant_page`; widgets `chat_bubble`, `typing_indicator`,
  `suggestion_chips`, `chat_input_bar`, `retry_bubble`, `assistant_welcome`
- Tests: ChatBloc (history trimming to 10, retry, 429/502/503), repository impl

### Steps 9 and 10
Polish pass and release (APK, README with screenshots), as in CLAUDE.md.

## 7. Open questions (need an answer before step 2)

1. **Font:** keep the platform font (no download, Bengali works everywhere), or bundle **Plus Jakarta Sans**
   for Latin text (downloaded from Google Fonts into `assets/fonts/`, Bengali falls back to the system font)?
2. **Extra packages:** none are required beyond the approved list. `flutter_native_splash` would give a branded
   native launch screen (before Flutter starts). Without it the native launch screen is plain brand color,
   followed by our animated Flutter splash. OK to skip it?
