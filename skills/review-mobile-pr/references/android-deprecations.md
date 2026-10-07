# Android deprecations & platform changes (2026)

Flag **newly added** usage of anything below. Context: Google Play requires new apps/updates to target **API 36 (Android 16)** from Aug 31, 2026 (existing apps: API 35 minimum). **Android 17 (API 37, "Cinnamon Bun") already shipped June 16, 2026** — devs can target it today even though Play's mandate for API 37 isn't expected until ~Aug 2027 (same annual cadence as 34→35→36). Treat the API 37 rows below as live, not speculative.

## Android 16 / API 36 behavior changes & deprecations

| Newly added usage of… | Status | Replacement / note | Severity |
|---|---|---|---|
| `screenOrientation` manifest locks, `setRequestedOrientation()`, `resizeableActivity=false`, min/max aspect-ratio restrictions | **Ignored on large screens (sw ≥ 600dp) when targeting API 36+; Android 17/API 37 removes the temporary opt-out entirely — unconditionally enforced, no exceptions** | Build adaptive layouts (`WindowSizeClass`, canonical layouts) instead of locking orientation | 🔴 |
| `announceForAccessibility()` | Deprecated | Use semantics-based live regions / `AccessibilityNodeInfo` alternatives per the API docs | 🟡 |
| `AccessibilityNodeInfo.setLabeledBy` / `getLabeledBy` | Deprecated in API 36 | `addLabeledBy` / `removeLabeledBy` / `getLabeledByList` | 🟡 |
| `elegantTextHeight` attribute | Deprecated; **ignored when targeting API 36** | Remove; verify layouts for Arabic/Thai/Tamil etc. tall scripts | 🟡 |
| Opting out of edge-to-edge (`windowOptOutEdgeToEdge`, legacy status-bar color APIs) | Edge-to-edge is enforced for apps targeting API 36; opt-out removed | `enableEdgeToEdge()` + `windowInsetsPadding` / `WindowInsets` APIs | 🟠 |
| `PendingIntent` without `FLAG_IMMUTABLE`/`FLAG_MUTABLE` | Crash on API 31+ | Add `PendingIntent.FLAG_IMMUTABLE` unless mutability is required | 🔴 |
| Broad implicit intents relying on lenient resolution | API 36 tightens implicit-intent resolution | Prefer explicit intents; validate receiving component | 🟠 |
| Writable-then-executed dynamically loaded code (DEX/JAR, and **native `.so` libraries as of API 37**) | API 36 requires DEX/JAR marked read-only before execution; API 37 extends the same Safer Dynamic Code Loading protection to native libraries | `setReadOnly()` before loading; avoid writing-then-`dlopen`ing native code at runtime | 🔴 |
| `AsyncTask`, `Loader`s, `IntentService`, `Handler()` no-arg ctor | Long deprecated | Coroutines/`WorkManager`, `Handler(Looper.getMainLooper())` | 🟡 |
| `startActivityForResult` / `onActivityResult`, `requestPermissions` overrides | Deprecated | Activity Result APIs (`registerForActivityResult`) | 🟡 |
| `SharedPreferences` for new preference storage | Superseded | Jetpack DataStore (Preferences or Proto) | 🟡 |
| `kapt` for new annotation processors | Maintenance mode | KSP | 🟡 |
| `LiveData` in new code | Superseded | `StateFlow`/`SharedFlow` (+ `asLiveData()` only at legacy boundaries) | 🟡 |
| `android.preference.*`, `PreferenceManager` | Deprecated | AndroidX Preference / DataStore | 🟡 |
| Back handling via `onBackPressed()` override | Deprecated | `OnBackPressedDispatcher` / predictive back (`android:enableOnBackInvokedCallback`) — Android 16 extends predictive back to 3-button nav | 🟠 |

## Android 17 / API 37 behavior changes (new — verify any diff that bumps `targetSdk` to 37, or already targets it)

