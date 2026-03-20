---
description: Validate all code changes, generate diffs, and produce a review report. Presents Gate 2 for developer approval.
---

Review the code changes for the active workstream.

## Preconditions

**FIRST ACTION**: Find and read `.czo-workstreams/paths.md`.

Search in order: current directory, parent directories (up to 3 levels), known converter location.
If not found: "No workspace found. Run `/czo-extractor:edit-init <Carrier>` first."

Find the active workstream:
1. List directories in `<workstreams_root>/ws-*/`
2. Read each `manifest.yaml` to find the one with `state: EXECUTED`
3. If none found, tell the user: "No executed workstream found. Run `/czo-extractor:edit-execute` first."

## Step 1: Launch Verifier Agent

Launch the `verifier` agent as a subagent with this prompt:

```
Verify code changes for ticket <ticket_id>, carrier <Carrier>.

Paths:
- converter_root: <from paths.md>
- vb_parser: <from paths.md>
- vbproj: <from paths.md>

Workstream: <workstreams_root>/ws-<ticket_id>/
Files:
- plan/intents.yaml — what was planned
- plan/execution_plan.md — human-readable plan
- execution/operations_log.yaml — what was executed
- execution/snapshots/ — pre-edit file copies
- ticket/llm-context-brief.md — original ticket

Write outputs to: <workstreams_root>/ws-<ticket_id>/review/
```

The verifier agent will produce:
- `review/validation.md` — parser check + .vbproj check results
- `review/changes.diff` — unified diff of all changes
- `review/summary.md` — Gate 2 presentation document

## Step 2: Gate 2 — Developer Approval

Read `review/summary.md` and present it.

Format:
```
## Gate 2: Review Approval

**Ticket**: #<id> — <title>
**Carrier**: <Carrier>

### Validation Results
<from validation.md — parser checks, .vbproj integrity>

### Changes Made
<from changes.diff — show the full diff>

### Traceability
<from summary.md — mapping of ticket requirements to code changes>

---

**Approve these changes?**
- Type `approve` to finalize
- Type `reject` to revert all changes (snapshots will be restored)
- Type `rework` to go back to planning

After approval, changes are final. Consider running a build to verify.
```

On approval:
```yaml
# Update manifest.yaml
state: COMPLETED
gates:
  gate2_review: approved
  gate2_approved_at: <ISO timestamp>
completed_at: <ISO timestamp>
```

On rejection:
1. Restore all modified files from snapshots (copy snapshot back to original path using `snapshots/manifest.yaml`)
2. **Delete any files that were CREATED** (intents with `action: create_file`) — these have no snapshot, they must be removed
3. **Revert .vbproj changes** if any `<Compile Include>` entries were added for new files
4. Update `state: REVERTED`
5. Tell user: "Changes have been rolled back. To start over, delete the workstream and re-plan:"
```
rm -rf <workstreams_root>/ws-<ticket_id>
/czo-extractor:edit-plan <ticket>
```

On rework:
1. **Clean up execution artifacts**: delete `execution/` subdirectory (snapshots, operations_log) so the next execution starts fresh
2. Update `state: PLANNING`, reset `gate1_plan: pending`
3. Tell user to re-plan: `/czo-extractor:edit-plan <ticket>` (ticket content will be reused, not re-fetched)

## Step 3: Post-Approval Suggestion

After approval, suggest:
```
Changes approved. Recommended next steps:
1. Build the solution to verify compilation
2. Run `/czo-extractor:extract <Carrier>` to update the extraction with new codes
3. Commit the changes
```
