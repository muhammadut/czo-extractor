# SGI Canada GIS - Business Rules

## Coverage Type Mapping (PolicyTypeConverter)

### TryConvertHomeToCsio
**What it does**: Converts framework home coverage type (PakA, PakB, PakI, etc.) to CSIO policy type code.
**When it runs**: Outbound request building for hab policies.
**Rules**:
- PakA, PakB, PakPlus, PakBPlus map to standard named perils / comprehensive forms via enum values
- PakI, PakIPlus map to csio:72 (Basic Residential Standard Form)
- PakII, PakIIPlus, PakIII, PakIIIPlus, SeniorsPakSpecial, Prestige map to csio:75 (Basic Residential Comprehensive Form)
- If limit is increased, uses the "Plus" variant of each form
- Falls back to base generic for unrecognized types
**Codes sent**: csio:72, csio:75, plus standard enum-based policy type codes

### TryConvertCondoToCsio
**What it does**: Converts condo coverage types to CSIO policy types.
**When it runs**: Outbound for condo policies.
**Rules**:
- PakI maps to named perils condo form
- PakII maps to all risk condo form
- PakIPlus/PakIIPlus map to plus variants with limit increased flag
**Codes sent**: Standard condo policy type codes via enum

### TryConvertTenantToCsio
**What it does**: Converts tenant coverage types to CSIO policy types.
**When it runs**: Outbound for tenant policies.
**Rules**:
- PakI maps to named perils tenant form
- PakII maps to all risk tenant form
- PakIPlus/PakIIPlus map to plus variants
- PakIII maps to all risk tenant form (same as PakII)
**Codes sent**: Standard tenant policy type codes via enum

### TryConvertSeasonalToCsio
**What it does**: Converts seasonal coverage types.
**When it runs**: Outbound for seasonal dwelling policies.
**Rules**:
- PakI maps to csio:72 (Basic Residential Standard Form)
- PakII maps to csio:75 (Basic Residential Comprehensive Form)
- Other Pak types map via enum values
**Codes sent**: csio:72, csio:75

### TryConvertFecToCsio
**What it does**: Converts FEC (Farm Extension Coverage) types.
**When it runs**: Outbound for farm policies.
**Rules**:
- PakIPlus maps to csio:72
- PakIIPlus and PakIIIPlus map to csio:75
- Others delegate to TryConvertHomeToCsio
**Codes sent**: csio:72, csio:75

---

## Home Endorsement Mapping (CoverageCodeConverter)

### TryConvertToCsioHomeEndorsement
**What it does**: Maps framework endorsement codes to CSIO coverage codes for outbound requests.
**When it runs**: Building hab endorsement PCCOVERAGE elements.
**Rules**:
- EquipmentBreakdownCoverage -> PowerFluctuation enum value (csio:PWFL)
- ServiceLineCoverage -> csio:SLEXT (CompanyConstants)
- BearDamage -> DamageCausedbyWildLife enum value
- WaterCoverage -> FloodDamage enum value
- CondoDeductibleAssessment -> csio:ZDBU (CompanyConstants)
- ClaimsProtector -> ClaimFreeProtection enum value (V137 only)
- InflationProtection -> InflationGuardEndorsement enum value (V137 only)
- LegalExpense -> LegalAssistance enum value
- SolidFuelWarranty -> csio:ZSFW (V134 only, removed from V137 TryConvertToCsioHomeEndorsement)
- All others fall back to base generic
**Codes sent**: csio:PWFL, csio:SLEXT, csio:ZDBU, csio:ZSFW, plus standard enum values

