# DOUDY — Project Report (summary)

Overview
- **Project**: DOUDY (Flutter app for children + parents)
- **Location**: workspace root
- **Main areas**: auth/onboarding/splash, parent UI, child UI, games, shared widgets/services

Screens / Pages (summary)

- **SplashScreen**: File: [lib/features/splash/splash_screen.dart](lib/features/splash/splash_screen.dart)
  - Purpose: app startup and routing. Uses `SharedPreferences`, `Provider` `AuthService` and `GoRouter` to route to `/login`, `/parent`, `/child`, or `/admin` based on saved onboarding flag and user role.
  - Notes: waits briefly for `auth.appUser` before routing; contains retry/timeouts.

- **OnboardingScreen**: File: [lib/features/onboarding/screens/onboarding_screen.dart](lib/features/onboarding/screens/onboarding_screen.dart)
  - Purpose: 4-page onboarding flow. Persists `seenOnboarding` in `SharedPreferences` and navigates to `/login` on finish.

- **Auth: Login / Register**:
  - Login: [lib/features/auth/screens/login_screen.dart](lib/features/auth/screens/login_screen.dart)
    - Uses `AuthService` (Provider), supports email/password and Google sign-in, then routes by `appUser.role` to `/parent` or `/child`.
  - Register: [lib/features/auth/screens/register_screen.dart](lib/features/auth/screens/register_screen.dart)
    - Sign-up form, chooses role (`parent`/`child`/`admin`), on success routes accordingly.

- **ParentHomeScreen**: File: [lib/features/home/screens/parent_home_screen.dart](lib/features/home/screens/parent_home_screen.dart)
  - Purpose: simple parent dashboard; shows parent name from `AuthService` and a sign-out button.

- **ChildHomeScreen**: File: [lib/features/home/screens/child_home_screen.dart](lib/features/home/screens/child_home_screen.dart)
  - Purpose: child landing page with activity choice cards (e.g., `NumbersScreen`, stories placeholder).
  - Navigation: pushes `NumbersScreen` and a stories placeholder.

- **NumbersScreen**: File: [lib/features/home/screens/numbers_screen.dart](lib/features/home/screens/numbers_screen.dart)
  - Purpose: grid of numbers (0–9). Tapping a number opens a `GameSelectionScreen` for that number.

- **Games** (in `lib/games/`) — each is a self-contained screen with game logic, feedback UI, and sound:
  - `BallGameScreen` — [lib/games/ball_game.dart](lib/games/ball_game.dart)
    - Mechanic: moving ball with timer; select target number before timeout. Uses `GameScaffold`, `GameNumberButton`, `FeedbackOverlay`, `SoundService`.
  - `JumpNumbersGameScreen` — [lib/games/jump_numbers_game.dart](lib/games/jump_numbers_game.dart)
    - Mechanic: find target number among choices; uses `GameScaffold` + overlays.
  - `PizzaGameScreen` — [lib/games/pizza_game.dart](lib/games/pizza_game.dart)
    - Mechanic: visual custom painter that draws pizza slices; choose how many slices.
  - `LogicoGameScreen` — [lib/games/logico_game.dart](lib/games/logico_game.dart)
    - Mechanic: pair/match numbers with counts; uses drag/select interactions.
  - `CardSortGameScreen` — [lib/games/card_sort_game.dart](lib/games/card_sort_game.dart)
    - Mechanic: draggable cards, timer-based rounds, drop target.
  - `ChairsGameScreen` — [lib/games/chairs_game.dart](lib/games/chairs_game.dart)
    - Mechanic: visual chairs + choose number of chairs; similar structure to other number games.

Shared patterns & services
- **AuthService**: central auth + appUser role handling; used across splash, auth screens, parent/home.
- **GameScaffold / FeedbackOverlay / SoundService**: common game UI pieces used by multiple game screens.
- **Responsive utilities**: `SizeConfig` and helpers used across games for responsive sizing.
- **GoRouter**: app navigation uses `GoRouter` for higher-level routes (`/login`, `/parent`, `/child`, `/admin`). Some screens still use `Navigator.push(MaterialPageRoute(...))` for local flows (e.g., `NumbersScreen` → `GameSelectionScreen`).

Notes & suggestions
- Many game screens share the same UX skeleton — consider consolidating repeated logic (init/restart/showGameOver) into a small game helper or base class to reduce duplication.
- Verify `GameSelectionScreen` and other referenced files (not listed in this summary) to map all possible navigation paths.
- Consider documenting app routes centrally (e.g., `app_router.dart`) — I saw `app_router.dart` in `/lib/core` which likely contains route definitions.

If you want, I can:
- Produce a more detailed per-file breakdown (public methods, key widgets, TODOs).
- Create a visual route map (graph) of navigation flows.
- Open and summarize the `GameSelectionScreen` and other referenced widgets.

Generated on: 2026-03-24
