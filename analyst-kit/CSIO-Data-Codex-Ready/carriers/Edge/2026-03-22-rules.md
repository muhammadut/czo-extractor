# Edge Mutual Insurance - Business Rules Document

**Carrier**: Edge Mutual Insurance
**Extraction Date**: 2026-03-22
**Versions**: v043 (base), V128 (active)
**Inheritance**: Generic v043 base with SGICanadaQuote V126 routing

---

## Overview

Edge Mutual is a "thin" carrier in the converter codebase. It has ZERO carrier-specific Z-codes (no CompanyConstants.vb) and inherits all standard CSIO codes from the v043 Generic base. Edge makes only a handful of targeted overrides to specific converter behaviors.

---

## Coverage Code Overrides

### TryConvertToFrameworkOntarioAutoEndorsement (CoverageCodeConverter.vb)

**What it does**: Remaps the CSIO End35 code specifically for Edge when parsing Ontario auto endorsements.

**When it runs**: When an Ontario auto policy response contains a coverage code matching End35.

**Rules**:
- If CSIO coverage code = End35: map to EmergencyAssistancePackage (framework endorsement)
- For all other Ontario auto endorsement codes: fall through to generic base
- Note: In the generic base, End35 maps to Opcf35 for Ontario policies. Edge explicitly overrides this to EmergencyAssistancePackage.

**Codes affected**: End35 (csio:35)

---

### TryConvertToFrameworkHomeEndorsement (CoverageCodeConverter.vb)

**What it does**: Remaps the CSIO SewerBackupCoverage code for Edge home endorsements.

**When it runs**: When a hab policy response contains a coverage code matching SewerBackupCoverage.

**Rules**:
- If CSIO coverage code = SewerBackupCoverage: map to WaterCoverageAndSewerBackup (framework endorsement)
- For all other home endorsement codes: fall through to generic base
- Note: In the generic base, SewerBackupCoverage maps to SewerBackup. Edge uses WaterCoverageAndSewerBackup which is a broader/combined coverage.

**Codes affected**: SewerBackupCoverage (csio:SEWBK)

---

## Alarm and Security Classification

### IsLocal (AlarmAndSecurityConverter.vb)

**What it does**: Determines whether an alarm system is local (non-monitored) based on the alarm description code.

**When it runs**: During hab policy response parsing when alarm/security information is present.

**Rules**:
- If AlarmDescCd = NoneNotApplicable: return false (not local, no alarm)
- If AlarmDescCd = LocalAlarm: return true (local alarm)
- For any other alarm description code: fall through to generic base logic
- If no AlarmDescCd is present at all: fall through to generic base logic

---

## Credit Score Processing

### ConvertFromPolicyInsuredOrPrincipal - Outbound (FrameworkToCsio/CreditScoreInfoConverter.vb)

**What it does**: Converts framework credit score data to CSIO CreditScoreInfo XML for sending to Edge.

**When it runs**: During request building, for each credit score in the company's credit scores collection that matches the target person.

**Rules**:
- Loop through all credit scores in the company data
- Match by PersonID = target person's ID
- If Score has a value: set CreditScore element
- If ConsentDate has a value and is a valid date: set CreditScoreDt element
- If ReferenceID is not empty: set ReferenceNumber element
- Only output the CreditScoreInfo if BOTH CreditScore and CreditScoreDt are present (both required)

### ConvertFromPolicyInsuredOrPrincipal - Inbound (CsioToFramework/CreditScoreInfoConverter.vb)

**What it does**: Parses CSIO CreditScoreInfo XML from Edge response into framework credit score data.

**When it runs**: During response parsing when CreditScoreInfo is present.

**Rules**:
- If CreditScoreDt is present: set ConsentDate
- If ReferenceNumber is present: set ReferenceID
- If CreditScore is present and parseable as integer: set Score
- Add the credit score to InsuranceCompanyCode.EdgeMutual company entry (hardcoded)

---

## Dwelling Inspection Valuation

### ConvertDwellInspectionValuation (DwellConverter.vb)

**What it does**: Processes dwelling inspection valuation data from CSIO response.

**When it runs**: During hab response parsing when DwellInspectionValuation data is present.

