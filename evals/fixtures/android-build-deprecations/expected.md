# Expected — android-build-deprecations

Exercises the Deprecation Scanner on build and manifest files: a targetSdk 36 bump that changes how already-deprecated APIs behave, plus build-tooling deprecations.

## Must find
- id: back-not-called | file: app/src/main/java/com/example/scan/ScannerActivity.kt | line: ~15-18 | min severity: HIGH | with targetSdk 36 (this PR), `onBackPressed()` is no longer called on Android 16+ (predictive back), so `camera.stop()` never runs when the user backs out; use `OnBackPressedDispatcher`/`OnBackPressedCallback` (or release the camera in a lifecycle callback).
- id: orientation-lock | file: app/src/main/AndroidManifest.xml | line: ~13 | min severity: MEDIUM | `android:screenOrientation="portrait"` is ignored on large screens (sw ≥ 600dp) when targeting API 36, which this PR now does.
- id: kotlin-options | file: app/build.gradle.kts | line: ~19-21 | min severity: MEDIUM | new `kotlinOptions { }` block is deprecated with error since Kotlin 2.2; use `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }`.

## Should find
- id: kapt-for-new-processor | file: app/build.gradle.kts | line: ~4 or ~27 | new annotation processor added through `kapt`; KSP is the replacement (Room supports it).

## Must not flag
- `MainActivity.kt` and `CameraSession.kt` (unchanged).
- The pre-existing `id("org.jetbrains.kotlin.android")` plugin line as newly added (it's unchanged context).
- The `versionCode`/`versionName` bump.

## Max low comments: 4
