# Expected — ios-clean-refactor

A behavior-preserving iOS refactor large enough (over 30 changed lines) to dispatch the passes. Every output string is unchanged: the date format and `%.2f` total are the same, just moved. Measures false positives on Swift/SwiftUI.

## Must find

## Should find

## Must not flag
- "Missing tests" — no behavior changed.
- A `DateFormatter` created per call (pre-existing; moved, not introduced). Suggesting a cached formatter as a defect is a false positive (a static `DateFormatter` would also raise a Swift 6 non-`Sendable` global-state error).
- `%.2f` not being locale- or currency-aware (pre-existing; the string is identical to before).
- `totalText` going from inline to `static` internal (needed by `OrderTotals`).
- `OrderTotals` being `private`, or needing `@MainActor` (SwiftUI `View` bodies already run on the main actor).
- The pluralization ternary (unchanged, moved).

## Max low comments: 1
