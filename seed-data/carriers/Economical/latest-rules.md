# Economical (Definity) - Business Rules

Extracted: 2026-03-22
Versions: v043, V128, V132, V133 (latest)

---

## Auto Endorsements

### TryConvertToCsioAutoEndorsement (V133 CoverageCodeConverter)
**What it does**: Converts framework auto endorsement codes to CSIO coverage codes.
**When it runs**: Outbound auto endorsement conversion for non-Ontario provinces.
**Rules**:
- If endorsement = HitAndRunDeductibleWavier: send csio:41
- All other endorsements: fall back to generic V133 converter
**Codes sent**: csio:41

### TryConvertToCsioOntarioAutoEndorsement (V133 CoverageCodeConverter)
**What it does**: Converts framework Ontario-specific auto endorsement codes to CSIO codes.
**When it runs**: Outbound auto endorsement conversion for Ontario.
**Rules**:
- If endorsement = Opcf47R: send csio:47R
- If endorsement = Opcf49: send csio:49
- If endorsement = HitAndRunDeductibleWavier: send csio:41
- All other endorsements: fall back to generic Ontario converter
**Codes sent**: csio:47R, csio:49, csio:41

### TryConvertToFrameworkAutoEndorsement (V133 CoverageCodeConverter)
**What it does**: Converts CSIO coverage codes back to framework auto endorsement codes.
**When it runs**: Inbound auto endorsement parsing.
**Rules**:
- If CSIO code matches End35 standard value: map to EndorsementCodes.End35
- If CSIO code = csio:41: map to EndorsementCodes.HitAndRunDeductibleWavier
- All other codes: fall back to generic converter
**Codes received**: standard End35 value, csio:41

### TryConvertToFrameworkOntarioAutoEndorsement (V133 CoverageCodeConverter)
**What it does**: Converts CSIO Ontario-specific codes back to framework.
**When it runs**: Inbound Ontario auto endorsement parsing.
**Rules**:
- If CSIO code = csio:41: map to HitAndRunDeductibleWavier
- If CSIO code = csio:47R: map to Opcf47R
- All other codes: fall back to generic Ontario converter
**Codes received**: csio:41, csio:47R

---

## Auto Surcharges

### TryConvertToFrameworkAutoSurcharge (V133 CoverageCodeConverter)
**What it does**: Converts CSIO surcharge codes back to framework surcharge codes.
**When it runs**: Inbound auto surcharge parsing.
**Rules**:
- If CSIO code = csio:SURHT: map to SurchargeCode.HighTheft
- All other codes: fall back to generic converter
**Codes received**: csio:SURHT

---

## Home Endorsements

### TryConvertToCsioHomeEndorsement (V133 CoverageCodeConverter)
**What it does**: Converts framework home endorsement codes to CSIO coverage codes.
**When it runs**: Outbound hab endorsement conversion.
**Rules**:
- If endorsement = WaterCoverage: send standard OverlandWaterCoverage value
- If endorsement = WaterDamageDeductible: send csio:PAWAT
- If endorsement = EnvironmentFriendlyReplacement: send csio:ENVLS
- If endorsement = MatchingOfUndamagedSiding: send csio:MASDC
- If endorsement = MatchingOfUndamagedRoofSurfacing: send csio:MARFC
- All other endorsements: fall back to generic converter
**Codes sent**: standard OverlandWaterCoverage, csio:PAWAT, csio:ENVLS, csio:MASDC, csio:MARFC

### TryConvertToFrameworkHomeEndorsement (V133 CoverageCodeConverter)
**What it does**: Converts CSIO home coverage codes back to framework endorsement codes.
**When it runs**: Inbound hab endorsement parsing.
**Rules**:
- If CSIO code = standard HailCoverageEndorsement: map to WindHailCoverage
- If CSIO code = standard OverlandWaterCoverage OR FloodWater: map to WaterCoverage
- If CSIO code = csio:PAWAT: map to WaterDamageDeductible
- If CSIO code = csio:ENVLS: map to EnvironmentFriendlyReplacement
- If CSIO code = csio:MASDC: map to MatchingOfUndamagedSiding
- If CSIO code = csio:MARFC: map to MatchingOfUndamagedRoofSurfacing
- All other codes: fall back to generic converter
**Codes received**: HailCoverageEndorsement, OverlandWaterCoverage, FloodWater, csio:PAWAT, csio:ENVLS, csio:MASDC, csio:MARFC

