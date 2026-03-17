---
description: Compare two extractions for a carrier to see what changed. Useful after code updates to identify new/removed/changed codes.
---

Diff: $ARGUMENTS

Parse the arguments:
- First word = carrier name
- Next two words = dates (YYYY-MM-DD) or "latest" keyword

Example: `/czo-extractor:diff Aviva 2026-03-17 2026-04-01`
Example: `/czo-extractor:diff Aviva 2026-03-17 latest`

## Procedure

1. Load the two extraction files from `.czo-extraction/carriers/<Carrier>/`
2. Compare the `zCodeInventory` sections — find added/removed Z-codes
3. Compare `coverageCodes` — find added/removed/changed coverage mappings
4. Compare `discountCodes` — find added/removed discounts and surcharges
5. Compare `enumMappings` — find changed enum value mappings

## Output Format

```
## Diff: Aviva (2026-03-17 vs 2026-04-01)

### Added Codes (in new, not in old)
- csio:ZNEW1 — New discount code (description)

### Removed Codes (in old, not in new)
- csio:ZOLD1 — Removed surcharge (description)

### Changed Mappings
- Earthquake BC deductible: was 5%, now 8%

### Summary
- X codes added, Y codes removed, Z mappings changed
```

If only one date is provided, compare that date against `latest.json`.
If no dates are provided, show the two most recent extractions from `history.json`.
