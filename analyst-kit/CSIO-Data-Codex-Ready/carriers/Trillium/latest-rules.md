# Trillium Mutual - Business Rules Document

**Carrier**: Trillium Mutual
**Version**: v043 (single version)
**Extraction Date**: 2026-03-22
**Direction**: Outbound only (FrameworkToCsio). No CsioToFramework directory exists.

---

## Carrier Overview

Trillium Mutual is a v043-only carrier that inherits extensively from the Generic base. It has **no proprietary Z-codes** -- all CSIO codes used are standard. The carrier overrides specific behaviors for:

- Dwelling coverages (burglary, vandalism)
- Accident benefits (Ontario SABS pre/post June 2016)
- Question/answer indicators (day care, recreational vehicles, watercraft)
- Watercraft handling (boat/motor split with separate accessory tracking)
- Policy type mappings (home, condo, tenant, seasonal, mobile home, FEC)
- Roof material codes
- Valuation products
- Company code routing (Intact -> GC, Unica -> YorkFire)

---

## Coverage Conversion Rules

### ConvertEndorsement (PcCoverageConverter)
**What it does**: Converts framework endorsement codes to CSIO coverage codes for outbound requests.
**When it runs**: For every endorsement attached to a dwelling or vehicle.
**Rules**:
- If endorsement is GardenTractor AND category is Liability: SKIP (do not send)
- If endorsement is GardenTractor AND category is NOT Liability: send with code csio:LT
- All other endorsements: delegate to Generic base

**Codes sent**: csio:LT (garden tractor, property only)

---

### ConvertBurglary (PcCoverageConverter)
**What it does**: Adds a burglary coverage element if the dwelling has burglary selected.
**When it runs**: Called from PcCoverageCollectionConverter.ConvertToDwell for every dwelling.
**Rules**:
- Read the "Theft" field from the company-specific fields for the coverage item
- If the field exists AND is true: create a PCCOVERAGE with code csio:THFBU
- If field is missing or false: do nothing

**Codes sent**: csio:THFBU

---

### ConvertVandalism (PcCoverageConverter)
**What it does**: Adds a vandalism coverage element if the dwelling has vandalism selected.
**When it runs**: Called from PcCoverageCollectionConverter.ConvertToDwell for every dwelling.
**Rules**:
- Read the "Vandalism" dynamic field from the company-specific fields
- If the field exists AND is true: create a PCCOVERAGE with code csio:VMBC
- If field is missing or false: do nothing

**Codes sent**: csio:VMBC

---

### TryConvertAccidentBenefits (PcCoverageCollectionConverter)
**What it does**: Converts Ontario increased accident benefits (SABS) to CSIO coverages.
**When it runs**: Called from ConvertToPersVeh for every personal vehicle.
**Rules**:

**Post-June 1, 2016 (new SABS)**:
- If MedicalAttendantCatastrophic is true: send csio:CIMRB
- If MedicalAttendantNonCatastrophic is true: send MedicalRehabAttendantCare (standard) with limit $130,000
- If MedicalAttendantNonCatastrophic1M is true: send MedicalRehabAttendantCare (standard) with limit $1,000,000

**Pre-June 1, 2016 (old SABS)**:
- If AttendantCare is true: send csio:ACB
- If MedicalRehabilitation is true: send csio:MEDRH
- If MedicalRehabilitationAndAttendantCare is true: send MedicalRehabAttendantCare (standard)

**Regardless of date**:
- If Caregiver is true: send csio:CHHMB
- If DependantCare is true: send csio:DCB
- If IncomeReplacementCoverage > $400: send IncomeReplacement (standard) with the coverage amount as limit
- If IndexationBenefit is true: send Indexation (standard)
- If DeathAndFuneral is true: send DeathAndFuneralBenefits (standard)

**Codes sent**: csio:CIMRB, csio:ACB, csio:MEDRH, csio:CHHMB, csio:DCB, plus standard codes

---

## Discount and Surcharge Rules

### TryConvertToCsioAutoDiscount (CoverageCodeConverter)
**What it does**: Converts framework auto discount codes to CSIO codes.
**When it runs**: For every auto discount on the policy.
**Rules**:
- No Trillium-specific overrides -- delegates entirely to Generic base
- All standard CSIO auto discount codes apply

---

### TryConvertToCsioHabDiscount (CoverageCodeConverter)
**What it does**: Converts framework hab discount codes to CSIO codes.
**When it runs**: For every habitational discount on the policy.
**Rules**:
- No Trillium-specific overrides -- delegates entirely to Generic base
- All standard CSIO hab discount codes apply

---

### TryConvertToCsioHabSurcharge (CoverageCodeConverter)
**What it does**: Converts framework hab surcharge codes to CSIO codes.
**When it runs**: For every habitational surcharge on the policy.
**Rules**:
- SurchargeCode.Suites: map to standard MultipleFamilySurcharge code
- SurchargeCode.Mercantile: map to standard CommercialExposure code
- All other surcharges: delegate to Generic base

---

### ConvertHabSurcharges (Rated PcCoverageCollectionConverter)
**What it does**: Filters which hab surcharges appear in rated output.
**When it runs**: During rated (premium) conversion.
**Rules**:
- SurchargeCode.Electricity: SKIP (do not send in rated output)
- All other surcharges: delegate to Generic base

---

## Question/Answer Rules

