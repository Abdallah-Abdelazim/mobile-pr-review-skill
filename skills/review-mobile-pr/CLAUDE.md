# review-mobile-pr (skill)

Owns the PR-review orchestration logic (`SKILL.md`), the 6 review-pass prompts (`passes/*.md`), and the platform review knowledge bases (`references/*.md`). There are no separate agent files: every dispatched pass is a fresh general-purpose agent told to read its own `passes/<name>.md`, not a named, independently-installed subagent.

## Entry Points

- `SKILL.md` - the orchestrator: pre-flight (incl. `--local`/`--since-last`/worktree checkout), platform detection + external-skill resolution, gated pass dispatch, aggregation (confidence filter, cross-pass merge, re-verification, comment budget), cross-check against existing PR comments, opt-in safe-fix application, anchor validation and posting, summary
- `scripts/prepare-diff.sh` - annotates the PR diff with per-line `R<n>`/`L<n>` numbers (and collapses lockfile/binary/snapshot noise); `check` mode validates comment anchors before step 8 posts; `slice` mode cuts per-shard diffs for Bug Hunter on large PRs
- `references/deprecation-symbols.txt` - grep patterns gating the Deprecation Scanner (step 4); keep in step with the deprecation tables
- `passes/shared.md` - what every pass follows: untrusted-data and scope rules, the one severity scale, confidence levels, and the JSON output schema
- `passes/<name>.md` - one prompt file per review pass (persona, checklist, pass-specific severity examples); the pass reads it itself, the orchestrator never loads or pastes it
- `scripts/test-prepare-diff.sh` - self-check for `prepare-diff.sh`; run after any change to it
- `references/android.md`, `references/ios.md`, `references/kmp.md`, `references/engineering-excellence.md` (checklists) and `references/android-deprecations.md`, `references/ios-deprecations.md` (deprecation tables, Deprecation Scanner only) - read directly by dispatched passes via their `Read` tool, given as absolute paths the orchestrator resolves itself — never pasted inline as excerpts

## Contracts & Invariants

- Every reference file is **literal review criteria an agent checks a diff against**, not documentation for leisurely reading. Terse checklist bullets only — no prose padding, no decorative headers. An agent cannot execute vague prose.
- `android.md` and `ios.md` each have a "Table of contents" that must stay in sync with their actual H2 headers — adding or renaming an H2 section without updating the TOC is a bug. `kmp.md`, `engineering-excellence.md` and the two `*-deprecations.md` files deliberately have no TOC (short enough not to need one) — don't add one just for consistency.
- The tables in `android-deprecations.md`/`ios-deprecations.md` use an exact column format: `| Newly added usage of… | Status | Replacement / note | Severity |`. The Deprecation Scanner pass (`passes/deprecation-scanner.md`) structurally depends on this shape — don't reflow it into prose. Deprecation rows live only in those files, never back in the checklists: every other pass would pay to read them.
- `engineering-excellence.md` "always applies, regardless of platform" — `context.md` (`SKILL.md` step 3) must always list its path, and `passes/code-quality.md` always reads it, even on a PR that only touches one platform's files.
- Version/date-specific facts in these files (Android API level, iOS/Xcode/Swift version, Compose Multiplatform version) are **verified-live facts, not evergreen prose** — when editing, confirm current values via WebSearch rather than assuming last year's numbers still hold. These files get stale on their own schedule, independent of the code they describe. Each platform file carries a "Facts last updated: <date>" line under its title — bump it only when you actually re-verify facts, never for a rule-wording edit (it tells the Deprecation Scanner how far to trust the file).
- `SKILL.md`'s workflow steps are numbered 1–9 and cross-referenced by number from the Posting mode section, the Safety contract, the Fix mode section, the Review mode section, and several steps themselves. Renumbering requires a repo-wide grep-and-fix, not a local edit.
- **`--lite` mode reads as "these two passes' prompt files, unchanged" — never as "these passes, but with a reduced checklist."** Bug Hunter and Code-Quality Reviewer run their full prompt file under `--lite` exactly as in full mode; the cost saving comes entirely from dispatching fewer passes (2 instead of 6), not from thinning any one pass's own instructions. Don't add `--lite`-conditional branching inside a pass's own prompt file — see root `CLAUDE.md`'s anti-pattern on the coverage gap being intentional.
- `engineering-excellence.md`'s "Error handling standards" and "Test quality standards" sections are backstop-only, each carrying its own ownership note (Bug Hunter's error-handling lens and Test Analyzer respectively) — `passes/code-quality.md` points at this file for Parts 1–2 rather than restating them; don't let that duplication creep back in when either file changes.
- Dispatched passes read the PR context from files (`<run dir>/context.md`, `<run dir>/pr.diff`) — never from their prompt, which is a one-line pointer to those files, `passes/shared.md` and the pass's own file (see `SKILL.md` step 3 and root `CLAUDE.md`). Pasting the diff into prompts makes the orchestrator emit it as output tokens once per pass.
- `scripts/prepare-diff.sh` owns the annotated-diff format (`R<n>`/`L<n>` line prefixes, `=== <path>` headers, `(omitted: …)` noise lines) and anchor validation (`check`). Passes copy line numbers from it and step 8 validates against it — change the format only together with the `check` mode and `SKILL.md` steps 1, 3 and 8, and run `bash scripts/test-prepare-diff.sh` after any change (it caught a `-v` unescaping bug that silently dropped every `.java` file).
- **External platform skills are strictly additive, never a substitute** — see `SKILL.md`'s "External platform skills" section. A pass always gets its `references/{android,ios,kmp}.md` path regardless of whether a matching skill was also resolved for that platform in step 2; the skill's name, when present, is extra context appended alongside, not a replacement for the `Read` call. Reversing this (skip the reference file because a skill covers that platform) breaks the floor/ceiling guarantee this design promises.
- **The "no skill installed for <platform>" hint is aggregated and singular.** Step 2 records misses on a running list as it resolves each platform; step 9 is the *only* place that list gets printed, combined into one line. No pass, and no earlier step, prints its own version of this hint — that was tried and reverted (2026-09) specifically because scattered hints buried the same install suggestion 2-6 times across one review's output.

