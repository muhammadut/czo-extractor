# CZO Extractor Plugin

Extract and query CZO/CSIO mapping codes from VB.NET converter codebases for any insurance carrier.

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

- **v043/** through **V149/** = versioned folders with class inheritance (latest wins)
- **Generic/** = shared converters for all carriers
- **Companies/\<Carrier\>/** = carrier-specific overrides
- **FrameworkToCsio/** = TBW to CZO XML (outbound)
- **CsioToFramework/** = CZO XML to TBW (inbound)
- **CompanyConstants.vb** = carrier's CZO code dictionary
- **EnumConverters/** = value-to-value lookup tables
