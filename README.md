# CZO Extractor

A Claude Code plugin that extracts and queries CZO/CSIO mapping codes from VB.NET converter codebases for insurance carriers.

## What It Does

Insurance brokers use TBW (The Broker's Workstation) to collect policy data. This data gets converted into CZO/CSIO XML format and sent to carriers (Aviva, Intact, Wawanesa, etc.). The conversion logic lives in thousands of VB.NET files across 30+ versioned folders with complex inheritance.

This plugin extracts **every CZO code, coverage mapping, discount, surcharge, endorsement, and Z-code** from that codebase and produces a structured JSON inventory — saving weeks of manual analysis.

## Installation

```bash
# Add the marketplace
claude plugin marketplace add https://github.com/muhammadut/czo-extractor/.claude-plugin/marketplace.json

# Install the plugin
claude plugin install czo-extractor@czo-extractor-marketplace
```

### Prerequisites

- [Claude Code CLI](https://claude.ai/code)
- Git LFS (for the bundled VB Parser binary)

## Usage

Open Claude Code in your converter project directory, then:

```bash
# Extract all CZO mappings for a carrier
/czo-extractor:extract Aviva

# Ask questions about the extraction
/czo-extractor:query Aviva What earthquake codes do we send in BC?
/czo-extractor:query Aviva List all Z-codes
/czo-extractor:query Aviva @2026-03-17 What discounts existed then?

# See all carriers and extraction status
/czo-extractor:list
/czo-extractor:list pending

# View extraction history
/czo-extractor:history Aviva

# Compare two extractions
/czo-extractor:diff Aviva 2026-03-17 2026-04-01
```

## Output

Extractions are saved to `.czo-extraction/` in your project:

```
.czo-extraction/
├── config.json                    # Plugin state
├── inventory.json                 # All carriers + status
└── carriers/
    └── Aviva/
        ├── latest.json            # Most recent extraction
        ├── 2026-03-17.json        # Date-stamped (never overwritten)
        └── history.json           # Extraction log
```

## How It Works

The plugin uses a 7-phase extraction methodology:

1. **Discovery** — Find all version folders with carrier-specific code
2. **Constants** — Parse CompanyConstants.vb (the carrier's CZO code dictionary)
3. **EnumConverters** — Parse value mapping tables (coverage codes, discounts, surcharges)
4. **Generic Base** — Parse the foundational codes all carriers inherit from v043
5. **FrameworkToCsio** — Parse outbound conversion logic (TBW → CZO XML)
6. **CsioToFramework** — Parse inbound response parsing (CZO XML → TBW)
7. **Verify** — Cross-reference all codes via grep sweep

Files are parsed using the Roslyn-based VB Parser (bundled at `tools/win-x64/vb-parser.exe`, tracked via Git LFS) for reliable structural analysis of VB.NET code.

## License

MIT
