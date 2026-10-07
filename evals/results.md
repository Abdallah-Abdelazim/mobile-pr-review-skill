# Eval results

Recall = must-find found / total. FP = false positives. Sev = must-finds at or above min severity.

| Date | Skill commit | Fixture | Recall | Sev | Should | FP | Extra | Comments / max | Readability | Pass tokens | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 2026-10-07 | 7ed5d87 | android-cart | 3/3 | 3/3 | 3/3 | 0 | 6 | 17 / 10 ⚠️ | 4 | 299,518 (4 passes) | Baseline. No cross-pass dedup: 3 duplicate pairs. Severity inflation (broad catch CRITICAL, missing tests HIGH). |
| 2026-10-07 | 7ed5d87 | android-payment | 2/2 | 2/2 | 2/2 | 0 | 1 | 10 / 6 ⚠️ | 3 | 348,860 (5 passes) | Baseline. Each must-find posted 3–4× by different passes. |
| 2026-10-07 | 7ed5d87 | clean-refactor | – | – | – | 1 | 0 | 1 / 2 | 4 | 277,433 (4 passes) | Baseline. Test Analyzer flagged "missing tests" on a no-behavior-change refactor. ~69k tokens/pass even for a 17-line diff. |
| 2026-10-07 | 59a8a5c | android-cart | 3/3 | 3/3 | 3/3 | 0 | 2 | 8 / 10 | 4 | 302,598 (4 passes) | After batches 5–8. 10 raw → 8 merged. Readability held at 4: three comments on line 26 with overlapping fixes. |
| 2026-10-07 | 59a8a5c | android-payment | 2/2 | 2/2 | 1/2 | 0 | 0 | 2 / 6 | 5 | 290,171 (4 passes) | After. 8 raw → 2 merged; Deprecation Scanner gated off. Missed should-find "no tests" (folded into the bug). |
| 2026-10-07 | 59a8a5c | clean-refactor | – | – | – | 0 | 0 | 0 / 2 | – | 0 (tiny-diff path) | After. Reviewed directly, zero passes (was 277k tokens, 1 FP). Scored by hand: nothing to grade. |