| Newly added usage of… | Status | Replacement / note | Severity |
|---|---|---|---|
| `ActivityOptions.setPendingIntentBackgroundActivityStartMode(MODE_BACKGROUND_ACTIVITY_START_ALLOWED)` (legacy blanket BAL opt-in) | Superseded at API 37 | Granular constants: `MODE_BACKGROUND_ACTIVITY_START_ALLOW_IF_VISIBLE` etc. — pick the narrowest that fits | 🟡 |
| Background audio playback, focus requests, or volume changes from a non-visible component | Strictly enforced at API 37 target — requires a foreground service | Use `MediaSessionService` + a proper foreground service declaration for background audio | 🟠 |
| Reflection-based mutation of `static final` fields (`Field.setAccessible` + `set`) | No longer permitted targeting API 37 | Refactor to a mutable holder/property if the value must change; don't rely on reflection to patch constants | 🟠 |
| Discovering devices on the local network (mDNS/NSD, direct socket/broadcast scans, printers, Chromecast, IoT) | Requires the `ACCESS_LOCAL_NETWORK` permission at API 37 | Declare `android.permission.ACCESS_LOCAL_NETWORK` and request it at runtime before LAN discovery | 🟠 |
| Reading `ACCOUNT_NAME` / `ACCOUNT_TYPE` / `ACCOUNT_TYPE_AND_DATA_SET` from the Contacts Provider data view | Removed at API 37 target | Query the `RawContacts` table for account info instead | 🟡 |

**Behavior changes with no direct API replacement — verify the diff still behaves correctly, don't just grep for a banned symbol:**
- Certificate Transparency is enforced by default at API 37 target — a new network call to a privately-issued cert (internal API, staging, on-prem, corporate CA never submitted to a CT log) will fail to connect. Flag new endpoints added against internal/staging hosts.
- `BluetoothSocket`'s RFCOMM `InputStream.read()` now returns `-1` on disconnect at API 37 target instead of throwing — new connection-loss handling written expecting an exception will silently misbehave.
- SMS auto-read (OTP autofill via direct SMS read, not the SMS Retriever API) faces a new 3-hour delay at API 37 target — a new OTP flow relying on immediate direct SMS read will feel broken; prefer the SMS Retriever API/Credential Manager OTP flow, which isn't delayed.
- Encrypted Client Hello (ECH) is opportunistically used for TLS at API 37 target — informational, but a new certificate-pinning or DPI-dependent network debugging path may need re-verification.

## Compose & AndroidX supersessions

| Newly added usage of… | Status | Replacement | Severity |
|---|---|---|---|
| `collectAsState()` on Android UI flows | Superseded | `collectAsStateWithLifecycle()` (lifecycle-aware; stops collection in background) | 🟡 |
| Material 2 (`androidx.compose.material.*`) components in new UI | Superseded | Material 3 (`androidx.compose.material3.*`) equivalents | 🟡 |
| Accompanist libraries that were upstreamed (SystemUiController, Pager, FlowLayout, Navigation-Material, Permissions where applicable, Placeholder…) | Deprecated/archived | Core Compose equivalents: `enableEdgeToEdge()`+insets, `androidx.compose.foundation.pager`, `FlowRow`/`FlowColumn`, `material-navigation`, etc. | 🟡 |
| String-route Navigation-Compose in new graphs | Superseded | Type-safe navigation (serializable route objects) or the project's typed-nav wrapper | 🟡 |
| `LocalLifecycleOwner` from `androidx.compose.ui.platform` | Moved | Import from `androidx.lifecycle.compose` | 🟢 |
| `rememberRipple()` | Deprecated | `ripple()` indication API | 🟢 |
| `Divider` (material3) | Deprecated | `HorizontalDivider` / `VerticalDivider` | 🟢 |

If the diff uses an API you don't recognize or you're unsure whether it's been deprecated since this file was written, search the web before commenting.
