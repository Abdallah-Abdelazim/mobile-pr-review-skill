# Expected — android-rereview

Re-review fixture: run with `--local main --re-review round1 --threads <fixture>/threads.json`. `round1` is the tree the threads were written against; `head` is after the author's fixes. Quick path (the round1→head change is far under 400 lines), so zero dispatch and no nits.

## Must find
- id: refresh-resets-state | file: app/src/main/java/com/example/wallet/TransferViewModel.kt | line: ~31 | min severity: MEDIUM | `refreshBalance()` now rebuilds `TransferUiState(balanceCents = …)` from scratch, so the post-transfer refresh (line 62) wipes `sent = true` (no success shown) and the inputs, and the `init` refresh wipes anything typed before the fetch returns. New since round1.

## Should find
- id: untrimmed-recipient | file: TransferViewModel.kt | line: ~60 | `recipientInput` is passed to `transfer()` raw although its KDoc requires an E.164 number with no whitespace — a pasted number with a space fails. Present since round1, missed then.

## Thread verdicts
- thread: https://github.com/example/app/pull/1#discussion_r101 | verdict: addressed | delivery: none
- thread: https://github.com/example/app/pull/1#discussion_r102 | verdict: not fully addressed (the new guard compares cents to `balanceCents * 100`, allowing up to 100× the balance) | delivery: reply
- thread: https://github.com/example/app/pull/1#discussion_r103 | verdict: still present | delivery: reply
- thread: https://github.com/example/app/pull/1#discussion_r104 | verdict: pushback valid | delivery: reply
- thread: https://github.com/example/app/pull/1#discussion_r105 | verdict: pushback invalid (KDoc says `transfer()` throws `TransferDeclinedException`) | delivery: reply
- thread: https://github.com/example/app/pull/1#discussion_r106 | verdict: still present (CRITICAL double charge) | delivery: reply
- thread: https://github.com/example/app/pull/1#discussion_r107 | verdict: addressed | delivery: body
- thread: https://github.com/example/app/pull/1#discussion_r108 | verdict: still present (bot right) | delivery: body
- thread: https://github.com/example/app/pull/1#discussion_r109 | verdict: not an issue (bot wrong: `transfer()` is a suspend call, main-safe) | delivery: none

## Must not flag
- Any inline comment labeled optional (nit) — the re-review quick path posts no nits.
- An inline comment re-raising thread 102, 103, 105, 106 or 108 — those are answered by the thread verdicts, not new comments.
- `viewModelScope.launch` without `Dispatchers.IO` (thread 109's claim is wrong).
- `refreshBalance()` after `transfer()` as a redundant call (thread 104's pushback is right).

## Max comments: 4
