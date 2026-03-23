# Sandbox Business Rules

Extracted: 2026-03-22
Version: V141 (only version)
Inheritance: V141/Companies/Sandbox -> V141/Generic -> V137/Generic -> V136/Generic -> ... -> v043/Generic

---

## CoverageCodeConverter (EnumConverters)

### TryConvertToCsioHomeLiability
**What it does**: Converts framework liability codes to CSIO coverage codes for hab policies.
**When it runs**: Outbound request building, when a hab liability item is being converted.
**Rules**:
- If liability code is any of AdditionalResidenceHouse, AdditionalResidenceCondo, AdditionalResidenceTenant, AdditionalResidenceMobileHome, AdditionalResidence, SeasonalDwelling, RentedCondo, or RentedDwelling: send AdditionalResidencesPropertiesAcreage
- If liability code is VoluntaryPropertyDamageInc: send VoluntaryPropertyDamage
- If liability code is AdditionalNamedInsured: send AdditionalNamedInsured
- If liability code is Horses: send AnimalLiabilityExtension
- If liability code is RentedRoomSuite: send AdditionalUnits (V134 schema)
- Otherwise: delegate to V141 Generic base

**Codes sent**: AdditionalResidencesPropertiesAcreage, VoluntaryPropertyDamage, AdditionalNamedInsured, AnimalLiabilityExtension, AdditionalUnits

### TryConvertToCsioHomeEndorsement
**What it does**: Converts framework endorsement codes to CSIO coverage codes for hab endorsements.
**When it runs**: Outbound request building, when a hab endorsement is being converted.
**Rules**:
- If endorsement is CondoDeductibleAssessment: send csio:CDEDA (Condo Deductible Assessment, Earthquake Excluded)
- If endorsement is EquipmentBreakdownCoverage: send csio:HOEQP
- If endorsement is ReplacementCostPlus: send GuaranteedReplacementCostBuilding
- If endorsement is Glass: send GlassBreakage
- If endorsement is AdditionalNamedInsuredProperty: send AdditionalNamedInsured
- If endorsement is WaterCoverageAndSewerBackup: send SurfaceWater (V134 schema)
- Otherwise: delegate to V141 Generic base

**Codes sent**: csio:CDEDA, csio:HOEQP, GuaranteedReplacementCostBuilding, GlassBreakage, AdditionalNamedInsured, SurfaceWater

### TryConvertToFrameworkHomeEndorsement
**What it does**: Converts incoming CSIO coverage codes back to framework endorsement codes.
**When it runs**: Response parsing, when classifying incoming hab coverages.
**Rules**:
- If CSIO code is csio:CDEDA: return CondoDeductibleAssessment
- If CSIO code is csio:HOEQP: return EquipmentBreakdownCoverage
- If CSIO code is GlassBreakage: return Glass
- If CSIO code is SurfaceWater (V134): return WaterCoverageAndSewerBackup
- If CSIO code is AdditionalNamedInsured: return AdditionalNamedInsuredProperty
- If CSIO code is csio:JPPWB (JetSkiLiability): return JetSki (cast as EndorsementCodes)
- If CSIO code is AdditionalUnits (V134): return RentedRoomSuite (cast as EndorsementCodes)
- If CSIO code is VandalismTheftByTenantsAndGuest: return False (skip, not classified as endorsement)
- If CSIO code is VoluntaryPropertyDamage: return VoluntaryPropertyDamageInc (cast as EndorsementCodes)
- Otherwise: delegate to V141 Generic base

### TryConvertToFrameworkHabDiscount
**What it does**: Classifies incoming CSIO codes as hab discounts.
**When it runs**: Response parsing, when classifying discounts on hab policies.
**Rules**:
- If CSIO code is DiscountCreditConsentReceived (V137 Auto): return CreditScore
- If CSIO code is DiscountHigherFloorUnit (V137 Hab): return AboveThirdFloor
- If CSIO code is MiscellaneousDiscount (V137 Hab): return FireResistive
- If CSIO code is DiscountUnfinishedBasement (V137 Hab): return UnderConstruction
- Otherwise: delegate to V141 Generic base

### TryConvertToFrameworkHabSurcharge
**What it does**: Classifies incoming CSIO codes as hab surcharges.
**When it runs**: Response parsing, when classifying surcharges on hab policies.
**Rules**:
- If CSIO code is CommercialExposure (V137 Hab): return TenantCondoWithCommercialOccupancy
- Otherwise: delegate to V141 Generic base

---

## PolicyTypeConverter (EnumConverters)

