# Gore Mutual - Business Rules Document

**Carrier**: Gore Mutual
**Version**: V131 (single active version)
**Extraction Date**: 2026-03-22
**Policy Types Supported**: Home (Homeowner, Condo, Tenant, Seasonal, FEC/Farm)

---

## Coverage Code Converter (EnumConverters/CoverageCodeConverter.vb)

### TryConvertToCsioHomeEndorsement (outbound)
**What it does**: Converts framework endorsement codes to CSIO coverage codes for home endorsements.
**When it runs**: When sending hab endorsements to Gore in a quote/bind request.
**Rules**:
- WaterCoverageAndSewerBackup maps to the V131-specific SurfaceWater code (not the standard SewerBackupCoverage)
- SewerBackup maps to the standard SewerBackupCoverage code
- GolfCart maps to the standard GolfCart LiabilityExtensions value
- DissapearingDeductible maps to the V131-specific EndorsementForChangeInDeductibleNotice value
- Lifestyle3Pack maps to csio:OTH3
- Lifestyle4Pack maps to csio:OTH4
- VacantLandCondoCorpEndorsement maps to VacantLand under PersonalLiability
- SpecialLimitsEnhancement maps to V131-specific EnhancedInternalLimits
- CondoDeductibleAssessment maps to csio:CDEDA

**Codes sent**: SurfaceWater, SewerBackupCoverage, GolfCart, EndorsementForChangeInDeductibleNotice, csio:OTH3, csio:OTH4, VacantLand, EnhancedInternalLimits, csio:CDEDA

### TryConvertToCsioHomeLiability (outbound)
**What it does**: Converts framework liability codes to CSIO coverage codes for home liabilities.
**When it runs**: When sending liability endorsements to Gore.
**Rules**:
- BusinessUseOfHome maps to csio:HBBLI (Home Based Business Liability Extension) -- OVERRIDES the v043 generic mapping of IncidentalBusinessPursuitsEndorsement
- AdditionalResidenceTenant, AdditionalResidenceHouse, AdditionalResidenceCondo all map to the standard AdditionalResidencesPropertiesAcreage
- RentedDwelling and RentedCondo both map to csio:ADRNT (Additional Locations Rented)
- SeasonalDwelling maps to csio:SEDWG (Seasonal Dwelling Liability Extension) -- OVERRIDES the v043 generic mapping of SeasonalResidence
- All other liability codes fall through to the v043 generic base

**Codes sent**: csio:HBBLI, AdditionalResidencesPropertiesAcreage, csio:ADRNT, csio:SEDWG

### TryConvertToCsioAutoEndorsement (outbound)
**What it does**: Converts framework auto endorsement codes to CSIO codes.
**When it runs**: When sending auto endorsements to Gore.
**Rules**:
- DissapearingDeductible maps to the V131-specific EndorsementForChangeInDeductibleNotice value
- All other auto endorsements fall through to the v043/V129 generic base (standard OPCF codes)

---

## PcCoverageConverter (FrameworkToCsio/Unrated/PcCoverageConverter.vb)

### ConvertHabCoverageCd
**What it does**: Determines the CSIO coverage code for hab dwelling coverage.
**When it runs**: When building the PCCOVERAGE element for a dwelling item.
**Rules**:
- If the coverage is Dwell AND the policy type is Condo: use PersonalPropertyHomeownersForm (instead of standard DwellingResidenceforHomeowner)
- All other combinations fall through to the base implementation

### ConvertEndorsementDeductible
**What it does**: Determines how to extract and send endorsement deductibles.
**When it runs**: When a hab endorsement has a deductible value.
**Rules**:
- Earthquake endorsement: reads the EarthquakeDeductible field and strips the trailing "%" character (e.g., "5%" becomes 5)
- GlassReducedDeductible: reads the GlassDeductible field
- All other endorsements: reads the standard Deductible field

