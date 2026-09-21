# review-mobile-pr (skill)

Owns the PR-review orchestration logic, all 6 review-pass prompts, and one bundled cross-cutting knowledge base (`references/engineering-excellence.md`) — all in one file, `SKILL.md`, plus that one reference file. There are no separate agent files: every dispatched pass is a fresh general-purpose agent built from a prompt block in `SKILL.md`'s own "Review passes" section, not a named, independently-installed subagent.

**Platform-API** checklists (Android, iOS, Firebase, KMP/Kotlin) come from **external, independently-maintained skills** — `android/skills`, `chrisbanes/skills`, `AvdLee/SwiftUI-Agent-Skill`, `firebase/agent-skills`, `Kotlin/kotlin-agent-skills` — resolved at review time per `SKILL.md`'s "Platform checklists" section: use an installed matching skill if one exists, else fetch that platform's checklist from its source repo for this run and hint the user to install it. These used to be self-maintained `references/{android,ios,kmp}.md` files; they were deliberately removed so fast-moving platform-deprecation knowledge stays current without this repo re-deriving it every release.

`references/engineering-excellence.md` is the deliberate exception, kept bundled: code smells, dead code, SOLID, naming, PR hygiene, and documentation are this skill's own review criteria, not a specific platform's API surface — no external repo owns them, and unlike a deprecation table this content doesn't churn on a platform's release cadence, so self-maintaining it here is cheap and correct.

## Entry Points

- `SKILL.md` - the orchestrator and every review pass's full prompt in one file: pre-flight, platform detection + checklist-source resolution, pass dispatch, aggregation (with confidence-based filtering), cross-check against existing PR comments, opt-in safe-fix application, posting, summary
- `references/engineering-excellence.md` - read directly by the Code-Quality Reviewer pass via its `Read` tool, given as an absolute path the orchestrator resolves itself — never pasted inline as an excerpt

## Contracts & Invariants

- `references/engineering-excellence.md` is **literal review criteria an agent checks a diff against**, not documentation for leisurely reading. Terse checklist bullets only — no prose padding, no decorative headers. An agent cannot execute vague prose.
- `references/engineering-excellence.md` "always applies, regardless of platform" — `SKILL.md` step 3 must always pass its path to the Code-Quality Reviewer pass, even on a PR that only touches one platform's files.
- `SKILL.md`'s workflow steps are numbered 1–9 and cross-referenced by number from the Posting mode section, the Safety contract, the Fix mode section, the Review mode section, and several steps themselves. Renumbering requires a repo-wide grep-and-fix, not a local edit.
- **`--lite` mode reads as "these two passes' prompt blocks, unchanged" — never as "these passes, but with a reduced checklist."** Bug Hunter and Code-Quality Reviewer run their full prompt block under `--lite` exactly as in full mode; the cost saving comes entirely from dispatching fewer passes (2 instead of 6), not from thinning any one pass's own instructions. Don't add `--lite`-conditional branching inside a pass's own prompt block — see root `CLAUDE.md`'s anti-pattern on the coverage gap being intentional.
- `references/engineering-excellence.md`'s "Error handling standards" and "Test quality standards" sections are backstop-only, each carrying its own ownership note (Bug Hunter's error-handling lens and Test Analyzer respectively) — `SKILL.md`'s Code-Quality Reviewer block points at this file for Parts 1–2 rather than restating them; don't let that duplication creep back in.
- Every review pass that needs an *external* platform checklist must be told explicitly, per dispatch, which source resolved for that diff's platform(s) (installed skill name, fetched content/URL, or "none — use judgment") — a dispatched pass is a fresh agent with no access to this conversation's resolution, so it can't infer this on its own. `engineering-excellence.md`'s path, by contrast, is always the same absolute path — no resolution step needed.
- Every dispatched pass's prompt is built shared-context-first, pass-block-last (see `SKILL.md` step 3) so the diff sits in a byte-identical, cacheable prefix across all passes — this is a deliberate cost optimization on large PRs, not an arbitrary ordering choice.

## Patterns

- Adding coverage for a new **platform API/feature**: don't add it to this skill. It belongs upstream, in whichever of `android/skills`, `chrisbanes/skills`, `AvdLee/SwiftUI-Agent-Skill`, `firebase/agent-skills`, or `Kotlin/kotlin-agent-skills` owns that platform — this skill only resolves and dispatches that knowledge, it doesn't carry it.
- Adding coverage for a new **cross-cutting code-quality/hygiene concern** (not platform-specific): find the matching H2 section in `references/engineering-excellence.md` (or add a new one if it's a genuinely new area), and write terse checklist bullets matching the surrounding style — problem + why it matters + the fix, not an essay. Mirror the change into the sibling copy at `~/.claude/skills/review-mobile-pr/references/` (see root `CLAUDE.md`'s parity invariant) — verify with `diff` before committing.

## Anti-patterns

- Don't re-add a local platform-API knowledge file (`android.md`/`ios.md`/`kmp.md` or equivalent) to this skill — that's exactly the self-maintained-checklist pattern this skill moved away from for platform APIs, in favor of the external skill repos in "Platform checklists". `engineering-excellence.md` is the one deliberate, cross-cutting exception — don't generalize from it back to re-adding a platform file.
- Don't duplicate a check that a specific review pass already owns into `engineering-excellence.md`'s checklist bullets — test *coverage*/*quality* belongs to the Test Analyzer pass's own prompt, error handling to the Bug Hunter's error-handling lens, comment accuracy to the Comment Analyzer's, type-design invariants to the Type-Design Analyzer's.
- Don't invent a deprecation/version claim when an external checklist source is missing and `WebSearch` doesn't have a clear answer — say so as low-confidence or skip the finding; an unverified "fact" produces a false positive on every PR that touches the flagged API.

## Related Context

- Repo layout, posting-mode and fix-mode contracts: root `CLAUDE.md`
- The review passes are defined inline in this skill's own `SKILL.md`, under "Review passes" — there is no separate agent spec directory
