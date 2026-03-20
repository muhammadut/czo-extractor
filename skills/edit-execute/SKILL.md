---
description: Execute the approved plan — apply code changes to VB.NET converter files with snapshots and verification.
---

Execute the approved code change plan.

## Preconditions

**FIRST ACTION**: Find and read `.czo-workstreams/paths.md`.

Search in order: current directory, parent directories (up to 3 levels), known converter location.
If not found: "No workspace found. Run `/czo-extractor:edit-init <Carrier>` first."

Then find the active workstream:
1. List directories in `<workstreams_root>/ws-*/`
2. Read each `manifest.yaml` to find one matching:
   - `state: PLANNING` with `gate1_plan: approved` (fresh execution), OR
   - `state: EXECUTE_FAILED` (retry after failure)
3. If none found, tell the user: "No approved plan found. Run `/czo-extractor:edit-plan <ticket>` first."
4. If multiple found, list them and ask which to execute.

## Step 1: Load the Plan

Read from the workstream directory:
- `plan/intents.yaml` — the machine-readable change list
- `plan/execution_plan.md` — for reference
- `manifest.yaml` — verify Gate 1 was approved

Update manifest state to `EXECUTING`.

## Step 2: Launch Editor Agent

Launch the `editor` agent as a subagent with this prompt:

```
Execute code changes for ticket <ticket_id>, carrier <Carrier>.

Paths:
- converter_root: <from paths.md>
- vb_parser: <from paths.md>

Plan: <workstreams_root>/ws-<ticket_id>/plan/intents.yaml
Snapshots dir: <workstreams_root>/ws-<ticket_id>/execution/snapshots/
Operations log: <workstreams_root>/ws-<ticket_id>/execution/operations_log.yaml

Key rules:
1. Snapshot EVERY file before editing (copy to snapshots/)
2. Apply edits using the Edit tool (NEVER write entire files)
3. Run VB parser after EACH file edit to verify no parse errors
4. If parser finds errors, REVERT from snapshot and report failure
5. Log every operation to operations_log.yaml
6. Edit files bottom-to-top (highest line numbers first) to preserve line numbers
```

## Step 3: Report Results

After the editor agent completes, read `execution/operations_log.yaml`.

Update manifest:
- If all edits succeeded: `state: EXECUTED`
- If any edits failed: `state: EXECUTE_FAILED`, list failures

Report to user:
```
## Execution Complete

**Ticket**: #<id>
**Files modified**: <count>
**Operations**: <count> edits applied

<list each file and what was done>

Failures: <none or list>

Next: /czo-extractor:edit-review
```

## Error Recovery

If the editor agent fails mid-execution:
- All snapshots are preserved in `execution/snapshots/`
- The operations log shows what was completed
- State is set to `EXECUTE_FAILED`

**Re-running `/czo-extractor:edit-execute`** after a failure:
1. It will detect `state: EXECUTE_FAILED` in the manifest
2. Read `execution/operations_log.yaml` to find completed operations
3. **Skip** intents that were already successfully applied (matching intent IDs in operations log)
4. Resume from the first incomplete/failed intent
5. If a file was partially edited and reverted (from snapshot), it will re-snapshot and retry all intents for that file

**Manual revert** — to undo all changes and start over:
1. For each file in `execution/snapshots/`, copy the snapshot back to its original path
2. Delete the workstream directory: `rm -rf <workstreams_root>/ws-<ticket_id>`
3. Re-plan with `/czo-extractor:edit-plan <ticket>`

**Important**: The edit-execute skill also accepts `state: EXECUTE_FAILED` workstreams (not just `PLANNING` with approved gate1). This allows retry after failure.
