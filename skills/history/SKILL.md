---
description: Show extraction history for a carrier — all past extractions with dates, code counts, and version info.
---

History for: $ARGUMENTS

Read `.czo-extraction/carriers/<CarrierName>/history.json`.

If no carrier is specified, show a summary across ALL carriers from `.czo-extraction/inventory.json`.

## Output Format

For a specific carrier:
```
## Aviva — Extraction History

| Date       | Total Codes | Z-Codes | Files | Versions          | Status   |
|------------|------------|---------|-------|-------------------|----------|
| 2026-03-17 | 575        | 163     | 219   | V132, V134, V148  | complete |
| 2026-04-01 | 580        | 165     | 221   | V132, V134, V148  | complete |

Latest: 2026-04-01 (extractions/carriers/Aviva/latest.json)
Use `/czo-extractor:query Aviva @2026-03-17 <question>` to query a specific date.
Use `/czo-extractor:diff Aviva 2026-03-17 2026-04-01` to compare.
```

For all carriers (no argument):
```
## All Carriers — Last Extraction

| Carrier    | Last Extracted | Total Codes | Status    |
|------------|---------------|-------------|-----------|
| Aviva      | 2026-03-17    | 575         | extracted |
| Intact     | —             | —           | pending   |
| Wawanesa   | —             | —           | pending   |
```
