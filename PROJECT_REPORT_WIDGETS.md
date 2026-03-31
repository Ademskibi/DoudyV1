Project Widgets & Functions Report

Scope: files under lib/features (scanned files listed below). For each widget file we list named functions/methods and a short note how they are used in widgets.

- Child Home
  - File: lib/features/home/screens/child_home_screen.dart
  - Widgets: `ChildHomeScreen` (Stateless), `_MainChoiceCard` (Stateful)
  - Functions / methods:
    - `build(BuildContext)` (ChildHomeScreen): constructs layout with two main `_MainChoiceCard` instances; navigates to `NumbersScreen` and `StoriesScreen` on taps.
    - `_onTapDown`, `_onTapUp`, `_onTapCancel` (in `_MainChoiceCardState`): local gesture handlers that adjust `_scale` for tap animation.
  - Usage: `_MainChoiceCard` encapsulates tappable choices; gesture helpers provide animated press feedback. Navigation callbacks are passed via `onTap`.

- Splash
  - File: lib/features/splash/splash_screen.dart
  - Widgets: `SplashScreen` (Stateful)
  - Functions / methods:
    - `initState()` and `_init()` (async): initialization and routing logic based on SharedPreferences and `AuthService` state; routes to `/login`, `/parent`, `/child`, or `/admin`.
    - `build(BuildContext)`: simple progress UI while `_init()` performs checks.
  - Usage: `_init()` contains app startup routing and auth polling; no UI callbacks besides `build`.

- Number Card
  - File: lib/features/home/widgets/number_card.dart
  - Widgets: `NumberCard` (Stateful)
  - Functions / methods:
    - `_tapDown`, `_tapUp` (gesture handlers): change `_scale` for tap animation.
    - `build(BuildContext)`: shows number with color gradient; uses `onTap` callback when tapped.
  - Usage: used on `NumbersScreen` as tappable cards representing numbers.

- Register Screen
  - File: lib/features/auth/screens/register_screen.dart
  - Widgets: `RegisterScreen` (Stateful)
  - Functions / methods:
    - `build(BuildContext)`: contains form fields, dropdown, and the `onPressed` async handler for registration which calls `AuthService.signUpWithEmail` and routes based on chosen role.
    - `StringExt.capitalize()` extension: utility used to present role strings.
  - Usage: form submission triggers auth service and navigation.

- Game Card
  - File: lib/features/home/widgets/game_card.dart
  - Widgets: `GameCard` (Stateful)
  - Functions / methods:
    - Gesture handlers in `build`: inline `onTapDown`, `onTapUp`, `onTapCancel` that mutate `_elevation` for visual press effect.
    - `build(BuildContext)`: renders a card with icon, title and forward arrow; `onTap` calls `widget.onTap`.
  - Usage: used on `GameSelectionScreen` to list games and navigate to game screens.

- Login Screen
  - File: lib/features/auth/screens/login_screen.dart
  - Widgets: `LoginScreen` (Stateful)
  - Functions / methods:
    - `build(BuildContext)`: contains login form and two handlers:
      - Email/password login `onPressed` async: calls `AuthService.signInWithEmail`, polls `auth.appUser`, then routes by role.
      - Google sign-in handler (outlined button): calls `AuthService.signInWithGoogle` and routes similarly.
  - Usage: authentication entry points for users; shows loading states and snackbars on errors.

- Admin Dashboard
  - File: lib/features/home/screens/admin_dashboard.dart
  - Widgets: `AdminDashboard` (Stateless)
  - Functions / methods:
    - `build(BuildContext)`: renders admin UI and an `IconButton` that calls `auth.signOut()`.
  - Usage: simple admin landing with sign-out action.

- Numbers Screen
  - File: lib/features/home/screens/numbers_screen.dart
  - Widgets: `NumbersScreen` (Stateless)
  - Functions / methods:
    - `build(BuildContext)`: builds a `GridView.builder` of `NumberCard` items; checks `StoryProgressService.isUnlocked(index)` to enable taps and navigate to `GameSelectionScreen`.
  - Usage: presents number tiles and conditions taps on story progress.

- Game Selection
  - File: lib/features/home/screens/game_selection_screen.dart
  - Widgets: `GameSelectionScreen` (Stateless)
  - Functions / methods:
    - `build(BuildContext)`: defines `games` list mapping title/icon to game widget instances; `itemBuilder` creates `GameCard` widgets whose `onTap` pushes respective game screens.
  - Usage: acts as a router between number selection and concrete game screens.

- Parent Home
  - File: lib/features/home/screens/parent_home_screen.dart
  - Widgets: `ParentHomeScreen` (Stateless)
  - Functions / methods:
    - `build(BuildContext)`: shows parent info and `IconButton` that calls `auth.signOut()`.
  - Usage: parent landing page with sign-out.

- Story Video Screen
  - File: lib/features/home/screens/story_video_screen.dart
  - Widgets: `StoryVideoScreen` (Stateless)
  - Functions / methods:
    - `build(BuildContext)`: shows video placeholder and a button whose `onPressed` calls `StoryProgressService.markWatched(number)` then pops navigation if possible.
  - Usage: marks a story as watched and updates progress service.

- Stories Screen
  - File: lib/features/home/screens/stories_screen.dart
  - Widgets: `StoriesScreen` (Stateless)
  - Functions / methods:
    - `build(BuildContext)`: `GridView.builder` of story tiles; uses `StoryProgressService.isWatched(n)` to change appearance; taps push `StoryVideoScreen`.
  - Usage: lets users access stories; indicates watched state and navigates to `StoryVideoScreen`.

- Onboarding
  - File: lib/features/onboarding/screens/onboarding_screen.dart
  - Widgets: `OnboardingScreen` (Stateful)
  - Functions / methods:
    - `_finish()` async: writes `seenOnboarding` to SharedPreferences and routes to `/login` via `GoRouter`.
    - `build(BuildContext)`: page view with next/get started button that calls `_finish` on last page.
  - Usage: onboarding flow / persistent flag to skip on next start.

Notes & Quick Observations
- Common patterns: many widgets use small internal gesture handlers (`_tapDown`, `_tapUp`) for animated press effects.
- Navigation: `Navigator.of(context).push(MaterialPageRoute(...))` is used in many places; routing logic also uses `GoRouter` in auth/onboarding flows.
- Services: `AuthService` and `StoryProgressService` are consulted by multiple screens for routing and gating content.

Next steps available
- Expand the report to include every function in `lib/` (not just `lib/features`).
- Add cross-reference: where a service method (e.g., `AuthService.signInWithEmail`) is defined and all call sites.

Report file: PROJECT_REPORT_WIDGETS.md