### TryConvertToCsio (main dispatcher)
**What it does**: Routes policy type conversion based on coverage item code.
**When it runs**: Outbound, for every coverage item.
**Rules**:
- If coverage item code is COVITEM_RENTEDDWELLING: use RentedDwelling conversion
- If coverage item code is COVITEM_RENTEDCONDO: use RentedCondo conversion
- Otherwise: delegate to V118 Generic base (which dispatches by policy type: Home, Condo, Tenant, Seasonal, FEC)

### TryConvertHomeToCsio
**What it does**: Converts homeowner coverage types to CSIO policy type codes.
**Rules**:
- FormB: HomeownersBroadReverseForm
- FormD, Comprehensive, HomeComprehensive: HomeownersComprehensiveForm
- FormK, Broad: HomeownersBroadForm
- NamedPerils, Basic: HomeownersStandardForm
- FormDCR (Sandbox-specific): Other
- Otherwise: delegate to base

### TryConvertCondoToCsio
**Rules**:
- FormCNF, FormF, Comprehensive, HomeComprehensive: ComprehensiveCondominiumForm
- FormCNE, FormE, NamedPerils, Basic: CondominiumPackageStandardForm
- Otherwise: delegate to base

### TryConvertRentedDwellingCsio (Sandbox-specific)
**Rules**:
- Comprehensive, HomeComprehensive: RentedDwellingComprehensiveForm
- FireAndExtendedCoverage: RentedDwellingFireECForm (V141 schema extension)
- Otherwise: return False

### TryConvertRentedCondoToCsio (Sandbox-specific)
**Rules**:
- FormCNF, Comprehensive, HomeComprehensive: RentedCondominiumForm (V141 schema extension)
- FormCNE, NamedPerils, Basic: CondomimiumFormOther
- Otherwise: return False

### TryConvertTenantToCsio
**Rules**:
- FormTNE, FormE, NamedPerils, Basic: TenantsPackageStandardForm
- FormTNF, FormF, Comprehensive, HomeComprehensive: TenantsComprehensiveForm
- Senior's Tenant Pak, Senior Tenant, Seniors Tenant: TenantsSeniorsPackage
- Otherwise: delegate to base

### TryConvertSeasonalToCsio
**Rules**:
- NamedPerils, Basic: SecondaryHomeownersLimitedForm
- FormB: SecondaryHomeownersFormOther
- Broad, FormK: SecondaryHomeownersBroadForm
- FormD, Comprehensive, HomeComprehensive: SecondaryHomeownersComprehensiveForm
- FireAndExtendedCoverage: SeasonalDwellingFireECForm (V141 schema extension)
- AllRisk: SeasonalDwellingComprehensiveForm
- Otherwise: delegate to base

### TryConvertFecToCsio
**Rules**:
- Delegates entirely to TryConvertRentedDwellingCsio (FEC uses same policy types as rented dwelling)

---

## PcCoverageConverter (FrameworkToCsio/Unrated)

### ConvertEndorsementLimit
**What it does**: Sets endorsement limits with special handling for certain endorsements.
**Rules**:
- CondoDeductibleAssessment: Custom limit from CondoDeductibleAssessmentEndorsement field (or Coverage field as fallback)
- SewerBackup: Limit from SewerBackup field or Coverage field. If "Policy Limit" selected, sends -2
- WaterCoverageAndSewerBackup: Same pattern as SewerBackup but using WaterCoverageAndSewerBackup field. If "Policy Limit", sends -2
- BuildingBylawsExtension: Limit from BuildingBylawsCoverage field or Coverage field. Always exits after setting limit
- All others: delegate to base

### ConvertEndorsementDeductible
**Rules**:
- GlassReducedDeductible: If GlassDeductible field value is "Policy Deductible", sends -2. Otherwise sends the field value
- All others: delegate to base

### ConvertHabCoverageCd
**What it does**: Overrides the coverage code for Contents on Seasonal policies.
**Rules**:
- If coverage is Contents AND policy type is Seasonal: use PersonalPropertyOtherthanHomeownersTenantandCondominiumForm instead of the default
- Otherwise: delegate to base

### ConvertHabCoverage
**What it does**: Post-processes hab coverage to handle Senior Tenant special case and add descriptions.
**Rules**:
- If the output coverage code is PersonalPropertyTenantandCondominiumUnitOwnersForm AND it is a Senior Tenant on a Tenant policy: override to PersonalPropertyHomeownersForm
- Sets CoverageDesc to "Contents" for tenant/condo content items, "Residence" for dwelling items

### IsSeniorTenantOnTenantPolicy
**Rules**:
- Returns true if policy type is Tenant AND coverage type is one of: "Seniors Tenant", "Senior's Tenant Pak", "Senior Tenant"

### ConvertWatercraftLiability
**What it does**: Converts watercraft liability, with special JetSki handling.
**Rules**:
- First checks if the item has liability (via Liability field or Liability category)
- If item is JetSki: send csio:JPPWB and use the item's specific liability limit
- If item is any other watercraft: send standard WatercraftLiabilityA with the policy TPL limit
- Always adds CoverageDesc = "Liability"

