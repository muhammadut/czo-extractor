# Intact Business Rules - CZO Converter Logic

**Extraction Date**: 2026-03-22
**Active Versions**: V134, V145, V146
**Latest Active**: V145 (V146 only has factory stubs)

---

## Auto Endorsements

### ConvertRoadsideAssistance
**What it does**: Determines which CZO code to send for roadside assistance based on calculation date.
**When it runs**: When endorsement code is Opcf35 or End35.
**Rules**:
- If calculationDate >= June 16, 2021: send `csio:SRAP` (Intact-specific Roadside Assistance)
- If calculationDate < June 16, 2021: send standard End35 code
**Codes sent**: csio:SRAP (post-2021), standard End35 (pre-2021)

### ConvertDrivingRecordProtectorConvictions
**What it does**: Handles driving record protector endorsement with optional occasional operator companion.
**When it runs**: When endorsement code is DrivingRecordProtectorConvictions.
**Rules**:
- If coverage type = "Occasional Operator": send MinorConvictionProtectionForOccasionalDriver (V134 interface code)
- If coverage type = "Principal + Occasional Operators": send both the standard DRP code AND a companion code MCPOD (for the occasional operator portion)
- Otherwise: send standard DRP code via base class
**Codes sent**: MinorConvictionProtectionForOccasionalDriver, MCPOD, or standard DRP

### TryConvertToCsioOntarioAutoEndorsement (Ontario-specific)
**What it does**: Maps Ontario-specific endorsements to CZO codes.
**When it runs**: For Ontario auto policies.
**Rules**:
- End19A: standard 19A code
- DeductibleWaiver: WaiverOfDeductible (V134 interface)
- Opcf49: csio:49 (Intact-specific)
- All others: fall back to generic base
**Codes sent**: csio:19A, WaiverOfDeductible, csio:49

### TryConvertToCsioAutoEndorsement (Non-Ontario)
**What it does**: Maps non-Ontario auto endorsements to CZO codes.
**When it runs**: For non-Ontario auto policies.
**Rules**:
- DeletionOfHailCoverageWithoutPreexistingDamage, HailDeductible: V134 interface codes
- End8A, End4A, End8B (maps to End8), End19B (maps to End19), End28C (maps to End28), End39A (maps to End39): standard CSIO codes
- Pak01, Pak04: standard PAK codes
- All others: fall back to generic base
**Codes sent**: Standard endorsement codes

---

## Auto Discounts and Surcharges

### TryConvertToCsioAutoDiscount
**What it does**: Converts framework discount codes to Intact-specific CZO discount codes.
**When it runs**: For all auto discount conversions.
**Rules**:
- 21 discount types mapped to Intact-proprietary DIS* codes
- DriverTraining maps to csio:DISTE (My Driving Discount Program / UBI telematics)
- All codes without csio: prefix except DISTE
- Falls back to generic base for unmapped discounts
**Codes sent**: DISAS, DISRN, DISRO, DISGS, DISGR, DISGO, DISHY, DISMP, DISVC, csio:DISTE, DISNB, DISON, DISAL, DISCF, DISCO, DISSN, DISRD, DISMV, DISEL, DISGD, DISOC

### TryConvertToCsioAutoSurcharge
**What it does**: Converts framework surcharge codes to Intact-specific surcharge codes.
**When it runs**: For all auto surcharge conversions.
**Rules**:
- Convictions: SURCN
- ConvictionsOccasional: SURCD
- HighTheft: SURHT
- All others: fall back to generic base
**Codes sent**: SURCN, SURCD, SURHT

### ConvertWebDiscount (Vehicle-Level)
**What it does**: Adds web discount as a vehicle-level coverage.
**When it runs**: During vehicle coverage conversion (ConvertToPersVeh).
**Rules**:
- If the field "WebDiscount" = "Yes" on the vehicle: add a coverage with code csio:ZINTD
- This is NOT in the discount/surcharge section; it is a vehicle coverage entry
**Codes sent**: csio:ZINTD

---

## Home Endorsements

### ConvertWaterCoverage
**What it does**: Determines water coverage CZO code based on policy type and coverage type.
**When it runs**: When endorsement code is WaterCoverage.
**Rules**:
- If policy type = Seasonal AND coverage type = Fire & Extended Coverage: send WaterDamageDeductible code
- If policy type = FEC AND coverage type = Fire & Extended Coverage or Comprehensive: send WaterDamageDeductible code
- If policy type = Condo: send WaterDamageDeductible code
- Otherwise (Home policy with standard coverage): send csio:PAWAT via base class
**Codes sent**: csio:PAWAT or WaterDamageDeductible (depending on policy type)

### ConvertWindHailCoverage
**What it does**: Sends Wind and Hail coverage as two separate PCCOVERAGE entries.
**When it runs**: When endorsement code is WindHailCoverage.
**Rules**:
- First: send the wind coverage via base class (csio:PAWIN from TryConvertToCsioHomeEndorsement)
- Then: create an additional PCCOVERAGE with csio:PAHAI for hail, including limit and deductible
- Limit: from HailCoverage field. If "Policy Limit", send -1.
- Deductible: from HailDeductible field. If "Policy Deductible", send -1.
**Codes sent**: csio:PAWIN (wind) + csio:PAHAI (hail)

