---
description: Answer questions about a carrier's CZO/CSIO mappings. Supports querying specific dates with @date syntax.
---

Query: $ARGUMENTS

**If $ARGUMENTS is empty**, show usage and stop:
```
Usage: /czo-extractor:query <CarrierName> <question>

Example: /czo-extractor:query Aviva What earthquake codes do we send in BC?
```

Parse the arguments:
- First word = carrier name
- Validate the carrier name matches a known carrier (check `.czo-extraction/carriers/` or `*/Companies/` folders). If not recognized, tell the user: "'<word>' is not a recognized carrier. Available carriers: <list>"
- If `@YYYY-MM-DD` appears anywhere, use that date's extraction instead of latest
- Remaining words = the question

## Data Sources

1. **Date-specific extraction**: If `@YYYY-MM-DD` was specified, read `.czo-extraction/carriers/<Carrier>/<YYYY-MM-DD>.json`
2. **Latest extraction**: Otherwise read `.czo-extraction/carriers/<Carrier>/latest.json`
3. **No extraction exists**: Tell the user to run `/czo-extractor:extract <Carrier>` first

## JSON Structure Reference

The extraction JSON has these top-level keys:
- `.coverageCodes.autoEndorsements` — auto endorsement codes (OPCF, etc.)
- `.coverageCodes.homeEndorsements` — home endorsement codes (earthquake, bylaw, water, etc.)
- `.coverageCodes.homeLiabilities` — liability coverage codes (day care, ATV, pool, etc.)
- `.coverageCodes.watercraftLiability` — boat/motor liability by HP/length
- `.coverageCodes.scheduledPropertyItems` — jewellery, cameras, furs, etc.
- `.discountCodes.autoDiscounts` — auto discount codes
- `.discountCodes.autoSurcharges` — auto surcharge codes
- `.discountCodes.habDiscounts` — home discount codes
- `.discountCodes.habSurcharges` — home surcharge codes
- `.discountCodes.tierCodes` — tier discount/surcharge codes
- `.genericBaseCodes` — standard CSIO codes inherited from generic base
- `.enumMappings` — policy types, vehicle types, construction types, etc.
- `.responseClassification` — IsDiscount/IsSurcharge prefix patterns
- `.zCodeInventory` — all carrier-proprietary Z-codes by category
- `.verificationReport` — completeness stats

Each code entry has: `csioCode`, `description`, `version` (latest version folder), `availableIn` (all versions containing this code). May also have: `source`, `provinceSpecific`, `deductibleOptions`, `limitOptions`.

### Version fields
- `"version": "V148"` — the latest version where this code is defined
- `"availableIn": ["V134", "V148"]` — which service versions include this code
- `"_metadata.versionRoles"` — explains what each version is (e.g., V148=Guidewire, V134=BAU)

### Common version-based queries
- "What codes are Guidewire-only?" → filter where `availableIn` contains only the Guidewire version
- "What codes are BAU-only?" → filter where `availableIn` does NOT contain the Guidewire version
- "What's new in V148?" → filter where `availableIn` = ["V148"] only

## Answer Format

- Include actual CZO codes (e.g., `csio:ERQK`) in every answer
- Note standard CSIO vs carrier-proprietary (Z-codes start with Z after csio:)
- Include the version and availableIn when relevant to the question
- Show province variants if applicable
- Show all condition branches (policy type, coverage type, etc.)
