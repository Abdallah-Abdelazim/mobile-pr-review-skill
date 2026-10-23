#!/usr/bin/env bash
# Usage: evals/run.sh [<fixture>...]          (default: every fixture, one at a time)
# Each fixture: setup.sh → `claude -p "/review-mobile-pr --local main"` in the fixture repo → `claude -p` grader.
# A fixture with threads.json is a re-review: the prompt adds `--re-review round1 --threads <its threads.json>`.
# Writes <out>/<fixture>/{review.json,findings.md,grade.json} and <out>/summary.tsv; prints <out>.
# Spends real tokens: ~200–400k per fixture that dispatches passes (see results.md). Needs the skill installed.
# Env: EVAL_OUT (output dir), EVAL_MODEL (orchestrator model; recorded in summary.tsv), EVAL_BUDGET_USD
#      (cap per claude call, default 15), EVAL_CLAUDE_ARGS (extra flags, e.g. --bare), CLAUDE (binary).
set -euo pipefail
evals=$(cd "$(dirname "$0")" && pwd)
out=${EVAL_OUT:-$(mktemp -d)}
claude=${CLAUDE:-claude}
budget=${EVAL_BUDGET_USD:-15}
model=${EVAL_MODEL:-}
args=(--output-format json --max-budget-usd "$budget")
[ -n "$model" ] && args+=(--model "$model")
# shellcheck disable=SC2206
[ -n "${EVAL_CLAUDE_ARGS:-}" ] && args+=($EVAL_CLAUDE_ARGS)
# -p denies any tool not listed. Bash stays unscoped (the skill runs git/awk/grep); --local makes no GitHub calls.
review_tools='Bash Read Write Glob Grep Agent Skill WebSearch WebFetch'

[ $# -eq 0 ] && set -- $(ls "$evals/fixtures")
for name in "$@"; do
  dir="$out/$name"
  mkdir -p "$dir/tmp"
  repo=$(bash "$evals/setup.sh" "$evals/fixtures/$name" "$dir/work")
  prompt='/review-mobile-pr --local main'
  [ -f "$evals/fixtures/$name/threads.json" ] && prompt+=" --re-review round1 --threads $evals/fixtures/$name/threads.json"
  touch "$dir/start"
  # The skill's run dir comes from mktemp -d, so a per-fixture TMPDIR makes its findings.md unambiguous.
  (cd "$repo" && TMPDIR="$dir/tmp" "$claude" -p "$prompt" "${args[@]}" --allowedTools "$review_tools") \
    > "$dir/review.json" || echo "$name: review run failed (see $dir/review.json)" >&2
  findings=$(find "$dir/tmp" "${TMPDIR:-/tmp}" -name findings.md -newer "$dir/start" 2>/dev/null | head -1 || true)
  if [ -z "$findings" ]; then echo "$name: no findings.md written" >&2; continue; fi
  cp "$findings" "$dir/findings.md"
  "$claude" -p "Read $evals/grader.md and follow it. expected.md: $evals/fixtures/$name/expected.md. findings.md: $dir/findings.md." \
    "${args[@]}" --allowedTools Read > "$dir/grade.json" || echo "$name: grader failed (see $dir/grade.json)" >&2
done

# One line per fixture: the raw material for a results.md row (notes stay a human call).
python3 -I - "$out" "$model" <<'PY'
import json, os, re, sys
out, model = sys.argv[1], sys.argv[2] or "default"
rows = ["fixture\tmodel\trecall\tsev\tshould\tthreads\tfp\textra\tcomments\tover_budget\treadability\tpass_tokens\treview_usd\tgrader_usd"]
for name in sorted(os.listdir(out)):
    d = os.path.join(out, name)
    if not os.path.isdir(d): continue
    def load(f):
        try: return json.load(open(os.path.join(d, f)))
        except Exception: return {}
    review, grade = load("review.json"), load("grade.json")
    m = re.search(r"```json\s*(\{.*?\})\s*```", grade.get("result", ""), re.S)
    g = json.loads(m.group(1)) if m else {}
    mf = g.get("must_find", [])
    tv = g.get("thread_verdicts", [])
    pt = re.search(r"Pass tokens:\s*([\d,]+)", review.get("result", ""))
    rows.append("\t".join(map(str, [
        name, model,
        f"{sum(x.get('found', False) for x in mf)}/{len(mf)}" if mf else "-",
        f"{sum(x.get('severity_ok', False) for x in mf)}/{len(mf)}" if mf else "-",
        f"{g.get('should_find_found', '-')}/{g.get('should_find_total', '-')}",
        f"{sum(x.get('verdict_ok', False) and x.get('delivery_ok', False) for x in tv)}/{len(tv)}" if tv else "-",
        len(g.get("false_positives", [])) if g else "-", g.get("extra_valid", "-"),
        g.get("comments", "-"), g.get("over_budget", "-"), g.get("readability", "-"),
        pt.group(1) if pt else "-", review.get("total_cost_usd", "-"), grade.get("total_cost_usd", "-")])))
open(os.path.join(out, "summary.tsv"), "w").write("\n".join(rows) + "\n")
print("\n".join(rows))
PY
echo "$out"