### ConvertWatercraftHullAllRisks
**Rules**:
- Delegates to base, then sets CoverageDesc to the item's Description (or "Hull - All Risk" if empty)

### ConvertWatercraftHull
**Rules**:
- Delegates to base, then adds MotorCoverage limit to the boat hull limit (combined hull+motor)

### ConvertLossAssessment
**Rules**:
- Always sends AllRiskLossAssessmentCoverage code with description "Loss Assessment - Property"
- Limit from LossAssessment field (only if > 0)

### ConvertAdditionalLivingExpense
**Rules**:
- Delegates to base, then sets CoverageDesc = "Additional Living Expense"

---

## PcCoverageCollectionConverter (FrameworkToCsio/Unrated)

### ConvertHabCoverages
**What it does**: Adds extra standalone coverages beyond the standard hab set.
**Rules**:
- Standard hab coverages are converted by base
- If Burglary field is true: add TheftAndBurglary coverage
- If Vandalism field is true: add VandalismTheftByTenantsAndGuest coverage (V134)
- If Replacement field is true: add GuaranteedReplacementCostBuilding coverage (desc: "Replacement Cost Plus")
- If LifeLease field is true: add ValuedPreferredCustomer discount code (desc: "Life Lease Dis.")
- If building type is "Commercial Building" AND commercialBuildingType is not "None": add CommercialExposure surcharge (desc: "Commercial Occupancies Surcharge")

### ConvertUnskippedEndorsement
**What it does**: Post-processes endorsements, filtering out invalid combinations.
**Rules**:
- If policy is Seasonal AND endorsement is GuaranteedReplacementCostBuilding with desc "Guaranteed Replacement Cost": SKIP (do not add)
- If endorsement is GlassReducedDeductible AND it is a Seasonal Residence (AllRisk or FEC coverage on Seasonal policy): override code to GlassBreakage
- Otherwise: add normally

### IsSeasonalResidence
**Rules**:
- Returns true if policy type is Seasonal AND coverage type is AllRisk or FireAndExtendedCoverage

### ConvertToWatercraft
**What it does**: Special watercraft conversion that separates hull and liability.
**Rules**:
- If item category is MiscProperty: convert all-risks hull
- Always convert watercraft liability (separate coverage element)

### ConvertToPropertySchedule
**What it does**: Converts scheduled property items with special field handling.
**Rules**:
- If coverage type is NamedPerils: use named perils conversion
- Otherwise: use all-risks conversion
- If item has liability, add property schedule liability
- If item is Tools: add UsedOutsideOfHome company-specific field (0 or 1)
- If item is Computer: add UsedOutsideOfHome (from Floater field) as company-specific field (0 or 1)

---

## PcCoverageConverter (CsioToFramework/Rated)

### ConvertFromDwell
**What it does**: Routes incoming rated dwelling coverages to endorsement or coverage parsing.
**Rules**:
- If the coverage code maps to a framework home endorsement AND it is NOT guaranteed replacement on secondary/seasonal: treat as endorsement
- Otherwise: treat as dwelling coverage (building, contents, etc.)
- Special: if CoverageDesc contains "?", the "?" is stripped

### IsGuarantedReplacementOnSecondarySeasonal
**Rules**:
- Returns true if: CoverageDesc = "Replacement Cost Plus" AND CoverageCd = GuaranteedReplacementCostBuilding AND PrincipalUnitAtRiskInd = False

### ConvertDwellCoverage
**What it does**: Routes specific coverage codes to proper framework fields.
**Rules**:
- CondominiumContingentLegalLiability: add as hab coverage
- AllRiskUnitOwnersAdditionalProtection: add as hab coverage
- TheftandBurglary or VandalismTheftByTenantsAndGuest: add as hab coverage
- GuaranteedReplacementCostBuilding: add as hab coverage
- AllRiskPersonalProperty (V121): add as hab coverage
- Otherwise: delegate to base

### ConvertAddHabCoverageLimit
**What it does**: Maps rated coverage limits to framework field names.
**Rules**:
- PersonalPropertyHomeownersForm or AllRiskPersonalProperty: ContentsGiven
- PersonalPropertyTenantandCondominiumUnitOwnersForm: CoverageGiven
- CondominiumContingentLegalLiability: ContingentGiven
- AllRiskUnitOwnersAdditionalProtection: LossAssessmentLiabilityGiven
- AdditionalLivingExpense: AdditionalLivingExpense
- TheftandBurglary: BurglaryCoverageGiven
- VandalismTheftByTenantsAndGuest: VandalismCoverageGiven
- GuaranteedReplacementCostBuilding: ReplacementCostGiven
- Otherwise: delegate to base

