# SGICanada CZO Business Rules

**Carrier**: SGICanada
**Version**: v043 (only version)
**Extraction Date**: 2026-03-22

---

## Architecture Overview

SGICanada is a single-version carrier living entirely in `v043/Companies/SGICanada/`. It inherits from `v043/Generic/` for all base converter behavior and has no `CsioToFramework/` overrides (uses Generic response parsing). There are 66 carrier-specific VB files covering EnumConverters, FrameworkToCsio/Unrated, FrameworkToCsio/Rated, Helpers, BaseTypeConverters, and CommonConverters.

---

## EnumConverters

### CoverageCodeConverter.TryConvertToCsioHabDiscount
**What it does**: Maps framework hab discount codes to CZO discount coverage codes.
**When it runs**: When a habitational discount needs to be converted for the outbound CSIO payload.
**Rules**:
- If discount = SecuritySystem: map to PremisesAlarmFireorIntrusionSystem
- If discount = Age: map to ValuedPreferredCustomer
- If discount = WaterLeakDetectionSystem: map to WaterLeakDetectionSystem
- All other discounts: fall through to Generic base
**Codes sent**: PremisesAlarmFireorIntrusionSystem, ValuedPreferredCustomer, WaterLeakDetectionSystem (resolved via enum values factory)

### CoverageCodeConverter.TryConvertToCsioHomeEndorsement
**What it does**: Maps framework home endorsement codes to CZO endorsement coverage codes.
**When it runs**: When a habitational endorsement needs to be converted for the outbound CSIO payload.
**Rules**:
- If endorsement = GlassBreakage: map to GlassDeductibleEndorsement
- If endorsement = EquipmentBreakdownCoverage: map to PowerFluctuation
- If endorsement = SolidFuelWarranty: map directly to csio:ZSFW (carrier-proprietary)
- If endorsement = ServiceLineCoverage: map directly to csio:SLEXT
- If endorsement = WaterCoverage: map to FloodDamage
- All other endorsements: fall through to Generic base
**Codes sent**: csio:ZSFW, csio:SLEXT, GlassDeductibleEndorsement, PowerFluctuation, FloodDamage

### PolicyTypeConverter.TryConvertHomeToCsio
**What it does**: Maps framework coverage type strings to CZO policy type codes for homeowners.
**When it runs**: When building the policy type for a homeowners dwelling.
**Rules**:
- Pak A -> HomeownersLimitedForm
- Pak B -> HomeownersBroadForm; if limitIncreased AND province is not Manitoba -> HomeownersBroadExpandedForm
- Pak I -> HomeownersStandardForm; if limitIncreased AND province is not Manitoba -> HomeownersStandardExpandedForm
- Pak II -> HomeownersBroadReverseForm; if limitIncreased AND province is not Manitoba -> HomeownersBroadReverseExpandedForm
- Pak III -> HomeownersComprehensiveForm; if limitIncreased AND province is not Manitoba -> HomeownersComprehensiveExpandedForm
- PakBPlus -> HomeownersBroadExpandedForm (always expanded)
- PakIPlus -> HomeownersStandardExpandedForm (always expanded)
- PakIIPlus -> HomeownersBroadReverseExpandedForm (always expanded)
- PakIIIPlus -> HomeownersComprehensiveExpandedForm (always expanded)
- Code A -> csio:72 (Basic Residential Standard Form)
- Code AE -> BasicResidentialFireECForm
- Code B -> BasicResidentialForm
- Code C, Code H -> csio:75 (Basic Residential Comprehensive Form)
- Prestige -> HomeownersInsuranceMinimumProtection
- All others: fall through to Generic base
**Limit Increased Detection**: Triggered when SpecialLimitsEnhancement endorsement is present, or SpecialLimitsEnhancement company field = "Yes"

