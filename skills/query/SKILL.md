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
3. **Live code**: If no extraction exists, tell the user to run `/czo-extractor:extract <Carrier>` first, or offer to read files directly using the `czo-extractor` agent

## Answer Format

- Include actual CZO codes (e.g., `csio:ERQK`) in every answer
- Note standard CSIO vs carrier-proprietary (Z-codes)
- Show province variants if applicable
- Show all condition branches (policy type, coverage type, etc.)
- Include source file path where the mapping is defined

## Example Queries

```
/czo-extractor:query Aviva What earthquake codes do we send in BC?
/czo-extractor:query Aviva List all Z-codes
/czo-extractor:query Aviva @2026-03-17 What discounts existed on that date?
```
