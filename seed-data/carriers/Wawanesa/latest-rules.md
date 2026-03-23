# Wawanesa CZO Business Rules

Extracted: 2026-03-22
Latest version: V145
Versions: V135, V136, V137, V141, V145

---

## Auto Endorsement Routing (TryConvertToCsioAutoEndorsement)

### What it does
Maps framework auto endorsement codes to CSIO coverage codes for outbound requests.

### Rules
- End5CS (Carsharing) -> PermissionToRentOrLeaseTheVehicleForCarsharing (standard V141 code)
- OEMReplacementRepair -> csio:OEMA (Wawanesa-specific OEM Advantage Coverage)
- EmergencyAssistancePackage -> EnhancedRoadsideAssistanceProgram (standard V141 code)
- End35 (Removing Depreciation) -> standard End35 code
- End39B (Minor Conviction Protection) -> MinorConvictionProtection (standard V134 code)
- DrivingRecordProtectorClaimsPolicyLevel -> ClaimsProtectionPlan (standard code)
- PersonalEffectsAndProtectiveEquipment -> PersonalProtectiveEquipmentExcludingPersonalEffects (standard V133 code)
- DeductibleWaiver -> WaiverOfDeductible (standard V129 code)
- DissapearingDeductible -> DecreasingDeductibleEndorsement (standard V141 code, routed through HabPackageAndOtherForms)
- OEMEssentials -> AttachedMachineryPropertyDamageReimbursement (standard V133 code)
- All other endorsements fall through to the generic base class

### Codes sent
csio:OEMA (Wawanesa-only), plus standard CSIO codes resolved from enum values factories

---

## Ontario Auto Endorsement Routing (TryConvertToCsioOntarioAutoEndorsement)

### What it does
Maps Ontario-specific OPCF endorsement codes for outbound requests.

### Rules
- Opcf45W -> csio:45 (Extending Auto Liability to Watercraft)
- Opcf49 -> csio:49 (Agreement Not to Recover)
- Opcf47R -> csio:47R (Agreement for Suspension of Coverage)
- PerilOfCrime -> End18 (standard V141 code)
- OEMReplacementRepair -> csio:OEMA (same as non-Ontario)
- EmergencyAssistancePackage -> EnhancedRoadsideAssistanceProgram
- Opcf5CS (Ontario Carsharing) -> PermissionToRentOrLeaseTheVehicleForCarsharing
- Opcf44 (Family Protection) -> standard End44
- CommercialAccidentRatingWaiverEndorsement -> standard End39
- DeductibleWaiver -> WaiverOfDeductible
- DissapearingDeductible -> DecreasingDeductibleEndorsement
- All other Ontario endorsements fall through to the generic base

### Codes sent
csio:45, csio:49, csio:47R, csio:OEMA (Wawanesa-specific), plus standard codes

---

## Home Endorsement Routing (TryConvertToCsioHomeEndorsement)

### What it does
Maps framework home endorsement codes to CSIO coverage codes for outbound hab requests.

### Rules
- HomeBasedBusiness -> HomeBusinessCoverage (standard)
- ShortTermRentalEndorsement -> RentalEndorsement (standard V135)
- InflationProtection -> InflationGuardEndorsement (standard)
- AdditionalNamedInsuredCooccupant -> AdditionalNamedInsured (liability extension)
- RoofSurfaceBasisOfSettlement -> RoofBasisOfSettlementDueToWindstormHail (standard V118)
- EquipmentBreakdownCoverage -> SmartHomeSystems (standard V135)
- CyberCoverage -> PersonalCyberCoverage (standard V135)
- PermissionForUnoccupancy -> EstateOfPermissionForUnoccupancy (standard V133)
- DeductibleAssessmentBuydownEarthquake -> CondominiumDeductibleAssessmentEarthquake (standard V133)
- FireFollowingEarthquake -> PostearthquakeDamage (standard)
- DeductibleWaiver (Home) -> WaiverOfDeductible (standard V129), BUT ONLY if policyType is NOT Auto. Returns False for Auto policies.
- DissapearingDeductible -> DecreasingDeductibleEndorsement (V141)
- DwellingUnderConstruction -> Buildingunderconstruction (personal liability)
- LegalExpense -> LegalFees (standard)
- TelephoneLegalHelplineCoverage -> LegalAssistance (standard)
- FloodEndorsement -> OverlandWaterCoverage (V141)
- EnvironmentFriendlyReplacement -> EnvironmentallyFriendlyHomeReplacementLossSettlement (V141, resolves to csio:ENVLS)
- StrongerHomeEndorsement -> csio:STHE (Wawanesa-specific)
- LifeLeasePropertyCoverage -> LifeLeaseUnitCoverage (V141)
- CollectivelyOwnedLifeLeasePropertyCoverage -> LifeLeasePropertyCoverage (V141)
- LifeLeaseDeductibleAssessment -> LifeLeaseDeductible (V141)
- LifeLeaseDeductibleEarthquake -> LifeLeaseDeductibleEarthquakes (V141)
- CoverageAlignmentEndorsement -> csio:SELCL (Wawanesa-specific)
- All other home endorsements fall through to the generic base

