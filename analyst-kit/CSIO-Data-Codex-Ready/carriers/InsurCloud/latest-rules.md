# InsurCloud Business Rules

**Carrier**: InsurCloud (Gore Mutual / SGI Canada via InsurCloud service vendor)
**Version**: V134
**Extracted**: 2026-03-22

---

## Routing

### ConverterFactoryLoader Routing
**What it does**: Determines which converter factory to use based on company code and service vendor.
**When it runs**: On every CZO request/response for Gore Mutual or SGI Canada.
**Rules**:
- If company = GoreMutual AND serviceVendor = InsurCloud: use InsurCloud converter factory
- If company = SGICanada/CoachmanInsurance AND serviceVendor = InsurCloud: use InsurCloud converter factory
- Otherwise: falls back to generic or other carrier-specific factories

---

## Auto Endorsements

### TryConvertToCsioOntarioAutoEndorsement
**What it does**: Converts framework auto endorsement codes to CSIO codes for Ontario vehicles.
**When it runs**: When building outbound auto endorsement XML for Ontario-rated vehicles.
**Rules**:
- If endorsement = DissapearingDeductible: use the EndorsementForChangeInDeductibleNotice value from V134 enum factory
- If endorsement = Opcf49: send csio:49
- If endorsement = Opcf47R: send csio:47R
- All other Ontario auto endorsements: delegate to V134.Generic base (which inherits standard OPCF codes from v043)
**Codes sent**: csio:49, csio:47R, plus dynamic EndorsementForChangeInDeductibleNotice

### TryConvertToCsioAutoEndorsement (Non-Ontario)
**What it does**: Converts non-Ontario auto endorsements.
**When it runs**: For vehicles not rated in Ontario.
**Rules**:
- If endorsement = DissapearingDeductible: use EndorsementForChangeInDeductibleNotice from V134 enum factory
- All others: delegate to generic base
**Codes sent**: EndorsementForChangeInDeductibleNotice (dynamic)

---

## Auto Discounts (Inbound)

### TryConvertToFrameworkAutoDiscount
**What it does**: Maps CSIO discount codes from carrier response back to framework DiscountCode enum.
**When it runs**: When parsing rated auto responses from InsurCloud.
**Rules**:
- csio:DISTR -> DiscountCode.Territory (Northern Territory)
- csio:DISAL -> DiscountCode.AntiTheft
- csio:DISAS -> DiscountCode.AwayAtSchool
- csio:DISRN -> DiscountCode.Renewal (Loyalty)
- csio:DISMP -> DiscountCode.MultiLine
- csio:DISSN -> DiscountCode.WinterTire
- csio:DISRD -> DiscountCode.Retiree
- csio:DISMV -> DiscountCode.MultiVehicle
- csio:DISGR -> DiscountCode.GraduatedLicense
- csio:DISFR -> DiscountCode.Farm
- csio:DISCF -> DiscountCode.ConvictionFree
- csio:DISTP -> DiscountCode.TrailPermit
- csio:DISEM -> DiscountCode.Occupation (Employee)
- csio:DISLC -> DiscountCode.LowCommuteDistance
- All others: delegate to generic base

---

## Auto Surcharges (Inbound)

### TryConvertToFrameworkAutoSurcharge
**What it does**: Maps CSIO surcharge codes from carrier response to framework SurchargeCode.
**When it runs**: When parsing rated auto responses.
**Rules**:
- csio:SURCL -> SurchargeCode.Claims (At-Fault Claim)
- csio:SURML -> SurchargeCode.StandAlone
- csio:SURAT -> SurchargeCode.Miscellaneous (Underage)
- csio:SURCE -> SurchargeCode.Miscellaneous (Snow Plough/Blades)
- csio:SURRA -> SurchargeCode.RadiusOfOperation
- csio:SURCN -> SurchargeCode.Convictions
- csio:SURHT -> SurchargeCode.HighTheft
- All others: delegate to generic base

---

## Home Endorsements

