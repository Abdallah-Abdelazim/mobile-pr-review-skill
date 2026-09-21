# review-mobile-pr (skill)

Owns the PR-review orchestration logic, all 6 review-pass prompts, and the platform review knowledge bases (`references/*.md`) — all in one file, `SKILL.md`. There are no separate agent files: every dispatched pass is a fresh general-purpose agent built from a prompt block in `SKILL.md`'s own "Review passes" section, not a named, independently-installed subagent.

## Entry Points

- `SKILL.md` - the orchestrator and every review pass's full prompt in one file: pre-flight, platform detection + external-skill resolution, pass dispatch, aggregation (with confidence-based filtering), cross-check against existing PR comments, opt-in safe-fix application, posting, summary
- `references/android.md`, `references/ios.md`, `references/kmp.md`, `references/engineering-excellence.md` - read directly by dispatched passes via their `Read` tool, given as absolute paths the orchestrator resolves itself — never pasted inline as excerpts

## Contracts & Invariants

- Every reference file is **literal review criteria an agent checks a diff against**, not documentation for leisurely reading. Terse checklist bullets only — no prose padding, no decorative headers. An agent cannot execute vague prose.
- `android.md` and `ios.md` each have a "Table of contents" that must stay in sync with their actual H2 headers — adding or renaming an H2 section without updating the TOC is a bug. `kmp.md` and `engineering-excellence.md` deliberately have no TOC (short enough not to need one) — don't add one just for consistency.
- The Deprecations tables in `android.md`/`ios.md` use an exact column format: `| Newly added usage of… | Status | Replacement / note | Severity |`. `mobile-pr-deprecation-scanner` (the agent) structurally depends on this shape — don't reflow it into prose.
- `engineering-excellence.md` "always applies, regardless of platform" — `SKILL.md` step 3 must always pass its path to the Code-Quality Reviewer pass, even on a PR that only touches one platform's files.
- Version/date-specific facts in these files (Android API level, iOS/Xcode/Swift version, Compose Multiplatform version) are **verified-live facts, not evergreen prose** — when editing, confirm current values via WebSearch rather than assuming last year's numbers still hold. These files get stale on their own schedule, independent of the code they describe.
- `SKILL.md`'s workflow steps are numbered 1–9 and cross-referenced by number from the Posting mode section, the Safety contract, the Fix mode section, the Review mode section, and several steps themselves. Renumbering requires a repo-wide grep-and-fix, not a local edit.
- **`--lite` mode reads as "these two passes' prompt blocks, unchanged" — never as "these passes, but with a reduced checklist."** Bug Hunter and Code-Quality Reviewer run their full prompt block under `--lite` exactly as in full mode; the cost saving comes entirely from dispatching fewer passes (2 instead of 6), not from thinning any one pass's own instructions. Don't add `--lite`-conditional branching inside a pass's own prompt block — see root `CLAUDE.md`'s anti-pattern on the coverage gap being intentional.
- `engineering-excellence.md`'s "Error handling standards" and "Test quality standards" sections are backstop-only, each carrying its own ownership note (Bug Hunter's error-handling lens and Test Analyzer respectively) — `SKILL.md`'s Code-Quality Reviewer block points at this file for Parts 1–2 rather than restating them; don't let that duplication creep back in when either file changes.
- Every dispatched pass's prompt is built shared-context-first, pass-block-last (see `SKILL.md` step 3) so the diff sits in a byte-identical, cacheable prefix across all passes — this is a deliberate cost optimization on large PRs, not an arbitrary ordering choice.
- **External platform skills are strictly additive, never a substitute** — see `SKILL.md`'s "External platform skills" section. A pass always gets its `references/{android,ios,kmp}.md` path regardless of whether a matching skill was also resolved for that platform in step 2; the skill's name, when present, is extra context appended alongside, not a replacement for the `Read` call. Reversing this (skip the reference file because a skill covers that platform) breaks the floor/ceiling guarantee this design promises.
- **The "no skill installed for <platform>" hint is aggregated and singular.** Step 2 records misses on a running list as it resolves each platform; step 9 is the *only* place that list gets printed, combined into one line. No pass, and no earlier step, prints its own version of this hint — that was tried and reverted (2026-09) specifically because scattered hints buried the same install suggestion 2-6 times across one review's output.

## Patterns

Adding coverage for a new platform API/feature:
1. Find the matching H2 section in the relevant reference file (or add a new one if it's a genuinely new area — see `kmp.md`'s "Compose Multiplatform" section for an example of a whole new section added this way)
2. Write terse checklist bullets matching the surrounding style — problem + why it matters + the fix, not an essay
3. If a new H2 section was added to `android.md`/`ios.md`, update that file's Table of contents
4. Mirror the change into the sibling copy at `~/.claude/skills/review-mobile-pr/references/` (see root `CLAUDE.md`'s parity invariant) — verify with `diff` before committing

This is still where platform-API substance belongs, even though an external skill might also cover it — the bundled files are the floor a review meets with nothing else installed, so they can't be allowed to fall behind just because some installs also happen to have deeper coverage from elsewhere.

## Anti-patterns

- Don't duplicate a check that a specific review pass already owns into these reference files' checklist bullets — test *coverage*/*quality* belongs to the Test Analyzer pass's own prompt, error handling to the Bug Hunter's error-handling lens, comment accuracy to the Comment Analyzer's, type-design invariants to the Type-Design Analyzer's. These reference files are the shared platform-knowledge backstop (read by the Code-Quality Reviewer and Bug Hunter passes), not a place to re-litigate what a specialist pass already checks better.
  - A real instance of this, not a hypothetical: `android.md`, `ios.md`, and `kmp.md` each carried their own dedicated `## Testing`/`## KMP testing` section that restated the Test Analyzer pass's own prompt block near-verbatim (removed 2026-09) — every dispatched pass paid to read it, and Code-Quality Reviewer's own prompt already explicitly excluded "non-testing sections" from its platform-checklist backstop, so nothing was actually backstopping through it. If a platform-specific test convention needs adding, put it in the Test Analyzer's prompt block in `SKILL.md`, not back into these files.
- Don't invent a deprecation/version claim to fill out a table row — an unverified "fact" here produces a false positive on every PR that touches the flagged API.
- Don't delete `references/{android,ios,kmp}.md` in favor of external skills again without re-reading this file's git history first — that exact change was made, then reverted the same week (2026-09) once it became clear an install-optional review tool can't have its baseline coverage depend on the reviewer's environment. External skills stay additive; see the invariant above.

## Related Context

- Repo layout, posting-mode and fix-mode contracts: root `CLAUDE.md`
- The review passes that consume these files are defined inline in this skill's own `SKILL.md`, under "Review passes" — there is no separate agent spec directory