### Codes sent
csio:STHE, csio:SELCL (Wawanesa-only), csio:ENVLS, plus many standard codes

---

## Home Liability Routing (TryConvertToCsioHomeLiability)

### What it does
Maps framework liability codes to CSIO codes for hab requests.

### Rules
- ATV -> MiscellaneousVehiclesAllRisks (watercraft/utility boat forms)
- RentedCondo or RentedDwelling -> AdditionalLocationsRented (V134 liability extension)
- DwellingUnderConstruction -> csio:CONTR (Insured Acting As Own Contractor), NOT the standard Buildingunderconstruction code
  - NOTE: The standard code is commented out in the source. Wawanesa deliberately uses CONTR instead.
- All other liabilities fall through to the generic base

### Important
The DwellingUnderConstruction case routes differently depending on whether it arrives as an endorsement (routed to standard Buildingunderconstruction) or as a liability (routed to csio:CONTR).

---

## Liability Extensions Detection (IsLiabilityExtenstions)

### What it does
Determines which coverage codes should be treated as liability extensions.

### Rules
Returns True for:
- MiscellaneousVehiclesAllRisks (ATV)
- AdditionalLocationsRented (V134)
- GardenTypeTractor (V137)
- Plus all base class liability extension codes

---

## Hab Discount Routing (TryConvertToCsioHabDiscount)

### What it does
Maps framework hab discount codes to CSIO codes.

### Rules
- ExteriorWall -> PreferredConstruction (standard)
- All other hab discounts fall through to the generic base

### Response direction
- PreferredConstruction -> ExteriorWall
- DiscountProtectionDevice (V118) -> PreventativeMeasures

---

## Hab Surcharge Routing (TryConvertToFrameworkHabSurcharge)

### What it does
Maps CSIO hab surcharge codes back to framework codes on response.

### Rules
- VacancyPermit (V135) -> SurchargeCode.Vacancy
- SurchargeUnderConstruction (V137) -> SurchargeCode.UnderConstruction
- SurchargeShortTermRental (V137) -> SurchargeCode.Rental
- SurchargeStandaloneDwelling (V137) -> SurchargeCode.StandAlone
- AgeOfStructure (V137) -> SurchargeCode.AgeOfHome
- All other hab surcharges fall through to the generic base

---

## Auto Discount Routing (TryConvertToCsioAutoDiscount)

### What it does
Maps framework auto discount codes to CSIO codes for outbound requests.

### Rules
- AntiTheftDevice -> DiscountAntiTheftDeviceAutomaticallyActivatedNonAlarms (V135)
- DriverAssist -> DiscountElectronicStabilityControlSystemFactoryEquipped (V135)
- UsageBasedInsurance -> DiscountTelematics (V141)
- NewlyLicensedCredit -> DiscountNewDriver (standard)
- NewlyLicensedCreditUnderageOccasional -> csio:DISOL (Wawanesa-specific)
- Newcomer -> csio:DISNU (Wawanesa-specific)
- NewcomerUnderageOccasional -> csio:DISOU (Wawanesa-specific)
- DriverTrainingCredit -> DiscountDriverTraining (standard)
- DriverTrainingCreditUnderageOccasional -> csio:DISOT (Wawanesa-specific)
- All other auto discounts fall through to the generic base

### Codes sent
csio:DISOL, csio:DISNU, csio:DISOU, csio:DISOT (all Wawanesa-specific underage/occasional driver variants)

---

## Auto Surcharge Routing (TryConvertToCsioAutoSurcharge)

### What it does
Maps framework auto surcharge codes to CSIO codes.

### Rules
- LicenseSuspension -> SurchargeLicenseSuspension (standard V126)
- LicenseSuspensionUnderageOccasional -> csio:SUROS (Wawanesa-specific)
- AccidentUnderageOccasional -> SurchargeConvictionClaimOccasionalDriverClass06And05 (V126)
- All other auto surcharges fall through to the generic base

