---
description: Answer questions about a carrier's CZO/CSIO mappings. Supports querying specific dates with @date syntax.
---

Query: $ARGUMENTS

Parse the arguments:
- First word = carrier name
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

Each code entry has at minimum: `csioCode`, `description`. May also have: `source`, `provinceSpecific`, `deductibleOptions`, `limitOptions`.

## Answer Format

- Include actual CZO codes (e.g., `csio:ERQK`) in every answer
- Note standard CSIO vs carrier-proprietary (Z-codes start with Z after csio:)
- Show province variants if applicable
- Show all condition branches (policy type, coverage type, etc.)