### TryConvertToCsioHomeEndorsement
**What it does**: Maps home endorsement codes to CZO codes.
**When it runs**: For all home endorsement conversions.
**Rules**:
- WaterCoverage: csio:PAWAT
- EnhancedWaterDamage: csio:ZEWDP
- WindHailCoverage: csio:PAWIN
- DeductibleWaiverAndClaimsProtector: LifestyleAdvantage (V134)
- FloodEndorsement: OverlandWaterCoverage (V134)
- ClaimsProtector: ClaimsAdvantage (V134)
- CondoExtension: AllRiskUnitOwnersAdditionalProtection (V134)
- LogEndorsement: LogConstructionSettlementLimitation (V134)
- DentClause: csio:HLDNT
- AdditionalLivingExpense: AdditionalLivingExpense (V134)
- All others: fall back to generic base
**Codes sent**: See above

### ConvertSewerBackACVCoverage
**What it does**: Adds ACV sewer backup companion coverage when valuation method indicates actual cash value.
**When it runs**: When SewerBackup endorsement has ACV valuation method set.
**Rules**:
- If SewerBackupValuationMethodContents = True OR ValuationMethod_Contents = True: add ActualCashValueForSewerBackUp coverage (V134 interface)
- Limit and deductible are sent from parent fields
**Codes sent**: ActualCashValueForSewerBackUp

### Skipped Endorsements
**What it does**: Certain endorsements are intentionally not sent in the XML request.
**When it runs**: During ConvertUnskippedEndorsement.
**Rules**:
- Skipped codes: Pak08, Pak09, Pak01, Pak04, Pak06, EnhancedWaterDamage, BoatAndMotor
- These are handled elsewhere or not applicable for the request
**Codes not sent**: PAK08, PAK09, PAK01, PAK04, PAK06, csio:ZEWDP (in request direction)

---

## Home Coverages (Dwelling Level)

### ConvertHabCoverages
**What it does**: Adds hab-level coverages including bareland condo, burglary, and vandalism.
**When it runs**: For dwelling coverage collection conversion.
**Rules**:
- If bareland condo = True AND policy type is Home/FEC/Seasonal: add CondominiumBareLandLossAssessment coverage
- If policy type = Seasonal AND NOT Fire & EC coverage type:
  - If burglary = True: add ResidenceBurglary coverage
  - If vandalism = True: add MaliciousDamageonBuilding coverage
- If policy type != Condo: also convert loss assessment

### ConvertAdditionalLivingExpense
**What it does**: Adds additional living expense coverage when selected.
**When it runs**: For hab coverage collection conversion.
**Rules**:
- If AddLivingExpense field = "Yes": add Additional Living Expense coverage with limit = 0

---

## Group Discount Tier Mapping

### ConvertGroupId
**What it does**: Maps group discount tiers to province-specific prefix codes.
**When it runs**: During policy conversion for auto.
**Rules**:
- If GroupDiscount field is set and not "No Discount":
  - For MB, ON, NB, NS, PE, NL: GroupId = "ZHAL" + tier number
  - For BC, AB, YT, NT: GroupId = "ZWU" + tier number
**Codes sent**: ZHAL{n} or ZWU{n}

---

## Multi-Policy Discount

### ConvertMultiPolicyDiscountCd
**What it does**: Sets multi-policy discount indicator based on supporting hab policy field.
**When it runs**: During policy conversion.
**Rules**:
- If ParentsSupportingHomePolicy = True: MultiPolicyDiscountCd = "1"
- If ParentsSupportingHomePolicy = False: MultiPolicyDiscountCd = "0"

---

## Response Parsing (CsioToFramework)

### ConvertFromPersVeh
**What it does**: Parses vehicle-level coverages from rated response.
**When it runs**: For each PCCOVERAGE in the rated response.
**Rules**:
- AccidentBenefits (CatastrophicImpairment, MedicalRehabAttendantCare, etc.): route to optional increased accident benefits handler
- All other coverages: standard conversion via base class
- Credit/surcharge collections on each coverage are also converted

### ConvertFromDwell
**What it does**: Parses dwelling-level coverages from rated response.
**When it runs**: For each PCCOVERAGE in the dwelling section.
**Rules**:
- If code matches a known home endorsement: route to dwelling endorsement handler
- WindHailCoverage special handling: wind premium set separately, hail coverage merged
- Otherwise: standard dwelling coverage conversion

### Earthquake Deductible
**What it does**: Handles earthquake deductible parsing differently from other endorsements.
**When it runs**: When coverage code = csio:ERQK in rated response.
**Rules**:
- If deductible has FormatCurrencyAmt: parse as integer
- If deductible has FormatPct: parse percentage value as integer
- Sets DeductibleGiven field

---

## Version Differences (V146 vs V145)

### V146 Changes:
1. **Renamed constant**: `Atv` renamed to `Buggy` (same code `csio:AT`)
2. **Removed constant**: `SnowMobile` (`csio:SM`) dropped from V146
3. **No converter overrides**: V146 only has factory stubs; all converter logic inherited from V145

### V145 Changes from V134:
1. **MyDrivingDiscountProgram**: Changed from `DISTE` to `csio:DISTE` (added csio: prefix)
2. **Added**: `Atv` (csio:AT) and `SnowMobile` (csio:SM) constants
3. **Added files**: `VehicleBodyTypeConverter.vb`, `BillingMethodConverter.vb`, `AddrConverter.vb`, `OutsideCountryConverter.vb`, `TelematicsDriverInfoConverter.vb`, `VehicleAlterationsInfoCollectionConverter.vb`, `VehicleAlterationsInfoConverter.vb`
4. **Added modules**: `OwnershipOfVehicle` and `ActualOwnerName` in CompanyConstants
5. **Added**: `AntiTheftDeviceInfoCollectionConverter.vb` (V134 only had `AntiTheftDeviceConverter.vb`)