---

## Accident Benefits (Ontario) - New Benefits (July 1, 2026+)

### ConvertAccidentBenefits (V133 PcCoverageCollectionConverter)
**What it does**: Converts new Ontario increased accident benefits to CSIO coverages.
**When it runs**: When calc date >= July 1, 2026 for Ontario policies.
**Rules**:
- If MedicalCareAttendantCareNew > 0: send standard MedicalRehabAttendantCare with limit
- If MedicalAttendantCareCatNew > 0: send standard CatastrophicImpairment (V132) with limit
- If IncomeReplacementNew > 0: send standard IncomeReplacement with limit
- If NonEarnerBenefitNew > 0: send csio:NEB with limit
- If CaregiverBenefitNew > 0: send csio:CGB with limit
- If CaregiverBenefitCatNew > 0 AND CaregiverBenefitNew = 0: send csio:CGCAT with limit (only if base caregiver is not selected)
- If LostEducationalExpensesNew > 0: send csio:LEE with limit
- If ExpensesOfVisitorsNew is True: send csio:EXV (no limit)
- If HousekeepMaintNew > 0: send csio:HHM with limit
- If HousekeepMaintCatNew > 0 AND HousekeepMaintNew = 0: send csio:HHCAT with limit (only if base housekeeping is not selected)
- If DamageToPersonalItemsNew is True: send csio:DPI (no limit)
- If DeathBenefitNew > 0: send csio:DEA with limit
- If FuneralBenefitNew > 0: send csio:FNB with limit
- If DependantCareBenefitNew > 0: send standard DependantCareBenefits (V132)
- If IndexationBenefitNew is True: send standard Indexation
- If calc date < July 1, 2026: fall back to legacy conversion (V132 logic with csio:CATIM, csio:MRB, csio:CIMRB codes)
**Codes sent**: csio:NEB, csio:CGCAT, csio:CGB, csio:LEE, csio:EXV, csio:HHCAT, csio:HHM, csio:DPI, csio:DEA, csio:FNB, plus standard codes

### ConvertAccidentBenefits - Legacy (V132 PcCoverageCollectionConverter)
**What it does**: Converts legacy Ontario increased accident benefits before July 2026.
**When it runs**: When calc date < July 1, 2026 for Ontario policies.
**Rules**:
- If AttendantCare: TODO (code has a TODO comment)
- If Caregiver: convert caregiver coverage
- If DeathAndFuneral: send standard DeathAndFuneralBenefits
- If DependantCare: send standard DependantCareBenefits (V132)
- If IncomeReplacementCoverage > 400: send standard IncomeReplacement with limit
- If IndexationBenefit: send standard Indexation
- If MedicalRehabilitation: send standard MedicalExpenses
- If MedicalRehabilitationAndAttendantCare: send standard MedicalRehabAttendantCare
- If MedicalAttendantNonCatastrophic1M: send csio:CIMRB with limit $1,000,000
- If MedicalAttendantNonCatastrophic: send csio:MRB with limit $130,000
- If MedicalAttendantCatastrophic: send csio:CATIM with limit $1,000,000
**Codes sent**: csio:CIMRB, csio:MRB, csio:CATIM, plus standard codes

