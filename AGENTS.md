# mobile-pr-review-skill (repo)

Home of `review-mobile-pr`, an agent skill for Android/iOS/KMP pull-request review (an orchestrator `SKILL.md` plus one prompt file per review pass), and of the eval set that measures it. Installed with the `skills` CLI (`npx skills add ...`); see README.md.

## Intent Layer

**Before modifying code in a subdirectory, read its AGENTS.md first** to understand local patterns and invariants.

- **The skill**: `skills/review-mobile-pr/AGENTS.md` - orchestration, review passes, reference checklists, scripts, and every posting/dispatch contract
- **Evals**: `evals/README.md` - seeded-bug fixtures, setup script and grader prompt for measuring review quality and cost; results in `evals/results.md`

```
mobile-pr-review-skill/
├── skills/review-mobile-pr/ # the skill — the only thing that ships; see its AGENTS.md
└── evals/                   # quality/cost benchmark — never shipped
```

## Global Invariants

- **`AGENTS.md` is the canonical agent-instructions file in each directory; `CLAUDE.md` is a relative symlink to it** (`CLAUDE.md -> AGENTS.md`), so Pi, OpenCode, Codex and other `AGENTS.md`-reading agents and Claude Code all load the same text. Edit `AGENTS.md` only — never replace the symlink with a copy — and give any new directory that gets agent docs the same pair.
- **Only `skills/review-mobile-pr/` ships** (`npx skills add …/tree/main/skills/review-mobile-pr`). Anything a review reads at runtime — `SKILL.md`, passes, references, scripts — must live inside it and must not point at `evals/` or repo-root files (they don't exist in an install). The skill's `AGENTS.md` may cite them, since it's maintainer documentation.
- `skills/review-mobile-pr/{SKILL.md,AGENTS.md,CLAUDE.md,passes/*.md,references/*,scripts/*}` must stay in sync with the maintainer's global mirror at `~/.claude/skills/review-mobile-pr` (a symlink to `~/.agents/skills/review-mobile-pr`, used for local testing) — after any edit, `rsync -a --delete` it across and verify with `diff -rq`.
- **The skill and the evals share one format:** `--local`/`--dry-run` write the would-be review to `<run dir>/findings.md` (the summary body, then `### <path>:<line> (<side>)` per comment), and `evals/grader.md` scores exactly that. Change it on both sides together.
- **Run the evals before and after any change that affects review output** — pass prompts, references, dedup/severity/format rules, dispatch gates — and add the rows to `evals/results.md`.

## Anti-patterns

- **Don't edit a fixture's `expected.md` to fit a run's output without recording it.** Two were corrected 2026-10 (a class-declaration anchor, an over-broad "must not flag"), each noted in `evals/results.md` beside the run that exposed it — a silently changed answer key makes before/after comparisons meaningless.

## Related Context

- The skill itself, all its contracts: `skills/review-mobile-pr/AGENTS.md`
- Running and extending the evals: `evals/README.md`