### Response direction (TryConvertToFrameworkAutoSurcharge)
- csio:SURHT (HighTheftRisk) -> SurchargeCode.HighTheft
- SurchargeOperatorExperience (V136) -> SurchargeCode.Miscellaneous
- SurchargeRadius (V136) -> SurchargeCode.RadiusOfOperation
- SurchargeTowsNonOwnedTrailer (V137) -> SurchargeCode.TowsNonOwnedTrailer
- SurchargeTelematics (V144) -> SurchargeCode.Telematics
- SurchargeLicenseSuspension (V126) -> SurchargeCode.LicenseSuspension
- csio:SUROS -> SurchargeCode.LicenseSuspensionUnderageOccasional
- SurchargeConvictionClaimOccasionalDriverClass06And05 (V126) -> SurchargeCode.AccidentUnderageOccasional

---

## Endorsement Limit Conversion (ConvertEndorsementLimit)

### What it does
Determines how limits are converted for different endorsement types.

### Rules
- WaterCoverage, SewerBackup, FloodEndorsement -> ConvertWaterCoverageLimit (special water coverage logic)
- CondoDeductibleAssessment -> ConvertLimit from Coverage field
- FireFollowingEarthquake -> NO LIMIT SENT (Return immediately)
- Earthquake -> ConvertEarthquakeLimitPercent (special percentage calculation)
- VoluntaryCompensation -> ConvertLimit from WeeklyBenefit field
- All others -> base class logic

### Water Coverage Limit Logic
- If endorsement is WaterCoverage (parent), skip limit conversion entirely
- For SewerBackup and FloodEndorsement:
  - If Coverage field is numeric, send as currency amount
  - If Coverage field is text, send as text
  - If no Coverage field, send "Policy Limit" as text

---

## Endorsement Deductible Conversion (ConvertEndorsementDeductible)

### What it does
Determines how deductibles are sent for different endorsement types.

### Rules
- GlassReducedDeductible -> from GlassDeductible field
- FireFollowingEarthquake -> NO DEDUCTIBLE SENT (Return immediately)
- Earthquake -> from EarthquakeDeductible field
- WindHailCoverage -> from WindandHailCoverageEndorsementDeductible field (fallback to Deductible field)
- All others -> base class logic

---

## HAB Third-Party Liability (ConvertHabThirdPartyLiability)

### What it does
Sends the correct liability coverage code based on policy type.

### Rules
- For MobileHome + FireAndExtendedCoverage coverage type: send PersonalLiabilityOtherthanHomeownersTenantandCondominiumForm
- For all other policy types: send PersonalLiability (standard)

---

## HAB Coverage Code Routing (ConvertHabCoverageCd)

### What it does
Routes coverage codes based on policy type.

### Rules
- PersonalLiability:
  - Home, Condo, Tenant, MobileHome -> LegalLiabilityHomeownersTenantandCondominium
  - All other policy types -> LegalLiabilityOtherthanHomeownersTenantandCondominiumForm
- PersonalLiabilityOtherthanHomeownersTenantandCondominiumForm -> always use that code
- Contents:
  - Seasonal policy type -> PersonalPropertyOtherthanHomeownersTenantandCondominiumForm
  - All other types -> base class logic
- ImprovementsAndBetterments:
  - Tenant policy type -> LifeLeaseUnitOwnerImprovement (V141)
  - All other types -> base class logic

---

## Construction Type (ConstructionConverter)

### What it does
Determines the primary construction type by checking construction percentages.

### Rules
- Picks the construction type with the highest percentage
- TimberFrame -> csio:6 (hardcoded)
- PostBeamWood -> csio:5 (hardcoded)
- FrameWood -> standard Frame code
- Log -> standard Log code

---

## Heating Installation Codes (HeatingUnitInfoConverter)

### What it does
Sets installation codes for heating units.

### Rules
- For all heating unit types (WoodStove, Fireplace, SpaceHeater):
  - Primary installation -> csio:1
  - Secondary installation -> csio:2

---

## Lapse Reasons (ConvictionCodeConverter)

### What it does
Maps lapse reasons to CSIO lapse type codes.

### Rules
- NonPaymentOfPremium -> csio:NP
- FraudOrMaterialMisrepresentation -> csio:CM
- All others -> base class logic

---

## Anti-Theft Product Codes (AntiTheftProductCodeConverter)

### What it does
Maps anti-theft product names to CSIO codes.

### Rules
- KYCS Global Inc. -> csio:3A
- Domino Commercial -> csio:3B
- Domino (non-commercial) -> standard Other code
- All others -> base class logic

---

## Nature of Interest (NatureOfInterestConverter)

### What it does
Maps mortgagee types to CSIO interest codes.

### Rules
- CoOwner -> standard Other interest code
- Assignee -> csio:AS (Wawanesa-specific)
- All others -> base class logic

---

## Watercraft Type (WaterUnitTypeConverter)

