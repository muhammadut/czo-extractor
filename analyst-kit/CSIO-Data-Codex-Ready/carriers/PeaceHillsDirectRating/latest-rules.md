# PeaceHillsDirectRating - Business Rules

**Extracted**: 2026-03-22
**Versions**: V143 (base), V144, V145 (latest)
**Inheritance**: V145 -> V144 -> V143 -> V141/Generic -> v043/Generic

---

## Auto Endorsements

### TryConvertToCsioAutoEndorsement
**What it does**: Converts TBW auto endorsement codes to CSIO coverage codes for outbound requests.
**When it runs**: When sending an auto endorsement to the carrier.
**Rules (V145 - latest)**:
- End8B -> standard End8 code
- End19B -> standard End19 code
- End28C -> standard End28 code
- End30B -> standard End30 code
- End39A -> standard End39 code
- End39X -> csio:ZP39X (carrier proprietary accident rating waiver)
- End5B -> standard End5B code
- End21B -> standard End21B code
- AccessoriesExtension -> standard End37 code
- All other endorsements fall through to the generic base converter (V141)

**Rules (V143 - base, additional codes)**:
- AccessoriesExtension -> csio:ZPMAP (carrier proprietary, changed to standard in V144)
- SparePartsCoverage -> csio:ZPUAE (CAE6 - collector vehicle parts)
- BelongingsMotorhome -> csio:CCMVT (CAE7 - motorhome contents)
- EmergencyAssistancePackage -> csio:MOVAE (roadside assistance)
- End43R -> standard End43R code
- End43RL -> standard End43Rl code

**Codes sent**: csio:ZP39X, standard SEF codes (5B, 8, 19, 21B, 28, 30, 37, 39)

---

## Home Endorsements

### TryConvertToCsioHomeEndorsement
**What it does**: Converts TBW home endorsement codes to CSIO coverage codes.
**When it runs**: When sending a hab endorsement to the carrier.
**Rules (V145 - latest)**:
- If endorsement is a MiscProperty, delegates to TryConvertToCsioMiscProperty instead.
- EquipmentBreakdownCoverage -> standard HomeEquipmentProtection
- CondoDeductibleAssessment -> standard CommonElementsCondominiumCorporationExtensionEndorsement
- WindHailCoverage -> standard WindHailDeductible
- GlassReducedDeductible -> standard GlassBreakage
- HotTub -> csio:ZPOHTE (carrier proprietary)
- LimitedRoofCoverage -> csio:ZRLE (carrier proprietary)
- RentalIncome -> standard RentorRentalValue
- WaterCoverage -> csio:ZPWPE (carrier proprietary)
- DeductibleAssessmentBuydownEarthquake -> csio:ZPECC (carrier proprietary)
- All others fall through to generic base

**Rules (V143 - base, differences)**:
- CondoDeductibleAssessment -> csio:CECCE (carrier proprietary, changed in V144)
- HotTub -> csio:SPDAM (changed to csio:ZPOHTE in V144)
- WaterCoverage -> csio:OVWAT (changed to csio:ZPWPE in V144)
- DeductibleAssessmentBuydownEarthquake -> csio:CDEDA (changed to csio:ZPECC in V144)
- LimitedRoofCoverage -> csio:ROOFW (changed to csio:ZRLE in V144)
- WindEnergySystem -> WINDTURB (company constant, V143 only)
- SolarEnergySystem -> csio:SolarPanel (company constant, V143 only)

**Codes sent**: csio:ZPOHTE, csio:ZRLE, csio:ZPWPE, csio:ZPECC, csio:ZPCSCI, plus standard codes

---

### TryConvertToCsioMiscProperty
**What it does**: Converts scheduled property item codes to CSIO coverage codes.
**When it runs**: When a home endorsement is classified as MiscProperty.
**Rules (V145 - latest)**:
- ComputerHardware, ComputerSoftware, ComputerSoftwareIncreasedLimits, CellularPhone -> csio:ZPCSCI (all map to single carrier code)
- WineAndSpirits -> standard WineSpiritsEndorsement
- BelongingsStorage -> standard PropertyInStorage
- All others fall through to generic base

**Rules (V143 - base, differences)**:
- Computer codes are commented out (disabled)
- BusinessPersonalProperty, BusinessPropertyIncreasedLimits -> standard BooksToolsandInstrumentsPertainingtoaBusiness
- WindEnergySystem -> WINDTURB (company constant)
- SolarEnergySystem -> csio:SolarPanel (company constant)

---

## Home Liability