### PolicyTypeConverter.TryConvertCondoToCsio
**What it does**: Maps framework coverage type strings to CZO policy type codes for condos.
**Rules**:
- Pak A -> CondominiumPackageLimitedForm
- Pak I -> CondominiumPackageBroadForm; if limitIncreased -> CondominiumBroadExpandedForm
- Pak II -> ComprehensiveCondominiumForm; if limitIncreased -> CondominiumComprehensiveExpandedForm
- All others: fall through to Generic base

### PolicyTypeConverter.TryConvertTenantToCsio
**What it does**: Maps framework coverage type strings for tenants.
**Rules**:
- Pak A -> TenantsPackageLimitedForm
- Pak I -> TenantsPackageBroadForm; if limitIncreased -> csio:1A (Tenants Package Broad Expanded)
- Pak II -> TenantsComprehensiveForm; if limitIncreased -> TenantsComprehensiveExpandedForm
- Special Senior's Pak -> TenantsSeniorsPackage
- All others: fall through to Generic base

### PolicyTypeConverter.TryConvertSeasonalToCsio
**What it does**: Maps framework coverage type strings for seasonal dwellings.
**Rules**:
- Code A -> csio:72
- Code B -> BasicResidentialForm
- Code C -> csio:75
- Pak A -> SeasonalDwellingLimitedForm
- Pak B -> SeasonalDwellingBroadForm
- Pak I -> SeasonalDwellingStandardForm
- Pak II -> SeasonalDwellingBroadReverseForm
- Pak III -> SeasonalDwellingComprehensiveForm

### PolicyTypeConverter.TryConvertFecToCsio
**What it does**: Maps framework coverage type strings for rented/FEC dwellings.
**Rules**:
- Code A -> RentedDwellingStandardForm
- Code B -> RentedDwellingBroadForm
- Code C -> RentedDwellingComprehensiveForm
- All Pak types: fall through to TryConvertHomeToCsio (same as homeowners)

### ChimneyTypeConverter.TryConvertToCsioChimney
**What it does**: Converts framework chimney types to CZO chimney codes.
**Rules**:
- MetalHighTemperatureS629M, MetalSingleWall, MetalTypeAVent, MetalTypeBVent, MetalUnspecified -> FactoryBuiltDoubleWalledMetal
- MetalOther -> Other
- None -> Unknown
- DirectVent -> PrefabricatedandCertified
- All others: fall through to Generic base

### VehicleBodyTypeConverter.TryConvertToCsioMotorcycle
**What it does**: Overrides motorcycle body type mapping.
**Rules**:
- If Generic converts to MinibikeTrailBikeOffRoad: remap to Motorcyclesover50cc
- All other types: use Generic result unchanged

### ValuationProductConverter.TryConvertToCsio
**What it does**: Maps framework evaluator types to CZO valuation product codes.
**Rules**:
- EZITV -> "7"
- IClarify -> "8"
- E2Value -> "9"
- All others: fall through to Generic base

### PaymentPlanConverter.TryConvertToCsio
**What it does**: Maps framework payment plans to CZO frequency codes.
**Rules**:
- Plan One -> Annual
- Plan Two -> Semiannual
- Plan Three -> ThreePayments403030
- All others: fall through to Generic base

### BillingMethodConverter.TryConvertToCsio
**What it does**: Maps billing method codes to CZO billing method values.
**Rules**:
- "MAC" or BillingCodes.Mac -> DirectBill
- All others: fall through to Generic base

### CompanyProductConverter
**What it does**: Maps company codes bidirectionally.
**Rules**:
- InsuranceCompanyCode.Echelon <-> "ECHE"
- All others: fall through to Generic base

### OccupancyTypeConverter.TryConvertToCsio
**What it does**: Maps occupancy types with special SGICanada condo logic.
**Rules**:
- Tenant + PrimaryItem + Condo or PrimaryItemCondo -> RentedToThirdParty
- Tenant + PrimaryItem + Other -> Rental
- FamilyMember + PrimaryItem + Condo -> "C" (company-specific FamilyMemberOccupied value)
- PrimaryItemTenant (any occupancy) -> Rental
- All others: fall through to Generic base