**Rules**:
- If DwellInspectionValuation exists (non-null): process it as a single item (not collection)
- Generic base expects DwellInspectionValuationCollection (plural). Edge treats it as singular.

---

## Heating Unit Filtering

### Convert (HeatingUnitInfoCollectionConverter.vb)

**What it does**: Processes heating unit information from CSIO response, filtering out "None" values.

**When it runs**: During hab response parsing when heating unit data is present.

**Rules**:
- For each heating unit in the input collection:
  - If HeatingUnitCd is null OR HeatingUnitCd value is NOT "None": process the heating unit
  - If HeatingUnitCd value = None: SKIP (do not add to output)
- Generic base does not filter and processes all heating units regardless of code

---

## Driving Record Protector

### ConvertAccidentRatingWaiverField (PcCoverageConverter.vb)

**What it does**: Processes the Accident Rating Waiver field from CSIO response and creates a DrivingRecordProtector endorsement.

**When it runs**: During auto response parsing when an AccidentRatingWaiver coverage is encountered.

**Rules**:
- Set DrivingRecordProtectorYesNo = True (always)
- If exactly one EffectiveDt is present: parse it and set DrivingRecordProtectorClaimsEffectiveSince
- Edge does NOT require effective date (comment in code: "EdgeMutual doesn't require effective date on DrivingRecordProtector endorsement")
- Create an endorsement with:
  - Category = Endorsement
  - Code = DrivingRecordProtectorClaims
  - ID = derived from coverage ID
  - ParentID = parent vehicle ID

---

## Payment Plan

### TryConvertToFramework (PaymentPlanConverter.vb)

**What it does**: Converts CSIO payment frequency to framework payment plan.

**When it runs**: During response parsing when payment frequency information is present.

**Rules**:
- If frequency = Annual: map to PaymentPlan.One (single payment)
- For all other frequencies: fall through to generic base

---

## Loss Location

### TryToLocationString (LossLocationCdConverter.vb)

**What it does**: Converts CSIO loss location codes to framework claim location strings.

**When it runs**: During claims-related response parsing when loss location is present.

**Rules**:
- ALocationNumber -> PrincipalResidence
- InsuredAddress -> PrincipalResidence
- PremisesAddress -> SecondaryResidence
- Other -> SeasonalDwelling
- Any other code -> return False (no fallthrough to generic base)

---

## Factory Routing (V128)

### ConverterFactoryFactory (V128)

**What it does**: Routes converter creation to Edge-specific or inherited implementations.

**Key routing decisions**:
- EnumConverterFactory: Returns Edge's own factory (which returns Edge's CoverageCodeConverter and LossLocationCdConverter, but generic everything else)
- CsioToFrameworkUnrated: Returns V128 Edge factory (which creates v043 Edge converters for PcCoverage, DwellInspectionValuation, Dwell, Construction, HeatingUnitInfoCollection, CreditScoreInfo)
- FrameworkToCsio: Imported from SGICanadaQuote V126 (f2cu, f2cr, c2fu, c2fr) -- Edge shares SGICanadaQuote's request builders
- PaymentPlanConverter: Only in v043 Edge EnumConverterFactory, NOT in V128 (V128 dropped the PaymentPlan override from its factory)

---

## Version Differences (V128 vs v043)

| Aspect | v043 | V128 |
|--------|------|------|
| Base class | v043.Generic.ConverterFactoryFactory | V128.Generic.ConverterFactoryFactory |
| EnumConverterFactory | v043 Edge factory (3 overrides: CoverageCode, LossLocation, PaymentPlan) | V128 Edge factory (2 overrides: CoverageCode, LossLocation; PaymentPlan dropped) |
| FrameworkToCsio routing | v043 Generic (with Edge CreditScoreInfo override) | SGICanadaQuote V126 (full import) |
| CsioToFramework routing | v043 Edge custom factory | V128 Edge factory (still references v043 Edge converters) |
| Schema version | V043 XML schema | V128 XML schema (with V043 enum compatibility layer) |

**Key change in V128**: Edge now shares SGICanadaQuote V126's FrameworkToCsio implementation. The v043 Edge FrameworkToCsio factory (which only overrode CreditScoreInfoConverter) is no longer directly used by V128 routing. However, the CsioToFramework direction still uses v043 Edge converters.
