# Travelers Business Rules

**Carrier**: Travelers (Dominion)
**Version**: V141 (single version)
**Extracted**: 2026-03-22

---

## Overview

Travelers is a single-version carrier (V141 only) that uses zero proprietary Z-codes. All CZO codes are resolved through the standard CSIO enumValuesFactory, with only 3 hardcoded `csio:` strings in the entire codebase. The carrier operates under InsuranceCompanyCode.Dominion and supports several mutual insurance subsidiaries.

---

## Coverage Code Converter (CoverageCodeConverter.vb)

### TryConvertToCsioHomeEndorsement
**What it does**: Maps framework home endorsement codes to CSIO coverage codes for outbound requests.
**When it runs**: When building a home policy XML request that includes endorsements.
**Rules**:
- If endorsement = FloodEndorsement: send OverlandWaterCoverage code
- If endorsement = LimitedHiddenWaterDamage: send LimitedHiddenWaterDamage code
- If endorsement = MatchingOfUndamagedRoofSurfacing: send MatchingOfUndamagedRoofSurfacingAdditionalCoverage code
- If endorsement = MatchingOfUndamagedSiding: send MatchingOfUndamagedSidingAdditionalCoverage code
- If endorsement = EquipmentBreakdownCoverage: send HomeEquipmentProtection code
- If endorsement = WindHailCoverage: send csio:PAHAI (hardcoded from CompanyConstants)
- If endorsement = PersonalRecordsAndDataReplacement: send PersonalRecordsandDataReplacement code
- For all other endorsements: delegate to Generic base chain (V141 -> V137 -> v043)
**Codes sent**: Standard CSIO values (factory-resolved) + csio:PAHAI for hail

### TryConvertToFrameworkHomeEndorsement
**What it does**: Maps CSIO coverage codes from carrier response to framework endorsement codes.
**When it runs**: When parsing an inbound home policy response that contains coverage nodes.
**Rules**:
- If incoming code = LegalLiabilityLossAssessment: return False (explicitly excluded from endorsement mapping)
- If incoming code = ReplacementCostContentsBasic: return False (explicitly excluded from endorsement mapping)
- If incoming code = OverlandWaterCoverage OR SurfaceWater: map to FloodEndorsement
- If incoming code = LimitedHiddenWaterDamage: map to LimitedHiddenWaterDamage
- If incoming code = MatchingOfUndamagedRoofSurfacingAdditionalCoverage: map to MatchingOfUndamagedRoofSurfacing
- If incoming code = MatchingOfUndamagedSidingAdditionalCoverage: map to MatchingOfUndamagedSiding
- If incoming code = HomeEquipmentProtection: map to EquipmentBreakdownCoverage
- If incoming code = csio:PAHAI: map to WindHailCoverage
- If incoming code = PersonalRecordsandDataReplacement: map to PersonalRecordsAndDataReplacement
- For all other codes: delegate to Generic base

### TryConvertToFrameworkHabDiscount
**What it does**: Maps CSIO hab discount codes from carrier response to framework discount codes.
**When it runs**: When parsing hab discounts in an inbound response.
**Rules**:
- First, if the incoming code does NOT start with "csio:", prefix it with "csio:" (fixup logic)
- If incoming code = DiscountWaterFlowDevice: map to WaterLeakDetectionSystem
- For all other codes: delegate to Generic base

---

## Policy Type Converter (PolicyTypeConverter.vb)

### TryConvertToCsio (main dispatch)
**What it does**: Routes coverage items to the correct policy type mapping function.
**When it runs**: For every hab coverage item during outbound request building.
**Rules**:
- If coverage code = COVITEM_RENTEDDWELLING: use Rented Dwelling mapping
- If coverage code = COVITEM_RENTEDCONDO: use Rented Condo mapping
- If coverage code = COVITEM_ADDITIONALRESIDENCEHOUSE: use Additional Residence Home mapping
- For all other coverage codes: delegate to Generic base

### TryConvertRentedDwellingCsio
**What it does**: Maps rented dwelling coverage types to CSIO policy types.
**Rules**:
- If coverage type = Broad: send RentedDwellingBroadForm
- If coverage type = Basic: send RentedDwellingStandardForm
- Otherwise: return False (unsupported)

### TryConvertRentedCondoToCsio
**What it does**: Maps rented condo coverage types to CSIO policy types.
**Rules**:
- If coverage type = Basic: send RentedCondominiumForm (resolves to csio:2F via V141 PolicyTypeValues)
- Otherwise: return False (unsupported)

### TryConvertAddResiHomeToCsio
**What it does**: Maps additional residence home coverage types to CSIO policy types.
**Rules**:
- If coverage type = Broad: send SecondaryHomeownersBroadForm
- If coverage type = ComprehensiveLongForm: send SecondaryHomeownersComprehensiveForm
- Otherwise: return False (unsupported)

