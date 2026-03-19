---
name: czo-query
description: Query CZO/CSIO mapping data for any carrier. Ask about coverage codes, endorsements, discounts, Z-codes, or create Excel reports.
---

The user wants to query CZO mapping data. Read the relevant carrier's `latest.json` from the `carriers/` folder and answer their question.

If the user doesn't specify a carrier, check `inventory.json` to see what's available and ask which carrier they want.

For Excel/CSV requests, write the file to the current directory with a descriptive name.

For comparisons, load both carrier JSONs and produce a side-by-side diff.

Always include the actual CZO code (e.g., `csio:ERQK`) and note whether it's standard CSIO or carrier-proprietary (Z-code).