### ConvertEndorsementOption (Earthquake)
**What it does**: Adds coverage option codes to endorsements.
**When it runs**: When sending endorsement details with option values.
**Rules**:
- Earthquake endorsement: reads EarthquakeCoverage field. If "Building and Contents" sends BuildingandContents option code. If "Building Only" sends Building option code.
- ResidenceEmployees: calculates total employee count from Chauffeurs + InsideEmployees + OutsideEmployees + OccassionalEmployees
- Horses: sends the horse count as OptionValue
- AdditionalNamedInsured: sends mortgagee count and CrossLiability option (Yes/No)

### ConvertWatercraftLiability
**What it does**: Determines the CSIO coverage code for watercraft liability.
**When it runs**: When the watercraft item has liability enabled.
**Rules**:
- Liability is true if the Liability company field is true, OR if the coverage item category is Liability
- JetSki items get WaterjetPropulsionPersonalWatercraftBasic
- All other watercraft get WatercraftLiabilityA

### ConvertHabCoverageEffectiveDt
**What it does**: Adds an effective date to certain hab endorsements.
**When it runs**: When converting PermissionForUnoccupancy endorsement.
**Rules**:
- Only applies to PermissionForUnoccupancy endorsement code
- Reads the DeceasedDate field and sets it as the coverage EffectiveDt

### GetCoverageCdPropertyScheduleAllRisks
**What it does**: Determines the coverage code for scheduled property all-risks.
**When it runs**: When building scheduled property (floater) coverage.
**Rules**:
- TrailerBoat items get TrailerAllRisks from WatercraftUtilityBoatTrailerCoverageForms
- All other items fall through to the base implementation

### Additional Residence Endorsements
**What it does**: Adds special endorsements for additional residences (secondary dwellings).
**When it runs**: When converting additional residence endorsements.
**Rules**:
- LossAssessment: sends AllRiskLossAssessmentCoverage if LossAssessment field > 0
- SpecialLimitsEnhancement: sends EnhancedInternalLimits if SpecialLimitsEnhancement field > 0
- ClaimProtector: sends ClaimFreeProtection if ClaimsProtectorEndorsment field > 0
- DeathAndDismemberment: sends AccidentalDeathandDismemberment if CoverageDeathAndDismemberment field > 0
- Betterments: sends AllRiskUnitOwnersBuildingImprovementsandBettermentsIncreasedLimits if BettermentsGiven field > 0

---

## PcCoverageCollectionConverter (FrameworkToCsio/Unrated/PcCoverageCollectionConverter.vb)

### ConvertToPropertySchedule
**What it does**: Routes property schedule items to named perils or all risks conversion.
**When it runs**: When building property schedule coverage elements.
**Rules**:
- If CoverageType is NamedPerils: use named perils conversion
- Otherwise: use all risks conversion (default)

### SkipEndorsements
**What it does**: Determines which endorsement codes to skip during hab coverage conversion.
**When it runs**: When processing hab endorsement collections.
**Rules**:
- Skips all watercraft coverage item codes (watercraft handled separately)

### ConvertAdditionalLivingExpense
**What it does**: Controls whether additional living expense is sent.
**When it runs**: When converting hab coverages.
**Rules**:
- Condo policy type: do NOT send additional living expense
- All other policy types: send additional living expense normally

### ConvertHabCoverages (Condo special handling)
**What it does**: Special condo coverage handling.
**When it runs**: When policy type is Condo.
**Rules**:
- For Condo: sends only the hab coverage, improvements/betterments, contingent liability, and loss assessment
- For non-Condo: uses the standard base implementation

### ConvertHabTPL
**What it does**: Controls whether TPL (Third Party Liability) is sent.
**When it runs**: When converting hab TPL coverage.
**Rules**:
- Only sends TPL if the Liability company field is explicitly set to True
- If Liability field is missing or False, TPL is NOT sent

---

## PolicyTypeConverter (EnumConverters/PolicyTypeConverter.vb)

### TryConvertHomeToCsio
**What it does**: Maps Gore coverage types to CSIO policy type codes.
**When it runs**: When determining the CSIO policy type for a homeowner policy.
**Rules**:
- "Comp. Plus" maps to HomeownersComprehensiveForm
- "Plus" maps to HomeownersBroadForm
- "VIP Plus" maps to HomeownersComprehensiveExpandedForm
- Any other coverage type maps to HomeownersBroadExpandedForm (default)

