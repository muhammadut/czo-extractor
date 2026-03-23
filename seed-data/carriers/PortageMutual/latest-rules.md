# PortageMutual Business Rules

**Carrier**: PortageMutual
**Version**: v043 (only version)
**Extracted**: 2026-03-22

---

## Outbound (FrameworkToCsio)

### TryConvertToCsioAutoDiscount
**What it does**: Converts framework auto discount codes to CSIO coverage codes for auto policies.
**When it runs**: When building the outbound CSIO XML for auto discount items.
**Rules**:
- If discount = Age: send standard DiscountDriverAge code
- If discount = MultiVehicleTpl, MultiVehicleDcpd, or MultiVehicleColl: send standard DiscountMultiVehicle code (all three map to the same CSIO code)
- For all other discount codes: fall through to the generic base handler

**Codes sent**: Standard CSIO DiscountDriverAge, DiscountMultiVehicle

---

### TryConvertToCsioHabDiscount
**What it does**: Converts framework hab discount codes to CSIO coverage codes for hab policies.
**When it runs**: When building the outbound CSIO XML for hab discount items.
**Rules**:
- If discount = SecuritySystem: send standard PremisesAlarmFireorIntrusionSystem code
- If discount = Deductible: send standard MiscellaneousDiscount code
- If discount = Age: send standard MatureCitizen code
- If discount = CreditScore: send csio:DISST (PortageMutual proprietary Distinct Client Discount)
- For all other discount codes: fall through to the generic base auto discount handler (NOTE: calls TryConvertToCsioAutoDiscount, not TryConvertToCsioHabDiscount on base -- this appears to be a possible bug or intentional cross-line fallback)

**Codes sent**: Standard PremisesAlarm, MiscellaneousDiscount, MatureCitizen; Proprietary csio:DISST

---

### TryConvertToCsioHabSurcharge
**What it does**: Converts framework hab surcharge codes to CSIO coverage codes for hab policies.
**When it runs**: When building the outbound CSIO XML for hab surcharge items.
**Rules**:
- If surcharge = Suites: send standard MultipleFamilySurcharge code
- If surcharge = Deductible: send standard MiscellaneousSurcharge code
- If surcharge = Heating: send standard SecondaryAuxiliaryHeating code
- For all other surcharge codes: fall through to the generic base handler

**Codes sent**: Standard MultipleFamilySurcharge, MiscellaneousSurcharge, SecondaryAuxiliaryHeating

---

### TryConvertToCsioHomeEndorsement
**What it does**: Converts framework home endorsement codes to CSIO coverage codes.
**When it runs**: When building the outbound CSIO XML for home endorsement items.
**Rules**:
- If endorsement = SewerBackup:
  - If coverageType = "Unlimited Form": send csio:WATER (standard water coverage code)
  - If coverageType = "Limited Form" OR coverageType/coverage contains a non-zero numeric value: send standard SewerBackupCoverage code
  - Otherwise (fallback): send csio:WATER
- If endorsement = ClaimsProtector: send standard ClaimFreeProtection code
- If endorsement = WaterCoverage: send csio:OVWAT (PortageMutual proprietary Overland Water code)
- If endorsement = HomeSystemandServiceLineBundle: send csio:SMART (PortageMutual proprietary)
- If endorsement = TenantRestriction: send csio:VTEXC  (PortageMutual proprietary, note trailing space)
- If endorsement = RoofSurfaceBasisOfSettlement: send csio:ROOFW (PortageMutual proprietary)
- For all other endorsement codes: fall through to the generic base handler

**Codes sent**: csio:WATER, standard SewerBackupCoverage, csio:OVWAT, csio:SMART, csio:VTEXC , csio:ROOFW, standard ClaimFreeProtection

---

