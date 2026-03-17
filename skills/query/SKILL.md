---
description: Answer questions about a carrier's CZO/CSIO mappings from extracted data or live code
---

Query: $ARGUMENTS

Parse the arguments to extract the carrier name (first word) and the question (remaining words).

## Data Sources (check in order)

1. **Pre-extracted JSON** — look for `extracts/<CarrierName>_czo_mapping.json` in the converter root
2. **Live code** — if no extract exists, use the `czo-extractor` agent to read files directly

## Answer Format

- Include the actual CZO code (e.g., `csio:ERQK`) in every answer
- Note whether codes are standard CSIO or carrier-proprietary (Z-codes)
- Show province variants if the answer varies by province
- Show all condition branches if the answer depends on policy type, coverage type, etc.
- Include the source file path where the mapping is defined