### TryConvertToCsioHomeLiability (V143 only)
**What it does**: Converts TBW liability codes to CSIO coverage codes.
**When it runs**: When sending a hab liability extension to the carrier.
**Rules**:
- AdditionalResidenceHouse, AdditionalResidenceCondo, AdditionalResidenceTenant, AdditionalResidence, SeasonalDwelling, RentedCondo, RentedDwelling -> standard AdditionalResidencesPropertiesAcreage (all 7 codes map to same CSIO value)
- BusinessUseOfHome -> standard ProfessionalUseResPremises
- Horses -> standard ExhibitionofAnimals
- DayCareInHome -> csio:DAYC (carrier proprietary)
- RentedRoomSuite -> standard AdditionalLocationsRented
- TouristRoomSuites -> standard BedBreakfast
- Boat, BoatAndMotor -> csio:WALI2 (carrier proprietary)
- DocksOrWharves -> csio:WHADO (carrier proprietary)
- Atv -> csio:AMPHL (carrier proprietary, amphibious vehicle liability)
- All others fall through to generic base

**Codes sent**: csio:DAYC, csio:WALI2, csio:WHADO, csio:AMPHL, plus standard codes

---

## Auto Surcharges

### TryConvertToCsioAutoSurcharge (V143 only)
**What it does**: Converts TBW surcharge codes to CSIO codes.
**When it runs**: When sending an auto surcharge to the carrier.
**Rules**:
- RightHandDriveVehicle -> csio:SURRH (carrier proprietary)
- All others fall through to generic base

---

## Multi-Line Discount

### ConvertCoverage (PersPolicyConverter)
**What it does**: Adds a multi-line discount coverage node when the insured has both auto and hab with PeaceHills.
**When it runs**: During outbound personal policy conversion.
**Rules**:
- If policy type is Auto AND there are supporting hab policies with PeaceHills -> add multi-line discount
- If policy type is Home/Condo/Tenant/FEC/Seasonal AND there are supporting auto policies (or misc auto policies) with PeaceHills -> add multi-line discount
- The discount uses standard DiscountMultipleLine code with description "Multi Line"

---

## Policy Type Mapping

### TryConvertToCsio (PolicyTypeConverter)
**What it does**: Maps TBW policy types to CSIO policy type codes.
**When it runs**: For every hab quote/submission.
**Rules**:
- Rented Condo (coverage item code) -> delegates to TryConvertRentedCondoToCsio
- All other coverage codes -> fall through to generic base

### TryConvertCondoToCsio
- Comprehensive -> standard ComprehensiveCondominiumForm
- All others -> fall through to generic base

### TryConvertTenantToCsio
- CompSenior or BroadSenior -> standard TenantsSeniorsPackage
- All others -> fall through to generic base

### TryConvertFecToCsio (Rented Dwelling)
- Comprehensive -> standard RentedDwellingComprehensiveForm
- FireAndExtendedCoverage or Standard -> RentedDwellingFireECForm (V143 custom)
- Package -> standard RentedDwellingComprehensiveForm
- All others -> Return False (unsupported)

### TryConvertRentedCondoToCsio
- Comprehensive -> RentedCondominiumForm (V143 custom)
- All others -> Return False (unsupported)

### TryConvertSeasonalToCsio
- FireAndExtendedCoverage -> SeasonalDwellingFireECForm (V143 custom)
- NamedPerils -> standard SeasonalDwellingBroadForm
- SeasonalPlus -> standard SeasonalDwellingComprehensiveForm
- All others -> fall through to generic base

---

## Earthquake Coverage Handling

### ConvertEndorsementDeductible (PcCoverageConverter)
**What it does**: Handles earthquake deductible conversion specially.
**When it runs**: When converting an endorsement with a deductible.
**Rules**:
- If endorsement is Earthquake -> convert deductible using EarthquakeDeductible field
- All other endorsements -> fall through to generic base

### GetCoverageType (PcCoverageConverter)
**What it does**: Gets the coverage type for earthquake endorsements from a special field.
**When it runs**: When determining the coverage type string for an endorsement.
**Rules**:
- If endorsement is Earthquake -> get coverage type from EarthquakeCoverage field
- All others -> fall through to generic base

### ConvertFromDwell (Rated PcCoverageConverter, V143)
**What it does**: Handles rated earthquake response parsing with building/contents/outbuildings split.
**When it runs**: When parsing rated hab responses from the carrier.
**Rules**:
- If coverage code matches Earthquake:
  - OptionCd = Building -> set limit/deductible/premium for Buildings
  - OptionCd = Contents -> set limit/deductible/premium for Contents
  - OptionCd = csio:EO (Outbuildings) -> set limit/deductible/premium for Outbuildings
- All other endorsements -> standard conversion

---

## Dwelling Coverage Handling

### ConvertHabCoverageCd (PcCoverageConverter)
**What it does**: Converts hab coverage codes, with a special override for improvements/betterments.
**When it runs**: When converting hab coverage types to CSIO.
**Rules**:
- ImprovementsAndBetterments -> standard CondominiumUnitOwnersUnitImprovementsandBetterments
- All others -> fall through to generic base

### ConvertLossAssessment (PcCoverageConverter)
**What it does**: Sends loss assessment as a separate coverage node.
**When it runs**: When the LossAssessment field has a non-zero value.
**Rules**:
- If LossAssessment > 0 -> send standard PropertyLossAssessment code with limit
- Otherwise -> do nothing