### ConvertEndorsement (PcCoverageConverter - Outbound)
**What it does**: Handles the full endorsement conversion including company-specific field placement for SewerBackup and Additional Residence endorsements.
**When it runs**: After the base ConvertEndorsement runs, for each endorsement being sent outbound.
**Rules**:
- Calls the base ConvertEndorsement first
- If the endorsement is SewerBackup OR any AdditionalResidence code:
  - Move the CompanySpecificField collection from the PCCOVERAGE output to the parent Location output
  - This places sewer/additional residence company fields at the location level instead of the coverage level

**Codes sent**: None directly (restructures XML output)

---

### ConvertEndorsementLimit (PcCoverageConverter - Outbound)
**What it does**: Handles limit conversion for specific endorsement types.
**When it runs**: When converting limits for endorsements in the outbound CSIO XML.
**Rules**:
- If endorsement = SewerBackup:
  - Try to get Coverage and CoverageType fields from the company fields
  - Strip non-numeric characters from CoverageType if present
  - If a numeric limit can be parsed from either field, add a Limit element with FormatCurrencyAmt
  - If no numeric value found, assume unlimited (no limit sent)
- If endorsement = Earthquake: call ConvertEarthquakeLimit (see below)
- For all others: fall through to generic base

**Codes sent**: None (sets limit amounts)

---

### ConvertEarthquakeLimit
**What it does**: Sets earthquake coverage option codes based on building/contents selection.
**When it runs**: When converting earthquake endorsement details outbound.
**Rules**:
- Read EarthquakeCoverage field from the coverage item company fields
- If EarthquakeCoverage = "Building Only": set valuation to csio:EB, option to Building
- If EarthquakeCoverage = "Building and Contents": set valuation to csio:EA, option to BuildingandContents
- Otherwise (default): set valuation to csio:EC, option to Contents

**Codes sent**: csio:EA, csio:EB, csio:EC (as option codes)

---

### ConvertHabCoverageCd
**What it does**: Converts hab coverage codes with policy-type-specific overrides.
**When it runs**: When converting the main dwelling coverage code outbound.
**Rules**:
- If coverage = Dwelling AND policyType = Condo or Tenant: send PersonalPropertyHomeownersForm code
- For all other combinations: fall through to the generic base

**Codes sent**: Standard PersonalPropertyHomeownersForm

---

### ConvertHabContents
**What it does**: Adds a deductible conversion for hab contents.
**When it runs**: When converting contents coverage outbound.
**Rules**:
- Call the base ConvertHabContents first
- Then additionally convert the Deductible field from the coverage item (base does not do this for PortageMutual)

---

### PolicyTypeConverter - TryConvertCondoToCsio
**What it does**: Maps framework condo coverage types to CSIO policy types.
**When it runs**: When building the outbound policy type for condo policies.
**Rules**:
- If coverageType = Comprehensive: send ComprehensiveCondominiumForm
- If coverageType = Basic: send CondominiumPackageBroadForm (rating manual lists broad, but tables listed as basic; sent as broad)
- For all others: fall through to generic base

---

### PolicyTypeConverter - TryConvertSeasonalToCsio
**What it does**: Maps framework seasonal coverage types to CSIO policy types.
**When it runs**: When building the outbound policy type for seasonal dwelling policies.
**Rules**:
- If coverageType = "Homeowners Basic": send SeasonalDwellingStandardForm
- If coverageType = "Homeowners Broad": send SeasonalDwellingBroadForm
- If coverageType = "Homeowners Comp.": send SeasonalDwellingComprehensiveForm
- For all others: fall through to generic base

---

### PolicyTypeConverter - TryConvertHomeToCsio
**What it does**: Maps framework home coverage types to CSIO policy types, including PortageMutual-specific product tiers.
**When it runs**: When building the outbound policy type for homeowner policies.
**Rules**:
- If coverageType = "Broad Single Limit": send HomeownersBroadForm
- If coverageType = "Comp. Single Limit": send HomeownersComprehensiveForm
- If coverageType = "Enhanced Broad": send HomeownersBroadExpandedForm
- If coverageType = "Enhanced Comp": send HomeownersComprehensiveExpandedForm
- If coverageType = "Essentials Broad": send HomeownersBroadForm (same code as standard broad)
- If coverageType = "Essentials Comp": send HomeownersComprehensiveForm (same code as standard comp)
- For all others: fall through to generic base

