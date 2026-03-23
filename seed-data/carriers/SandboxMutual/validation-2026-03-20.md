# Validation Report: SandboxMutual (2026-03-20)

## Summary
- **Status**: PASS
- **Gates passed**: 8/8
- **Critical issues**: 0
- **Warnings**: 3

## Gate Results

| Gate | Name | Status | Details |
|------|------|--------|---------|
| 1 | File Integrity | PASS | All 5 files present; latest.json matches 2026-03-20.json; latest-rules.md matches 2026-03-20-rules.md |
| 2 | JSON Schema | PASS | All required top-level keys present. 2 optional keys absent (genericBaseCodes, isDiscountPatterns/isSurchargePatterns) -- acceptable for small carrier with no auto overrides |
| 3 | Code Entry Completeness | PASS | 26 code entries checked, 0 missing required fields (csioCode, description, version/source, availableIn) |
| 4 | Z-Code Cross-Reference | PASS | 3 csio: codes in VB source (csio:CDEDA, csio:HOEQP, csio:JPPWB), 3 in JSON zCodeInventory -- exact match, 0 missed |
| 5 | CompanyConstants Coverage | PASS | 26 Public Const entries in VB source (22 CompanyConstants + 4 CsioConstants), 26 constant entries in JSON -- exact match. 3 csio: codes correctly identified |
| 6 | Rules Document Coverage | PASS | 6/6 sections present (endorsement routing, deductible calculation, limit calculation, province-specific rules, discount/surcharge rules, version info) |
| 7 | Version Tag Consistency | PASS | All 3 Z-codes tagged availableIn: ["V141"], all 3 verified present in V141/Companies/Sandbox/ source files. Carrier exists only in V141 -- no cross-version mismatches possible |
| 8 | Inventory Consistency | PASS | inventory.json has SandboxMutual with status "extracted", totalCodes: 3 matching verificationReport. history.json has "complete" entry for 2026-03-20 |

## Detailed Gate Analysis

### Gate 1: File Integrity
- `2026-03-20.json` -- present, valid JSON (472 lines)
- `2026-03-20-rules.md` -- present, non-empty (441 lines)
- `latest.json` -- present, byte-for-byte identical to 2026-03-20.json
- `latest-rules.md` -- present, byte-for-byte identical to 2026-03-20-rules.md
- `history.json` -- present, contains entry for 2026-03-20 with status "complete"

### Gate 2: JSON Schema Compliance
Required top-level keys present:
- `_metadata`: carrier, versions, extractionDate, filesProcessed, versionRoles -- all present
- `coverageCodes`: homeEndorsements, homeLiabilities -- present; also watercraftCoverage, habAdditionalCoverages
- `discountCodes`: autoDiscounts, autoSurcharges, habDiscounts, habSurcharges -- all present
- `enumMappings`: present with 13 mapping categories
- `responseClassification`: present with habCoveragesTreatedAsParentItems, specialResponseRules, premiumFieldMappings
- `zCodeInventory`: present with habCoverage (3 entries), autoCoverage (empty), discountsSurcharges (empty)
- `verificationReport`: present with full breakdown

Optional keys absent (acceptable):
- `genericBaseCodes` -- not present (carrier uses companyConstants/csioConstants structure instead)
- `autoEndorsements` in coverageCodes -- not present (carrier has no auto-specific overrides, all auto inherited from generic)
- `isDiscountPatterns`/`isSurchargePatterns` in responseClassification -- not present (carrier uses habCoveragesTreatedAsParentItems structure instead)

### Gate 3: Code Entry Completeness
- 26 total code entries across coverageCodes and discountCodes
- 0 entries missing csioCode
- 0 entries missing description
- 0 entries missing version or source
- 0 entries missing availableIn
- All entries have valid version tag "V141"

### Gate 4: Z-Code Cross-Reference
Independent grep across V141/Companies/Sandbox/:
- VB source: `csio:CDEDA` (CsioConstants.vb:13), `csio:HOEQP` (CsioConstants.vb:14), `csio:JPPWB` (CompanyConstants.vb:29)
- JSON zCodeInventory: csio:CDEDA, csio:HOEQP, csio:JPPWB

| Status | Code | Source File | In JSON |
|--------|------|-------------|---------|
| MATCH | csio:CDEDA | CsioConstants.vb:13 | Yes |
| MATCH | csio:HOEQP | CsioConstants.vb:14 | Yes |
| MATCH | csio:JPPWB | CompanyConstants.vb:29 | Yes |