### TryConvertHomeToCsio
**What it does**: Maps homeowner coverage types to CSIO policy types.
**Rules**:
- If coverage type = ComprehensiveLongForm: send HomeownersComprehensiveExpandedForm
- For all other types: delegate to Generic base

### TryConvertCondoToCsio
**What it does**: Maps condo coverage types to CSIO policy types.
**Rules**:
- If coverage type = ComprehensiveLongForm: send ComprehensiveCondominiumForm
- If coverage type = Basic: send CondominiumPackageStandardForm
- For all other types: delegate to Generic base

### TryConvertTenantToCsio
**What it does**: Maps tenant coverage types to CSIO policy types.
**Rules**:
- If coverage type = ComprehensiveLongForm: send TenantsComprehensiveForm
- If coverage type = Basic: send TenantsPackageStandardForm
- For all other types: delegate to Generic base

### TryConvertFecToCsio
**What it does**: Maps FEC (Farm Equipment Coverage) policy types.
**Rules**:
- Always delegates to the same mapping as Rented Dwelling

---

## Cause Of Loss Converter (CauseOfLossConverter.vb)

### ConvertToCsio
**What it does**: Maps framework claim perils to CSIO cause of loss codes.
**When it runs**: When sending claim/loss information in outbound requests.
**Rules**:
- If claim policy type = Auto: delegate entirely to Generic base
- If claim policy type = Hab (anything else):
  - If peril = SurfaceWater: send value "643"
  - If peril = GroundWater: send value "646"
  - For all other perils: delegate to Generic base

### ConvertToFramework
**What it does**: Maps CSIO cause of loss codes from response to framework perils.
**Rules**:
- If loss policy type = Auto: delegate entirely to Generic base
- If loss policy type = Hab:
  - If code = "643": map to SurfaceWater
  - If code = "646": map to GroundWater
  - For all other codes: delegate to Generic base

---

## PcCoverage Converter (FrameworkToCsio/Unrated/PcCoverageConverter.vb)

### ConvertLossAssessment
**What it does**: Sends the All Risk Loss Assessment Coverage code with a limit.
**When it runs**: When a loss assessment value exists on the coverage item.
**Rules**:
- Always send AllRiskLossAssessmentCoverage code
- If LossAssessment field value > 0: include it as the limit

### ConvertLimit (override)
**What it does**: Handles the special case where Contents or Outbuildings limit is zero.
**Rules**:
- If the limit field is Contents or Outbuildings AND the value is 0: send limit as -1 (indicating excluded)
- Otherwise: send the actual numeric value

### ConvertEndorsementOption
**What it does**: Sends earthquake coverage options.
**Rules**:
- Only handles Earthquake endorsement
- If EarthquakeCoverage field = BuildingAndContents: send BuildingandContents option code
- If EarthquakeCoverage field = BuildingOnly: send BuildingandOutbuilding option code
- If EarthquakeCoverage field = ContentsOnly: send Contents option code

### ConvertEndorsementLimit
**What it does**: Converts endorsement coverage limits.
**Rules**:
- For SewerBackup and FloodEndorsement:
  - If Coverage field = "Policy Limit": look up parent coverage amount and use that as limit
  - Otherwise: parse as decimal and send numeric limit
- For GroundWaterEndorsement:
  - Same logic as above but reads from GroundWaterEndorsement custom field
- For ServiceLineCoverage: send ServiceLineCoverage field as limit
- For all others: delegate to Generic base

### ConvertEndorsementDeductible
**What it does**: Converts endorsement deductibles.
**Rules**:
- For Earthquake: read EarthquakeDeductible field
- For WindHailCoverage: read WindandHailCoverageEndorsement field
- For all others: delegate to Generic base

### ConvertDeductible (override)
**What it does**: Handles deductible conversion with percentage support.
**Rules**:
- If deductible string ends with "%": send as percentage deductible
- If deductible is a valid integer: send as dollar amount
- If deductible string contains non-numeric characters: strip them and parse
- If WindandHailCoverageEndorsement has no value: send -1 (default/excluded indicator)

---

## PcCoverage Collection Converter (FrameworkToCsio/Unrated/PcCoverageCollectionConverter.vb)

### ConvertToPropertySchedule
**What it does**: Routes property schedule conversion based on coverage type.
**Rules**:
- If CoverageType = NamedPerils: use Named Perils conversion
- For all other types: use All Risks conversion

### ConvertHabCoverages
**What it does**: Adds extra hab coverages beyond the base set.
**Rules**:
- First: call Generic base ConvertHabCoverages
- Then: if Replacement field = true: add ReplacementCostContentsBasic coverage
- Else if LossAssessment field = true AND policy type is NOT Condo: add LossAssessment coverage

---

## CoverageConverterHelper (CsioToFramework/Rated/CoverageConverterHelper.vb)