- **`QUESTION` is a `severity` value only Bug Hunter emits, posted in its own shape.** It posts as a short `**❓ Question: …**` prose comment (step 8's "QUESTION findings" block) with no severity label, `body` paragraph or `fix`, and gets its own line in step 9's summary. It's deliberately scarce — important cases only (boundary/money/auth/PII or behavior others rely on), max 5 per review, never trivial or pure-confirmation (defined in `passes/bug-hunter.md`); don't loosen that, a review full of questions is noise. Other passes don't emit it; it still goes through step 5's LOW-confidence drop and step 6's duplicate check like any finding.

## Patterns

Adding coverage for a new platform API/feature:
1. Find the matching H2 section in the relevant reference file (or add a new one if it's a genuinely new area — see `kmp.md`'s "Compose Multiplatform" section for an example of a whole new section added this way)
2. Write terse checklist bullets matching the surrounding style — problem + why it matters + the fix, not an essay
3. If a new H2 section was added to `android.md`/`ios.md`, update that file's Table of contents
   - A new deprecation-table row also needs a matching pattern in `deprecation-symbols.txt`, or step 4's pre-scan never dispatches the scanner for it
4. Mirror the change into the sibling copy at `~/.claude/skills/review-mobile-pr/references/` (see root `CLAUDE.md`'s parity invariant) — verify with `diff` before committing

Changing how a pass behaves: persona, process and pass-specific checks go in `passes/<name>.md`; anything every pass should follow (scope, severity, output fields) goes in `passes/shared.md`, never copied into individual pass files. Run the evals before and after (root `CLAUDE.md`).

This is still where platform-API substance belongs, even though an external skill might also cover it — the bundled files are the floor a review meets with nothing else installed, so they can't be allowed to fall behind just because some installs also happen to have deeper coverage from elsewhere.

## Anti-patterns

- Don't duplicate a check that a specific review pass already owns into these reference files' checklist bullets — test *coverage*/*quality* belongs to the Test Analyzer pass's own prompt, error handling to the Bug Hunter's error-handling lens, comment accuracy to the Comment Analyzer's, type-design invariants to the Type-Design Analyzer's. These reference files are the shared platform-knowledge backstop (read by the Code-Quality Reviewer and Bug Hunter passes), not a place to re-litigate what a specialist pass already checks better.
  - A real instance of this, not a hypothetical: `android.md`, `ios.md`, and `kmp.md` each carried their own dedicated `## Testing`/`## KMP testing` section that restated the Test Analyzer pass's own prompt block near-verbatim (removed 2026-09) — every dispatched pass paid to read it, and Code-Quality Reviewer's own prompt already explicitly excluded "non-testing sections" from its platform-checklist backstop, so nothing was actually backstopping through it. If a platform-specific test convention needs adding, put it in `passes/test-analyzer.md`, not back into these files.
- Don't invent a deprecation/version claim to fill out a table row — an unverified "fact" here produces a false positive on every PR that touches the flagged API.
- Don't delete `references/{android,ios,kmp}.md` in favor of external skills again without re-reading this file's git history first — that exact change was made, then reverted the same week (2026-09) once it became clear an install-optional review tool can't have its baseline coverage depend on the reviewer's environment. External skills stay additive; see the invariant above.

## Related Context

- Repo layout, posting-mode and fix-mode contracts: root `CLAUDE.md`
- The review passes that consume these files are prompt files in this skill's own `passes/` directory, listed in `SKILL.md`'s "Review passes" table — there is no separate agent spec directory