### ConvertOptionalIncreasedAccidentBenefits - Inbound (V133 CsioToFramework/Rated/PcCoverageConverter)
**What it does**: Parses rated response accident benefits premiums.
**When it runs**: When reading back rated auto coverage premiums.
**Rules**:
- standard MedicalRehabAttendantCare: maps to MedicalAttendantNonCatastrophicTermPremium
- standard CatastrophicImpairmentMedicalRehabAndAttendantCare: maps to MedicalAttendantNonCatastrophic1MTermPremium
- standard CatastrophicImpairment (V132): maps to MedicalAttendantCatastrophicTermPremium
- csio:NEB: maps to NonEarnerBenefitNewTermPremium
- csio:CGCAT: maps to CaregiverBenefitCatNewTermPremium
- csio:CGB: maps to CaregiverBenefitNewTermPremium
- csio:LEE: maps to LostEducationalExpensesNewTermPremium
- csio:EXV: maps to ExpensesOfVisitorsNewTermPremium
- csio:HHCAT: maps to HousekeepMaintCatNewTermPremium
- csio:HHM: maps to HousekeepMaintNewTermPremium
- csio:DPI: maps to DamageToPersonalItemsNewTermPremium
- csio:DEA: maps to DeathBenefitNewTermPremium
- csio:FNB: maps to FuneralBenefitNewTermPremium

---

## Discount / Surcharge Classification (Response)

### IsDiscount (V132 CsioToFramework/Rated/PcCoverageConverter)
**What it does**: Determines if a coverage code represents a discount in the rated response.
**When it runs**: When parsing rated hab response coverages.
**Rules**:
- Extract the part after ":" in the CSIO code
- If it starts with "DIS": classify as discount
- Otherwise: not a discount

### IsSurcharge (V132 CsioToFramework/Rated/PcCoverageConverter)
**What it does**: Determines if a coverage code represents a surcharge in the rated response.
**When it runs**: When parsing rated hab response coverages.
**Rules**:
- Extract the part after ":" in the CSIO code
- If it starts with "SUR": classify as surcharge
- Otherwise: not a surcharge

---

## Policy Type Mapping

### TryConvertHomeToCsio (V133 PolicyTypeConverter)
**What it does**: Converts home coverage types to CSIO policy types.
**When it runs**: Outbound homeowner policy conversion.
**Rules**:
- HomeownersComprehensiveSingleQuote maps to HomeownersComprehensiveForm (V133 override)
- HomeownersEnhanced maps to HomeownersComprehensiveExpandedForm (V133 override)
- All other types: fall back to v043 Economical (HomeownersBasicSingleQuote -> HomeownersStandardForm)

### TryConvertFecToCsio (V133 PolicyTypeConverter)
**What it does**: Converts FEC (landlord) coverage types to CSIO policy types.
**When it runs**: Outbound FEC policy conversion.
**Rules**:
- LandlordComprehensive maps to RentedDwellingBroadForm (V133 override)
- LandlordEnhanced maps to RentedDwellingComprehensiveForm (V133 override)
- HomeownersBasicSingleQuote -> BasicResidentialFireECForm (v043)
- LandlordBasic -> RentedDwellingLimitedForm (v043)

### TryConvertSeasonalToCsio (V133 PolicyTypeConverter)
**What it does**: Converts seasonal coverage types to CSIO policy types.
**When it runs**: Outbound seasonal policy conversion.
**Rules**:
- HomeownersComprehensiveSingleQuote maps to SeasonalDwellingBroadForm (V133 override)
- HomeownersEnhanced maps to SeasonalDwellingComprehensiveForm (V133 override)

### TryConvertToFramework (V133 PolicyTypeConverter)
**What it does**: Converts CSIO policy types back to framework coverage types.
**When it runs**: Inbound policy type conversion.
**Rules** (date-sensitive for effective dates >= April 27, 2025):
- SeasonalDwellingBroadForm: if effectiveDate >= 2025-04-27 then HomeownersComprehensiveSingleQuote, else HomeownersEnhanced
- RentedDwellingBroadForm: if effectiveDate >= 2025-04-27 then LandlordComprehensive, else LandlordEnhanced
- SeasonalDwellingComprehensiveForm -> HomeownersEnhanced
- RentedDwellingComprehensiveForm -> LandlordEnhanced
- HomeownersComprehensiveExpandedForm -> HomeownersEnhanced
- HomeownersComprehensiveForm -> HomeownersComprehensiveSingleQuote
- CondominiumPackageBroadForm -> Condominium
- HomeownersStandardForm -> HomeownersBasicSingleQuote
- HomeownersBroadForm -> HomeownersEnhanced
- MobileHomeStandardForm -> Bronze
- BasicResidentialFireECForm -> HomeownersBasicSingleQuote
- SeasonalDwellingStandardForm -> HomeownersBasicSingleQuote
- TenantsPackageBroadForm -> Tenant
- RentedDwellingLimitedForm -> LandlordBasic

