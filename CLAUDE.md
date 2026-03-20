# CZO Extractor Plugin

Extract, query, and edit CZO/CSIO mapping codes in VB.NET converter codebases for any insurance carrier.

## Installation

```bash
# Add marketplace
claude plugin marketplace add https://github.com/muhammadut/czo-extractor/.claude-plugin/marketplace.json

# Install plugin
claude plugin install czo-extractor@czo-extractor-marketplace
```

Or for local development:
```bash
claude --plugin-dir ./path/to/czo-extractor
```

## Skills

### `/czo-extractor:extract <CarrierName>`
Full 7-phase extraction for a carrier. Runs as an isolated subagent using the VB Parser. Saves output to `.czo-extraction/carriers/<Carrier>/<date>.json`.

```
/czo-extractor:extract Aviva
/czo-extractor:extract Intact
```

### `/czo-extractor:query <CarrierName> <question>`
Answer questions from extracted data. Supports `@YYYY-MM-DD` to query historical extractions.

```
/czo-extractor:query Aviva What earthquake codes do we send in BC?
/czo-extractor:query Aviva @2026-03-17 List all Z-codes
```

### `/czo-extractor:list [pending|extracted]`
Show all carriers and their extraction status.

```
/czo-extractor:list             # All carriers
/czo-extractor:list pending     # Only un-extracted
```

### `/czo-extractor:history [CarrierName]`
Show extraction history for a carrier or all carriers.

```
/czo-extractor:history Aviva    # Aviva's extraction timeline
/czo-extractor:history          # Summary of all carriers
```

### `/czo-extractor:diff <CarrierName> <date1> <date2>`
Compare two extractions to see what codes were added, removed, or changed.

```
/czo-extractor:diff Aviva 2026-03-17 2026-04-01
/czo-extractor:diff Aviva 2026-03-17 latest
```

## Code Editing (Ticket-Driven)

Ticket-driven workflow for modifying converter code. Reads an ADO ticket, analyzes the code, proposes changes, executes them, and verifies. Runs extraction automatically if not already done.

### `/czo-extractor:edit-init <CarrierName>`
One-time setup per carrier. Discovers paths, validates tools, checks extraction status, and configures ADO credentials.

```
/czo-extractor:edit-init Aviva
```

### `/czo-extractor:edit-plan <TicketNumber>`
Fetch an ADO ticket, analyze the converter code, and produce a change plan. Presents **Gate 1** for developer approval. Runs extraction first if none exists.

```
/czo-extractor:edit-plan 26765
/czo-extractor:edit-plan https://dev.azure.com/rivalitinc/.../_workitems/edit/26765
```

### `/czo-extractor:edit-execute`
Execute the approved plan — apply code changes with file snapshots and VB parser verification after each edit.

```
/czo-extractor:edit-execute
```

### `/czo-extractor:edit-review`
Validate all changes: parser checks, .vbproj integrity, diff generation, ticket traceability. Presents **Gate 2** for developer approval.

```
/czo-extractor:edit-review
```

### Edit Workflow

```
1. /czo-extractor:edit-init Aviva          # One-time setup
2. /czo-extractor:edit-plan 26765          # Analyze ticket → plan → Gate 1
3. /czo-extractor:edit-execute             # Apply changes → verify
4. /czo-extractor:edit-review              # Validate → diff → Gate 2
```

### Edit Workspace Structure

```
.czo-workstreams/                          # At converter root
├── paths.md                               # All absolute paths (read first by every command)
├── config.yaml                            # Carrier metadata
└── ws-<ticket-id>/                        # Per-ticket workstream
    ├── manifest.yaml                      # State machine + gate approvals
    ├── ticket/                            # Fetched ticket content
    │   ├── llm-context.md                 # Full ticket
    │   ├── llm-context-brief.md           # Brief version
    │   └── attachments/                   # Downloaded files
    ├── plan/
    │   ├── execution_plan.md              # Human-readable (Gate 1)
    │   └── intents.yaml                   # Machine-readable change list
    ├── execution/
    │   ├── snapshots/                     # Pre-edit file copies
    │   └── operations_log.yaml            # What was done
    └── review/
        ├── validation.md                  # Parser + .vbproj checks
        ├── changes.diff                   # Unified diff
        └── summary.md                     # Gate 2 presentation
```

