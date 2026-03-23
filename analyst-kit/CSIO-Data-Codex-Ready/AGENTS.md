# CSIO Mapping Analyst Workspace

You are helping a business analyst query and analyze CSIO insurance mapping data. The data has been pre-extracted from the VB.NET converter codebase and saved as JSON files.

## What This Data Is

When an insurance broker fills out a policy in TBW (The Broker's Workstation), the system converts that data into CZO/CSIO XML format and sends it to carriers like Aviva, Intact, Wawanesa, etc. These JSON files contain **every code** that gets sent in that XML — coverages, endorsements, discounts, surcharges, and more.

This data helps the analyst understand: "What are we currently sending to each carrier?" without having to manually run test quotes.

## Data Location

All extraction data is in the `carriers/` folder:
```
carriers/
├── Aviva/
│   ├── latest.json          ← code dictionary (use this for code lookups)
│   ├── latest-rules.md      ← business rules in plain English (use this for HOW/WHEN/WHY questions)
│   ├── 2026-03-17.json      ← date-stamped code dictionary
│   ├── 2026-03-17-rules.md  ← date-stamped business rules
│   └── history.json         ← log of all extractions
├── Intact/
│   ├── latest.json
│   ├── latest-rules.md
│   └── ...
└── ...
```

Also:
- `inventory.json` — shows all carriers and their extraction status
- `config.json` — extraction settings

**Two files per carrier — use BOTH:**
- `latest.json` — answers "WHAT codes exist?" (the dictionary)
- `latest-rules.md` — answers "HOW does it work?" (the logic, conditions, province rules)

Always check BOTH files when answering questions. The JSON has the code list; the rules doc has the conversion logic (province-specific branches, deductible tiers, limit calculations, version differences).

## JSON Structure

Each carrier's JSON has these sections:

### `_metadata`
Carrier name, versions extracted, date, file count.
- `versionRoles` explains what each version is used for (e.g., V148=Guidewire new service, V134=BAU current service)

### `coverageCodes`
The core data. Sub-sections:
- `autoEndorsements` — auto policy add-ons (OPCF endorsements, bundles, accident benefits)
- `homeEndorsements` — home policy add-ons (earthquake, building bylaw, water coverage, etc.)
- `homeLiabilities` — liability coverages (day care, ATV, pool, business use, etc.)
- `watercraftLiability` — boat/motor liability codes by HP and length
- `scheduledPropertyItems` — jewellery, cameras, furs, musical instruments, etc.

### `discountCodes`
- `autoDiscounts` — auto discounts (multi-vehicle, loyalty, telematics, etc.)
- `autoSurcharges` — auto surcharges (claims, convictions, high performance, etc.)
- `habDiscounts` — home discounts (new home, claims-free, security system, etc.)
- `habSurcharges` — home surcharges (log home, absentee landlord, etc.)
- `tierCodes` — tier-based discount/surcharge codes

### `genericBaseCodes`
Standard CSIO codes that the carrier inherits from the base system without modification.

### `enumMappings`
Non-coverage field translations: policy types, vehicle body types, construction types, fire protection classes, conviction codes, lapse reasons, etc.

### `responseClassification`
How the system identifies whether a code coming back from the carrier is a discount or surcharge (prefix patterns).

### `zCodeInventory`
Complete list of carrier-proprietary Z-codes (codes starting with Z that only this carrier uses). Grouped by: autoCoverage, habCoverage, discountsSurcharges.

### `verificationReport`
Extraction completeness stats, version breakdown, any orphan or undeclared codes.

## Code Entry Format

Each code entry looks like:
```json
{
  "csioCode": "csio:ERQK",           // The actual code sent in XML
  "source": "aviva",                   // "standard" = all carriers use it, "aviva" = proprietary
  "version": "V134",                   // Latest version where this code is defined
  "availableIn": ["V134", "V148"],     // Which service versions include this code
  "description": "Earthquake Coverage"
}
```

### Key concepts:
- **csioCode** — the literal string that appears in the CSIO XML sent to the carrier
- **source: "standard"** — this is a standard CSIO code all carriers understand
- **source: "aviva"** (or other carrier name) — this is a proprietary code only this carrier uses
- **Z-codes** — codes where the part after "csio:" starts with Z (e.g., `csio:ZINTD`). These are ALWAYS carrier-proprietary
- **version** — the latest converter version folder where this code appears
- **availableIn** — tells you which services use this code:
  - `["V148"]` only → Guidewire-only (new service)
  - `["V134"]` only → BAU-only (current service, dropped from new)
  - `["V134", "V148"]` → both services

## Which File Answers Which Question

| Question type | Use this file |
|---|---|
| "What code do we send for X?" | `latest.json` |
| "List all Z-codes" | `latest.json` → zCodeInventory |
| "What codes are Guidewire-only?" | `latest.json` → filter by availableIn |
| "How does earthquake deductible work in BC?" | `latest-rules.md` |
| "What are the province-specific rules?" | `latest-rules.md` |
| "What limit options exist for building bylaw?" | `latest-rules.md` |
| "What changed between V134 and V148?" | `latest-rules.md` → Version Differences section |
| "Create an Excel of all codes" | `latest.json` |
| "Compare Aviva vs Intact" | Both carriers' `latest.json` |

**Rule of thumb**: If the question is "WHAT code?" → JSON. If the question is "HOW/WHEN/WHY?" → rules.md. If unsure, check both.

## What You Can Do

When the analyst asks questions, you can:

1. **Look up codes**: Read the JSON and find specific coverages, endorsements, discounts
2. **Explain conversion logic**: Read the rules doc and explain how a specific code is determined (conditions, province rules, deductible tiers)
3. **Create Excel files**: Generate .csv or .xlsx files with any subset of the data
4. **Compare carriers**: Load two carrier JSONs and diff their codes
5. **Filter by version**: Show only Guidewire-new codes, BAU-only codes, etc.
6. **List Z-codes**: Show all proprietary codes that may need updating
7. **Province analysis**: Read rules doc for province-specific branches
8. **Create reports**: Summarize findings in tables, charts, or documents
9. **Answer "what do we send?"**: For any coverage/endorsement/discount, show the exact code AND the conditions under which it's sent

## Common Questions the Analyst Will Ask

- "What coverages do we send for Aviva home?"
- "List all Z-codes for Aviva"
- "What earthquake deductible options do we have?" ← needs rules.md
- "How does earthquake work differently in BC vs Alberta?" ← needs rules.md
- "What discounts are Guidewire-only?"
- "Create an Excel of all auto endorsements with their codes"
- "Compare Aviva vs Intact home endorsements"
- "What codes were dropped from V134 to V148?"
- "Which codes are proprietary vs standard CSIO?"
- "What building bylaw limit options exist?" ← needs rules.md
- "Show all watercraft liability codes by boat type" ← needs rules.md
- "How does End 39 routing work in NS vs Ontario?" ← needs rules.md
- "What sewer backup limit do we send in NB vs Ontario?" ← needs rules.md