### ConvertDeductible
**What it does**: Parses deductibles from carrier response, with earthquake special handling.
**When it runs**: When processing rated response coverage deductibles.
**Rules**:
- If coverage code = "csio:ERQK" (earthquake):
  - Try to get deductible from FormatCurrencyAmt first
  - If not available, try FormatPct
  - Append "%" suffix to the deductible value
  - Store in DeductibleGiven field
- For all other coverages: use standard deductible parsing (DeductibleGiven field)

---

## PcPolicy Converter (FrameworkToCsio/Unrated/PcPolicyConverter.vb)

### ConvertCompanyCd
**What it does**: Swaps CompanyCd to NAICCd in outbound policy.
**When it runs**: For every outbound policy request.
**Rules**:
- Call Generic base ConvertCompanyCd to set CompanyCd
- Then: move CompanyCd value to NAICCd field
- Then: clear CompanyCd to null

---

## PcPolicy Converter - Rated Response (CsioToFramework/Rated/PcPolicyConverter.vb)

### Convert
**What it does**: Defaults company code when missing in response.
**Rules**:
- If response input exists but has no CompanyCd: default to Dominion company code
- If response input is null: set company name to Dominion directly
- Then: call Generic base Convert

---

## Company Code Converter (CompanyCodeConverter.vb)

### TryConvertToCsio
**What it does**: Maps framework insurance company codes to CSIO company values.
**Rules**:
- DufferinMutualInsurance -> "DUF"
- SEMutualInsurance -> "SEM"
- GermaniaMutual -> Germania (standard value)
- AMCMutualFire -> MutualFire (standard value)
- NorthBlenheimMutual -> "NBM"
- MutualONEInsuranceCompany -> Other (standard value)
- For all other companies: delegate to Generic base
- If still unmapped after Generic base: default to "Other"

---

## Residence Type Converter (ResidenceTypeConverter.vb)

### TryConvertToCsio
**What it does**: Maps building attachment types to CSIO residence types.
**Rules**:
- If attachment type = Fourplex, Fiveplex, or Sixplex: send HighRise
- For all other types: delegate to Generic base

---

## Number Of Stories Converter (NumberOfStoriesConverter.vb)

### TryConvertToCsio
**What it does**: Maps framework number of stories to CSIO values.
**Rules**:
- OneStory -> OneStorey
- OnePointFiveStories -> OnePointFiveStoreys
- TwoStories -> TwoStoreys
- TwoPointFiveStories -> TwoPointFiveStoreys
- ThreeStories -> ThreeStoreys
- BiLevel -> BiLevel
- TriLevel -> TriLevel
- If numeric and > 6: HighRise
- All other values: Other

---

## Payment Plan Converter (PaymentPlanConverter.vb)

### TryConvertToCsio
**What it does**: Maps payment plans to CSIO frequency values.
**Rules**:
- If billing method = "Broker/Agent": delegate to Generic base
- If billing method is anything else:
  - If payment plan = Three: send ThreePayments403030
  - For all other plans: delegate to Generic base

### TryConvertToFramework
**What it does**: Maps CSIO frequency values to framework payment plans.
**Rules**:
- If frequency = ThreeEqualPayments: map to Three
- For all other values: delegate to Generic base

---

## Credit Info Consent Converter (CreditInfoConsentConverter.vb)

### TryConvertToCsio (from ConsentCode)
**What it does**: Maps credit info consent codes to CSIO values.
**Rules**:
- If no consent value provided: send NotAsked
- If consent = Yes: send ConsentNoMailings
- If consent = No: send Denied
- For any other value: send NotAsked

### TryConvertToCsio (from String)
**What it does**: Maps credit info consent string codes to CSIO values.
**Rules**:
- If string = ConsentYes: send ConsentNoMailings
- If string = ConsentNo: send Denied
- For any other value: send NotAsked

---

## Credit Score Info Converter (CreditScoreInfoConverter.vb)

### ConvertFromPrincipalInfo
**What it does**: Builds credit score information for a specific person.
**Rules**:
- Default consent code = "0" (No/Not asked)
- Search through credit scores to find the one matching the target person
- If person found with consent = "Yes": set consent code = "1", mark as found
- If person found with consent = "No": set consent code = "0", mark as found
- If person is found: create CreditScoreInfo node with consent date and consent code
- Credit score date: prefer account-level date, fall back to person-level date

---

## Exterior Wall Material Code Converter (ExteriorWallMaterialCodeConverter.vb)

### TryConvertToCsio
**What it does**: Maps framework exterior wall covering types to CSIO codes.
**Rules**:
- HardboardSiding -> WoodExterior
- Masonite, Masonry, MasonryVeneer, Brick, BrickVeneer -> BrickVeneer
- Log, CustomLog -> LogSiding
- Wood, WoodShake -> WoodExterior
- MetalClad -> MetalSiding
- Stone -> StoneVeneer
- AsphaltShingle, Clapboard, ICFConstruction -> Other
- For all other types: delegate to Generic base

