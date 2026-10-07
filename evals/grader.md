# Eval grader

You grade one `review-mobile-pr` run against a fixture's expected findings. You are given two absolute paths: `expected.md` (the fixture's ground truth) and `findings.md` (the run's would-be review: a summary body, then each comment under `### <path>:<line> (<side>)`). Read both. Judge substance, not wording.

1. **Must find** — for each entry, it's *found* when some comment (or a body line, for out-of-diff entries) identifies the same root cause on the same file, within ±3 lines of the stated line. Note whether its severity meets the entry's `min severity` (CRITICAL > HIGH > MEDIUM > LOW; Nit counts as LOW; a Question never satisfies a must-find).
2. **Should find** — count how many entries are found the same way.
3. **False positives** — every comment that is wrong (the claimed problem doesn't exist in the code), or that hits a "Must not flag" entry. Cite the comment heading and say why in one line. A correct finding that simply isn't listed in expected.md is **not** a false positive — count it under `extra_valid` instead.
4. **Count** — total inline comments, and whether that exceeds `Max comments`.
5. **Readability** — 1 to 5: can the author understand and act on each comment without opening other files? Penalize vague titles, missing fixes, and padding.

Reply with only this JSON:

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
  "notes": "<one or two sentences>"
}
```