### TryConvertCondoToCsio
**What it does**: Maps Gore condo coverage types.
**Rules**:
- AllRisks/AllRisk maps to ComprehensiveCondominiumForm
- VipPlus maps to CondominiumComprehensiveExpandedForm
- Others fall through to the v043 base

### TryConvertTenantToCsio
**What it does**: Maps Gore tenant coverage types.
**Rules**:
- AllRisks/AllRisk maps to TenantsComprehensiveForm
- Others fall through to the v043 base

### TryConvertSeasonalToCsio
**What it does**: Maps Gore seasonal coverage types.
**Rules**:
- FourSeasonsSuperior maps to SeasonalDwellingBroadForm
- Others fall through to the v043 base

### TryConvertFecToCsio
**What it does**: Maps Farm Equivalent Coverage (FEC) types.
**Rules**:
- Delegates to TryConvertHomeToCsio with the same logic as homeowner

### TryConvertToCsio (Farm policy detection)
**What it does**: Detects farm policy types and adjusts the conversion.
**Rules**:
- If policy type is Farm AND the coverage code is a valid PrimaryItemCode: converts the farm policy type using IsEquivalentFarmPolicyTypeOf helper, then delegates to the base converter
- Otherwise: delegates directly to the base converter

---

## MultiPolicyDiscountConverter (EnumConverters/MultiPolicyDiscountConverter.vb)

### TryConvertToCsio
**What it does**: Sends multi-policy discount information.
**When it runs**: When building the quote request with multi-line discount data.
**Rules**:
- Calls the base converter first (handles standard multi-policy logic)
- Then checks the primary item coverage item for a MultiLine company field
- If MultiLine is True: sets the multi-policy discount to ImmediateDiscount
- Supporting policy validation: accepts "Quote All" or "Gore Mutual" as valid supporting policy values

---

## CsioToFramework (Response Parsing)

### IsDiscount / IsSurcharge (CsioToFramework/Rated/PcCoverageConverter.vb)
**What it does**: Classifies incoming coverage codes as discounts or surcharges.
**When it runs**: When parsing rated response from Gore.
**Rules**:
- IsDiscount: the portion of the coverage code after the colon must start with "DIS" (e.g., "csio:DISXYZ")
- IsSurcharge: the portion of the coverage code after the colon must start with "SUR" (e.g., "csio:SURXYZ")
- All other codes are treated as endorsements/coverages

### ConvertDwellCoverage (special condo handling)
**What it does**: Routes certain coverage codes to additional hab coverage conversion.
**When it runs**: When parsing rated dwelling coverages.
**Rules**:
- CondominiumContingentLegalLiability, AllRiskLossAssessmentCoverage, AllRiskUnitOwnersAdditionalProtection, AdditionalLivingExpense: treated as additional hab coverages (not primary dwelling)
- All others: use the standard base conversion

### ConvertCoveragePremium
**What it does**: Routes premiums to the correct framework fields.
**When it runs**: When parsing rated coverage premiums.
**Rules**:
- PersonalPropertyHomeownersForm -> PremiumContents
- OtherStructuresHomeownersForms -> PremiumOutbuildings
- DwellingResidenceforHomeowner -> PremiumBase
- AdditionalLivingExpense -> PremiumAdditionalLivingExpense
- SewerBackupCoverage / SurfaceWater -> Premium (generic)

### FixSurfaceWaterLimit
**What it does**: Adjusts the surface water endorsement limit in the rated response.
**When it runs**: When the response contains a SurfaceWater coverage code.
**Rules**:
- Finds the WaterCoverageAndSewerBackup endorsement attached to the dwelling
- If condo AND the limit equals the contents given: sets Coverage to "Policy Limit"
- If the limit equals the Coverage field value: sets Coverage to "Policy Limit"
- Otherwise: sets Coverage to the actual limit amount

---

## Construction Converter (FrameworkToCsio/Unrated/ConstructionConverter.vb)

