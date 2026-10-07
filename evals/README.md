# review-mobile-pr evals

Fixtures with seeded bugs, used to measure whether a change to the skill helps or hurts: recall on known bugs, false positives, comment count, readability, and pass tokens. Not shipped with the skill (`npx skills add` installs only `skills/review-mobile-pr/`).

## Layout

```
evals/
├── setup.sh                 # fixture → throwaway git repo (main = base, pr = head)
├── grader.md                # grader-agent prompt → JSON score
├── results.md               # one row per fixture per run
└── fixtures/<name>/
    ├── base/  head/         # full file trees before/after the change
    ├── intent.txt           # the "PR description" (becomes the head commit message)
    └── expected.md          # must find / should find / must not flag / max comments
```

| Fixture | Exercises |
|---|---|
| `android-cart` | crash on empty list, broad catch swallowing cancellation, `collectAsState`, Compose false-positive traps |
| `android-payment` | forgotten `when` branch in a file outside the diff, field dropped at the DTO boundary vs stated intent |
| `ios-profile` | `@Published` mutated off the main actor, `try?` swallowing, uncancelled `Task`, `ObservableObject` on iOS 17 |
| `kmp-sync` | JVM API in `commonMain`, `synchronized` on Native, `runBlocking` in `commonTest`, missing `@Throws` |
| `android-login-tests` | test that never calls the code under test, silent rule change with no test diff |
| `android-comments-types` | stranded KDoc, out-of-diff stale caller, mutually exclusive nullable fields |
| `clean-refactor` | false positives on a correct refactor |
| `tiny-typo` | tiny-diff path: zero dispatch, zero comments |

## Running

For each fixture, in a Claude Code session with the skill installed (the repo's `skills/review-mobile-pr`, or the synced global mirror):

1. `evals/setup.sh evals/fixtures/<name> <work-dir>` → prints the fixture repo path.
2. From that repo, run `/review-mobile-pr --local main`. It writes `<run dir>/findings.md` and prints `Pass tokens` when the host reports agent usage.
3. Dispatch a fresh agent: *"Read `<this repo>/evals/grader.md` and follow it. expected.md: `<fixture>/expected.md`. findings.md: `<run dir>/findings.md`."*
4. Add a row to `results.md`.

Run the whole set before and after a change that affects output (pass prompts, references, dedup, severity, comment format) and compare. Model runs vary, so treat a one-fixture difference as noise; look for consistent shifts.

If a run shows a fixture's `expected.md` is wrong (e.g. it rejects a valid anchor), fixing it is fine — but note the change in `results.md` beside the run that exposed it, so before/after numbers stay comparable.

When adding a fixture, keep it small (2–4 files), make every seeded bug unambiguous from the diff plus the files shown, and add at least one "must not flag" trap.