### TryConvertToFrameworkHomeEndorsement
**What it does**: Maps incoming CSIO coverage codes to framework endorsement codes.
**When it runs**: Parsing hab endorsements from responses.
**Rules**:
- csio:ZLIFA/ZLIFB/ZLIFC/ZLIFD -> SpecialLimitsEnhancement (all four lifestyle options collapse to one framework code)
- PowerFluctuation -> EquipmentBreakdownCoverage
- csio:ZSFW -> SolidFuelWarranty
- csio:SLEXT -> ServiceLineCoverage
- FloodDamage -> WaterCoverage
- csio:ZDBU -> CondoDeductibleAssessment
- ClaimFreeProtection -> ClaimsProtector
- Roomer -> RentedRoomSuite (as liability)
- AllTerrainVehiclesBasic/PassengerHazard/UnderageOperator -> ATV (as liability)
- WatercraftLiabilityA -> Boat (as liability)
- csio:SEARS -> SeasonalDwelling (as liability)
- csio:ADRNT -> RentedDwelling (as liability)
- JetSki variants -> JetSki (as liability)
- WaivedPremium -> no framework code (returns True but no assignment)
- BuildingUnderConstruction -> DwellingUnderConstruction (V137 only)
- InflationGuardEndorsement -> InflationProtection (V137 only)
- LegalAssistance -> LegalExpense (V137 only)
- If code doesn't start with "csio:", the prefix is prepended automatically

---

## Special Limits Enhancement (PcCoverageCollectionConverter)

### ConvertSpecialLimitsEnhancement
**What it does**: Converts SpecialLimitsEnhancement endorsement to CSIO coverage.
**When it runs**: Outbound hab endorsement processing.
**Rules**:
- If parent coverage type is "Prestige", reads CoverageOptions field and splits by "|"
- Each option maps to a separate PCCOVERAGE element:
  - "Option A (Business)" -> csio:ZLIFA
  - "Option B (Collectibles & Treasures)" -> csio:ZLIFB
  - "Option C (Family & Security)" -> csio:ZLIFC
  - "Option D (Home & Recreation)" -> csio:ZLIFD
- If NOT Prestige, sends single EnhancedInternalLimits (csio:ENHIN) code
- Multiple lifestyle options generate deterministic IDs for subsequent elements
**Codes sent**: csio:ZLIFA, csio:ZLIFB, csio:ZLIFC, csio:ZLIFD, csio:ENHIN

---

## Equipment Breakdown + Service Line (PcCoverageCollectionConverter)

### ConvertEquipmentBreakdownandServiceLineCoverage
**What it does**: Splits the combined EquipmentBreakdownAndServiceLine endorsement into two PCCOVERAGE elements.
**When it runs**: Outbound hab endorsement processing.
**Rules**:
- Creates first coverage with PowerFluctuation code (csio:PWFL) + deductible
- Creates second coverage with ServiceLineCoverage code (csio:SLEXT) + deductible
- Both share the same deductible from the input endorsement
**Codes sent**: csio:PWFL, csio:SLEXT

---

## Commercial Exposure Surcharge (PcCoverageCollectionConverter)

### ConvertCommercialExposureSurchargeCoverage
**What it does**: Converts commercial building type to a surcharge coverage.
**When it runs**: Outbound for tenant policies only.
**Rules**:
- None -> no surcharge sent
- Bank, Office -> csio:SUREL (Low)
- Store -> csio:SUREM (Medium)
- Garage, Restaurant -> csio:SUREH (High)
**Codes sent**: csio:SUREL, csio:SUREM, csio:SUREH

---

## Skip Endorsements Logic (PcCoverageCollectionConverter)

### SkipEndorsements
**What it does**: Determines which endorsements should NOT be sent as separate PCCOVERAGE elements.
**When it runs**: Before processing hab endorsements.
**Rules**:
- BearDamage is skipped UNLESS coverage type is PakI, PakII, PakIPlus, or PakIIPlus
- All liability-category endorsements are skipped (handled separately)
- WindEnergySystem is always skipped
- SolidFuelWarranty is always skipped
**Effect**: These endorsements are not sent as separate PCCOVERAGE in the outbound XML

---

## Auto Endorsement Mapping (CoverageCodeConverter)

