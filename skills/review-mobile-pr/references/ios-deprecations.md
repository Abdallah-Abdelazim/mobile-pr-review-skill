# iOS deprecations & platform changes (2026)

Context: since **April 28, 2026**, every App Store upload must be built with the **iOS 26 SDK / Xcode 26** or later — no exceptions. Privacy Manifests (`PrivacyInfo.xcprivacy`) are mandatory, and "required reason" APIs need declared reasons. Swift 6 strict concurrency is the compiler default for new modules. iOS 26 unified Apple's OS versioning (iOS/iPadOS/macOS/watchOS/tvOS/visionOS all on the "26" cycle) — treat any codepath still branching on `#available` for the old numbering scheme (iOS 17/18) as still valid, but new `#available(iOS 26, *)` checks are the current baseline.

| Newly added usage of… | Status | Replacement / note | Severity |
|---|---|---|---|
| `UIWebView` | Removed; apps rejected | `WKWebView` | 🔴 |
| `ObservableObject` + `@Published` + `@StateObject`/`@ObservedObject`/`@EnvironmentObject` in **new** view models (iOS 17+ deployment target) | Superseded by the Observation framework | `@Observable` macro + `@State` (ownership) / plain property (passed) / `@Bindable` (two-way) / `@Environment` — gives property-level tracking and fewer re-renders. **Migration trap:** `@State` initializes its value on every view rebuild, unlike `@StateObject`'s lazy `@autoclosure` — flag expensive VM construction in the view initializer. | 🟡 |
| `NavigationView` | Deprecated | `NavigationStack` / `NavigationSplitView` with typed `NavigationPath` | 🟡 |
| `PreviewProvider` boilerplate in new previews | Superseded | `#Preview` macro | 🟢 |
| Old alert/sheet APIs (`Alert(title:…)`, `.alert(isPresented:content:)` returning `Alert`) | Deprecated | `.alert(_:isPresented:actions:message:)` builder APIs | 🟢 |
| `foregroundColor(_:)` | Deprecated | `foregroundStyle(_:)` | 🟢 |
| `.animation(_:)` (no value) | Deprecated (ambient animation) | `.animation(_:value:)` or `withAnimation { }` | 🟡 |
| `onChange(of:) { newValue in }` single-param | Deprecated iOS 17 | Two-parameter `onChange(of:) { old, new in }` or zero-param | 🟢 |
| `DispatchQueue`/GCD in new async code paths | Superseded | Swift Concurrency: `Task`, `async/await`, actors, `AsyncSequence`; `@MainActor` instead of `DispatchQueue.main.async` for UI hops | 🟡 |
| New Combine pipelines for one-shot async work | Not deprecated, but Apple investment is in Swift Concurrency | Prefer `async/await` / `AsyncSequence` for new code; Combine fine where the codebase is already Combine-based | 🟢 |
| Completion-handler APIs where an async overload exists (`URLSession.dataTask` vs `data(for:)`) | Superseded | Async overloads | 🟡 |
| Core Data for brand-new persistence in a greenfield module (iOS 17+) | Superseded for new work | SwiftData (`@Model`) — but do **not** flag additions to an existing Core Data stack | 🟢 |
| `NSCoding`/`NSKeyedArchiver` without secure coding | Insecure/deprecated pattern | `Codable`, or `NSSecureCoding` with `requiresSecureCoding = true` | 🟠 |
| XCTest for brand-new unit-test targets | Superseded for new pure-Swift tests | Swift Testing (`@Test`, `#expect`, `#require`) — don't flag additions to existing XCTest suites; UI tests remain XCTest | 🟢 |
| Storyboard/XIB additions for new screens in a SwiftUI-first codebase | Legacy direction | SwiftUI (or the project's established UIKit pattern) | 🟢 |
| Required-reason APIs (`UserDefaults`, file timestamps, disk space, boot time…) added without a `PrivacyInfo.xcprivacy` entry | Store rejection risk | Declare the reason in the privacy manifest | 🟠 |
| `@preconcurrency import` added to silence warnings | Escape hatch | Acceptable at true legacy boundaries; flag when used to dodge fixing the module's own isolation | 🟡 |
| New user-facing feature with a custom in-app UI screen and no `AppIntent` equivalent | Discovery gap, not a hard deprecation | Expose the action via `AppIntent` so it surfaces in Siri/Spotlight/Shortcuts/widgets — App Intents are the default discovery surface as of iOS 26 | 🟡 |
| `NavigationLink(destination:isActive:)` / other Boolean-driven navigation in new code | Superseded | Value-driven `NavigationStack(path:)` / `NavigationLink(value:)` | 🟢 |

If the diff uses an API you don't recognize or you're unsure whether it's been deprecated since this file was written, search the web before commenting.