---

### ValuationProductConverter - TryConvertToCsio
**What it does**: Maps evaluator types to CSIO valuation product codes.
**When it runs**: When building the outbound valuation product field.
**Rules**:
- If evaluator = EZITV: send "7"
- If evaluator = IClarify: send "8"
- If evaluator = E2Value: send "9"
- For all others: fall through to generic base

---

### ClassSpecificRatedIndicatorConverter - TryConvertToCsio
**What it does**: Maps classification values to CSIO rated indicator codes.
**When it runs**: When setting the rated indicator for coverage items.
**Rules**:
- If classification = "Single Limit": send Preferred rated indicator
- For all others: fall through to generic base

---

### DwellRatingConverter - ConvertTerritoryCd
**What it does**: Reformats territory codes to a compact format expected by PortageMutual.
**When it runs**: After base territory code conversion.
**Rules**:
- Call base ConvertTerritoryCd first
- Apply regex to parse "Metro NNN" or "Text NNN" format
- If match found with "Metro" prefix: reformat to "M" + numeric (e.g., "Metro 001" becomes "M1")
- If match found without "Metro" prefix: extract just the numeric part (e.g., "Rural 005" becomes "5")
- If exact match on "Metro": reformat to "M1"
- Leading zeros are stripped

---

### CompanySpecificFieldCollectionConverter
**What it does**: Adds PortageMutual-specific company fields to policy, dwelling, and coverage output.
**When it runs**: At various conversion points during outbound XML building.

**Policy-level fields** (ConvertFromPolicy):
- Sets LocationName to "PortageMutualApplicationFields"
- Adds SignedApplication warranty field (Y/N/NA)
- Adds SignedPaymentAuthorization field (Y/N/NA)
- For auto policies only: adds CurrentMVR field (Y/N/NA based on ClaimsCheck containing MvrManual)

**Dwelling-level fields** (ConvertToDwell):
- Adds RebuildingCost field (GuaranteedReplacementCostValue as string)

**Coverage-level fields** (ConvertToCoverage):
- For primary items and additional residence codes:
  - Adds BackwaterValve field (Y/N/NA)
  - If BackwaterValve = Y: adds BackwaterValveInstallationDate
  - Adds OldStyleBackup / CatchBasin field (Y/N/NA)
  - If OldStyleBackup = Y: adds OldStyleBackupInstallationDate
  - Adds AutomaticSumpPump field (Y/N/NA based on SumpPumpType = "Automatic")
  - If AutomaticSumpPump = Y: adds AutomaticSumpPumpInstallationDate

---

### PortageMutualSpecificFieldConverter - ConvertSolidFuelWETTInspected
**What it does**: Indicates whether a solid fuel heating system has WETT inspection.
**When it runs**: When converting heating system details.
**Rules**:
- If heating fuel is solid fuel (OilWood, OtherSolidFuels, Coal, Wood): check WETT approval
  - If WETT inspection flag is set: send "Y"
  - If not: send "N"
- If heating fuel is NOT solid fuel (Electric, Oil, Gas, Propane, Solar, etc.): send "NA"

---

## Inbound (CsioToFramework)

### PcCoverageConverter - ConvertFromLineBusiness
**What it does**: Parses increased accident benefits from CSIO response.
**When it runs**: When processing line-of-business coverages from carrier response.
**Rules**:
- If CoverageCd = csio:ACB: set AttendantCare = True on IncreasedAccidentBenefitsOntario
- If CoverageCd = csio:DCB: set DependantCare = True
- If CoverageCd = csio:MEDRH: set MedicalRehabilitation = True
- For all others: fall through to generic base

---

