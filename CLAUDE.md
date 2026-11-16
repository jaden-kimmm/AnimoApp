# CLAUDE.md

Notes for Claude Code on the Animo repo. (`README.md` is the public/human-facing description; this file is the working knowledge.)

## What this is
Animo: SwiftUI iOS prototype of an emotion-based running companion. Front-end only, all data is hardcoded mock data (Los Angeles / "Echo Park Run", fake stats, simulated run timer). No networking, persistence, HealthKit, or CoreLocation yet. ~2,000 lines of Swift, 23 files.

## Build / run
- Open `AnimoApp.xcodeproj`, scheme **Animo**. Bundle ID `swiftUI.Test.Animo`.
- Deployment target is **iOS 26.0** (raised from 18 to allow Liquid Glass) and `SWIFT_VERSION = 5.0` in the pbxproj. Liquid Glass APIs (`.glassEffect()`, `GlassEffectContainer`, `.glass` button styles) can be used without `#available` checks. Design changes to adopt glass are being decided incrementally with the user.
- A `LiveActivityExtension` scheme is checked in, but there is no extension source in the repo. Treat it as a leftover unless the user says otherwise.
- No tests, no packages, no CI. Verify UI changes via `#Preview` or the iOS Simulator tools.
- `.gitignore` ignores `.cursor/` and everything in `*.xcodeproj` except `project.pbxproj` and `xcshareddata`.

## Architecture
- `Animo/App/AnimoApp.swift`: `@main`, wraps `ContentView` on `AppColor.bg`.
- `Animo/App/ContentView.swift`: the **whole navigation model**. A `@State route: AppRoute` enum switched in `body` (no NavigationStack). Flow:
  `landing → onboarding → home → loading (1.2s auto) → afterHome (SelectedRun) → running → afterRunComplete → home`
  Shared state lives here: `selectedEmotion`. Screens receive it plus closure callbacks (`onStart`, `onBack`, `onEnd`, ...). The file also has a private `AppPreviewHost` that duplicates the switch for per-route `#Preview`s, so **a new route must be added in both places** (plus the `AppRoute` enum and a preview).
- `Animo/DesignSystem/`: `AppColor`, `TextStyle` + `Text.textStyle(_:)`, `Color(hex:)`, `PrimaryButton` (`.black`/`.white`), `SelectablePill`.
- `Animo/Features/<Area>/`: Landing, Onboarding, Home, Running, SelectedRun, AfterRun.

## Core concept: `Emotion`
`enum Emotion { angry, stressed, anxious, tired, happy }` is defined in `Home/EmotionBackgroundView.swift`. Its accent color + `angularGradient` are in `SelectedRun/Emotion+Style.swift`; `displayName` is an extension at the bottom of `Home/HomeView.swift`. Nearly every screen takes an `emotion` and tints itself with `emotion.color` and `EmotionBackgroundView` (two big blurred, "breathing" circles at top/bottom edges). When adding an emotion, update all three files.
- Each emotion has two tones: `color` (vivid; the glow, and by the user's choice also the route line and position dot in `RouteView`, on Running and AfterRun) and `ink` (deep, ≥3:1 over the light background; currently unused). The user prefers the vivid `color` for routes even though yellow and green are low-contrast (~1.3:1) on the light screen; don't switch them back to `ink` unprompted. A new emotion still needs both tones.

## Route visuals
`RouteShape` (route1...route5, in `RouteGradientView.swift`) maps to asset names `routeN_fill` / `routeN_stroke` under `Assets.xcassets/Routes/{Fill,Stroke}`. Routes are drawn by masking an emotion-colored fill/gradient with those images (fill at 10% opacity + stroke). Three variants: `RouteGradientView` (angular gradient, SelectedRun), `RouteFillView` (flat, AfterRun), `RouteGradientRunningView` (1000pt design canvas scaled to fit, with a dot, Running). Only `.route1` is actually used.

## Conventions
- Fonts: OverusedGrotesk (Book + Roman), registered in `Animo/Info.plist` `UIAppFonts`. Always use `.textStyle(.display/.headline/.body/.label)`, not raw `.font`.
- Colors via `AppColor.*` (defined in `DesignSystem.swift`); emotion colors via `emotion.color`. Background is `#F7F7F7`. Minimalist black/white UI over soft color glow.
  - Use role tokens, not raw colors: text is `textPrimary` / `textSecondary` / `textOnDark` / `textOnDarkMuted`; photo overlays are `scrimLight` / `scrimLightSoft` / `scrimDark` / `scrimDarkSoft`; also `separator`, `hairline`, `routeRemaining`, `glassTintLight`, `shadow`. `AppColor.black` / `.white` are for solid fills and glass tints.
  - Don't write `Color.white` / `Color.black` or a new `.opacity(...)` on a color in a view; add a token instead. Allowed exceptions: `#Preview` backgrounds, `Color.clear`, and the `Color.white.opacity(0.001)` hit-test layer in `EmotionBackgroundView`.
  - Muted/secondary text is always `textSecondary`, never `textPrimary.opacity(...)`. The only remaining ad hoc color is the 0.05 black tint in the `HomeAccountSheet` preview host.
- Screens are padded 24pt on the left, right and bottom: always use `AppSpacing.screenMargin` (in `DesignSystem.swift`), never a literal 16/24. Don't copy a Figma frame's inner 16pt padding on top of it.
- Screens are padded 24pt horizontally; buttons are capsules (`PrimaryButton`, 50pt); big overlay cards use ~20pt continuous corners.
- The `blurFade` effect (blur 20/10 + opacity, 0.35s ease) is duplicated as **private** `BlurFade` modifiers in both `HomeView.swift` and `SelectedRun.swift` (different signatures). Don't assume a shared one exists.
- `.cursor/rules/swift-rule.mdc` (the user's rules): SwiftUI only, **MVVM with `ObservableObject`**, prefer structs for models, `lazy var` for expensive computed class properties. Current code has no view models (state is `@State` in views), so introduce VMs when adding real logic (tracking, data) rather than growing the views.
- Many views are long hand-written stacks with repeated "label + value" `VStack`s (SelectedRun, AfterRunComplete, RunningControl). A shared stat component would be a natural refactor if asked, but don't do it unprompted.

## Known loose ends / gotchas
- `ContentView` `onLogin` just prints; onboarding answers are only printed (`OnboardingFlowView`), never stored; `OnboardingFinishView` has a stray print; `HomeAccountSheet` has hardcoded user ("Jaden Kim") and a `// TODO: wire destinations`.
- `AfterRunComplete` copy is hardcoded ("You found joy!") regardless of emotion; `SelectedRun` note text and "Echo Park Run" are also fixed.
- `RunningControl`'s timer is simulated (`Timer.scheduledTimer`, starts at 12:44 / 2.40 mi), the "..." button is a no-op, and turn directions are fake.
- `EmotionBackgroundView.blob` computes an unused `end` point; `BlobSeed.duration/delay/end` are unused.
- `Run_BG` assets (Arts_District, Griffith_Park, Santa_Monica, Silver_Lake, Echo_Park) exist but only `Echo_Park_Run_Bg` is referenced.
- Uncommitted at time of writing: a whitespace-only change to `SelectedRun.swift` line 1.

## Working style for this repo
- Small, focused edits that match the existing look; keep previews working.
- Update the `AppRoute` switch + `AppPreviewHost` together.
- Don't hand-edit `project.pbxproj` unless necessary; new Swift files under `Animo/` are picked up by Xcode's synchronized folder group (verify before relying on it).
