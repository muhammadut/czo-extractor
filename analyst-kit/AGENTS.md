# CZO Mapping Analyst Workspace

You are helping a business analyst query and analyze CZO/CSIO insurance mapping data. The data has been pre-extracted from the VB.NET converter codebase and saved as JSON files.

## What This Data Is

When an insurance broker fills out a policy in TBW (The Broker's Workstation), the system converts that data into CZO/CSIO XML format and sends it to carriers like Aviva, Intact, Wawanesa, etc. These JSON files contain **every code** that gets sent in that XML — coverages, endorsements, discounts, surcharges, and more.

This data helps the analyst understand: "What are we currently sending to each carrier?" without having to manually run test quotes.

## Data Location

All extraction data is in the `carriers/` folder:
```
carriers/
├── Aviva/
│   ├── latest.json          ← most recent extraction (use this by default)
│   ├── 2026-03-17.json      ← date-stamped extraction
│   └── history.json         ← log of all extractions
├── Intact/
│   ├── latest.json
│   └── ...
└── ...
```

Also:
- `inventory.json` — shows all carriers and their extraction status
- `config.json` — extraction settings

Always use `carriers/<Carrier>/latest.json` unless the user specifies a date.

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
- **csioCode** — the literal string that appears in the CZO XML sent to the carrier
- **source: "standard"** — this is a standard CSIO code all carriers understand
- **source: "aviva"** (or other carrier name) — this is a proprietary code only this carrier uses
- **Z-codes** — codes where the part after "csio:" starts with Z (e.g., `csio:ZINTD`). These are ALWAYS carrier-proprietary
- **version** — the latest converter version folder where this code appears
- **availableIn** — tells you which services use this code:
  - `["V148"]` only → Guidewire-only (new service)
  - `["V134"]` only → BAU-only (current service, dropped from new)
  - `["V134", "V148"]` → both services

## What You Can Do

When the analyst asks questions, you can:

1. **Look up codes**: Read the JSON and find specific coverages, endorsements, discounts
2. **Create Excel files**: Generate .csv or .xlsx files with any subset of the data
3. **Compare carriers**: Load two carrier JSONs and diff their codes
4. **Filter by version**: Show only Guidewire-new codes, BAU-only codes, etc.
5. **List Z-codes**: Show all proprietary codes that may need updating
6. **Province analysis**: Check for province-specific logic in the data
7. **Create reports**: Summarize findings in tables, charts, or documents
8. **Answer "what do we send?"**: For any coverage/endorsement/discount, show the exact code

## Common Questions the Analyst Will Ask

- "What coverages do we send for Aviva home?"
- "List all Z-codes for Aviva"
- "What earthquake deductible options do we have?"
- "What discounts are Guidewire-only?"
- "Create an Excel of all auto endorsements with their codes"
- "Compare Aviva vs Intact home endorsements"
- "What codes were dropped from V134 to V148?"
- "Which codes are proprietary vs standard CSIO?"
- "What building bylaw limit options exist?"
- "Show all watercraft liability codes by boat type"
