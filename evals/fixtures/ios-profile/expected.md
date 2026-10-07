# Expected — ios-profile

## Must find
- id: off-main-publish | file: App/Profile/ProfileViewModel.swift | line: ~21-22 | min severity: HIGH | `ProfileViewModel` isn't `@MainActor`, so the nonisolated `async load()` mutates `@Published profile` (and calls `onLoaded`) off the main actor — UI state updated from a background thread / data race.
- id: swallowed-errors | file: App/Profile/ProfileViewModel.swift | line: ~20-21 | min severity: MEDIUM | `try?` on both the network call and the decode silently drops failures; the view shows "Loading…" forever with no error state.
- id: uncancelled-task | file: App/Profile/ProfileView.swift | line: ~13 | min severity: MEDIUM | `Task {}` in `onAppear` is never cancelled and re-fires on every appear; use `.task { }`.

## Should find
- id: observable-macro | file: ProfileViewModel.swift | line: ~9 | `ObservableObject`/`@Published`/`@StateObject` in new code on iOS 17+ → `@Observable` + `@State`.
- id: hardcoded-string | file: ProfileView.swift | "Loading…" not localized.

## Must not flag
- ProfileView.swift `onLoaded = { loadCount += 1 }` as a retain cycle / missing `[weak self]` — `ProfileView` is a struct.
- `#Preview` usage.
- `URL(string: "<literal>")!` at CRITICAL/HIGH — a constant literal URL.

## Max comments: 8