### TryConvertToCsioHomeEndorsement (Outbound)
**What it does**: Converts framework home endorsement codes to CSIO for outbound requests.
**When it runs**: When building hab endorsement XML.
**Rules**:
- LogEndorsement -> LogConstructionSettlementLimitation (V134 enum)
- GolfCart -> csio:GOLFC
- GlassReducedDeductible -> GlassBreakage (V134 enum)
- VacantLandCondoCorpEndorsement -> VacantLand (PersonalLiability enum)
- WaterCoverage -> OverlandWaterCoverage (V134 enum)
- EnhancedCoverage -> EnhancedCoverageOptionForSelectedClients (V125 enum)
- CottageRentalEndorsement -> RentalEndorsement (V134 enum)
- VacancyPermit -> VacancyPermit (V134 enum)
- All others: delegate to generic base
**Codes sent**: csio:GOLFC, plus dynamic enum values

### TryConvertToFrameworkHomeEndorsement (Inbound)
**What it does**: Maps CSIO home endorsement codes back to framework.
**When it runs**: When parsing unrated hab responses.
**Rules**:
- LogConstructionSettlementLimitation -> EndorsementCodes.LogEndorsement
- csio:GOLFC -> EndorsementCodes.GolfCart
- GlassBreakage -> EndorsementCodes.GlassReducedDeductible
- VacantLand -> EndorsementCodes.VacantLandCondoCorpEndorsement
- OverlandWaterCoverage -> EndorsementCodes.WaterCoverage
- EnhancedCoverageOptionForSelectedClients -> EndorsementCodes.EnhancedCoverage
- RentalEndorsement -> EndorsementCodes.CottageRentalEndorsement
- All others: delegate to generic base

---

## Hab Discounts (Inbound)

### TryConvertToFrameworkHabDiscount
**What it does**: Maps hab discount codes from carrier response to framework.
**When it runs**: When parsing rated hab responses.
**Rules**:
- IMPORTANT: If the coverage code does NOT start with the "csio:" prefix, the system automatically prepends it before lookup (uses SGICanadaGIS.CompanyConstants.Csio.CsioPrifix)
- PremisesAlarmFireorIntrusionSystem -> DiscountCode.SecuritySystem
- DiscountAssociationMembership -> DiscountCode.AssociationMembership
- csio:DISEM -> DiscountCode.Occupation
- DiscountFemale -> DiscountCode.Female
- DiscountProfessional -> DiscountCode.Professional
- csio:DISTR -> DiscountCode.Territory
- Renewal -> DiscountCode.Loyalty
- All others: delegate to generic base

---

## Hab Surcharges (Inbound)

### TryConvertToFrameworkHabSurcharge
**What it does**: Maps hab surcharge codes from carrier response.
**When it runs**: When parsing rated hab responses.
**Rules**:
- SurchargeClaims -> SurchargeCode.Claims
- All others: delegate to generic base

---

## Accident Benefits (Ontario)

### ConvertAccidentBenefits (PcCoverageCollectionConverter)
**What it does**: Converts increased Ontario accident benefit selections into individual CSIO coverage nodes.
**When it runs**: For Ontario-rated personal and commercial vehicles when increased accident benefits are selected.
**Rules (post July 1, 2026)**:
- If MedicalCareAttendantCareNew > 0: send MedicalRehabAttendantCare coverage with limit
- If MedicalAttendantCareCatNew > 0: send CatastrophicImpairment coverage with limit
- If IncomeReplacementNew > 0: send IncomeReplacement coverage with limit
- If NonEarnerBenefitNew > 0: send csio:NEB with limit
- If CaregiverBenefitNew > 0: send csio:CGB with limit
- If CaregiverBenefitCatNew > 0: send csio:CGCAT with limit
- If LostEducationalExpensesNew > 0: send csio:LEE with limit
- If ExpensesOfVisitorsNew: send csio:EXV (no limit)
- If HousekeepMaintNew > 0: send csio:HHM with limit
- If HousekeepMaintCatNew > 0: send csio:HHCAT with limit
- If DamageToPersonalItemsNew: send csio:DPI (no limit)
- If DeathBenefitNew > 0: send csio:DEA with limit
- If FuneralBenefitNew > 0: send csio:FNB with limit
- If DependantCareBenefitNew > 0: send DependantCareBenefits (dynamic, no limit)
- If IndexationBenefitNew: send Indexation (dynamic, no limit)