### ClassSpecificRatedIndicatorConverter.TryConvertToCsio
**What it does**: Determines dwelling classification (Standard vs Preferred) based on policy type.
**Rules**:
- Policy types SeasonalDwellingStandardForm, SeasonalDwellingBroadForm, BasicResidentialFireECForm, BasicResidentialForm -> "Standard"
- Policy types HomeownersBroadForm, HomeownersComprehensiveExpandedForm, HomeownersFormOther, TenantsPackageStandardForm, TenantsComprehensiveForm, CondominiumPackageStandardForm, ComprehensiveCondominiumForm, MobileHomeBroadForm -> "Preferred"
- Falls through to Generic base first

---

## FrameworkToCsio (Outbound Request Building)

### PcCoverageCollectionConverter (Unrated)

#### ConvertToWatercraft
**What it does**: Converts watercraft coverages.
**Rules**:
- SGICanada watercrafts are always all risk (calls ConvertWatercraftAllRisks directly)

#### ConvertToPersVeh
**What it does**: Converts vehicle-level coverages and adds province-specific mandatory coverages.
**Rules**:
- Calls Generic base first
- If province = New Brunswick (NB): always add HealthServicesLevy coverage, even if we do not rate it

#### ConvertAccidentBenefits
**What it does**: Converts Ontario increased accident benefits as separate coverage codes.
**Rules**:
- If AttendantCare enabled: send csio:ACB
- If Caregiver enabled: send csio:CHHMB
- If DependantCare enabled: send csio:DCB
- If MedicalRehabilitation enabled: send csio:MEDRH
- If IncomeReplacement > $400: send IncomeReplacement coverage with the dollar limit
- If IndexationBenefit enabled: send Indexation coverage
- If MedicalRehabilitationAndAttendantCare enabled: send MedicalRehabAttendantCare coverage
- If DeathAndFuneral enabled: send DeathAndFuneralBenefits coverage

#### SkipEndorsements
**What it does**: Determines which endorsement codes should not be sent as separate coverage entries.
**Rules**:
- Always skip Opcf47 and SolidFuelWarranty
- If province = Nova Scotia (NS): skip Pak03, Pak05, Pak06 (send child endorsements instead of parent pak)
- For all other provinces: if a pak endorsement exists, skip its child endorsements (parent pak replaces children)

#### ConvertTPL / ConvertBodilyInjury / ConvertPropertyDamage
**What it does**: Sends liability coverages only when premiums are non-zero.
**Rules**:
- TPL: only send if PremiumTPL is non-zero AND PremiumTPLBodilyInjury = 0 AND PremiumTPLPhysicalDamage = 0 (combined TPL only when no split)
- BodilyInjury: only send if not a Trailer AND PremiumTPLBodilyInjury is non-zero
- PropertyDamage: only send if not a Trailer AND PremiumTPLPhysicalDamage is non-zero

#### ConvertAdditionalLivingExpense
**What it does**: Only sends additional living expense for tenant policies.
**Rules**:
- If policyType = Tenant: send additional living expense (via Generic base)
- Otherwise: do not send

### PcCoverageConverter (Unrated)

#### ConvertEndorsementLimit
**What it does**: Sets endorsement limit values with special handling for certain codes.
**Rules**:
- End19/Opcf19: clear existing limits, set limit from PurchasePrice field
- End44/Opcf44: clear existing limits, set limit from Liability company field
- DayCareInHome: clear existing limits, set limit from Liability field on the endorsement company
- SewerBackup: convert sewer backup limit (Policy Limit uses parent coverage amount, otherwise uses the coverage type value directly)
- Earthquake: convert earthquake limit with ValuationCd ("EB" for Building Only, "EA" for Building and/or Contents)

#### ConvertEndorsementDeductible
**What it does**: Sets endorsement deductible values.
**Rules**:
- GlassReducedDeductible: uses the GlassDeductibleEndorsementDeductible field
- All endorsements: also checks the generic Deductible field

