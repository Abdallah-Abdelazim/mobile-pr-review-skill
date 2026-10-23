# Eval grader

You grade one `review-mobile-pr` run against a fixture's expected findings. You are given two absolute paths: `expected.md` (the fixture's ground truth) and `findings.md` (the run's would-be review: a summary body, then each comment under `### <path>:<line> (<side>)`, then — for a re-review — each thread reply under `### reply <thread-url>`). Read both. Judge substance, not wording.

1. **Must find** — for each entry, it's *found* when some comment (or a body line, for out-of-diff entries) identifies the same root cause on the same file, within ±3 lines of the stated line. Note whether its severity meets the entry's `min severity` (CRITICAL > HIGH > MEDIUM > LOW; an optional (nit) finding counts as LOW; a Question never satisfies a must-find).
2. **Should find** — count how many entries are found the same way.
3. **False positives** — every comment that is wrong (the claimed problem doesn't exist in the code), or that hits a "Must not flag" entry. Cite the comment heading and say why in one line. A correct finding that simply isn't listed in expected.md is **not** a false positive — count it under `extra_valid` instead.
4. **Count** — total inline comments (`### reply` sections are not comments), and whether that exceeds `Max comments`.
5. **Readability** — 1 to 5: can the author understand and act on each comment without opening other files? Penalize vague titles, missing fixes, and padding.
6. **Thread verdicts** — only when expected.md has a `## Thread verdicts` section. For each entry, `delivery_ok` when findings.md delivers it through the stated channel: `reply` = a `### reply <url>` section for that URL; `body` = a summary-body line naming that URL, and no reply section; `none` = no reply section for that URL and no body line presenting it as an open issue. `verdict_ok` when what it says matches the expected verdict in substance (for `none`, true unless the run wrongly calls it an open issue).

Reply with only this JSON (`thread_verdicts` is `[]` when expected.md has none):

```json
{
  "fixture": "<name>",
  "must_find": [{"id": "<id>", "found": true, "severity_ok": true}],
  "should_find_found": 0,
  "should_find_total": 0,
  "false_positives": [{"comment": "<heading>", "why": "<one line>"}],
  "extra_valid": 0,
  "comments": 0,
  "over_budget": false,
  "readability": 0,
  "thread_verdicts": [{"thread": "<url>", "verdict_ok": true, "delivery_ok": true}],
  "notes": "<one or two sentences>"
}
```