---

## Construction Converter (ConstructionConverter.vb)

### ConvertConstructionCd
**What it does**: Converts building construction types from framework to CSIO. Multiple construction types can be sent.
**Rules**:
- CementConcrete -> ConcreteBlockMasonryFrame
- Log, LogHandHewn, LogManufactured, PostBeamWood, Modular, Panabode -> Log
- Sectional, FrameWood -> Frame
- StoneSolid -> Stone
- Steel -> Steel
- BrickSolid -> Brick
- MasonrySolid -> Masonry
- Each construction type with a value > 0 is added to the output list

---

## Swimming Pool / Dwell Converter

### ConvertSwimmingPool
**What it does**: Controls when swimming pool data is sent.
**Rules**:
- If swimming pool field is null, empty, or "None": skip entirely (do not send)
- Otherwise: delegate to Generic base conversion

---

## Watercraft Collection Converter

### IsWatercraft
**What it does**: Determines if a coverage item should be treated as watercraft.
**Rules**:
- If code = BoatAndMotor or JetSki AND category = Liability: NOT watercraft (return false)
- If code = BoatAndMotor or JetSki AND category is not Liability: IS watercraft (return true)
- For all other codes: check against standard watercraft code list

---

## Property Schedule Converter

### ConvertIsSummaryInd
**What it does**: Sets the IsSummaryInd flag.
**Rules**:
- Always send True (Travelers-specific request)

### ConvertPropertyClassCd
**What it does**: Determines property class code for property schedule items.
**Rules**:
- Default coverage type to AllRisk
- Read actual coverage type from company fields
- Use RiskConverter to map to CSIO property class code

---

## Risk Converter

### TryConvertToCsio
**What it does**: Maps property item codes to CSIO risk codes.
**Rules**:
- If code = FineArts:
  - Default to FineArts risk
  - If BreakageOption field = true (Dominion company): upgrade to FineArtsProfessionalCommercial
- For all other codes: delegate to Generic base

### TryConvertToFramework
**What it does**: Maps CSIO risk codes to framework property codes.
**Rules**:
- If risk = ElectronicEquipment: map to Equipment
- If risk = FineArtsProfessionalCommercial: map to FineArts
- For all other risks: delegate to Generic base

---

## Extended Status Converter (CsioToFramework/Rated)

### Convert
**What it does**: Defaults the ExtendedStatusCd when missing in response.
**Rules**:
- If response has no ExtendedStatusCd: default to VerifyData
- Then: call Generic base Convert

---

## Heating Unit Info Converter

### ConvertFuelTypeCd
**What it does**: Maps heating fuel types to CSIO fuel type codes.
**Rules**:
- If heating type = HeatPump AND fuel = GroundSource: send Electric
- For all other combinations: delegate to Generic base

---

## Insured Or Principal Collection Converter

### Convert
**What it does**: Builds the insured/principal collection with credit score person handling.
**Rules**:
- If credit score consent exists and is not false:
  - Find the credit score person by ID
  - Add credit person as "ACI" role with InsuredPrincipalRoleType = Other
- Match named insureds by full name comparison (case-insensitive)
- Named Insured 1 gets "Desktop" ID
- Named Insured 2 gets "COAPP" ID
- If account type = Corporation: also convert corporation account

---

## Alarm And Security Converter

### ConvertMonitoredFireAlarm
**What it does**: Converts monitored fire alarm information.
**Rules**:
- If MonitoredFireAlarm = true: send AlarmType = Fire, AlarmDesc = MonitoringStationFullService

### ConvertMonitoredSecuritySystem
**What it does**: Converts monitored security system information.
**Rules**:
- If MonitoredSecuritySystem = true:
  - Send AlarmType = Burglar, AlarmDesc = MonitoringStationFullService
  - If MonitoredSecuritySystemCompany has a value: add MiscParty with alarm company info

---

## Postal Installation Converter

### TryConvertToCsio
**What it does**: Maps installation types to CSIO postal installation codes.
**Rules**:
- Station -> "S"
- RetailPostOffice -> "R"
- All other types: return False (unsupported)

### TryConvertToFramework
**What it does**: Maps CSIO postal installation codes to framework types.
**Rules**:
- "S" -> Station
- "R" -> RetailPostOffice
- All other values: return False

---

## InsuranceSvcRq Converter

### ConvertQuoteInq
**What it does**: Routes quote inquiry conversion by policy type.
**Rules**:
- If policy type = Auto: convert to personal auto quote inquiry
- If policy type = Farm: convert to farm quote inquiry
- For all other types: convert to home quote inquiry
- After conversion: generate deterministic request UID from transaction document ID