---

## Lapse Reason Mapping

### TryConvertLapseReasonToCsioCode (V133 ConvictionCodeConverter)
**What it does**: Converts framework lapse reasons to CSIO conviction codes.
**When it runs**: Outbound lapse/conviction conversion.
**Rules**:
- ThreeMonthBloodAlcoholSuspension, AccidentRelated, CriminalCodeConviction, DrivingWhileUnderTheInfluence, LicenseSuspension, OffenseRelatedToUseOrOperation, OperatingWithoutALicense, OperatingWithoutInsurance, PointsAccumulation, Speeding: all map to "SUPLF" (Suspended License - Facility)
- Other, UnpaidTicket: map to "SUP" (Suspended)
- All other reasons: fall back to generic

### TryConvertLapseReasonToCsioLapseTypeCd (V133 ConvictionCodeConverter)
**What it does**: Converts lapse reasons to CSIO lapse type codes (numeric/string codes).
**When it runs**: Outbound lapse type conversion.
**Rules**:
- ThreeMonthBloodAlcoholSuspension -> "CSIO:CS" (uppercase prefix)
- FraudOrMaterialMisrepresentation -> "2"
- NonPaymentOfPremium -> "3"
- AccidentRelated -> "1"
- LicenseSuspension -> "csio:CS"
- Most driving offenses -> "9" (general offense code)
- AdministrativeSuspension -> "15"
- CourtOrderedSuspension -> "16"
- DemeritPointSuspension -> "17"
- DriverControlBoardSuspension -> "18"
- LegalJudgementSuspension -> "19"
- MedicalSuspension -> "20"
- ZeroAlcoholToleranceSuspension -> "21"
- Else (catch-all) -> "9"

---

## Endorsement Limit Rules (V128 PcCoverageConverter)

### ConvertEndorsementLimit
**What it does**: Controls how endorsement limits are sent in the outbound XML.
**When it runs**: For each hab endorsement during outbound conversion.
**Rules**:
- WindHailCoverage: send the Coverage field value as limit
- WaterCoverage: send the Coverage field value as limit; if Coverage = "PolicyLimit", use the parent coverage amount
- Earthquake on Condo: use the parent dwelling coverage amount as limit
- ClaimsProtector, WaterDamageDeductible, GuaranteedReplacementCost: do NOT send any limit
- All other endorsements: use generic limit conversion

### ConvertEndorsementCoverageCd (V128 PcCoverageConverter)
**What it does**: Maps the endorsement coverage code for outbound.
**When it runs**: For each hab endorsement code conversion.
**Rules**:
- WindHailCoverage: send standard HailCoverageEndorsement (V125)
- All other endorsements: use generic mapping

---

## DCPD Opt-Out Logic (V133 PcCoverageCollectionConverter)

### IsVehicleEligibleForDirectCompensationPropertyDamage
**What it does**: Checks if DCPD should be included for a vehicle.
**When it runs**: For each vehicle coverage conversion.
**Rules**:
- If the company field FNAME_IQ_OPTOUTDCPD exists:
  - If optOutDCPD = False: eligible (use generic logic)
  - If optOutDCPD = True: NOT eligible, skip DCPD
- If field does not exist: eligible (use generic logic)

### ConvertCollision / ConvertAllPerils
**What it does**: Conditionally converts collision/all-perils based on DCPD opt-out.
**When it runs**: For each vehicle during outbound.
**Rules**:
- If optOutDCPD = True: do NOT convert collision or all-perils coverages
- If optOutDCPD = False or field missing: convert normally

