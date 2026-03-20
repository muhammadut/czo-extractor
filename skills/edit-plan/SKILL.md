---
description: Fetch an ADO ticket and produce a code change plan for the carrier's CSIO converters. Runs extraction first if needed. Presents Gate 1 for developer approval.
---

Plan code changes for ticket: $ARGUMENTS

## Preconditions

**FIRST ACTION**: Find and read `.czo-workstreams/paths.md`.

Search for it in this order:
1. Current working directory: `./.czo-workstreams/paths.md`
2. Parent directories (up to 3 levels): `../.czo-workstreams/paths.md`, etc.
3. Known converter location: `E:/cssi/Cssi.Net/Components/Cssi.Schemas/Cssi.Schemas.Csio.Converters/.czo-workstreams/paths.md`

If not found, tell the user: "No workspace found. Run `/czo-extractor:edit-init <Carrier>` from the converter root first."

Parse all paths from it. These are your source of truth for the rest of this skill.

Also read `.czo-workstreams/config.yaml` for carrier metadata.
If config.yaml doesn't exist, tell the user: "Workspace incomplete — config.yaml not found. Re-run `/czo-extractor:edit-init <Carrier>`."

## Step 1: Parse Arguments

**If $ARGUMENTS is empty**, tell the user and stop:
```
Usage: /czo-extractor:edit-plan <ticket-number>

Example: /czo-extractor:edit-plan 26765
         /czo-extractor:edit-plan https://dev.azure.com/.../26765
```

- Accept a work item ID (e.g., `26765`) or full ADO URL
- Extract the numeric ID
- If no numeric ID can be extracted, error: "Expected a ticket number or ADO URL. Got: '<input>'"

## Step 2: Check for Existing Extraction

Read `latest_json` from paths.md.

**If extraction does NOT exist** (`NOT_EXTRACTED`):
1. Tell the user: "No extraction found for <Carrier>. Running extraction first to build the code dictionary..."
2. Launch the `czo-extractor` agent as a subagent with the carrier name.
3. After extraction completes, launch the `semantic-verifier` agent to validate.
4. If extraction fails OR the semantic-verifier reports CRITICAL failures, STOP and tell the user: "Extraction failed or has critical issues. Run `/czo-extractor:extract <Carrier>` manually to investigate, then retry `/czo-extractor:edit-plan`."
5. Update paths.md — change `latest_json` and `latest_rules` from `NOT_EXTRACTED` to the new file paths:
   - `latest_json: <converter_root>/.czo-extraction/carriers/<Carrier>/latest.json`
   - `latest_rules: <converter_root>/.czo-extraction/carriers/<Carrier>/latest-rules.md`
6. Update config.yaml — set `extraction.exists: true`, `extraction.date`, `extraction.total_codes`, `extraction.z_codes` from the new extraction's `_metadata`.
7. Continue to Step 3.

**If extraction exists**: Continue directly.

## Step 3: Fetch the Ticket

**First check if ticket was already fetched** (e.g., from a rework/re-plan):
```bash
test -f <workstreams_root>/ws-<ticket_id>/ticket/llm-context.md
```
If it exists, skip the fetch and go directly to Step 3b.

Otherwise, source the .env file and run fetch-ticket.sh with explicit output directory:
```bash
source <env_file> && export ADO_OUT_DIR="<workstreams_root>" && bash <fetch_ticket_path> <ticket_id>
```

**If fetch-ticket.sh fails** (non-zero exit code):
- Check if .env has all required vars: `ADO_PAT`, `ADO_ORG`, `ADO_PROJECT`
- If PAT is expired/invalid: tell user "ADO authentication failed. Check your PAT in <env_file>."
- If network error: tell user "Could not reach Azure DevOps. Check network connectivity."
- If ticket not found: tell user "Work item <id> not found in <org>/<project>."
- **Do not proceed** — the ticket content is required.

The output goes to `workitem-<id>-full/` in the current directory.

**Verify output exists**:
```bash
test -f <workstreams_root>/workitem-<ticket_id>-full/llm-context-brief.md
```

Move the output into the workstream:
```bash
mkdir -p <workstreams_root>/ws-<ticket_id>/ticket
mv <workstreams_root>/workitem-<ticket_id>-full/* <workstreams_root>/ws-<ticket_id>/ticket/
rmdir <workstreams_root>/workitem-<ticket_id>-full
```

## Step 3b: Check for External Links

