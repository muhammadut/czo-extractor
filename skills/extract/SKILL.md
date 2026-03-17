---
description: Extract all CZO/CSIO mapping codes for an insurance carrier. Output saved to .czo-extraction/carriers/<CarrierName>/<date>.json
---

Extract CZO mappings for: $ARGUMENTS

Use the `czo-extractor` agent to perform a full 7-phase extraction for the specified carrier.

The agent will:
1. Auto-detect the VB Parser and converter codebase
2. Find all version folders with carrier-specific code
3. Parse constants, enum converters, FrameworkToCsio, CsioToFramework files
4. Extract generic base codes the carrier inherits
5. Cross-verify all codes via grep sweep
6. Write output to `.czo-extraction/carriers/<CarrierName>/<today's date>.json`
7. Update `latest.json`, `history.json`, and `inventory.json`

Report back with: carrier name, total codes found, Z-code count, files processed, versions covered, and the output file path.
