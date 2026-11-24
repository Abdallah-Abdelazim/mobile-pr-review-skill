# Output format — steps 8 and 9

Read by the orchestrator at step 8, before building comments (or at step 9, when step 8 posted nothing). Step numbers refer to `SKILL.md`.

## Comment format

Build every inline comment from the finding's fields: a header that says how serious it is, what kind of problem it is and what the author should do; one short paragraph; then the fix. Length scales with severity — a nit is a header and a suggestion, nothing more.

| Severity | Label |
|---|---|
| 🔴 CRITICAL | must fix |
| 🟠 HIGH | must fix |
| 🟡 MEDIUM | should fix |
| 🟢 LOW | consider |
| 🟢 LOW with `nit: true` | optional |

````
<emoji> **<Severity> · <Category> · <label>** — <title>

<body>

**Fails when:** <failure_scenario>                 ← only when set

```suggestion
<fix.code>
```                                                   ← kind: suggestion; a ```kotlin / ```swift block for kind: code; nothing for kind: none

Ref: <doc URL>                                        ← only when `evidence` holds an official doc URL
````

`<Category>` is the `category` field in words: Bug, Error handling, Deprecation, Code quality, Tests, Comments, Type design. For a LOW finding whose `title` already says everything, drop the `body` paragraph. A finding step 5 softened keeps its conditional wording ("If `items` can be empty here, …"). A "Related existing comment" note from step 6 goes last.

Example:

````
🔴 **Critical · Bug · must fix** — `items.first()` crashes when the cart is empty

`CartRepository.fetchItems()` returns an empty list for new users (`CartRepository.kt:6`), so `first()` throws `NoSuchElementException` inside `viewModelScope`.

**Fails when:** a new user opens the cart before the first sync.

```suggestion
            _state.value = CartUiState(items = items, featured = items.firstOrNull())
```
````

````
🟢 **Low · Code quality · optional** — Unused import `kotlinx.coroutines.delay`

```suggestion
```
````

Use `suggestion` when:
- The fix is a 1–3 line drop-in replacement for the highlighted line(s)
- No surrounding context needs to change
- The correct code is unambiguous

Use a language block (not suggestion) when:
- The fix spans multiple non-contiguous locations
- A design decision or explanation is more valuable than the exact code
- The replacement requires context the author must supply

**QUESTION findings** (severity `QUESTION` from Bug Hunter) are not defects — they flag an asymmetry with related logic that is probably fine but easy to misread, and ask the author to confirm or document the intent. Use this shape instead of the one above — no severity, no label, no fix:

````
**❓ Question: <the intent being confirmed, phrased as a question>**

<2–3 sentences: what the diff does, the sibling it differs from (named by file/symbol), and how a later reader could misread the difference.>
````

Tone: findings, not verdicts. State the problem and its consequence; don't lecture. When something is a judgment call, say so ("Consider…" / "If X is intentional, ignore this"). Never pad the review with manufactured or speculative nitpicks to look thorough — a review with three real findings beats one with twenty trivia. A concrete, verifiable small catch (labeled optional) is not padding and stays welcome.

## Summary

After posting, print (heading depends on the resolved posting mode; append ` · lite` when `--lite` was resolved). If step 8 skipped posting because nothing survived, print `✅ No findings — nothing posted` in place of the heading and omit the posting-mode lines. Under `--local` or `--dry-run`, use `🧪 Local review — nothing posted` / `🧪 Dry run — nothing posted` as the heading, omit the posting-mode and Review URL lines, and, if the host reports token usage for the dispatched agents, add `Pass tokens: <sum>`:

```
✅ Draft review saved (NOT submitted)          [Draft mode]
✅ Review posted — visible on the PR now       [Live mode]

Posted (one line per inline comment, most severe first):
  🔴 must fix    <file>:<line>   <title>
  🟡 should fix  <file>:<line>   <title>
  …
Not tied to a diff line: <title>, <title>      [omit when none]
Over the LOW cap (<low_cap>), in the body's list: <file>:<line> <title>, …   [omit when none]
Applied directly: <file>:<line> <title>, …    [fix mode only]

Re-review since <sha7>: quick | escalated (<n> lines)[ · missed-issue sweep: skipped (PR > 1,500 lines)]   [--re-review only, this block]
Threads — yours:   <n> per verdict (`modes/re-review.md` section 5), zero parts omitted
Threads — others:  <same>
Threads — bots:    <same>
Replies posted: <n>[ · failed: <url>, …]
Reopened (were resolved, still not right): <url>, …   [omit when none; "Would reopen" under --local/--dry-run; visible now even in Draft]
Safe to resolve: <url>, <url>, …              [still-unresolved threads judged addressed, pushback valid or not an issue]
New findings: <n>                             [the inline comments above; replies aren't counted here]

Findings:
  🔴 Critical: <n>
  🟠 High:     <n>
  🟡 Medium:   <n>
  🟢 Low:      <n>
  ❓ Questions: <n>

By category (the findings' `category` field; omit zero rows):
  🐛 Bugs:            <n>
  🧯 Error handling:  <n>
  ⏳ Deprecations:    <n>
  🧹 Code quality:    <n>
  🧪 Tests:           <n>
  💬 Comments:        <n>
  🏗️  Type design:     <n>

🔀 Merged across passes: <n>
🔎 Re-verified: <n> confirmed · <n> softened · <n> dropped
🔁 Duplicates skipped (already on PR): <n>
🚫 Dropped for low confidence: <n>
🥊 Debate: <n> upheld · <n> weakened · <n> refuted (<n> dropped)   [only if a debate ran]

🔧 Fixes applied directly (--apply-safe-fixes): <n>          [only if fix mode was on]
🔎 Validation: <command run and result, or "skipped: <reason>">   [only if fix mode was on]
<git diff of the applied fixes> — uncommitted, not pushed       [only if fix mode applied any; the full diff, so each change can be checked]

Review URL: https://github.com/<owner>/<repo>/pull/<number>

The review is pending. Open the PR in GitHub to inspect, edit,       [Draft mode]
or submit your comments when ready. (Pass --live to post directly next time.)
💡 You reviewed this PR before (at <sha7>); --re-review checks your threads and only what changed since.   [only without --re-review, when you have an earlier review at another commit]
The review is live — comments are already visible on the PR.        [Live mode]

💡 For deeper platform coverage next run, install: <platform>: <skill source>, <platform>: <skill source>, ...   [only if step 2's "no skill installed for" list is non-empty]
```