### TryConvertToCsioOntarioAutoEndorsement
**What it does**: Maps Ontario-specific auto endorsements to CSIO codes.
**When it runs**: Outbound auto endorsement processing.
**Rules**:
- DrivingRecordProtectorClaims -> csio:ZAFW
- All others fall back to base generic (OPCF endorsements)
**Codes sent**: csio:ZAFW

---

## Auto Surcharge Mapping (CoverageCodeConverter)

### TryConvertToFrameworkAutoSurcharge
**What it does**: Maps incoming CSIO auto surcharge codes to framework surcharge codes.
**When it runs**: Parsing auto surcharges from responses.
**Rules**:
- csio:SURC2 -> SurchargeCode.ClaimConviction
- All others fall back to base generic
- Handles missing "csio:" prefix by prepending it

---

## Hab Discount Mapping (CoverageCodeConverter)

### TryConvertToFrameworkHabDiscount
**What it does**: Maps incoming CSIO hab discount codes to framework discount codes.
**When it runs**: Parsing hab discounts from responses.
**Rules**:
- PremisesAlarmFireorIntrusionSystem enum value -> SecuritySystem
- csio:ZPMSB -> PreventativeMeasures
- Employee enum value -> SGIEmployee (V137 only)
- All others fall back to base generic
- Handles missing "csio:" prefix

### TryConvertToCsioHabDiscount
**What it does**: Maps framework hab discount codes to CSIO codes for outbound.
**When it runs**: Outbound hab discount processing.
**Rules**:
- SGIEmployee -> Employee enum value (V137 only)
- All others fall back to base generic

---

## Earthquake Logic (PcCoverageConverter)

### ConvertEarthquakeLimit
**What it does**: Converts earthquake coverage options to limit amounts.
**When it runs**: Processing earthquake endorsement limits.
**Rules**:
- DwellingAndPersonalProperty or DwellingAnd0PercentPersonalProperty -> limit = 100
- DwellingAnd75PercentPersonalProperty -> limit = 75
- DwellingAnd50PercentPersonalProperty -> limit = 50
- DwellingAnd25PercentPersonalProperty -> limit = 25

### ConvertEndorsementCoverageDesc (Earthquake)
**What it does**: Sets earthquake coverage description.
**Rules**:
- Default description: "Earthquake - Belongings"
- If option is "100% dwelling, 0% personal property": description = "Earthquake - Dwelling"

---

## Liability Handling (PcCoverageConverter)

### ConvertEndorsement (Liability Category)
**What it does**: Special processing for liability-category endorsements.
**When it runs**: Outbound endorsement processing for liabilities.
**Rules**:
- Liabilities that are NOT AdditionalResidence/SeasonalDwelling/RentedCondo/RentedDwelling get CoverageRefs (location ID) and CategoryCd set
- TerritoryCd is set from LocationFactor field if present, otherwise from parent dwelling province
- Province mapping: Saskatchewan->SK, Alberta->AB, Manitoba->MB, Ontario->ON, BritishColumbia->BC

### IsLiability
**What it does**: Checks if a coverage code is a liability type.
**Rules**: Checks against the CsioCodes.Liability list: csio:ROOMR, csio:BUSNS, csio:BOCH, csio:VACLD, csio:ADDRR, csio:ADDNI, csio:BEDBR, csio:HORSE, csio:ALLTB, csio:ALLTP, csio:ALLTU, csio:WALIA, csio:BLDCR, csio:JPPWB, csio:JPPWP, csio:LLLA, csio:LLLAB, csio:IPL, csio:FORPA, csio:SEARS, csio:VACPR, csio:ADRNT

---

## ATV/JetSki as Misc Property (PcCoverageConverter + PcCoverageCollectionConverter)

### ConvertEndorsementCoverageCd (ATV/TrailBikes)
**What it does**: Overrides coverage code for ATV/TrailBikes misc property items.
**Rules**: ATV and TrailBikes misc property items get csio:ALLTB (AllTerrainVehiclesBasic) as their coverage code instead of the default.

