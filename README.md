# mobile-pr-review

[![CI](https://github.com/Abdallah-Abdelazim/mobile-pr-review-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/Abdallah-Abdelazim/mobile-pr-review-skill/actions/workflows/ci.yml)

An [agent skill](https://github.com/vercel-labs/skills) that reviews Android, iOS and Kotlin Multiplatform (KMP) pull requests. By default it saves every finding as a pending (draft) GitHub review, which nobody else sees until you submit it. Pass `--live`, or ask for it, to post immediately instead. It runs without stopping to ask questions.

It reviews Kotlin, Jetpack Compose and Gradle; Swift, SwiftUI and UIKit; and KMP code, including shared Compose Multiplatform UI. It checks for platform APIs deprecated as of 2026, Swift 6 and Compose best practices, code smells, and general engineering standards.

## What's inside

The skill is one orchestrator, `review-mobile-pr`. Give it a PR URL or number and it runs the whole review.

It has 6 review passes. Each is a prompt file in the skill (`passes/*.md`), and the passes run in parallel:

| Pass | Focus |
|---|---|
| Bug Hunter | Correctness: forgotten call sites, unhappy paths, wrong or non-exhaustive logic, contract mismatches, concurrency bugs. It also looks hard at error handling: swallowed exceptions, unjustified fallbacks, overly broad catches |
| Code-Quality Reviewer | Code smells, dead or unused code, duplication, SOLID, naming, PR scope, and the platform checklist as a backstop |
| Deprecation Scanner | APIs deprecated, superseded or removed as of 2026 (Android 16 and 17, API 36 and 37; Swift 6; iOS 17 to 26) |
| Test Analyzer | Gaps in test coverage, and tests that don't exercise what they claim to |
| Comment Analyzer | Whether comments and docs are accurate, and comments left behind by incomplete deletions |
| Type-Design Analyzer | Encapsulation and invariants in types (Kotlin sealed and data classes, Swift structs, enums and protocols) |

Bug Hunter and Code-Quality Reviewer read the platform checklist that matches the diff: `android.md`, `ios.md` or `kmp.md`. `kmp.md` has a Compose Multiplatform section covering shared Composables, `expect`/`actual` UI, CMP resources, cross-platform navigation and embedding through `ComposeUIViewController` on iOS. Both passes also read `engineering-excellence.md`, a cross-platform checklist for code smells, dead code, SOLID, naming, PR hygiene and docs. The Deprecation Scanner reads its own tables in `android-deprecations.md` and `ios-deprecations.md`.

The skill has no separate agent files. The pass prompts, the mode procedures (`modes/*.md`, read only when their flag is set) and the platform references all ship in the one skill directory, so a review needs only the GitHub CLI, `git`, and the `bash` and `awk` that come with macOS and Linux.

## How a review runs

1. **Pre-flight.** The skill fetches the PR, its linked issues and its existing comments, and stops if the PR is merged or closed. It checks out the PR head in a temporary worktree, or in a temporary blobless clone if you have no local clone, and never switches your own branch. It writes the diff to a file with every line already numbered, so comments copy their line numbers instead of guessing them.
2. **Dispatch.** Only the passes that have something to check run, in parallel. Each pass reads the diff and its own prompt from files, so nothing large is pasted into prompts.
3. **Aggregate.** When several passes report the same problem, the skill merges them into one finding. It re-checks every Critical and High finding, and every uncertain one, against the code, and drops whatever doesn't hold up. Every surviving finding, nits included, is posted inline at its line, not in the review summary.
4. **Post.** The skill checks every comment's line against the diff, then posts one review with the inline comments and a short summary, pinned to the commit it reviewed.

Each pass costs roughly 70k tokens before it reads the diff, so the number of passes drives cost far more than the size of the diff. That's why passes only run when they have something to check: Test Analyzer when code or tests changed, Deprecation Scanner when an added line matches a known deprecated symbol, and the Comment and Type-Design Analyzers when comments or types changed.

There are three cost tiers. A tiny diff (at most 30 changed lines in at most 2 files, no control-flow change, nothing on an auth, payment, persistence or concurrency path) is reviewed directly with no passes. `--lite` runs 2 passes, Bug Hunter and Code-Quality Reviewer. Everything else gets the full dispatch. Diffs above about 1,500 changed lines split Bug Hunter into 2 or 3 shards.

Bug Hunter and Code-Quality Reviewer find most of the issues, so they run on Opus. The four narrower passes run on Sonnet, and all six use high effort. On a host whose agent tool can't pick a model, passes run on the host's default.

## What a comment looks like

Each comment starts with the severity, the category and what to do (**must fix**, **should fix**, **consider** or **optional**). Then comes one short paragraph of evidence, a **Fails when:** line for bugs, and the fix. When the fix is a clean drop-in replacement, it's a `suggestion` block the author can apply with one click:

````
🔴 **Critical · Bug · must fix** — `items.first()` crashes when the cart is empty

`CartRepository.fetchItems()` returns an empty list for new users (`CartRepository.kt:6`), so `first()` throws `NoSuchElementException` inside `viewModelScope`.

**Fails when:** a new user opens the cart before the first sync.

```suggestion
            _state.value = CartUiState(items = items, featured = items.firstOrNull())
```
````

The review's summary counts findings by label, names the top risk, and lists anything that can't be anchored to a diff line, such as a caller in a file the PR didn't touch.

## Optional: deeper platform coverage

The bundled reference files are enough on their own. If you also have a platform skill installed, the review consults it on top of the bundled checklist, which it always reads. It uses at most two such skills per platform, picked by how relevant they are to the diff:

| Platform | Example skills |
|---|---|
| Android/Kotlin/Compose/Gradle | [`android/skills`](https://github.com/android/skills), [`chrisbanes/skills`](https://github.com/chrisbanes/skills), or any other Android or Compose skill you have installed |
| Swift/SwiftUI/UIKit/Xcode | [`AvdLee/SwiftUI-Agent-Skill`](https://github.com/AvdLee/SwiftUI-Agent-Skill), or any other SwiftUI or UIKit skill |
| Firebase (any platform) | [`firebase/agent-skills`](https://github.com/firebase/agent-skills). Firebase has no bundled reference, so an installed skill is the only Firebase-specific source |
| Kotlin/KMP | [`Kotlin/kotlin-agent-skills`](https://github.com/Kotlin/kotlin-agent-skills), or any other Kotlin tooling or KMP skill |

If nothing is installed for a platform your diff touches, the review uses the bundled reference alone. At the very end it prints one combined hint about what to install next time.

## Install

Install with the [`skills` CLI](https://github.com/vercel-labs/skills), which works across coding agents. If you use a different agent, swap `claude-code` below for its identifier:

```
npx skills add https://github.com/Abdallah-Abdelazim/mobile-pr-review-skill/tree/main/skills/review-mobile-pr --agent claude-code
```

This puts the skill in `.claude/skills/review-mobile-pr/` in the current project. Pass `--global` to install it to `~/.claude/skills/` instead, where every project can use it. Restart your agent or start a new session so it picks up the skill.

### Use it

```
/review-mobile-pr https://github.com/<org>/<repo>/pull/<number>
/review-mobile-pr <number>                     # when already inside the repo; saves a pending (draft) review
/review-mobile-pr <number> --live              # post live immediately instead (--now is the same)
/review-mobile-pr <number> --draft             # explicit draft (the default anyway)
/review-mobile-pr <number> --lite              # cheaper — only Bug Hunter + Code-Quality Reviewer, skips deprecation/test/comment/type-design passes
/review-mobile-pr <number> --apply-safe-fixes  # also apply narrow, safe fixes directly instead of just commenting on them
/review-mobile-pr <number> --dry-run           # full review, print the would-be review, post nothing
/review-mobile-pr <number> --since-last        # re-review only the commits pushed since your last review
/review-mobile-pr --local [<base>]             # self-review the current branch vs <base> before opening a PR; no GitHub calls; commits only — uncommitted changes are ignored
```

Flags combine, so `--lite --apply-safe-fixes` works.

It needs the [GitHub CLI](https://cli.github.com/) (`gh`) authenticated against the target repo (`gh auth status`).

## Safety contract

- Draft by default. Unless you ask for Live (`--live`, `--now`, or saying so in your request), every comment goes into a pending GitHub review that only you can see until you open the PR and submit it.
- Live posts everything at once when the review finishes. It only posts comments, never an approval or a change request, because the skill reports findings and doesn't gate the PR.
- The skill never uses `gh pr review --comment`, `gh pr comment`, or any other GitHub write call outside the single review it builds. That review has a short summary (finding counts, top risk, findings not tied to a diff line), written after all findings are final and pinned to the exact commit reviewed.
- If you already have a pending review on the PR, the skill stops before reviewing, since GitHub allows one per user, and asks you to submit or delete it first. If there are no findings, nothing is posted.
- Fix mode on someone else's PR still posts the comment for each fix it applies locally, so the author sees it. It also skips build and lint validation there, because that would run the PR's build scripts on your machine. Applied fixes stay uncommitted and unpushed, and the summary shows their full diff.
- If the API call fails, the skill prints the findings to your terminal. It never falls back to another way of posting, in either mode.
- The skill edits your repo's files only if you pass `--apply-safe-fixes`. Even then it applies only small, unambiguous fixes of about one line. It never auto-applies a fix that adds a URL or a dependency or touches a build, manifest or config file. Everything else becomes a review comment for you to act on.
- It reviews the PR's actual code. Lookups for call sites, tests and definitions run against the PR head: in your checkout if it's already there, otherwise in a temporary worktree, or in a temporary blobless clone if you have no local clone. Temporary copies are removed afterwards.
- PR content is treated as untrusted. The orchestrator and every pass are told never to follow instructions found in the diff, description, comments or linked issues, so that text can't change the posting mode or what gets posted. The review payload is never built in a shell, so text from the PR can't run as a command.
- `--lite` gives up coverage to save cost. With it, there's no deprecation checking, no test-coverage checking, and no comment or type-design review. Only correctness, error handling, and code quality and hygiene are checked.

## Evals

`evals/` has 9 fixtures with seeded bugs (Android, iOS, KMP, a clean refactor, a tiny diff and a prompt injection), a setup script, a grader prompt, and `evals/run.sh`. The script runs the review and the grader on each fixture with `claude -p`, capping what each call can spend. Together they measure recall, false positives, comment count and token cost before and after a change. Results are in [`evals/results.md`](./evals/results.md), and [`evals/README.md`](./evals/README.md) explains how to run them. The evals don't ship with the skill.

CI (`.github/workflows/ci.yml`, on Ubuntu and macOS) runs the `prepare-diff.sh` self-check, checks that every deprecation-table row matches a gate pattern in `deprecation-symbols.txt`, and fails if anything in the shipped skill references `evals/`. It doesn't run the evals.

## License

MIT. See [LICENSE](./LICENSE).