**Rules (pre July 1, 2026)**:
- Caregiver: sends CaregiverHousekeepingHomeMaintenanceBenefits (dynamic)
- DeathAndFuneral: sends DeathAndFuneralBenefits (dynamic)
- IncomeReplacement > 400: sends IncomeReplacement with limit
- Indexation: sends Indexation (dynamic)
- MedicalRehabilitation: sends MedicalExpenses (dynamic)
- MedicalAttendantCatastrophic: sends CatastrophicImpairment with limit 1000000
- MedicalAttendantNonCatastrophic: sends MedicalRehabAttendantCare with limit 130000
**Codes sent**: csio:NEB, csio:CGCAT, csio:CGB, csio:LEE, csio:EXV, csio:HHCAT, csio:HHM, csio:DPI, csio:DEA, csio:FNB, plus dynamic standard codes

---

## Endorsement Limits

### ConvertEndorsementLimit (PcCoverageConverter)
**What it does**: Converts endorsement coverage limits to CSIO XML format.
**When it runs**: When building endorsement coverage XML with limits.
**Rules**:
- If a limit override is provided: use the override value directly
- Opcf43 or Opcf43A: read Coverage field, convert months to limit (24 months = 24, 60 months = 60)
- CondoDeductibleAssessment: read Coverage field, convert as standard limit
- WaterCoverage: read WaterCoverage field. If "Policy Limit", send -1. Otherwise parse as decimal.
- SewerBackup: read SewerBackup field (fallback to Coverage). If "Policy Limit", send -1. Otherwise parse as decimal.
- All others: delegate to generic base

### ConvertEndorsementDeductible (PcCoverageConverter)
**What it does**: Converts endorsement deductibles to CSIO XML.
**Rules**:
- Earthquake: reads EarthquakeDeductible field
- GlassReducedDeductible: reads GlassDeductible field
- All others: reads standard Deductible field

### Earthquake Deductible Percent
**What it does**: Formats earthquake deductible as percentage.
**Rules**:
- If coverage code = Earthquake: set DeductibleTypeCd to Percent
- Format as PercentDecimal

---

## Sewer Backup Policy Limit Detection

### IsSewerBackPolicyLimitSelected (DefaultEndorsementConverter)
**What it does**: Determines if sewer backup coverage has "Policy Limit" selected (response parsing).
**When it runs**: When parsing unrated endorsement responses.
**Rules**:
- If coverage code = csio:SEWER AND limit exists AND limit is NOT in [6000, 10000, 20000, 30000]: treat as "Policy Limit" and set Coverage field to "Policy Limit" text
- Otherwise: use standard limit conversion
**Codes checked**: csio:SEWER (hardcoded, not in constants)

---

## Liability Coverages

### TPL Suppression
**What it does**: Suppresses Third Party Liability (TPL) coverage node.
**When it runs**: For all vehicle types (personal and commercial).
**Rules**:
- TPL is NEVER sent (commented as ICGORE-128: "Do not add TPL")
- Property Damage: only sent if TPLPhysicalDamage premium is non-zero, OR if TPL premium is zero
- Bodily Injury: only sent if TPLBodilyInjury premium is non-zero, OR if TPL premium is zero

### IsVehicleEligibleForLiabilityCoverages
**What it does**: Determines if a vehicle gets liability coverages.
**Rules**:
- If vehicle is NOT in Vehicles category AND code = ATV: it is a hab recreational vehicle, so NO liability coverages
- All other vehicles: eligible for liability coverages

---

## DCPD Opt-Out

### Direct Compensation Property Damage Opt-Out
**What it does**: Allows opting out of DCPD, Collision, and All Perils.
**When it runs**: For personal and commercial vehicles.
**Rules**:
- If FNAME_IQ_OPTOUTDCPD field is present AND true: do NOT send DCPD, Collision, or All Perils coverages
- If field is absent or false: send normally (delegate to base)