---

## Vehicle Coverage - Non-Alberta Uninsured Motorist

### ConvertToVehicleCoverages (V132 PcCoverageCollectionConverter)
**What it does**: Adds uninsured motorist coverage to vehicle coverages.
**When it runs**: After standard vehicle coverages are converted.
**Rules**:
- If province is NOT Alberta: add an uninsured motorist coverage to the output
- If province IS Alberta: skip (Alberta does not have uninsured motorist)

---

## Bareland Condo Logic (V133 PcCoverageCollectionConverter)

### GetHabBarelandcondo
**What it does**: Creates a bareland condo coverage section.
**When it runs**: During hab coverage conversion for Home or FEC policy types.
**Rules**:
- If policy type is Home or FEC AND the BarelandCondo field is True: create and convert a bareland condo coverage
- All other policy types or if BarelandCondo is False: return Nothing (skip)

---

## Response URL (V133 MsgRsInfoConverter)

### GetResponseURLText
**What it does**: Prefixes the response URL with Economical-specific text.
**When it runs**: When processing the response message info.
**Rules**:
- Prepend "To navigate to Economical Guidewire to review your quote, please click on the link below." followed by a line break before the URL

---

## Version Differences (V133 vs V132)

### New in V133 (not in V132):
1. **18 new CompanyCsioCode constants**: OPCF49, OPCF47R, HitAndRunDeductibleWavier, HighTheftSurcharge, PerilAdjustmentWater, GreenCoverage, NonEarnerBenefit, CaregiverBenefitCatastrophic, CaregiverBenefit, LostEducationalExpenses, ExpensesOfVisitors, HousekeepingHomeMaintenanceCatastrophic, HousekeepingHomeMaintenance, DamageToPersonalItems, DeathBenefit, FuneralBenefit, MatchingOfUndamagedSiding, MatchingOfUndamagedRoofSurfacing
2. **Gender X support**: New GenderX constant (csio:X) and bidirectional GenderConverter
3. **Lapse reason expansion**: Full lapse reason type codes with suspension subtypes (15-21)
4. **Plumbing code**: PlumbingGalvanizedIron = "C"
5. **New AB benefits (July 1, 2026+)**: 12 new accident benefit codes (csio:NEB, csio:CGB, csio:CGCAT, csio:LEE, csio:EXV, csio:HHM, csio:HHCAT, csio:DPI, csio:DEA, csio:FNB) with date-gated logic
6. **Home endorsements expansion**: WaterDamageDeductible (csio:PAWAT), GreenCoverage (csio:ENVLS), MatchingOfUndamagedSiding (csio:MASDC), MatchingOfUndamagedRoofSurfacing (csio:MARFC)
7. **Auto surcharge**: HighTheftSurcharge (csio:SURHT) framework-to-code mapping
8. **DCPD opt-out**: New opt-out field logic for collision and all-perils
9. **Bareland condo**: New bareland condo support for Home and FEC
10. **Policy type overhaul**: New comprehensive/expanded form mappings with date-dependent reverse mapping (April 27, 2025 cutover)

### Changed from V132 to V133:
- CoverageCodeConverter inheritance changed: V132 inherited from V129.Generic; V133 inherits from V133.Generic
- PolicyTypeConverter was rewritten with date-dependent response mapping
- PcCoverageCollectionConverter added new accident benefits conversion for July 2026+
- V133 shadows the CompanyCsioCode class from V132, adding many more constants

### Still in V132 but NOT in V133 CompanyConstants:
- csio:CATIM (MdicalAttendantCatastrophic) - still used via V132 inheritance for pre-July-2026 dates
- csio:MRB (MedicalAttendantNonCatastrophic) - same
- csio:CIMRB (MedicalAttendantNonCatastrophic1M) - same
- CreditScoreConsent constants (StringZero, StringOne) - still available via V132

### V132 CsioConstants.vb
- Present but empty (no carrier-specific CSIO constants defined)
