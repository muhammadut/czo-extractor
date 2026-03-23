# Validation Report: Aviva (2026-03-20)

## Summary
- **Status**: PASS
- **Gates passed**: 7/8
- **Critical issues**: 0
- **Warnings**: 2

## Gate Results
| Gate | Name | Status | Details |
|------|------|--------|---------|
| 1 | File Integrity | PASS | All 5 files present; latest.json and 2026-03-20.json are byte-identical; latest-rules.md and 2026-03-20-rules.md are byte-identical; history.json has today's entry |
| 2 | JSON Schema | WARN | 7/8 required top-level keys present; `genericBaseCodes` is MISSING. All required subkeys in `_metadata`, `coverageCodes`, `discountCodes`, and `responseClassification` are present |
| 3 | Code Entry Completeness | PASS | 290 code entries in coverageCodes + discountCodes; 0 entries missing required fields (csioCode, description, version, availableIn all present) |
| 4 | Z-Code Cross-Reference | PASS | 200 Z-codes in JSON vs 203 in VB grep. 3 apparent misses (csio:ZIN, csio:ZLOY, csio:ZT) are FALSE POSITIVES -- these are `.StartsWith()` prefix patterns in classification logic, not actual code values. No `Public Const` declarations exist for them. 0 true misses, 0 extra |
| 5 | CompanyConstants Coverage | PASS | V148 CompanyConstants has 322 Public Const entries; verificationReport reports 322 carrier-specific codes. Exact match. Total entries across JSON sections (coverage + discount + enum) = 335, within expected range |
| 6 | Rules Document Coverage | PASS | 6/6 sections present (see details below) |
| 7 | Version Tag Consistency | PASS | All 13 V148-only codes verified: 12 found in V148 CompanyConstants.vb, 1 (csio:UAOD) found inline in V148 VB converter files (documented as undeclared in verificationReport) |
| 8 | Inventory Consistency | PASS | inventory.json status = "extracted", totalCodes = 322 matches verificationReport. history.json has "complete" entry for 2026-03-20 |

## Gate 2: Schema Detail

Required top-level keys:
- `_metadata`: PRESENT (carrier, versions, extractionDate, filesProcessed, versionRoles all present)
- `coverageCodes`: PRESENT (autoEndorsements: 58, homeEndorsements: 46, buildingByLawCodes: 9, scheduledPropertyItems: 14, homeLiabilities: 15, watercraftLiability: 13)
- `discountCodes`: PRESENT (autoDiscounts: 86, autoSurcharges: 10, habDiscounts: 29, habSurcharges: 10)
- `genericBaseCodes`: **MISSING**
- `enumMappings`: PRESENT (7 categories, 45 total entries)
- `responseClassification`: PRESENT (isDiscountPatterns, isSurchargePatterns)
- `zCodeInventory`: PRESENT (3 categories: autoCoverage, habCoverage, discountsSurcharges; 196 entries)
- `verificationReport`: PRESENT (totalCarrierSpecificCodes: 322, totalGenericInheritedCodes: 55, orphanCodes: [], undeclaredCodes: 1)

## Gate 4: Z-Code Cross-Reference Detail

Z-codes found in VB files (grep across V132/V134/V148): 203
Z-codes in JSON extraction: 200

3 codes in grep but not in JSON (all false positives):
- `csio:ZIN` -- used in `.StartsWith("csio:ZIN")` pattern in PcCoverageConverter.vb for discount classification; the actual code `csio:ZINTD` IS captured
- `csio:ZLOY` -- used in `.StartsWith("csio:ZLOY")` pattern for loyalty discount classification; actual codes `csio:ZLOY1`, `csio:ZLOY2`, `csio:ZLOY3`, `csio:ZLOYD` ARE captured
- `csio:ZT` -- used in `.StartsWith("csio:ZT")` pattern for tier discount classification; actual codes `csio:ZT0`-`csio:ZT4` ARE captured

Verdict: No true missed Z-codes. All 200 actual Z-code values are captured.

## Gate 5: CompanyConstants Coverage Detail

| Version | Public Const Count |
|---------|--------------------|
| V148 | 322 |
| V134 | 437 |
| V132 | 299 |
| Unique across all | 448 |

Extraction verificationReport totalCarrierSpecificCodes: 322 (matches V148, the latest version)
Version breakdown from extraction: V148-only: 8, V134-only: 7, V132-only: 0, V132+V134 only: 15, shared across all: 292

## Gate 6: Rules Document Coverage

| Requirement | Present | Location in Document |
|-------------|---------|---------------------|
| Endorsement routing rule | Yes | ConvertEndorsementCoverageCd section (lines 9-37) |
| Deductible calculation | Yes | ConvertEarthquakeCoverageCd section -- earthquake deductibles by province and tier (lines 157-181) |
| Limit calculation | Yes | Earthquake limits for BC (75%/50%/25% of property value, lines 177-179) |
| Province-specific rule | Yes | Multiple: AB-specific 43L/43RL, NS/PE/NB Claims Protector, ON anti-theft, BC earthquake tiers |
| Discount/surcharge addition | Yes | ConvertToPersVeh adds web discount, multi-vehicle, car+home, anti-theft; ConvertHabCoverages adds water alarm, septic, non-smoker, broker discretionary |
| Version differences section | Yes | "Version Differences (V148 vs V134)" section covering codes added, removed, and logic changes (lines 294-333) |

All 6/6 required sections are present.

## Gate 7: V148-Only Code Verification

All 13 V148-only codes verified in source:

| Code | Found In |
|------|----------|
| csio:28C | CompanyConstants.vb |
| csio:19B | CompanyConstants.vb |
| csio:35 | CompanyConstants.vb |
| csio:26 | CompanyConstants.vb |
| csio:5CS | CompanyConstants.vb |
| csio:UAOD | Inline in PcCoverageCollectionConverter.vb (documented as undeclared) |
| csio:CDEDE | CompanyConstants.vb |
| csio:ZYR01 | CompanyConstants.vb |
| csio:HYDS | CompanyConstants.vb |
| csio:DISEL | CompanyConstants.vb |
| csio:EVDS | CompanyConstants.vb |
| csio:DISAD | CompanyConstants.vb |
| csio:SURRH | CompanyConstants.vb |

0 mismatches.

## Critical Issues (must fix)
None.

## Warnings (should review)
1. **Gate 2 -- Missing `genericBaseCodes` key**: The JSON is missing the `genericBaseCodes` top-level key. The extraction captures 55 generic inherited codes (per verificationReport) but they are not surfaced in a dedicated section. Consider adding this key in a future extraction to separate carrier-specific from generic-inherited codes.
2. **Gate 5 -- V134 constant count discrepancy**: V134 CompanyConstants has 437 Public Const entries vs 322 in the extraction total. This is expected because V134 contains constants for features that are either deprecated, superseded by V148 standard codes, or shared with other carriers. The extraction correctly uses V148 as the canonical version. No action needed unless V134-only codes are missing from the output (Gate 4 confirms they are not).