### ConvertCoveragePremium
**What it does**: Maps rated coverage premiums to framework premium field names.
**Rules**:
- AllRiskPersonalProperty (V121): PremiumContents
- OtherStructuresHomeownersForms: PremiumOutbuildings
- AdditionalLivingExpense: PremiumAdditionalLivingExpense
- AllRiskUnitOwnersAdditionalProtection: PremiumLossAssessmentLiability
- TheftandBurglary: PremiumBurglary
- VandalismTheftByTenantsAndGuest (V134): PremiumVandalism
- Otherwise: delegate to base

---

## OccupancyTypeConverter (EnumConverters)

### TryConvertToCsio
**What it does**: Maps framework occupancy to CSIO occupancy type codes.
**Rules**:
- If dwelling is under construction: send UnderConstruction
- If occupancy is Owner:
  - Primary item: PrimaryResidence (default), SecondarySeasonal (Seasonal policy), SecondaryNonSeasonal (FEC policy)
  - Seasonal/Rented dwelling: SecondarySeasonal
  - Other additional residences: SecondaryNonSeasonal
- If occupancy is FamilyMember:
  - Primary item: FamilyOccupied (V128, default), SecondarySeasonal (Seasonal policy)
  - Seasonal dwelling: SecondarySeasonal
  - Other: FamilyOccupied (V128)
- If occupancy is Tenant:
  - Primary item on Tenant policy: not sent (returns False)
  - Primary item on other policy: RentedToThirdParty (V128)
  - Additional Residence Tenant: not sent (returns False)
  - Other: RentedToThirdParty (V128)
- If occupancy is Unoccupied: Other (V128)

---

## ConstructionConverter (FrameworkToCsio/Unrated)

### ConvertConstructionCd
**What it does**: Converts multiple construction type fields to CSIO construction codes.
**Rules**:
- Each construction type field is checked independently; multiple can be sent
- CementConcrete: ConcreteBlockMasonryFrame (V132)
- Log, LogHandHewn, LogManufactured, PostBeamWood: Log
- Sectional, Modular, Panabode, MasonrySolid: Other
- StoneSolid: Stone
- Steel: Steel
- BrickSolid: Brick
- FrameWood: Frame

---

## HomeLineBusinessConverter (CsioToFramework/Rated)

### ConvertBoatAndMotorLiability
**What it does**: Post-processes rated watercraft items to move liability premiums to the MiscProperty items.
**Rules**:
- Find BoatAndMotor liability premium and JetSki liability premium from rated coverage items
- Copy those premiums to the corresponding MiscProperty coverage items via the LiabilityPremium field
- This enables the premium to be displayed alongside the watercraft item rather than as a separate liability line

---

## WatercraftConverter (CsioToFramework/Rated)

### Convert
**What it does**: Overrides the item code for Jet Ski watercraft.
**Rules**:
- After base conversion, if ItemDesc = "Jet Ski": override Code to MiscPropertyCodes.JetSki
- This ensures Jet Ski items are recognized as such regardless of the standard classification

---

## DwellRatingConverter (FrameworkToCsio/Unrated)

### ConvertClassSpecificRatedCd
**What it does**: Sends the dwelling classification (Standard/Preferred/Preferred Plus).
**Rules**:
- Reads ClassificationOverride from company fields
- Uses ClassSpecificRatedIndicatorConverter to map: Standard -> Standard, Preferred -> Preferred, PreferredPlus -> Superior

### ConvertTerritoryCd
**What it does**: Suppresses territory code.
**Rules**:
- Does nothing (intentionally empty to prevent cache values from being sent)

---

## DwellOccupancyConverter (FrameworkToCsio/Unrated)

### ConvertResidenceTypeCd
**What it does**: Converts residence type with policy-type-specific logic.
**Rules**:
- For Tenant or FEC policies: use the "Type" field (or "BuildingType" as fallback) via ResidenceTypeConverter
- For all other policy types: delegate to V128 Generic base

---

## CauseOfLossConverter (EnumConverters)

### ConvertToCsio
**What it does**: Converts claim perils to CSIO cause of loss codes.
**Rules**:
- If claim policy type is Auto: delegate entirely to base
- For property claims:
  - SurfaceWater -> SurfaceWater (V130)
  - GroundWater -> GroundWater (V130)
  - WaterDamageInfiltration -> WaterDamageInfiltration (V130)
  - ImpactByVehicle -> ImpactLandVehicleInsuredOperator (V130)
  - ExteriorSewerLineBreakage -> ExteriorSewerLine (V130)
  - ExteriorWaterLineBreakage -> ExteriorWaterLine (V130)
  - Otherwise: delegate to base