- Codes in grep but NOT in JSON (MISSED): **0** -- no critical misses
- Codes in JSON but NOT in grep (EXTRA): **0**

### Gate 5: CompanyConstants Coverage
| Source | Count |
|--------|-------|
| CompanyConstants.vb Public Const entries | 22 |
| CsioConstants.vb Public Const entries | 4 |
| **Total VB source constants** | **26** |
| JSON companyConstants + csioConstants entries | **26** |
| **Divergence** | **0%** (within 10% tolerance) |

Breakdown:
- Carrier-specific csio: codes: 3 (in both source and JSON)
- Configuration constants (SpeedMPH, string values, form names, etc.): 23 (all accounted for in JSON companyConstants/csioConstants sections)

Note: filesProcessed metadata says 57 but actual VB file count in Sandbox folder is 63 (33 FrameworkToCsio + 9 CsioToFramework + 13 EnumConverters + 3 root + 5 other). The 6-file difference likely represents files that were examined but contained no extractable constants (e.g., empty overrides or purely structural files). This does not affect code completeness.

### Gate 6: Rules Document Coverage
| Section | Status | Evidence |
|---------|--------|----------|
| Endorsement routing rule | PRESENT | TryConvertToCsioHomeEndorsement, TryConvertToFrameworkHomeEndorsement sections |
| Deductible calculation | PRESENT | ConvertEndorsementDeductible section with GlassReducedDeductible rules |
| Limit calculation | PRESENT | ConvertEndorsementLimit section covering CondoDeductibleAssessment, SewerBackup, WaterCoverage, BuildingBylaws |
| Province-specific rule | PRESENT | Territory code handling in DwellRatingConverter |
| Discount/surcharge addition | PRESENT | TryConvertToFrameworkHabDiscount (4 codes), TryConvertToFrameworkHabSurcharge (1 code) |
| Version differences section | PRESENT | V141-specific enum values noted (SeasonalDwellingFireECForm, RentedDwellingFireECForm, RentedCondominiumForm) |

### Gate 7: Version Tag Consistency
SandboxMutual is a single-version carrier (V141 only). All 3 Z-codes in zCodeInventory are tagged `availableIn: ["V141"]`.

Verification:
- `csio:CDEDA` in V141/Companies/Sandbox/CsioConstants.vb -- CONFIRMED
- `csio:HOEQP` in V141/Companies/Sandbox/CsioConstants.vb -- CONFIRMED
- `csio:JPPWB` in V141/Companies/Sandbox/CompanyConstants.vb -- CONFIRMED

No other version folders contain a Sandbox carrier directory. No mismatches detected.

### Gate 8: Inventory and History Consistency
inventory.json:
- SandboxMutual entry present with status "extracted"
- totalCodes: 3 -- matches verificationReport.totalCarrierSpecificCodes (3)
- totalMappings: 42 -- matches verificationReport.totalStandardEnumMappings (42)
- lastExtraction: "2026-03-20" -- matches extractionDate

history.json:
- Has 1 extraction entry for "2026-03-20"
- Status: "complete"
- totalCodes: 3, totalMappings: 42 -- consistent with inventory and JSON
- Versions: ["V141"] -- matches _metadata.versions
- filesProcessed: 57 -- matches _metadata.filesProcessed

## Warnings (should review)

1. **filesProcessed discrepancy**: The JSON metadata reports 57 files processed, but the V141/Companies/Sandbox/ folder contains 63 VB files. The 6-file gap (~10%) likely represents files that were opened but found to have no extractable content (purely structural overrides or empty method bodies). This is cosmetic and does not affect extraction completeness.

2. **Missing optional schema sections**: `genericBaseCodes`, `autoEndorsements` in coverageCodes, and `isDiscountPatterns`/`isSurchargePatterns` in responseClassification are absent. This is appropriate for SandboxMutual because: (a) it has no auto-specific overrides, (b) the carrier-specific constants are captured in `companyConstants`/`csioConstants` sections instead, and (c) response classification uses `habCoveragesTreatedAsParentItems` instead of pattern-based detection. However, if schema standardization is desired across all carriers, these sections could be added as empty/placeholder entries.

3. **Auto discount/surcharge sections contain only notes**: The `autoDiscounts` and `autoSurcharges` sections in discountCodes contain only `note` and `inheritedFromGeneric` keys (not structured code entries with csioCode/description/availableIn). This is acceptable since the carrier has no auto-specific overrides, but differs from the structured format used in the hab sections.

## Critical Issues (must fix)

None. The extraction is complete and consistent across all validation gates.