### Important Notes

- **One workstream at a time**: Avoid running multiple edit-plan/execute cycles on the same carrier simultaneously. If two workstreams modify the same files, the second execution may find that anchors have shifted. Complete one ticket before starting the next.
- **Stale plans**: If the converter code changes between plan approval and execution (e.g., someone else commits), the editor may report anchor mismatches. Re-plan if this happens.
- **External document links**: SharePoint/OneDrive links in tickets are NOT auto-downloaded. The edit-plan skill will pause and ask you to download them manually.

### ADO Credentials

Create a `.env` file at the converter root (or parent directory):
```bash
export ADO_PAT='your-personal-access-token'
export ADO_ORG='rivalitinc'
export ADO_PROJECT='Rival Insurance Technology'
export ADO_USE_VSCOM='1'
```

## Output Folder Structure

All extractions are saved in `.czo-extraction/` at the converter root:

```
.czo-extraction/
├── config.json                          # Plugin state and settings
├── inventory.json                       # All carriers + extraction status
└── carriers/
    └── Aviva/
        ├── latest.json                  # Most recent extraction (auto-updated)
        ├── 2026-03-17.json              # Date-stamped extraction
        └── history.json                 # Extraction log for this carrier
```

## VB Parser

The Roslyn-based VB Parser is **bundled** at `tools/win-x64/vb-parser.exe` (37MB, tracked via Git LFS). No external dependencies required. The agent auto-detects it from the plugin's tools/ directory.

## Architecture Quick Reference

### Version Folders & Inheritance
- **v043/** through **V149/** = versioned folders with class inheritance (latest wins)
- Each version inherits from the previous: V148 → V146 → V145 → ... → v043
- **Generic/** = shared converters for all carriers (base implementations)
- **Companies/\<Carrier\>/** = carrier-specific overrides (inherit from Generic or earlier company version)
- **NEVER create new V-folders** — only add/edit files within existing version folders

### Conversion Directions
```
  TBW (our framework)                        CSIO/CZO (carrier side)
       │                                          │
       │── FrameworkToCsio/ ──── REQUEST ────────►│   (outbound: we send to carrier)
       │   ├── Unrated/  ← most request changes   │
       │   └── Rated/    ← rarely changed          │
       │                                          │
       │◄──── CsioToFramework/ ── RESPONSE ───────│   (inbound: carrier sends back)
       │   ├── Rated/    ← premium parsing         │
       │   └── Unrated/  ← non-premium parsing     │
```
- **FrameworkToCsio/** = REQUEST direction. We convert our TBW data → CSIO XML to send to carriers. Most ticket changes are in `Unrated/`.
- **CsioToFramework/** = RESPONSE direction. Carrier sends back CSIO XML, we parse it → TBW. Premium-related changes are in `Rated/`.
- **EnumConverters/** = Shared value-mapping tables used by BOTH directions. A change here affects both request and response.

### Key Files Per Carrier
- **CompanyConstants.vb** = CZO code dictionary (all `csio:` constants)
- **EnumConverters/CoverageCodeConverter.vb** = Select Case mapping of framework enums → CZO codes
- **ConverterFactory.vb** (in each subdirectory) = Factory that builds converter instances; MUST be updated when creating new converter files
- **Cssi.Schemas.Csio.Converters.vbproj** = Project file with EXPLICIT `<Compile Include>` entries; new files MUST be registered here

### File Creation Pattern
When a ticket requires changes to a converter that doesn't exist in the latest version:
1. Trace inheritance back to find the file (V134, V132, or v043/Generic)
2. Create new file in latest version inheriting from where you found it
3. Override only the specific method(s) needed
4. Update the ConverterFactory.vb in the same directory to return the new converter
5. Add `<Compile Include>` entry to the .vbproj