### ConvertConstructionCd
**What it does**: Sends construction type codes for the dwelling.
**When it runs**: When building the construction element.
**Rules**:
- Checks for Asbestos field first (adds Asbestos code if true)
- Then checks each construction material field (BrickSolid, CementConcrete, FrameWood, Log, MasonrySolid, Steel, StoneSolid) and adds the corresponding CSIO code if > 0%
- Sectional and PostBeamWood are both mapped to Frame
- If no specific construction fields found, falls back to the generic Construction field ("Log" or "Frame")

---

## Building Protection Converter (FrameworkToCsio/Unrated/BldgProtectionConverter.vb)

### ConvertFireProtectionClassCd
**What it does**: Determines fire protection class (Protected/Unprotected).
**When it runs**: When building the building protection element.
**Rules**:
- If RespondingFirehallHab is ProtectedUrban: Protected
- If RespondingFirehallHab is a numeric distance value: Protected
- If neither, checks HydrantProtectionHab: if hydrant within 300m: Protected
- If no fire protection found: Unprotected
- Protected sends "P", Unprotected sends "U"

---

## Watercraft Handling

### WaterUnitTypeConverter
**What it does**: Maps boat types to CSIO water unit types.
**Rules**:
- JetSki -> RunaboutSkiBoat
- Pontoon -> PontoonBoat
- Motorboat -> RunaboutSkiBoat
- Cruiser/CuddyCruiser -> CabinCruiser
- MultihulledVessels/TunnelHull -> MultiHulledVessels
- None, AirCushion, Canoe, Charter, Homebuilt, Houseboat, Hydroplane, Inflatable, JetBoat, Sailboat, Windsurfer: returns False (not sent as water unit type)

### PropulsionTypeConverter
**What it does**: Maps boat/motor types to propulsion types.
**Rules**:
- JetSki: returns False (no propulsion type sent)
- Sailboat -> Sail
- Canoe/Kayak/Rowboat/Windsurfer -> NonPowerCraft
- JetBoat -> Waterjet
- If boat type is not specific, checks motor type: Inboard, InboardOutdrive, Outboard

### CsioConstants overrides
**What it does**: Defines which coverage items are watercraft vs dwelling.
**Rules**:
- WatercraftAccessoryCoverageitemCodes: empty (no accessories)
- WatercraftCoverageitemCodes: BoatAndMotor, JetSki, Boat, Motor
- DwellingCoverageItemCodes: PrimaryItem, PrimaryItemTenant, PrimaryItemCondo, plus all additional residence codes (House, Tenant, Condo, MobileHome, RentedCondo, RentedDwelling, SeasonalDwelling)

---

## OccupancyTypeConverter

### TryConvertToCsio
**What it does**: Maps framework occupancy types to CSIO codes.
**When it runs**: When building occupancy type for a dwelling.
**Rules**:
- Owner + AdditionalResidence Condo -> PrimaryResidence
- FamilyMember + AdditionalResidence Condo -> csio:O (OccupancyTypeOther, workaround for CSIO v1.28 bug)
- All other combinations fall through to the v043 base

---

## RiskConverter (Scheduled Property)

### TryConvertToCsio (outbound)
**What it does**: Maps framework misc property codes to CSIO risk codes.
**Rules**:
- SportingEquipment -> MiscellaneousSportingEquipment
- VideoEquipment -> VideoEquipment
- AudioVideoMedia -> AudioVisualDataMediaCDDVDVHSetc
- Television -> Televisions
- StereoEquipment -> ElectronicEquipment
- Piano -> MusicalInstruments
- GolfCart -> GolfCart
- WindsurfingEquipment -> SportsEquipment
- HockeyEquipment -> MiscellaneousProperty
- Computer: checks Laptop field (true -> Laptop, false -> PersonalComputer)
- FineArts: checks Use field (Professional -> FineArtsProfessionalCommercial, otherwise -> FineArts)
- Jewellery: checks StoredInSafetyDepositBox field (true -> JewelleryInVaultSafetydeposit, otherwise -> Jewellery)