---

## Watercraft Coverage

### ConvertWatercraftMotorAllRisks
**What it does**: Converts watercraft/boat motor coverage to CSIO.
**When it runs**: For watercraft coverage items (except JetSki).
**Rules**:
- JetSki: uses standard base conversion
- All other watercraft: combine MotorCoverage + BoatCoverage limits into total, send as AMEAR (AdditionalMiscellaneousEquipmentAllRisks)
- Deductible: use MotorDeductible if present and > 0, otherwise use standard Deductible

### Contingent Coverage
**What it does**: Converts condo contingent coverage.
**Rules**:
- If Contingent field > 0: send as AllRiskUnitOwnersAdditionalProtection with limit

---

## Hab Coverage Code

### ConvertHabCoverageCd
**What it does**: Determines which CSIO coverage code to use for hab contents.
**Rules**:
- If coverage = Contents AND policy type = FEC: use PersonalPropertyHomeownersForm
- All others: delegate to generic base

---

## Policy Type Conversions

### Home Policy Types
- "Comp. Plus" -> HomeownersComprehensiveForm
- "Plus" -> HomeownersBroadForm
- "VIP Plus" -> HomeownersComprehensiveExpandedForm
- All others -> HomeownersBroadExpandedForm

### Condo Policy Types
- AllRisks/AllRisk -> ComprehensiveCondominiumForm
- VipPlus -> CondominiumComprehensiveExpandedForm
- NamedPerils -> CondominiumPackageLimitedForm

### Tenant Policy Types
- AllRisks/AllRisk -> TenantsComprehensiveForm
- VIP Plus -> TenantsComprehensiveExpandedForm

### Seasonal Dwelling Policy Types
- Basic -> SeasonalDwellingStandardForm
- FourSeasonsSuperior -> SeasonalDwellingBroadForm
- "4 Seasons Ultimate" -> SeasonalDwellingComprehensiveForm

### Rented Dwelling Policy Types
- AllRisk/AllRisks -> csio:61
- NamedPerils -> csio:62
- Fire & E.C. -> csio:69

### Rented Condo
- NamedPerils/Form5263/AllRisk/AllRisks -> CondomimiumFormOther

### FEC
- AllRisk/NamedPerils/Fire & E.C. -> csio:61

---

## Lapse Reason Mapping

### TryConvertLapseReasonToCsioLapseTypeCd
**What it does**: Maps framework lapse reasons to CSIO codes.
**Rules**:
- NonPaymentOfPremium -> csio:NP
- LicenseSuspension -> csio:CS
- FraudOrMaterialMisrepresentation -> csio:CM
- OperatingWithoutInsurance -> csio:DW
- Other (and default) -> csio:OT

---

## Construction Code Conversion

### ConvertConstructionCd (ConstructionConverter)
**What it does**: Converts framework construction type fields to CSIO construction codes.
**When it runs**: When building dwelling construction XML.
**Rules**:
- Checks for Asbestos first (adds Asbestos code if present)
- Then checks each construction type field (BrickSolid, CementConcrete, FrameWood, Log, MasonrySolid, Steel, StoneSolid) - adds matching CSIO code if percentage > 0
- FrameWood also includes PostBeamWood
- Log also includes LogHandHewn and LogManufactured
- Panabode, Modular, Sectional -> Other
- If no specific construction found, checks the generic "Construction" field for "Log" or "Frame"
- Multiple construction types can be sent simultaneously

---

## Multi-Policy Discount

### TryConvertToCsio (MultiPolicyDiscountConverter)
**What it does**: Converts multi-policy discount for outbound.
**Rules**:
- Iterates coverage items looking for PrimaryItem
- If MultiLine field is true on the primary item: set ImmediateDiscount

### GetSupportingPolicy
**What it does**: Determines if a supporting policy qualifies.
**Rules**:
- If input = QuoteAll OR "Gore Mutual": supporting policy is valid

---

## Occupancy and Dwelling Use