### CoverageConverterHelper - ConvertLimit
**What it does**: Parses sewer backup limits from carrier response.
**When it runs**: When converting limits from CSIO coverage response elements.
**Rules**:
- If CoverageCd = standard SewerBackupCoverage:
  - If Limit element exists with value: set CoverageType field to currency-formatted value (e.g., "$10,000.00")
  - If no Limit element: set CoverageType to "Unlimited Form"
- For all others: fall through to generic base

---

### TryConvertToFrameworkHomeEndorsement (CoverageCodeConverter)
**What it does**: Parses CSIO home endorsement codes back to framework endorsement codes from carrier response.
**When it runs**: When processing home endorsement codes from carrier response.
**Rules**:
- If CoverageCd = csio:SMART: map to HomeSystemandServiceLineBundle
- If CoverageCd = csio:VTEXC : map to TenantRestriction
- For all others: fall through to generic base

---

### CompanySpecificFieldConverter - ConvertFromPolicyLocation
**What it does**: Parses PortageMutual company-specific fields from CSIO response policy location.
**When it runs**: When processing CompanySpecificField elements from carrier response.
**Rules**:
- Only process if CompanyCd = PortageMutual
- If FieldCd = SIGN.APP: route to ConvertSignedApplicationWarranty (TODO: not mapped)
- If FieldCd = SIGN.PAY: route to ConvertPaymentAuthorization (TODO: not mapped)
- If FieldCd = MVR.CUR: route to ConvertMvr (TODO: not mapped)
- If FieldCd = WETT.INSP: route to ConvertSolidFuelWETTInspected (TODO: not mapped)

---

### CompanySpecificFieldConverter - ConvertFromCoverage
**What it does**: Parses PortageMutual company-specific fields from CSIO response coverage elements.
**When it runs**: When processing CompanySpecificField elements at coverage level from carrier response.
**Rules**:
- Only process if CompanyCd = PortageMutual
- If FieldCd = AU.SPUMP: route to ConvertAutomaticSumpPump (TODO: not mapped)
- If FieldCd = AU.IN.DT: route to ConvertAutomaticSumpPumpInstallationDate (TODO: not mapped)
- If FieldCd = BW.FLAPR: route to ConvertBackwaterValve (TODO: not mapped)
- If FieldCd = BW.IN.DT: route to ConvertBackwaterValveInstallationDate (TODO: not mapped)
- If FieldCd = CA.BASIN: route to ConvertOldStyleBackup (TODO: not mapped)
- If FieldCd = CA.IN.DT: route to ConvertOldStyleBackupInstallationDate (TODO: not mapped)

---

### CompanySpecificFieldConverter - ConvertFromDwell
**What it does**: Parses PortageMutual company-specific fields from CSIO response dwelling elements.
**When it runs**: When processing CompanySpecificField elements at dwelling level from carrier response.
**Rules**:
- Only process if CompanyCd = PortageMutual
- If FieldCd = REBUILD: route to ConvertRebuildingCost (TODO: not mapped)

---

## Known Issues

1. **Trailing space in TenantRestriction code**: The constant `csio:VTEXC ` has a trailing space character. This may cause matching issues if not handled carefully.

2. **Multiple TODO stubs in CsioToFramework**: The following inbound conversion functions are stubbed with "TODO: Map this":
   - ConvertSignedApplicationWarranty
   - ConvertPaymentAuthorization
   - ConvertMvr
   - ConvertSolidFuelWETTInspected (partially commented out)
   - ConvertAutomaticSumpPump
   - ConvertAutomaticSumpPumpInstallationDate
   - ConvertBackwaterValve
   - ConvertBackwaterValveInstallationDate
   - ConvertOldStyleBackup
   - ConvertOldStyleBackupInstallationDate
   - ConvertRebuildingCost

3. **Hab Discount fallback calls Auto base**: In TryConvertToCsioHabDiscount, the Case Else calls `MyBase.TryConvertToCsioAutoDiscount` instead of `MyBase.TryConvertToCsioHabDiscount`. This means hab discounts not handled by PortageMutual fall through to the auto discount handler in the generic base, not the hab discount handler. This may be intentional for cross-line discount support or a bug.
