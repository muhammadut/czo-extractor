---
description: Extract all CZO/CSIO mapping codes and business rules for an insurance carrier, then validate the output. Produces a JSON code dictionary, plain-English rules document, and validation report.
---

Extract CZO mappings for carrier: $ARGUMENTS

**If no carrier name is provided** ($ARGUMENTS is empty), show usage and stop:
```
Usage: /czo-extractor:extract <CarrierName>

Example: /czo-extractor:extract Aviva

Run /czo-extractor:list to see available carriers.
```

## Step 0: Check for Existing Extraction

Before running a full extraction, check TWO locations for existing data:

1. **Live extraction** at the converter root: `.czo-extraction/carriers/<Carrier>/latest.json`
2. **Seed data** bundled with the plugin: `seed-data/carriers/<Carrier>/latest.json` (relative to this plugin's root directory — use the Glob tool to find `**/czo-extractor-plugin/seed-data/carriers/<Carrier>/latest.json`)

If extraction data is found in EITHER location, read the `_metadata` section from the JSON to get the extraction date and code counts, then present the user with a choice:

```
Found existing extraction for <Carrier>:
  Source: <seed data / live extraction>
  Date: <extractionDate from _metadata>
  Codes: <count from _metadata or verificationReport>
  Versions: <versions from _metadata>

Options:
  1) Use existing data (instant — copies to .czo-extraction/ if needed)
  2) Run fresh extraction (~5-10 min)
```

**If the user chooses option 1:**
- If the data is from seed-data and `.czo-extraction/carriers/<Carrier>/` doesn't exist yet, copy ALL files from `seed-data/carriers/<Carrier>/` to `.czo-extraction/carriers/<Carrier>/`
- If the data is already in `.czo-extraction/`, do nothing — it's already in place
- Update `.czo-extraction/inventory.json` if the carrier isn't listed yet
- Report the summary and stop (skip Steps 1 and 2)

**If the user chooses option 2**, or if NO existing data is found, proceed with the full extraction below.

---

This skill chains TWO agents in sequence:

## Step 1: Extraction (czo-extractor agent)

Launch the `czo-extractor` agent as a subagent. It runs 8 phases:
1. **Discovery** — find all version folders with carrier-specific code
2. **Constants** — parse CompanyConstants.vb (code dictionary)
3. **EnumConverters** — parse value mapping tables
4. **Generic Base** — trace inheritance to v043 foundational codes
5. **FrameworkToCsio** — parse outbound conversion logic
6. **CsioToFramework** — parse response parsing logic
7. **Verify** — cross-reference all codes via grep sweep
8. **Business Rules** — translate converter logic to plain English

Produces:
- `.czo-extraction/carriers/<Carrier>/<date>.json` — code dictionary
- `.czo-extraction/carriers/<Carrier>/<date>-rules.md` — business rules
- Both also copied to `latest.json` and `latest-rules.md`

## Step 2: Validation (semantic-verifier agent)

After extraction completes, launch the `semantic-verifier` agent as a separate subagent. It runs 8 validation gates:
1. File Integrity — all output files exist and are valid
2. JSON Schema — all required sections present
3. Code Entry Completeness — every code has csioCode, description, version, availableIn
4. Z-Code Cross-Reference — grep sweep confirms no Z-codes were missed
5. CompanyConstants Coverage — code counts match within 10%
6. Rules Document Coverage — key sections present (endorsements, deductibles, limits, provinces)
7. Version Tag Consistency — availableIn tags match actual CompanyConstants
8. Inventory Consistency — history and inventory files are correct

Produces:
- `.czo-extraction/carriers/<Carrier>/validation-<date>.md` — validation report

## After Both Complete

Report back with:
- Carrier name
- Extraction: total codes, Z-code count, files processed, versions covered
- Validation: gates passed (X/8), any critical issues or warnings
- Output file paths (JSON, rules, validation report)
- Overall status: PASS or FAIL