### ConvertContingent (PcCoverageConverter)
**What it does**: Sends contingent coverage as a separate coverage node.
**When it runs**: When the Contingent field has a non-zero value.
**Rules**:
- If Contingent > 0 -> send standard AllRiskUnitOwnersAdditionalProtection code with limit
- Otherwise -> do nothing

---

## Hab Coverage Collection Overrides

### PcCoverageCollectionConverter
**What it does**: Overrides how hab coverages are generated for the collection.
**Rules**:
- PropertyDamageOccasional -> suppressed (does nothing)
- TPL (Third Party Liability) -> suppressed (does nothing)
- LossAssessment -> sent as separate coverage node if non-zero
- Hab Coverage, Hab Contents, Hab Outbuildings -> only sent if limit is non-zero (filtered out when limit = 0)
- Supports bareland condo (SupportBarelandcondo returns True)

---

## Watercraft Coverage Handling (V143 Rated Response)

### ConvertFromWatercraft (V143 Rated PcCoverageConverter)
**What it does**: Parses watercraft premiums from rated responses.
**When it runs**: When processing watercraft coverage in rated response.
**Rules**:
- If coverage code is csio:CCWT or csio:HLLAR or csio:ATVAR -> parse watercraft premium and liability premium
- Otherwise -> treat as discount/surcharge

---

## Occupancy Type Mapping

### TryConvertToCsio (OccupancyTypeConverter)
**What it does**: Maps TBW occupancy types to CSIO occupancy type codes.
**Rules**:
- Owner/FamilyMember with Primary Item -> PrimaryResidence
- Owner/FamilyMember with Seasonal Dwelling -> SecondarySeasonal
- Owner/FamilyMember with Rented Condo/Dwelling -> Rental
- Owner/FamilyMember with Tenant -> PrimaryResidence
- Owner/FamilyMember with anything else -> SecondaryNonSeasonal
- Tenant with Primary category -> PrimaryResidence
- Tenant with Rented Condo/Dwelling -> Rental
- Tenant with anything else -> SecondaryNonSeasonal
- Unoccupied -> Unoccupied

---

## Sewer Backup Prevention

### TryConvertSewerBackupPreventionCd (SewerBackupPreventionInfoConverter)
**What it does**: Converts sump pump and backwater valve configuration to CSIO sewer backup prevention codes.
**When it runs**: When sending dwelling inspection info.
**Rules**:
- If sumpPumpAlarm AND sumpPump AND backWaterValve AND generatorBackup -> AlarmedSumpPumpWithBatteryBackupBackupValve
- Otherwise delegates to SewerBackupPreventionCodeConverter which maps most combinations to "Other"
- Special case: sumpPump AND batteryBackup AND backWaterValve (no alarm) -> BackUpValveSumpPumpWithBattery

---

## Credit Info Consent

### TryConvertToCsio (CreditInfoConsentConverter)
**What it does**: Maps TBW credit authorization type to CSIO credit info consent codes.
**Rules**:
- ConsentYes -> SignedForm
- ConsentNo -> Denied
- AuthorizationAudio -> VerbalOK
- AuthorizationImplied -> ConsentNoMailings
- Anything else (including NotAsked) -> NotAsked

---

## Version Differences (V144/V145 vs V143)

### Major Changes in V144:
1. **CompanyConstants trimmed from 71 to 34 lines** - Many carrier-specific codes replaced with standard CSIO values
2. **5 coverage codes changed to Z-codes**: HotTub (SPDAM -> ZPOHTE), WaterPlus (OVWAT -> ZPWPE), EQ Buydown (CDEDA -> ZPECC), LimitedRoof (ROOFW -> ZRLE), CondoDeductibleAssessment (CECCE -> standard)
3. **13 codes removed entirely**: EmergencyAssistancePackage, CAE6, CAE7, Outbuildings, DeductiblePerilWater, RightHandDriveVehicle, SolarEnergySystem, WindTurbine, AmphibiousVehicleLiability, DayCareInHome, BoatAndMotor, WharvesAndDocks, CondominiumDeductibleAssessmentEarthquakeExcluded
4. **CsioConstants.vb removed** in V144 (watercraft and property schedule codes removed)
5. **Multiple V143-only EnumConverters removed** in V144: BackFlowValveConverter, CreditInfoConsentConverter, GarageTypeConverter, ItemDefinitionTypeConverter, MercantileBusinessTypeConverter, OccupancyTypeConverter, PropulsionTypeConverter, RiskConverter, SewerBackupPreventionCodeConverter

### V145 vs V144:
- CompanyConstants.vb is **identical** between V144 and V145
- V145 adds new **Generic** files only: CompanyCodeConverter, CoverageCodeConverter, VehicleSpecialUseConverter, PcCoverageCollectionConverter, PcCoverageConverter
- No carrier-specific code changes between V144 and V145