### What it does
Maps watercraft types to CSIO water unit type codes.

### Rules
- Inflatable boat (BoatAndMotor type) -> csio:17
- JetBoat (BoatAndMotor type) -> csio:18
- All others -> base class logic

---

## Vehicle Coverage Skipping

### What it does
Trailers do not get TPL, Bodily Injury, or Property Damage coverages.

### Rules
- If vehicle code = Trailer: skip TPL, BodilyInjury, PropertyDamage, DirectCompensationPropertyDamage
- If vehicle is in storage or has no liability: not eligible for liability coverages

---

## Skipped Endorsements (PcCoverageCollectionConverter)

### What it does
Determines which endorsements are skipped at vehicle/dwelling level.

### Rules
Skip the following endorsement codes:
- End8A, Opcf08A, End28, End28A, Opcf28, Opcf28A
- All PolicyLevelEndorsementsForHab (company-specific list)
- All DwellingCoverageItemCodes (from CsioConstants)
- All PolicyLevelLiabilitiesForHab (company-specific list)
- SolidFuelHeatingSystemExclusion
- LimitedExteriorCoverage
- LandRealEstate liability: never sent on request

---

## Rated Response: Coverage Alignment Endorsement (DefaultEndorsementConverter)

### What it does
Special handling for csio:SELCL on inbound.

### Rules
- If input coverage code is csio:SELCL: treated as Coverage Alignment Endorsement in response parsing

---

## Rated Response: Limit Suppression (V145 PcCoverageConverter.ConvertLimit)

### What it does
Suppresses limit conversion for specific coverage codes in rated response.

### Rules
- SmartHomeSystems (V132 ICoveragesValues): do NOT convert the limit value
- All other coverages: convert limit normally

---

## Accident Benefits (V145 CompanyConstants only)

### What it does
Defines Ontario Accident Benefit coverage codes available only in V145.

### Codes
- csio:NEB - Non-Earner Benefit
- csio:CGCAT - Caregiver Benefit (Catastrophic)
- csio:CGB - Caregiver Benefit
- csio:LEE - Lost Educational Expenses
- csio:EXV - Expenses of Visitors
- csio:HHCAT - Housekeeping/Home Maintenance (Catastrophic)
- csio:HHM - Housekeeping/Home Maintenance
- csio:DPI - Damage to Personal Items
- csio:DEA - Death Benefit
- csio:FNB - Funeral Benefit

---

## Version Differences (V145 vs V141)

### Added in V145 (not in V141)
1. **Accident Benefit codes** (csio:NEB, csio:CGCAT, csio:CGB, csio:LEE, csio:EXV, csio:HHCAT, csio:HHM, csio:DPI, csio:DEA, csio:FNB) - all new in V145 CompanyConstants
2. **OPCF45W** (csio:45) - new in V145
3. **OPCF47R** (csio:47R) - new in V145
4. **OEMAdvantageCoverage** (csio:OEMA) - new in V145
5. **StrongerHomeCoverage** (csio:STHE) - new in V145
6. **EnhancedHomeowner** (csio:ACLHV) - new in V145
7. **CoverageAlignmentEndorsement** (csio:SELCL) - new in V145
8. **InflatableBoat** (csio:17) and **JetBoat** (csio:18) - new in V145
9. **NatureInterestAssignee** (csio:AS) - new in V145
10. **KYCS** (csio:3A) and **DOMINO_Commercial** (csio:3B) anti-theft codes - new in V145
11. **CollisionNotAtFault** value "41" - new in V145
12. **Discount codes**: csio:DISOL, csio:DISNU, csio:DISOU, csio:DISOT - all new in V145
13. **Surcharge codes**: csio:SUROS - new in V145
14. **PersonalEffectsAndProtectiveEquipment**, **DeductibleWaiver**, **DissapearingDeductible**, **OEMEssentials** auto endorsement mappings - new in V145
15. **PerilOfCrime**, **Opcf5CS**, **CommercialAccidentRatingWaiverEndorsement** Ontario endorsement mappings - new in V145
16. **Life Lease** endorsements (unit, property, deductible, deductible earthquake) - new in V145
17. **LegalExpense** and **TelephoneLegalHelplineCoverage** home endorsements - new in V145
18. **FloodEndorsement** mapping - available from V141, added to company converter in V145
19. **FoundationCodeConverter** and **AntiTheftProductCodeConverter** - new enum converters in V145
20. **WaterUnitTypeConverter** - new in V145

### Changed in V145 from V141
- V141 had HighTheftRisk surcharge and OPCF49 as the only Wawanesa-specific codes
- V145 substantially expanded the carrier-specific code inventory from 3 codes to 30+ codes