#### ConvertEndorsementOption
**What it does**: Adds endorsement-specific option values.
**Rules**:
- DayCareInHome: adds number of children as option value
- ResidenceEmployees: sums chauffeurs + inside + outside employees as a single option value

#### ConvertHabContents
**What it does**: Skips hab contents conversion when SingleLimitEndorsement is active.
**Rules**:
- If any endorsement is SingleLimitEndorsement: skip contents entirely
- Otherwise: use Generic base

#### ConvertAdditionalLivingExpense (on PcCoverageConverter)
**What it does**: Overrides additional living expense to send as Rental Income.
**Rules**:
- Sets coverage code to RentalIncome (instead of standard additional living expense)
- Clears the limit

### CompanySpecificFieldCollectionConverter (Unrated)

#### ConvertToDwell
**What it does**: Adds SGICanada-specific company fields to dwelling output.
**Rules**:
- Adds HYDRANTDISTANCECODE: hydrantWithin300M = true -> 2, false -> 3
- Adds FIRESTATIONDISTANCECODE: calculated from distance in km (<=5 -> 1, <=8 -> 2, <=13 -> 4, >13 -> 5, unknown -> 0)
- Adds PRIMARY_BACKUP_VALVE: None -> 98, Other -> 99, Flapper -> 01, Gate -> 02

### QuestionAnswerConverter (Unrated)

**What it does**: Maps framework question/answer fields to CZO response indicator codes.
**Rules**:
- OwnTrampoline -> csio:137
- GardenTractor -> csio:138
- GolfCart -> csio:139
- UnlicensedRecreationalVehicles -> csio:140
- MotorizedWheelChairs -> csio:141
- OwnWaterCraft -> csio:142
- RegisteredOwner -> uses GetResponseIndicatorValues().RegisteredOwner (from factory)

### PersAutoPolInfoConverter (Unrated)

**What it does**: Aggregates and migrates vehicle and policy question/answers.
**Rules**:
- Aggregates these vehicle-level questions to the first vehicle: RentLeaseToOthers (no priority), CarryPassengersForCompensation (no priority), AutomobileUsedToHaulTrailer (yes priority), CarryExplosivesRadioactiveMaterial (no priority)
- Migrates these policy-level questions to the first vehicle: OtherDriversInHousehold, Fraud, MaterialMisrepresentation, RegisteredOwner
- Migrates these policy-level questions to the first driver: LicenseSuspendedCancelledLapsed, InsuranceCancelledDeclinedRefused
- Aggregation uses weighted responses: "No"/"NotAnswered" outweigh "Yes" (except when yes-priority is set)

### ConstructionConverter (Unrated)

**What it does**: Adds post-beam/log construction handling.
**Rules**:
- If ConstructionPostBeamWood percentage > 0: add Log construction code
- If ConstructionPostBeamWood = 100%: skip Generic base construction
- Otherwise: call Generic base for remaining construction types

### DwellConverter (Unrated)

**What it does**: Handles heating unit info migration and coverage ID assignment.
**Rules**:
- Migrates PrimaryHeatingApparatus and AuxiliaryHeatingApparatusProfessionallyInstalled question/answers from HeatingUnitInfo to Dwell level
- Assigns coverage IDs to all coverages that don't have one

### LossConverter (Unrated)

**What it does**: Modifies loss cause code format and damage amounts.
**Rules**:
- Strips "csio:" prefix from all loss cause codes (SGICanada expects codes without the prefix)
- Rounds damage total amounts to whole dollars (SGICanada service faults on decimal values)

### OtherOrPriorPolicyConverter (Unrated)

**What it does**: Adds previous policy termination details.
**Rules**:
- If no PolicyTerminatedCd set and PreviousRestrictedCoverage = true: set PolicyTerminatedCd to csio:6
- Sets OriginalInceptionDt from ContinuouslyInsuredSince date
- Always sets CancelledDeclinedCd to "Other"