### DwellOccupancyConverter
**What it does**: Converts dwelling occupancy and use codes.
**Rules**:
- If VacancyPermit endorsement is present for this dwelling: set occupancy to Vacant and dwelling use to Vacant
- If dwelling is under construction: set dwelling use to UnderConstruction
- If occupancy field exists: use standard dwelling use conversion
- If policy type = Tenant and no occupancy field: default to Tenant

---

## Gender Conversion

### GenderConverter
**What it does**: Handles non-binary gender code.
**Rules**:
- If framework gender = "X": send csio:X
- If CSIO gender = "X": map back to csio:X constant
- All others: delegate to generic base

---

## Marital Status

### MaritalStatusConverter
**What it does**: Handles partner/same-sex marital status.
**Rules**:
- PartnerSameSex -> Married (maps to standard Married CSIO code)
- All others: delegate to generic base

---

## Claims Filtering

### FilterClaims (PcPolicyConverter)
**What it does**: Filters claims by policy type before converting losses.
**Rules**:
- If policy type = Auto: only include ClaimAuto category claims
- If policy type = anything else: exclude ClaimAuto claims (include all others)

---

## Rated Response Parsing

### ConvertFromPersVeh (Rated PcCoverageConverter)
**What it does**: Routes rated personal vehicle coverages to appropriate handlers.
**Rules**:
- If coverage code is any of: csio:NEB, csio:CGCAT, csio:CGB, csio:LEE, csio:EXV, csio:HHCAT, csio:HHM, csio:DPI, csio:DEA, csio:FNB: route to ConvertOptionalIncreasedAccidentBenefits
- All others: delegate to generic base

### ConvertOptionalIncreasedAccidentBenefits
**What it does**: Maps rated accident benefit premiums back to framework fields.
**Rules**:
- csio:NEB -> NonEarnerBenefitNewTermPremium
- csio:CGCAT -> CaregiverBenefitCatNewTermPremium
- csio:CGB -> CaregiverBenefitNewTermPremium
- csio:LEE -> LostEducationalExpensesNewTermPremium
- csio:EXV -> ExpensesOfVisitorsNewTermPremium
- csio:HHCAT -> HousekeepMaintCatNewTermPremium
- csio:HHM -> HousekeepMaintNewTermPremium
- csio:DPI -> DamageToPersonalItemsNewTermPremium
- csio:DEA -> DeathBenefitNewTermPremium
- csio:FNB -> FuneralBenefitNewTermPremium

### IsWatercraftCoverage (Rated)
**What it does**: Identifies watercraft coverage in rated responses.
**Rules**:
- If coverage code = AdditionalMiscellaneousEquipmentAllRisks AND has CurrentTermAmt: treat as watercraft
- Otherwise: delegate to base

### ConvertDwellCoverage (Rated)
**What it does**: Handles dwelling coverage premium parsing in rated responses.
**Rules**:
- LegalLiabilityHomeownersTenantandCondominium: if NOT primary unit at risk, add premium to total term premium
- AllRiskUnitOwnersAdditionalProtection: convert as additional hab coverage
- AllRiskLossAssessmentCoverage: if primary unit at risk, SUBTRACT premium from total term premium
- All others: delegate to base

---

## Property Schedule Conversion

### Outbound (FrameworkToCsio PropertyScheduleConverter)
**What it does**: Converts scheduled property items for outbound.
**Rules**:
- Uses AllRisk as default coverage type, reads CoverageType field if available
- NumItemsPerSummary: reads HowMany field, minimum is 0

### Inbound (CsioToFramework PropertyScheduleConverter)
**What it does**: Parses scheduled property items from responses.
**Rules**:
- If PropertyClassCd = csio:MI (Musical Instrument): check ItemDesc for "Piano" -> MiscPropertyCodes.Piano, else -> MusicalInstruments
- If PropertyClassCd = csio:PR (Typewriter): check ItemDesc for "Typewriter" or "Typewriter Portable"
- If Coverage value already set for GoreMutual company: skip base ItemValueAmt conversion
