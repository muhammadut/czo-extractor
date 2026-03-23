# SandboxMutual (Sandbox) - Business Rules Document

**Carrier**: SandboxMutual (folder: Sandbox, company code: SKM)
**Version**: V141 (single version)
**Extraction Date**: 2026-03-20
**Inherits From**: V141.Generic -> V137 -> V134 -> V133 -> V043 (Generic base)

---

## Table of Contents

1. [Coverage Code Conversion (CoverageCodeConverter)](#coverage-code-conversion)
2. [Policy Type Conversion (PolicyTypeConverter)](#policy-type-conversion)
3. [Endorsement Limit Handling (PcCoverageConverter)](#endorsement-limit-handling)
4. [Hab Coverage Processing (PcCoverageCollectionConverter)](#hab-coverage-processing)
5. [Fire Protection Classification (BldgProtectionConverter)](#fire-protection-classification)
6. [Dwelling Rating Classification (DwellRatingConverter)](#dwelling-rating-classification)
7. [Occupancy Type Conversion (OccupancyTypeConverter)](#occupancy-type-conversion)
8. [Construction Type Conversion (ConstructionConverter)](#construction-type-conversion)
9. [Watercraft Handling](#watercraft-handling)
10. [Response Parsing (CsioToFramework)](#response-parsing)
11. [Other Converter Overrides](#other-converter-overrides)

---

## Coverage Code Conversion

### TryConvertToCsioHomeLiability
**What it does**: Converts TBW liability codes to CSIO coverage codes for hab policies.
**When it runs**: When a hab policy has a liability endorsement being sent outbound.
**Rules**:
- If liability code is any of: AdditionalResidenceHouse, AdditionalResidenceCondo, AdditionalResidenceTenant, AdditionalResidenceMobileHome, AdditionalResidence, SeasonalDwelling, RentedCondo, or RentedDwelling -> send "AdditionalResidencesPropertiesAcreage" code
- If liability code is VoluntaryPropertyDamageInc -> send "VoluntaryPropertyDamage" code
- If liability code is AdditionalNamedInsured -> send "AdditionalNamedInsured" code
- If liability code is Horses -> send "AnimalLiabilityExtension" code
- If liability code is RentedRoomSuite -> send "AdditionalUnits" (V134) code
- All other liability codes fall through to the generic base converter
**Codes sent**: AdditionalResidencesPropertiesAcreage, VoluntaryPropertyDamage, AdditionalNamedInsured, AnimalLiabilityExtension, AdditionalUnits

### TryConvertToCsioHomeEndorsement
**What it does**: Converts TBW endorsement codes to CSIO coverage codes for hab policies.
**When it runs**: When a hab policy endorsement is being sent outbound.
**Rules**:
- If endorsement is CondoDeductibleAssessment -> send "csio:CDEDA"
- If endorsement is EquipmentBreakdownCoverage -> send "csio:HOEQP"
- If endorsement is ReplacementCostPlus -> send "GuaranteedReplacementCostBuilding"
- If endorsement is Glass -> send "GlassBreakage"
- If endorsement is AdditionalNamedInsuredProperty -> send "AdditionalNamedInsured"
- If endorsement is WaterCoverageAndSewerBackup -> send "SurfaceWater" (V134)
- All other endorsement codes fall through to the generic base converter
**Codes sent**: csio:CDEDA, csio:HOEQP, GuaranteedReplacementCostBuilding, GlassBreakage, AdditionalNamedInsured, SurfaceWater

### TryConvertToFrameworkHomeEndorsement (Inbound)
**What it does**: Converts CSIO coverage codes back to TBW endorsement codes when parsing responses.
**When it runs**: When a CSIO response contains hab endorsement coverage codes.
**Rules**:
- csio:CDEDA -> CondoDeductibleAssessment
- csio:HOEQP -> EquipmentBreakdownCoverage
- GlassBreakage -> Glass
- SurfaceWater (V134) -> WaterCoverageAndSewerBackup
- AdditionalNamedInsured -> AdditionalNamedInsuredProperty
- csio:JPPWB (JetSkiLiability) -> JetSki (as LiabilityCodes cast to EndorsementCodes)
- AdditionalUnits (V134) -> RentedRoomSuite (as LiabilityCodes cast to EndorsementCodes)
- VandalismTheftByTenantsAndGuest (V134) -> Return False (explicitly ignored, not mapped to any framework code)
- VoluntaryPropertyDamage -> VoluntaryPropertyDamageInc (as LiabilityCodes cast to EndorsementCodes)
- All other codes fall through to the generic base converter

### TryConvertToFrameworkHabDiscount (Inbound)
**What it does**: Maps CSIO discount codes to TBW discount codes for hab.
**When it runs**: When parsing a rated response and identifying hab discounts.
**Rules**:
- DiscountCreditConsentReceived (V137 auto code) -> CreditScore
- DiscountHigherFloorUnit (V137) -> AboveThirdFloor
- MiscellaneousDiscount (V137) -> FireResistive
- DiscountUnfinishedBasement (V137) -> UnderConstruction
- All other codes fall through to the generic base converter

### TryConvertToFrameworkHabSurcharge (Inbound)
**What it does**: Maps CSIO surcharge codes to TBW surcharge codes for hab.
**When it runs**: When parsing a rated response and identifying hab surcharges.
**Rules**:
- CommercialExposure (V137) -> TenantCondoWithCommercialOccupancy
- All other codes fall through to the generic base converter

---

## Policy Type Conversion

### TryConvertToCsio (Routing)
**What it does**: Routes coverage items to the correct policy type conversion method.
**When it runs**: When determining the CSIO policy type for a coverage item.
**Rules**:
- If coverage item code is COVITEM_RENTEDDWELLING -> use rented dwelling conversion
- If coverage item code is COVITEM_RENTEDCONDO -> use rented condo conversion
- All other codes fall through to the base converter, which routes to Home/Condo/Tenant/Seasonal/FEC methods

### TryConvertHomeToCsio
**What it does**: Maps home policy coverage types to CSIO policy types.
**Rules**:
- Form B -> HomeownersBroadReverseForm
- Form D, Comprehensive, HomeComprehensive -> HomeownersComprehensiveForm
- Form K, Broad -> HomeownersBroadForm
- Named Perils, Basic -> HomeownersStandardForm
- Form DCR (Sandbox-specific) -> Other
- All others fall through to generic base

### TryConvertCondoToCsio
**What it does**: Maps condo policy coverage types to CSIO policy types.
**Rules**:
- Form CNF, Form F, Comprehensive, HomeComprehensive -> ComprehensiveCondominiumForm
- Form CNE, Form E, Named Perils, Basic -> CondominiumPackageStandardForm
- All others fall through to generic base

### TryConvertTenantToCsio
**What it does**: Maps tenant policy coverage types to CSIO policy types.
**Rules**:
- Form TNE, Form E, Named Perils, Basic -> TenantsPackageStandardForm
- Form TNF, Form F, Comprehensive, HomeComprehensive -> TenantsComprehensiveForm
- Senior's Tenant Pak, Senior Tenant, Seniors Tenant -> TenantsSeniorsPackage
- All others fall through to generic base

### TryConvertSeasonalToCsio
**What it does**: Maps seasonal policy coverage types to CSIO policy types.
**Rules**:
- Named Perils, Basic -> SecondaryHomeownersLimitedForm
- Form B -> SecondaryHomeownersFormOther
- Broad, Form K -> SecondaryHomeownersBroadForm
- Form D, Comprehensive, HomeComprehensive -> SecondaryHomeownersComprehensiveForm
- Fire and Extended Coverage -> SeasonalDwellingFireECForm (V141 new enum value)
- All Risk -> SeasonalDwellingComprehensiveForm
- All others fall through to generic base

### TryConvertRentedDwellingCsio
**What it does**: Maps rented dwelling coverage types to CSIO policy types.
**Rules**:
- Comprehensive, HomeComprehensive -> RentedDwellingComprehensiveForm
- Fire and Extended Coverage -> RentedDwellingFireECForm (V141 new enum value)
- All others return False (no match)

### TryConvertRentedCondoToCsio
**What it does**: Maps rented condo coverage types to CSIO policy types.
**Rules**:
- Form CNF, Comprehensive, HomeComprehensive -> RentedCondominiumForm (V141 new enum value)
- Form CNE, Named Perils, Basic -> CondomimiumFormOther
- All others return False (no match)

### TryConvertFecToCsio
**What it does**: FEC (Fire Extended Coverage) policies route to the rented dwelling conversion.

---

## Endorsement Limit Handling

### ConvertEndorsementLimit (PcCoverageConverter)
**What it does**: Handles special limit conversion for specific endorsement types.
**When it runs**: When an endorsement is being sent and needs its limit set.
**Rules**:
- CondoDeductibleAssessment: Read limit from CondoDeductibleAssessmentEndorsement field on parent, or Coverage field on endorsement itself. Send as formatted currency in Limit node.
- SewerBackup: Read coverage from SewerBackup field on parent, or Coverage field on endorsement. If value is "Policy Limit", send -2 as limit. Otherwise fall through to base.
- WaterCoverageAndSewerBackup: Same logic as SewerBackup but reads from WaterCoverageAndSewerBackup field.
- BuildingBylawsExtension: Read from BuildingBylawsCoverage field on parent, or Coverage field on endorsement. Always exits after setting limit.
- All other endorsements: If coverage value was "Policy Limit", send -2. Otherwise fall through to base converter.

### ConvertEndorsementDeductible (PcCoverageConverter)
**What it does**: Handles glass deductible endorsement specifically.
**Rules**:
- GlassReducedDeductible: Read from GlassDeductible field. If value is "Policy Deductible", send -2 as deductible. Otherwise send the numeric value.
- All other endorsements fall through to base.

### ConvertEndorsementCoverageDesc (PcCoverageConverter)
**What it does**: Sets the coverage description for endorsements.
**Rules**:
- If the endorsement has a Description, use it.
- Otherwise if it has a Name, use that.
- (Generic base uses a different logic for this)

---

## Hab Coverage Processing

### ConvertHabCoverages (PcCoverageCollectionConverter)
**What it does**: Adds additional coverages to the hab output based on company-specific fields.
**When it runs**: After base hab coverages are converted, before the output is sent.
**Rules**:
- If Burglary field is true -> Add "TheftandBurglary" coverage with description "Burglary"
- If Vandalism field is true -> Add "VandalismTheftByTenantsAndGuest" (V134) coverage with description "Vandalism"
- If Replacement field is true -> Add "GuaranteedReplacementCostBuilding" coverage with description "Replacement Cost Plus"
- If LifeLease field is true -> Add "ValuedPreferredCustomer" coverage (discount code used as coverage) with description "Life Lease Dis."
- If BuildingType = "Commercial Building" AND CommercialBuildingType is not "None" -> Add "CommercialExposure" surcharge with description "Commercial Occupancies Surcharge"

### ConvertHabCoverage (PcCoverageConverter)
**What it does**: Overrides the default hab coverage code for Senior Tenant policies.
**Rules**:
- After base conversion, if coverage code is PersonalPropertyTenantAndCondominiumUnitOwnersForm AND the policy is a Tenant type with Senior Tenant coverage type -> override code to PersonalPropertyHomeownersForm
- Always sets a coverage description ("Residence" for dwelling, "Contents" for tenant/condo)

### ConvertHabCoverageCd (PcCoverageConverter)
**What it does**: Overrides the contents coverage code for seasonal policies.
**Rules**:
- If coverage type is Contents AND policy type is Seasonal -> use PersonalPropertyOtherThanHomeownersTenantAndCondominiumForm instead of the standard contents code

### ConvertUnskippedEndorsement (PcCoverageCollectionConverter)
**What it does**: Handles special endorsement filtering and code changes.
**Rules**:
- If policy is Seasonal AND endorsement code is GuaranteedReplacementCostBuilding AND description is "Guaranteed Replacement Cost" -> skip the endorsement (do not add to request)
- If endorsement is GlassReducedDeductible AND it is a seasonal residence (Seasonal policy with All Risk or FEC coverage type) -> change the code from GlassReducedDeductible to GlassBreakage
- All other endorsements are added normally

### ConvertMedicalPayments (PcCoverageCollectionConverter)
**What it does**: Suppresses medical payments.
**Rules**:
- Do nothing. Medical payments are not sent for Sandbox.

### ConvertLossAssessment (PcCoverageCollectionConverter)
**What it does**: Sends loss assessment coverage only if the amount is non-zero.
**Rules**:
- If LossAssessment field exists AND value is not zero -> send AllRiskLossAssessmentCoverage with the amount as limit and description "Loss Assessment - Property"

---

## Fire Protection Classification

### ConvertFireProtectionClassCd (BldgProtectionConverter)
**What it does**: Determines fire protection classification for the dwelling.
**When it runs**: During outbound conversion of building protection information.
**Rules**:
- Read the RespondingFirehallHab field
- If value is "ProtectedUrban" -> Protected
- If value is a number and distance is <= 13 km -> Protected
- If not protected yet, check HydrantProtectionHab field: if hydrant within 300m -> Protected
- If protected -> send "P" (FireHallProtected)
- If not protected -> send "U" (FireHallUnprotected)
**Codes sent**: "P" or "U" as open enum values

---

## Dwelling Rating Classification

### ConvertClassSpecificRatedCd (DwellRatingConverter)
**What it does**: Converts dwelling classification override to CSIO classification.
**Rules**:
- Read ClassificationOverride field from coverage item company fields
- Map: "Standard" -> Standard, "Preferred" -> Preferred, "Preferred Plus" -> Superior
- Territory code is NOT sent (override suppresses it to avoid cache memory issues)

---

## Occupancy Type Conversion

### TryConvertToCsio (OccupancyTypeConverter)
**What it does**: Converts occupancy type to CSIO based on multiple factors.
**Rules**:
- If dwelling is under construction -> UnderConstruction
- Owner occupancy:
  - Primary item + Seasonal policy -> SecondarySeasonal
  - Primary item + FEC policy -> SecondaryNonSeasonal
  - Primary item + other policy -> PrimaryResidence
  - Seasonal Dwelling or Rented Dwelling additional residence -> SecondarySeasonal
  - Other additional residence -> SecondaryNonSeasonal
- Family Member occupancy:
  - Primary item + Seasonal -> SecondarySeasonal
  - Primary item + other -> FamilyOccupied (V128)
  - Seasonal Dwelling additional -> SecondarySeasonal
  - Other -> FamilyOccupied (V128)
- Tenant occupancy:
  - Primary item + Tenant policy -> Return False (do not send)
  - Primary item + other -> RentedToThirdParty (V128)
  - Tenant additional residence -> Return False (do not send)
  - Other -> RentedToThirdParty (V128)
- Unoccupied -> Other (V128)

### TryConvertToFramework (OccupancyTypeConverter - Inbound)
**What it does**: Converts CSIO occupancy type back to TBW.
**Rules**:
- FamilyOccupied (V128) -> FamilyMember
- PrimaryResidence -> Owner (unless additional residence Tenant -> Tenant)
- SecondaryNonSeasonal -> Owner (unless additional residence Tenant -> Tenant)
- All others fall through to generic base

---

## Construction Type Conversion

### ConvertConstructionCd (ConstructionConverter)
**What it does**: Maps TBW construction material fields to CSIO construction codes. Supports multiple materials per dwelling.
**Rules**:
- CementConcrete -> ConcreteBlockMasonryFrame (V132)
- Log, LogHandHewn, LogManufactured, PostBeamWood -> Log (all map to same code)
- Sectional, Modular, Panabode -> Other
- StoneSolid -> Stone
- Steel -> Steel
- BrickSolid -> Brick
- FrameWood -> Frame
- MasonrySolid -> Other
**Note**: Each construction type is checked independently and added if percentage > 0. Multiple construction types can be sent.

---

## Watercraft Handling

### ConvertWatercraftLiability (PcCoverageConverter)
**What it does**: Handles watercraft liability with special JetSki treatment.
**Rules**:
- Check if input has a Liability field set to true, or if category is Liability
- If JetSki -> send csio:JPPWB as coverage code with the JetSki's own liability limit
- If other watercraft (BoatAndMotor) -> send WatercraftLiabilityA with the policy TPL limit
- Description is always "Liability"

### ConvertWatercraftHullAllRisks (PcCoverageConverter)
**What it does**: Sends hull all risks coverage with description.
**Rules**:
- Call base conversion first
- If endorsement has a Description -> use it
- Otherwise -> set "Hull - All Risk"

### ConvertWatercraftHull (PcCoverageConverter)
**What it does**: Combines boat and motor values into hull limit.
**Rules**:
- Call base hull conversion
- If MotorCoverage field has a value > 0 -> add motor amount to the boat hull limit

### IsWatercraft (WatercraftCollectionConverter)
**What it does**: Determines if a coverage item is a watercraft.
**Rules**:
- BoatAndMotor, JetSki, TrailerHoliday -> yes if category is MiscProperty, no if Liability
- All others -> check against CsioConstants.WatercraftCoverageitemCodes

### ConvertSpeed (PcBasicWatercraftConverter)
**What it does**: Converts watercraft speed.
**Rules**:
- Read Speed field -> send as MPH (MilesPerHour measurement)
- Sandbox uses MPH unit (unlike standard which might use other units)

---

## Response Parsing

### ConvertFromDwell (CsioToFramework Rated PcCoverageConverter)
**What it does**: Processes rated response dwelling coverages.
**Rules**:
- Strip "?" characters from coverage descriptions
- If coverage code maps to a home endorsement AND it is NOT a "Guaranteed Replacement on Secondary Seasonal" -> treat as endorsement
- Otherwise -> treat as parent coverage item

### IsGuaranteedReplacementOnSecondarySeasonal
**What it does**: Identifies a special case for replacement cost on seasonal policies.
**Rules**:
- If description is "Replacement Cost Plus" AND code is GuaranteedReplacementCostBuilding AND PrincipalUnitAtRiskInd is False -> return True
- This means it is treated as a parent coverage item, not an endorsement

### ConvertDwellCoverage (CsioToFramework Rated PcCoverageConverter)
**What it does**: Routes dwelling coverage codes to the appropriate handler.
**Rules**:
- CondominiumContingentLegalLiability -> add as hab coverage
- AllRiskUnitOwnersAdditionalProtection -> add as hab coverage
- TheftandBurglary or VandalismTheftByTenantsAndGuest -> add as hab coverage
- GuaranteedReplacementCostBuilding -> add as hab coverage
- AllRiskPersonalProperty (V121) -> add as hab coverage
- All others -> fall through to base converter

### ConvertBoatAndMotorLiability (CsioToFramework Rated HomeLineBusinessConverter)
**What it does**: Moves watercraft liability premiums to the corresponding misc property items.
**Rules**:
- After base conversion, scan all coverage items for BoatAndMotor Liability and JetSki Liability premium values
- Copy those premiums to the corresponding MiscProperty coverage items' LiabilityPremium field

### WatercraftConverter (CsioToFramework Rated)
**What it does**: Identifies JetSki watercraft from item description.
**Rules**:
- If watercraft ItemDescription is "Jet Ski" -> set coverage item code to MiscPropertyCodes.JetSki

---

## Other Converter Overrides

### DwellOccupancyConverter
- OwnerOccupiesUnitInd: If occupancy is "Owner" -> set to True
- ResidenceTypeCd: For Tenant and FEC policies, read building type from "Type" or "BuildingType" field. Other policies use base logic.

### DetachedStructuresInfoConverter
- Adds ResidenceTypeCd to detached structures based on building attachment type
- For MobileHome policies: if Csaa277Approved -> ModularHome; if MiniHome (100%) -> MiniHome; otherwise -> MobileHome

### AddrConverter
- Clears DetailAddr and DetailAddr_Csio127 (uses simple address format only)
- Legal addresses include AddrValidationInd indicator

### CommunicationsConverter
- Adds broker language: French -> "fr", all others -> "en"

### InsuredOrPrincipalCollectionConverter
- Uses "Desktop" as primary insured ID and "ACI" as secondary
- Prioritizes persons marked as Insured, then falls back to name matching, then uses any person
- Supports corporation accounts

### AcordConverter
- PermId: Uses BrokerNumber (trimmed) instead of default PermId

### PropertyScheduleConverter
- NumItemsPerSummary: Read from HowMany field, minimum 1

### PropertyScheduleCollectionConverter
- Travel trailers are excluded from property schedule items

### DwellConverter
- SepticTankInd: Explicitly converts to True/False boolean (base may handle differently)

### FinishedBasementInfoConverter
- If basement finished percentage is empty -> clear the field (don't send a default)

### HeatingUnitInfoConverter
- Oil tank item info includes model year set to age of oil tanks

### NumberOfStoriesConverter
- If base converter cannot match the number of stories -> use "Other"

### MsgStatusCdConverter
- SuccessWithChanges and SuccessWithInfo -> empty alert message suffix (no warning text)

### PostConversionCleaner
- Cleans rated coverage items by merging Category, Code, ParentID, Name, and Active from target (unrated) items to rated items

### DwellRatingConverter (CsioToFramework Unrated)
- Territory code is suppressed (not read from CSIO response) to handle cache memory concerns

---

## Property Schedule Special Fields

### Tools
- If coverage item is Tools -> read UsedOutsideOfHome field and send as CompanySpecificField with FieldCd="UsedOutsideOfHome" and Value="1"/"0"

### Computer
- If coverage item is Computer -> read Floater field and send as CompanySpecificField with FieldCd="UsedOutsideOfHome" and Value="1"/"0"

### Horses (Liability)
- Sends NumOfUnits CompanySpecificField with the count from HowMany field

### RentedRoomSuite (Liability)
- Sends NumOfUnits CompanySpecificField with the count from Suites field
