# Expected — android-low-cap

Exercises step 5's LOW cap: seven seeded LOW findings, each in its own function so none folds into another comment, in a diff of under 200 reviewed lines (`low_cap=4`). At most 4 Low comments go inline; the rest belong in the body's "Minor findings not posted inline" list, which still counts as found.

## Must find
- id: scale-not-clamped | file: app/src/main/java/com/example/settings/SettingsViewModel.kt | line: ~23-26 | min severity: MEDIUM | `onFontScaleChanged` stores and persists any value; the intent promises 85%–130%, so an out-of-range scale (e.g. 0 from a slider) is saved.

## Should find
- id: unused-import | file: SettingsViewModel.kt | line: ~4 | `java.util.Locale` is imported but unused.
- id: redundant-tostring | file: SettingsViewModel.kt | line: ~28 | `.toString()` inside a string template is redundant.
- id: magic-number | file: SettingsViewModel.kt | line: ~30 | `1.15f` large-text threshold is an unnamed magic number.
- id: redundant-true-comparison | file: SettingsViewModel.kt | line: ~32 | `== true` on a non-null Boolean is redundant.
- id: redundant-local | file: SettingsViewModel.kt | line: ~34-37 | `isDarkMode` assigns to a local only to return it; an expression body would do.
- id: var-never-reassigned | file: SettingsViewModel.kt | line: ~40 | `var defaultScale` is never reassigned; should be `val` (or inlined).
- id: unused-private-fun | file: SettingsViewModel.kt | line: ~44 | `percentOf` is private and never called.

## Must not flag
- `onDarkModeToggled` and `SettingsStore` (unchanged).

## Max low comments: 4
