# Sharding Bug Hunter — step 3

Read by the orchestrator only, at step 3, when `added + removed` exceeds 1,500 lines. Step numbers refer to `SKILL.md`.

One Bug Hunter's attention thins out across the diff. Split the changed files into 2–3 groups by module or top-level directory (keep a file with its tests and its closest callers), write each group's paths to `<run dir>/shard-<n>.txt`, slice the diff with `<skill dir>/scripts/prepare-diff.sh slice <run dir>/pr.diff < <run dir>/shard-<n>.txt > <run dir>/shard-<n>.diff`, and dispatch one Bug Hunter per shard, pointing it at its `shard-<n>.diff` instead of `pr.diff` and adding to its one-line prompt: *"Your shard is the files in this diff; `context.md` lists the whole PR's files — read others only to check a call site or contract."* Other passes stay single. Shards' findings merge in step 5 like any other pass's.
