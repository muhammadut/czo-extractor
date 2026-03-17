---
description: Extract all CZO/CSIO mapping codes for an insurance carrier from the converter codebase
---

Extract CZO mappings for carrier: $ARGUMENTS

Use the `czo-extractor` agent to perform the extraction. Pass it the carrier name from the arguments above.

The agent will:
1. Auto-detect the VB Parser and converter codebase location
2. Find all version folders with carrier-specific code
3. Parse constants, enum converters, FrameworkToCsio, and CsioToFramework files
4. Extract the generic base codes the carrier inherits
5. Cross-verify all codes
6. Write the output to `extracts/<CarrierName>_czo_mapping.json`

Report back with a summary of what was extracted: total codes found, Z-code count, file count, and any verification warnings.
