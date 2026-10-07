# Expected — kmp-sync

## Must find
- id: jvm-import | file: shared/src/commonMain/kotlin/com/example/sync/SyncEngine.kt | line: ~3 | min severity: HIGH | `java.util.Date` in `commonMain` — use `kotlinx-datetime` (`Clock.System.now()`).
- id: synchronized-native | file: shared/src/commonMain/kotlin/com/example/sync/SyncEngine.kt | line: ~13 | min severity: HIGH | `synchronized {}` is JVM-only — use `kotlinx.coroutines.sync.Mutex` or atomicfu.
- id: run-blocking-common-test | file: shared/src/commonTest/kotlin/com/example/sync/SyncEngineTest.kt | line: ~13 | min severity: MEDIUM | `runBlocking` isn't available in `commonTest`; use `runTest`.

## Should find
- id: throws-swift | file: SyncEngine.kt | line: ~11 | `sync()` can throw (`IOException` per `SyncApi`) and is called from Swift without `@Throws` — an uncaught Kotlin exception terminates the iOS app.
- id: mutable-state-exposed | file: SyncEngine.kt | line: ~9 | public `MutableStateFlow` lets callers write sync status; expose `StateFlow`.

## Must not flag
- `SyncApi.kt` (unchanged).

## Max comments: 7