After fetching the ticket, read `<workstreams_root>/ws-<ticket_id>/ticket/llm-context.md` and scan for external links (SharePoint, OneDrive, or other URLs that fetch-ticket.sh couldn't download).

Common patterns to look for:
- `https://cssionline0.sharepoint.com/...`
- `https://*.sharepoint.com/...`
- Links to `.docx`, `.xlsx`, `.pdf` files
- Any URL that is NOT an ADO attachment URL

**If external links are found**, tell the developer:

```
This ticket references external documents that couldn't be auto-downloaded:

  1. <link URL> — <filename if visible>
  2. ...

Please download these files and place them in:
  <workstreams_root>/ws-<ticket_id>/ticket/attachments/

Then type 'continue' to proceed with analysis.
```

**Wait for the developer to confirm** before proceeding. The analyzer agent needs these documents to produce an accurate plan.

If no external links are found, proceed directly.

## Step 4: Create Workstream Manifest

**Check for existing workstream** at `<workstreams_root>/ws-<ticket_id>/manifest.yaml`:
- If it exists and state is `EXECUTED` or `COMPLETED`: warn the user "This ticket already has executed changes. Re-planning will reset the workstream. Type 'continue' to proceed or 'cancel' to stop."
- If it exists and state is `PLANNING` with `gate1_plan: approved`: warn "Plan was already approved. Re-planning will reset approval. Continue?"
- If state is `PLANNING` with `gate1_plan: pending`: proceed silently (re-plan is expected)

Write `<workstreams_root>/ws-<ticket_id>/manifest.yaml`:
```yaml
ticket_id: <id>
carrier: <Carrier>
state: PLANNING
created: <ISO timestamp>
gates:
  gate1_plan: pending
  gate2_review: pending
```

## Step 5: Launch Analyzer Agent

Launch the `analyzer` agent as a subagent with this prompt:

```
Analyze ticket <ticket_id> for carrier <Carrier>.

Paths:
- converter_root: <from paths.md>
- vb_parser: <from paths.md>
- latest_json: <from paths.md>
- latest_rules: <from paths.md>
- ticket_content: <workstreams_root>/ws-<ticket_id>/ticket/llm-context.md
- ticket_brief: <workstreams_root>/ws-<ticket_id>/ticket/llm-context-brief.md
- attachments_dir: <workstreams_root>/ws-<ticket_id>/ticket/attachments/

Carrier versions: <from config.yaml>
Key files: <from config.yaml>

Write your outputs to: <workstreams_root>/ws-<ticket_id>/plan/
```

The analyzer agent will produce:
- `execution_plan.md` — human-readable plan (for Gate 1)
- `intents.yaml` — machine-readable change list (for edit-execute)

**Validate analyzer output**:
1. Check `plan/execution_plan.md` exists and is non-empty
2. Check `plan/intents.yaml` exists and is valid YAML
3. If intents array is empty, tell user: "No code changes identified for this ticket. The ticket may not contain actionable CSIO/CZO mapping changes."
4. Check each intent has required fields: `id`, `file`, `action`, `changes`
5. Check that every file referenced in intents actually exists (except for `create_file` intents where the file is new)
6. **Check for `[NEEDS CLARIFICATION]` markers** in any intent's content. If found, flag them prominently at Gate 1: "WARNING: X intents have unresolved placeholders that MUST be filled in before execution."
7. If validation fails, tell the user what went wrong and offer to re-run analysis

## Step 6: Gate 1 — Developer Approval

Read the `execution_plan.md` the analyzer produced and present it to the developer.

Format:
```
## Gate 1: Plan Approval

**Ticket**: #<id> — <title>
**Carrier**: <Carrier> (version <latest_version>)

### Proposed Changes

<contents of execution_plan.md>

---

**Approve this plan?**
- Type `approve` to proceed to execution
- Type `reject` to cancel
- Type `modify` to request changes to the plan

After approval: `/czo-extractor:edit-execute`
```

On approval, update manifest.yaml:
```yaml
gates:
  gate1_plan: approved
  gate1_approved_at: <ISO timestamp>
```

On rejection, update state to `REJECTED` and explain how to re-plan.

## Important Notes

- If the ticket contains links to external documents (SharePoint, etc.) that couldn't be downloaded, **tell the developer**: "The ticket references external documents that couldn't be fetched. Please paste the relevant content or attach it to the ADO ticket."
- If the ticket has downloaded attachments (images, docs), tell the analyzer agent about them so it can read them.
- The analyzer agent has access to the full CZO extraction (latest.json + latest-rules.md) as context — this is the key advantage over iq-update, which has to discover code from scratch.