### ConvertToPersVeh (ATV/TrailBikes)
**What it does**: Routes ATV/TrailBikes to property schedule instead of vehicle coverages.
**Rules**: If item is ATV or TrailBikes with MiscProperty category, routes to ConvertToPropertySchedule instead of standard vehicle coverage processing.

### GetCoverageCdPropertyScheduleAllRisks
**What it does**: Returns appropriate all-risks coverage code for property schedule items.
**Rules**:
- ATV, TrailBikes, JetSki -> MiscellaneousVehiclesAllRisks
- All others -> AllRiskPersonalArticlesEndorsement

---

## Condo Coverage Specifics (PcCoverageConverter)

### ConvertHabCoverage / ConvertHabCoverageCd
**What it does**: Overrides dwelling coverage code for condo/tenant policies.
**Rules**: For Condo and Tenant policy types, the coverage code is set to PersonalPropertyHomeownersForm instead of the default dwelling code.

### ConvertContingent / ConvertLossAssessment / ConvertImprovementsAndBetterments
**What it does**: Converts additional condo coverage fields.
**Rules**:
- PakI -> Named Perils variant of each condo coverage
- PakII/SeniorsPakSpecial -> All Risk variant of each condo coverage
- Each includes separate limit and deductible conversions

---

## Discount/Surcharge Classification in Response (Rated PcCoverageConverter)

### ConvertDiscountSurcharge
**What it does**: Routes discount/surcharge processing for rated responses.
**Rules**:
- PreventativeMeasures code (ZPMSB) -> ConvertDiscount
- All others -> base generic processing
**Note**: The PreventativeMeasures code value used for matching is "ZPMSB" (without csio: prefix, from CompanyValue class)

---

## Version Differences (V137 vs V134)

### Added in V137:
- ClaimsProtector endorsement mapping (ClaimFreeProtection enum)
- InflationProtection endorsement mapping (InflationGuardEndorsement enum) - but ignored in rated responses
- LegalExpense endorsement mapping (LegalAssistance enum)
- SGIEmployee hab discount (Employee enum value)
- DwellingUnderConstruction liability (Buildingunderconstruction enum)
- TryConvertToCsioHabDiscount override for SGIEmployee
- Watercraft motor named perils and marine perils conversion
- Ride-sharing support (via V137 Generic)
- Exposure info support (via V137 Generic)

### Changed in V137:
- TryConvertToCsioHomeLiability: AdditionalResidenceMobileHome added to the group mapped to AdditionalResidencesPropertiesAcreage; RentedDwelling removed from that group and given its own ADRNT code instead; SeasonalDwelling added with SEARS code; DwellingUnderConstruction added
- TryConvertToFrameworkHomeEndorsement: Many new cases added (AllTerrainVehicles variants, JetSki variants, WatercraftLiabilityA, SEARS, ADRNT, WaivedPremium, BuildingUnderConstruction, InflationGuardEndorsement)
- ConvertToCsioLiability: Override added for ATV and JetSki with coverage type variants (Passenger Hazard, Underage Operator)
- TryConvertToFrameworkFloater: Override added for watercraft motor/trailer floater mapping

### Removed in V137 CompanyConstants:
- ATVBasic constant from Coverages class
- CsioCodes class (Liability, LiabilityJetSki, LiabilityATV, LiabilityDwelling lists) - still referenced via V134 namespace
- CoverageTypes: ScheduledItemCodeB, ScheduledItemCodeA, ScheduledItemCodeAE, ScheduledItemCodeH, ScheduledItemCodeBroadNamedPerils, Broad
- CompanyCd fields: BusinessOnPremisesCd, DaycareMeetsProvLeg, DayCareExposures, VacantLotExposures, DisplacementOver250Ind, RelatedAgencyID, RelatedInsurerID, RelatedInsuredDescription, CompanyName
- CsioCoverageTypeValue: LLLAB, ADDRR, ADRNT, SEARS, ALLTB, ALLTP, ALLTU, JPPWB, JPPWP, WAPRE, PWFL, GUARR removed (still used via V134 reference)