### ConvertToDwell (QuestionAnswerCollectionConverter)
**What it does**: Generates dwelling-level question/answer elements.
**When it runs**: For every dwelling on a hab policy.
**Rules**:
- Calls Generic base first (adds standard dwelling questions)
- Then adds Trillium-specific questions:
  - Garden Tractor (csio:138): yes/no from GardenTractor dynamic field
  - Golf Cart (csio:139): yes/no from GolfCart dynamic field
  - Unlicensed Recreational Vehicles (csio:140): yes/no from UnlicensedRecreationalVehicles field
  - Own Watercraft (csio:142): yes/no from OwnWatercraft field
  - Renewable Energy (RenewableEnergyInd): yes/no from RenewableEnergyInstallation field
  - Day Care In Household (csio:112): if not already added by Generic base, adds it with number-of-children details or "0" default

**Codes sent**: csio:138, csio:139, csio:140, csio:142, RenewableEnergyInd, csio:112

---

### ConvertFromAutoLineBusiness (QuestionAnswerCollectionConverter)
**What it does**: Generates auto policy-level question/answer elements.
**When it runs**: For every auto policy.
**Rules**:
- Adds these questions in order:
  1. Insurance Declined (from PreviousCancellations, PreviousRefusedRenewal, etc.)
  2. Registered Owner / Actual Owner
  3. Drivers Qualified
  4. Material Misrepresentation
  5. Other Licensed Drivers
  6. Fraud
  7. Under Special Circumstances
  8. Loss Claims in Five Years (counts claims within 5 years of calc date)
  9. New Business

---

## Policy Type Mapping Rules

### TryConvertCondoToCsio
- Comprehensive -> ComprehensiveCondominiumForm
- All others -> return False

### TryConvertFecToCsio (Farm Equipment Coverage / Rented Dwelling)
- Named Perils - Dwelling -> RentedDwellingStandardForm
- Named Perils - Mobile Home -> TravelVacationTrailerForm
- All others -> return False

### TryConvertHomeToCsio
- Comprehensive -> HomeownersComprehensiveForm
- Broad -> HomeownersBroadForm
- Standard -> HomeownersStandardForm
- Limited Perils -> BasicResidentialForm
- All others -> return False

### TryConvertMobileHomeToCsio
- All Risk -> MobileHomeComprehensiveForm
- NamedPerils -> MobileHomeStandardForm
- Limited Perils -> MobileHomeLimitedForm
- All others -> return False

### TryConvertSeasonalToCsio
- Gold -> SeasonalDwellingStandardForm
- Silver -> SeasonalDwellingLimitedForm
- All others -> return False

### TryConvertTenantToCsio
- Comprehensive -> TenantsComprehensiveForm
- Basic -> TenantsPackageStandardForm
- All others -> return False

---

## Roof Material Mapping

- Framework "Other" -> csio:999
- Framework "Other Tile" -> csio:O
- All others -> delegate to Generic base

---

## Valuation Product Mapping

- RCT -> standard RCT code
- EZITV -> "7"
- iClarify -> "8"
- E2Value -> "9"
- RSMeans -> standard MeansCostWorks code
- EvalWorks -> "12"
- Default (Case Else) -> standard Other code

---

## Watercraft Handling

### WatercraftCollectionConverter
**What it does**: Splits boat and motor into separate watercraft entries.
**Rules**:
- For each watercraft coverage item:
  - If Coverage (boat) field > 0: set BoatMotor = "Boat", create watercraft entry
  - If MotorCoverage field > 0: set BoatMotor = "Motor", create second watercraft entry
- The BoatMotor shared property controls which fields are read downstream (boat year/serial/manufacturer vs motor year/serial/manufacturer)

### WatercraftAccessoryCollectionConverter
**What it does**: Creates equipment type entries for hull and motor.
**Rules**:
- If boat Coverage > 0: create accessory with EquipmentTypeCd = csio:HU (Hull)
- If MotorCoverage > 0: create accessory with EquipmentTypeCd = csio:MO (Motor)

### PcBasicWatercraftConverter
**What it does**: Sets the present value amount for boat vs motor.
**Rules**:
- Uses the BoatMotor shared property to alternate between boat coverage and motor coverage amounts
- First call reads BoatCoverage, second call reads MotorCoverage

---

## Billing Method Mapping

- DirectBill -> standard DirectBill
- Mac -> standard DirectBill (both map to same CSIO code)
- All others -> delegate to Generic base

---

## Company Code Mapping

- IntactInsurance -> "GC" (Trillium-specific constant)
- UnicaInsurance -> standard YorkFire code
- All others -> delegate to Generic base

---

## Inspection Info

### InspectionInfoConverter
- If InspectionCompleted field = "Yes": set InspectionStatusCd to csio:1 (true)
- Otherwise: do not set

### InspectionReportSourceConverter
- If PropertySeen is true: set to AgentBrokerInspection (standard)
- If PropertySeen is false: set to NotOrderedorReplacementCostNotVerified (standard)

### DwellInspectionValuation (HomeLineBusinessConverter)
- PropertySeen -> InspectionReportSourceCd = csio:1 (true) or csio:0 (false)
- DateSeen -> InspectionDt

---

## Swimming Pool

- If SwimmingPool field is empty or "None": SKIP (do not send swimming pool element)
- Otherwise: delegate to Generic base

---

## Detached Structures

- Only convert detached structures if category = FarmBuilding
- All other categories are skipped

---

## Contract Term

- Always sends ContinuousInd based on ContinuouslyInsuredSince having a value
- Always sends StartTime from EffectiveDate

---

## Building Improvements

- Heating, Plumbing, Roofing, and Wiring improvement years are reformatted to year-only date format (CsioDateFormat.YearOnly) after base conversion

---

## Driver Vehicle Assignment

- After standard driver-vehicle assignment, also processes:
  - Unassigned driver IDs (marks as excluded usage)
  - Excluded driver IDs (marks as excluded usage)

---

## Measurement Units

- Years unit label is "Years" (not the default)
- Months unit label is "Months" (not the default)