### NameInfoConverter (Unrated)

**What it does**: Converts person and policy names as commercial names (not person names).
**Rules**:
- Person names: concatenated as "Title FirstName MiddleName LastName" into CommercialName
- Policy named insureds: combined as "Named1 & Named2" into a single CommercialName
- Mortgagee names: sent as CommercialName

---

## FrameworkToCsio (Rated)

### PcCoverageCollectionConverter (Rated)

#### ConvertToDwell
**What it does**: Removes coverages that SGICanada includes automatically when SingleLimitEndorsement is present.
**Rules**:
- When HomeownersSingleLimit coverage is found, remove these coverages from output:
  - AllRiskUnitOwnersBuildingImprovementsandBettermentsIncreasedLimits
  - PersonalPropertyOtherthanHomeownersTenantandCondominiumForm
  - PersonalPropertyHomeownersForm
  - NamedPerilsUnitOwnersAdditionalProtection
  - AllRiskUnitOwnersAdditionalProtection
  - NamedPerilsUnitOwnersBuildingImprovementsandBettermentsIncreasedLimits
  - AllRiskLossAssessmentCoverage
  - CondominiumBareLandLossAssessment
  - NamedPerilsLossAssessmentCoverage

#### ConvertPersVehDiscounts (Rated)
**What it does**: Filters and deduplicates vehicle discounts.
**Rules**:
- Skip these discounts: GraduatedLicense, DriverTraining, NewDriver, NewBusiness
- For all other discounts: prevent duplicates with same rate from being sent
- Duplicate detection compares the first CreditOrSurcharge numeric value

#### ConvertPersVehSurcharges (Rated)
**What it does**: Suppresses all auto surcharges.
**Rules**:
- Does nothing -- all surcharges are suppressed

#### ConvertHabDiscounts (Rated)
**What it does**: Filters certain hab discounts.
**Rules**:
- Skip: NoReplacementCost, Deductible, AboveThirdFloor
- All other discounts: send normally

#### SkipEndorsements (Rated)
**What it does**: Determines which endorsements to skip in rated output.
**Rules**:
- Always skip Opcf47, SolidFuelWarranty
- Skip Pak03, Pak05, Pak06 in Nova Scotia
- Skip any endorsement with $0 term premium AND $0 premium (except SingleLimitEndorsement)

### PcCoverageConverter (Rated)

#### GetValue
**What it does**: Converts percentage deviations to dollar deviations.
**Rules**:
- If deviation type = ByPercentage: multiply value by 100 and change type to ByDollars
- Then call Generic base

#### ConvertEndorsement
**What it does**: Special handling for SingleLimitEndorsement.
**Rules**:
- SingleLimitEndorsement: sets coverage ID, converts non-zero limit from SingleLimitCoverageGiven field
- All other endorsements: use Generic base

### PersAutoLineBusinessConverter (Rated)

**What it does**: Migrates accident benefit coverages from line-of-business level to first vehicle.
**Rules**:
- Migrates these coverage codes from LineBusiness to first PersVeh: ACB, CHHMB, DCB, MEDRH, IncomeReplacement, Indexation, MedicalRehabAttendantCare, DeathAndFuneralBenefits

---

## Additional Notes

- SGICanada removes foreign licenses from driver output (LicenseCollectionConverter)
- Driver use percentages are recalculated: primary = 51%, occasionals split remaining 49% evenly (DriverVehCollectionConverter)
- Payment options split into PMTINFO (main) and PMTDOWN (deposit) entries
- Territory codes have "Territory " prefix stripped (DwellRatingConverter)
- Building improvement years are formatted as year-only dates
- Swimming pool year built is formatted as year-only date
- Address converter uses simple address format (no DetailAddr) with suite, street number, name, type, direction, PO box
- Credit score consent is sent as company-specific values: ConsentYes, ConsentNo with consent date
