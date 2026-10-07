# Android review reference (2026)

Apply to Kotlin/Compose/Gradle files. Only review lines present in the diff (`+` lines). Never flag pre-existing code.

Deprecation tables live in `android-deprecations.md` (read by the Deprecation Scanner pass).

## Table of contents

1. [Architecture & MVVM/MVI](#architecture--mvvmmvi)
2. [Jetpack Compose](#jetpack-compose)
3. [Coroutines & Flows](#coroutines--flows)
4. [Lifecycle awareness](#lifecycle-awareness)
5. [Dependency injection](#dependency-injection-dagger--hilt)
6. [Security](#security)
7. [Performance & memory](#performance--memory)
8. [Kotlin quality](#kotlin-quality)
9. [Navigation](#navigation)
10. [Background work, permissions & notifications](#background-work-permissions--notifications)
11. [Data persistence (Room & DataStore)](#data-persistence-room--datastore)
12. [Resources & localisation](#resources--localisation)
13. [Accessibility](#accessibility)
14. [Dependency / build hygiene](#dependency--build-hygiene)

---

## Architecture & MVVM/MVI

- ViewModel holds no reference to `Activity`, `Fragment`, `View`, or `Context` (use `@ApplicationContext` via Hilt if truly needed)
- UI state lives in `StateFlow`/`MutableStateFlow` in the ViewModel, not in `Activity`/`Fragment` fields
- Side effects flow through a `SharedFlow` or sealed `Effect` channel — never called directly from the ViewModel into UI
- `viewModelScope` used for ViewModel work; `lifecycleScope` / `repeatOnLifecycle` used for UI collection — never `GlobalScope`
- No business logic inside Composable functions or `Fragment`s; logic belongs in ViewModel or domain layer
- No direct repository/data-layer access from UI layer; routes through ViewModel
- `SavedStateHandle` used for state that must survive process death (navigation arguments, form input)
- Unidirectional data flow preserved: state flows down, events flow up — flag two-way mutable state passed deep into the tree

## Jetpack Compose

- **Recomposition stability**: lambdas passed to composables are stable (method references, `remember`ed, or created outside hot paths) to avoid recomposition on every call-site recomposition
- Types passed to composables are primitive, `@Stable`, `@Immutable`, or data classes of stable types — stdlib `List`/`Map` should be `ImmutableList`/`ImmutableMap` (kotlinx.collections.immutable) or wrapped
- `remember { }` for objects expensive to create that should survive recomposition; `rememberSaveable { }` for values that must survive configuration changes
- Side-effect APIs used correctly:
  - `LaunchedEffect(key)` for coroutine work tied to a lifecycle event or key change
  - `DisposableEffect` for resources that must be cleaned up (listeners, subscriptions)
  - `SideEffect` only for non-suspending synchronous side effects after every successful recomposition
  - No coroutine launches or side effects directly in a composable body outside these APIs
- `items(key = ...)` / `key()` used in `LazyColumn`/`LazyRow` to preserve item state on list changes
- Scaffold `paddingValues` from the content lambda actually applied — content otherwise renders under system bars
- `Modifier` chains ordered correctly: layout modifiers (size, padding) before drawing modifiers (background, border)
- State hoisted: composables receive state + event lambdas; no `MutableState` mutated from outside its owning scope
- `derivedStateOf { }` for computed values that depend on other state, to avoid unnecessary recompositions
- `collectAsStateWithLifecycle()` for flow collection (see deprecation table)
- New public composables have a `@Preview` (or the project's screenshot-test equivalent)
- No expensive work (I/O, parsing, sorting large lists) in the composition body — precompute in the ViewModel or `remember`

## Coroutines & Flows

- No `runBlocking` on the main thread; no blocking I/O on `Dispatchers.Main`
- `launch`/`async` always structured — no orphaned coroutines or fire-and-forget outside a meaningful scope
- `launch { }` blocks that can throw use `try/catch` or a `CoroutineExceptionHandler`
- `collect` vs `collectLatest`: `collectLatest` when only the latest emission matters and previous work should be cancelled (search, debounce); `collect` when every emission must be processed
- `StateFlow` for state (single current value, replayed); `SharedFlow` for one-shot events
- `flow { }` builders don't capture an outer coroutine scope — use `callbackFlow` for callback-based APIs
- `flowOn(Dispatchers.IO)` applied in the data layer, not repeated in the ViewModel; inject dispatchers rather than hardcoding for testability
- `combine`, `zip`, `flatMapLatest` chosen for the intended semantics — verify the operator matches
- No `Flow` collected inside another `Flow` builder (use `flatMapLatest`/`flatMapMerge`)
- `CancellationException` never swallowed by a broad `catch (e: Exception)` — rethrow it

## Lifecycle awareness

- `Activity`/`Fragment` context never stored in ViewModel, companion object, or app-lifetime singleton
- `repeatOnLifecycle(Lifecycle.State.STARTED)` when collecting flows from Views/Fragments
- `viewLifecycleOwner` (not `this`) when observing in fragments
- Listeners/callbacks/subscriptions set in `onStart`/`onResume` removed in the paired `onStop`/`onPause`
- `onSaveInstanceState` / `SavedStateHandle` for UI state that should survive rotation and process death

## Dependency injection (Dagger / Hilt)

- Correct scope: `@Singleton` app-scoped, `@ActivityRetainedScoped` ViewModel-lifetime, `@ViewModelScoped` per-ViewModel
- `@ApplicationContext` instead of raw `Context` in singletons
- No manual `DaggerXxxComponent.create()` in production code — Hilt entry points
- `@InstallIn` target matches the intended lifetime
- `@Binds` preferred over `@Provides` for interface-to-implementation binding

## Security

- No API keys, tokens, passwords, or secrets in source files, string resources, or `local.properties` committed to the repo
- `WebView`: `setJavaScriptEnabled(false)` unless required; `setAllowFileAccess(false)` unless required; no `addJavascriptInterface` with untrusted content
- External-component intents are explicit or validate the receiving app
- No tokens/PII in `Log.*` — debug-only logging guarded by `BuildConfig.DEBUG`
- Sensitive data not in plain `SharedPreferences` — `EncryptedSharedPreferences` or encrypted DataStore
- Deep link URIs validated before acting on host/path/query parameters
- Exported components (`android:exported="true"`) justified; new manifest entries default to non-exported
- Certificate pinning / network-security-config changes reviewed deliberately — never a blanket `cleartextTrafficPermitted="true"`

## Performance & memory

- No static references to `Activity`, `Fragment`, `View`, or `Context` subclass
- Bitmaps managed via Coil/Glide; no manual large-bitmap allocations
- `RecyclerView`/`LazyList`: `DiffUtil` or stable keys — no `notifyDataSetChanged()` except where documented
- Heavy computation off the main thread — `Dispatchers.Default`/`IO`
- No object allocations inside `draw()`/`onDraw()` — pre-allocate
- Overly frequent work in tight loops (JSON parsing, regex compilation) hoisted out
- `ViewModel` caches data that shouldn't be re-fetched on recomposition/rotation
- **Cold start**: no new eager work added to `Application.onCreate()` or a manifest-declared `ContentProvider`'s `onCreate()` — defer via `androidx.startup` (App Startup library) or lazy-init on first use; a new SDK/library init call added to `Application.onCreate()` is a common regression to flag
- **Main-thread blocking risk (ANR)**: a new `BroadcastReceiver.onReceive()`, `ContentProvider` method, or Activity lifecycle callback doing I/O, DB access, or unbounded work synchronously — these all run on the main thread and have no `runBlocking`/coroutine escape hatch by default
- **Baseline Profiles**: if this PR adds a new critical user journey (first launch, a hot navigation path) or a library that ships its own baseline profile rules, check whether `app/src/main/baseline-prof.txt` (or the `androidx.baselineprofile` Gradle plugin config) needs a corresponding update — a stale profile silently loses its speedup
- **Fragment/View leaks**: `ViewBinding`/`FragmentBinding` reference nulled in `onDestroyView()` (not just `onDestroy()`) — a binding held past `onDestroyView()` leaks the whole view hierarchy
- Listeners/observers registered on an app-lifetime singleton (analytics, a repository, an event bus) from a `Fragment`/`Activity`/`ViewModel` are unregistered on teardown — a singleton is exactly where one-way "forgot to unregister" leaks accumulate silently across process lifetime

## Kotlin quality

- `sealed` when variants carry different data; `enum` for simple constant sets
- `data class` for value types needing `equals`/`hashCode`/`copy` — not for classes with identity semantics or mutable state
- Extension functions don't break encapsulation
- `object` singletons not used for stateful classes that need testing or DI
- Null safety: no new `!!` — `?: return` / `?: error(...)` / `requireNotNull` with a message
- `when` on sealed types exhaustive — no trailing `else ->` that swallows future variants
- `inline`/`reified` where appropriate for generic utilities
- Scope functions (`apply`, `let`, `run`, `also`, `with`) used idiomatically, not chained to obscure intent
- **No FQN in place of imports**: inline fully-qualified names (`androidx.compose.runtime.remember(...)`) replaced with a top-level import — implementation, test, and preview files alike
- **Nullable parameters carry `= null` defaults** when always optional at every call site
- **`data class` with empty `{ }` body** — remove the body

## Navigation

- Deep link URIs validated before acting on parameters
- Back-stack manipulation (`popUpTo`, `launchSingleTop`) intentional — comment if non-obvious
- `NavController` not stored in ViewModel — navigation events emitted as effects, consumed in UI
- Type-safe args between destinations (see deprecation table for string routes)
- **Predictive back**: a new screen intercepting back (`PredictiveBackHandler`, `BackHandler(enabled = true)`, `OnBackPressedCallback`) only enables the callback while it's actually on top/visible — a callback left enabled after the screen is gone intercepts back gestures meant for the screen underneath
- A new in-progress predictive-back gesture animation/preview (`BackEventCompat` progress) is cancellable — verify the screen restores correctly if the user drags back and releases without completing the gesture, not just on a completed back

## Background work, permissions & notifications

- **WorkManager**: a new `WorkRequest` declares the constraints it actually needs (network type, battery, storage) rather than none; retry/backoff policy (`BackoffPolicy`) set deliberately, not left at the default when the work has a real reason to back off differently; a uniquely-scheduled work chain uses `enqueueUniqueWork`/`enqueueUniquePeriodicWork` with the policy (`REPLACE`/`KEEP`/`APPEND`) that matches intent — `REPLACE` on a periodic work silently drops in-flight state if chosen without thought
- **Foreground services**: a new `startForeground()` call declares a `foregroundServiceType` in the manifest matching the work (required since API 34, enforced with a `SecurityException` if missing/mismatched) — a new type added here should also appear in the runtime `startForeground()` call, not just the manifest
- **Runtime permissions**: a new permission request shows rationale before asking when `shouldShowRequestPermissionRationale()` is true (not just fires the system dialog cold); a denial path exists and degrades the feature rather than crashing or silently no-op-ing; a permanently-denied ("don't ask again") case is distinguished from a first-time denial and routes to Settings rather than looping the request
- **Notification channels**: a new notification posts through a channel created via `NotificationChannel` with an appropriate `importance` (not blanket `IMPORTANCE_HIGH`) — channel IDs are stable across app versions (changing one orphans the user's existing per-channel settings); new channels aren't created redundantly on every app launch (check for `getNotificationChannel()` first, or accept `createNotificationChannel()`'s built-in idempotency rather than adding a manual guard that can drift out of sync)

## Data persistence (Room & DataStore)

- **Room migrations**: a schema change (`@Entity` field added/removed/retyped) ships a corresponding `Migration` — not `fallbackToDestructiveMigration()` added to make a crash go away, unless data loss is genuinely acceptable and that's stated in the PR description; a new migration's `migrate()` actually runs the SQL needed for the diff (a common miss: adding a column to the entity but writing a migration that doesn't `ALTER TABLE`)
- **Room DAO/query correctness**: a new `@Query` with a `LIKE`/dynamic `WHERE` built from string concatenation instead of a bind parameter (`:param`) — SQL-injection-shaped even against a local DB, and breaks on special characters; a new suspend DAO function that should be a `Flow`/`PagingSource` for observability isn't a one-shot `suspend fun` if callers actually need to react to changes; `@Transaction` present on a DAO method that performs more than one dependent write/read
- **DataStore**: a new `Preferences` DataStore key collision (same string key, different type, across files) — silently returns the wrong type or throws at runtime, not compile time; a new Proto DataStore schema change is additive (new fields have defaults) rather than renumbering/removing existing field numbers, which corrupts previously-persisted data; DataStore reads/writes aren't wrapped in try/catch expecting a corruption `CorruptionException` when the PR introduces a new custom `Serializer`

## Resources & localisation

- No hardcoded user-visible strings — `strings.xml` with meaningful keys
- No hardcoded dimensions — `dimens.xml`, design tokens, or design-system `Dp` values
- No hardcoded colors outside a theme/design-system file
- Plurals via `plurals` resource, not `if (count == 1)` inline
- RTL: `start`/`end` not `left`/`right` in XML; `Arrangement.Start`/`End` in Compose
- Format-specifier escaping correct (`%%` for literal percent, positional args `%1$s` when multiple)

## Accessibility

- Interactive elements have `contentDescription` or `semantics { }`
- Decorative images: `contentDescription = null`
- Stateful components (toggle, checkbox, selection) expose `stateDescription`
- `Modifier.semantics(mergeDescendants = true)` groups related content
- Touch targets ≥ 48×48dp
- No `announceForAccessibility` in new code (see deprecation table)

## Dependency / build hygiene

- New dependencies go in the version catalog (`libs.versions.toml`) — not hardcoded in `build.gradle.kts`
- No duplicates already provided transitively
- ProGuard/R8 keep rules added for any reflection-heavy or serialization library introduced in this PR
- `isShrinkResources`/minification settings not weakened without justification
- New modules follow the project's convention plugins; AGP 9-era source-set config uses `kotlin.srcDir()` for Kotlin sources
- No `-SNAPSHOT` or dynamic (`+`) versions introduced
