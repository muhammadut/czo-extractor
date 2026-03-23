# SGI Canada Direct Rating - Business Rules

Extracted: 2026-03-22 | Version: V134 (single version carrier)

---

## Coverage Code Mapping (CoverageCodeConverter.vb)

### TryConvertToCsioHomeEndorsement
**What it does**: Converts TBW home endorsement codes to CSIO coverage codes for outbound requests.
**When it runs**: For each home endorsement being sent to SGI Canada.
**Rules**:
- EquipmentBreakdownCoverage maps to SmartHomeSystems (V132 enum)
- SolidFuelWarranty maps to csio:ZSFW (carrier-specific)
- ServiceLineCoverage maps to csio:SLEXT (carrier-specific)
- BearDamage maps to standard DamageCausedbyWildLife
- WaterCoverage maps to standard FloodDamage
- ClaimsProtector maps to standard ClaimFreeProtection
- RoofSurfaceBasisOfSettlement maps to standard RoofBasisOfSettlementDueToWindstormHail (V118 enum)
- CondoExtension maps to standard HomeownersSingleLimit
- LegalExpense maps to standard LegalAssistance
- All other endorsement codes fall through to generic base (V133)

**Codes sent**: csio:ZSFW, csio:SLEXT, plus standard codes via enum factory

### TryConvertToFrameworkHomeEndorsement
**What it does**: Converts CSIO coverage codes from response back to TBW endorsement codes.
**When it runs**: When parsing SGI Canada response.
**Rules**:
- Prefixes csio: to coverage code if missing
- LifestyleOptionA/B/C/D (csio:CCBUS/CCCOL/CCFAM/CCHRC) all map to SpecialLimitsEnhancement
- SmartHomeSystems maps to EquipmentBreakdownCoverage
- csio:ZSFW maps to SolidFuelWarranty
- csio:SLEXT maps to ServiceLineCoverage
- FloodDamage maps to WaterCoverage
- ClaimFreeProtection maps to ClaimsProtector
- BuildingUnderConstruction maps to DwellingUnderConstruction (as liability code cast to endorsement)
- RoofBasisOfSettlementDueToWindstormHail maps to RoofSurfaceBasisOfSettlement
- LegalAssistance maps to LegalExpense
- All other codes fall through to generic base

### TryConvertToCsioOntarioAutoEndorsement
**What it does**: Converts Ontario-specific auto endorsements to CSIO codes.
**When it runs**: For Ontario auto policies.
**Rules**:
- DrivingRecordProtectorClaims maps to csio:39
- Opcf49 maps to csio:49
- Pak05 maps to standard Pak05 enum value
- All other Ontario endorsements fall through to generic base

### TryConvertToCsioAutoEndorsement
**What it does**: Converts non-Ontario auto endorsements to CSIO codes.
**When it runs**: For auto endorsements not specific to Ontario.
**Rules**:
- End19A maps to V134 IAutoCoverageAndEndorsement.End19A
- End39A maps to csio:39A (At-Fault Accident Waiver)
- End19B maps to standard End19
- End28C maps to standard End28
- All other auto endorsements fall through to generic base

### TryConvertToCsioHomeLiability
**What it does**: Maps liability codes to CSIO coverage codes for home policies.
**Rules**:
- All additional residence types (Condo, House, Tenant, RentedCondo, RentedDwelling, MobileHome) map to standard AdditionalResidencesPropertiesAcreage
- DwellingUnderConstruction maps to standard BuildingUnderConstruction
- PremisesLiabilityRestriction maps to V134 PremisesCoverageLimitation
- All other liability codes fall through to generic base

### TryConvertToFrameworkAutoSurcharge
**What it does**: Converts CSIO surcharge codes from response to TBW surcharge codes.
**Rules**:
- csio:SURC2 maps to SurchargeCode.ClaimConviction
- csio:SURRH maps to SurchargeCode.RightHandDriveVehicle
- All other surcharges: prefixes csio: if missing, then falls through to generic base

### TryConvertToCsioHabDiscount
**What it does**: Converts TBW hab discount codes to CSIO codes.
**Rules**:
- PreventativeMeasures maps to V134 SewerBackupPreventionDiscount
- All other hab discounts fall through to generic base

### TryConvertToFrameworkHabDiscount
**What it does**: Converts CSIO hab discount codes from response to TBW codes.
**Rules**:
- Prefixes csio: to code if missing
- PremisesAlarmFireorIntrusionSystem maps to DiscountCode.SecuritySystem
- SewerBackupPreventionDiscount maps to DiscountCode.PreventativeMeasures
- csio:DISCR maps to DiscountCode.CreditScore
- DiscountProtectionDevice (V118) maps to DiscountCode.FireAlarm
- All other hab discounts fall through to generic base

### TryConvertToFrameworkAutoDiscount
**What it does**: Converts CSIO auto discount codes from response to TBW codes.
**Rules**:
- csio:DISCR maps to DiscountCode.CreditScore
- csio:DISNO maps to DiscountCode.ClaimsFreeOccasional
- All other auto discounts fall through to generic base

---

## Outbound Coverage Collection (PcCoverageCollectionConverter.vb)

### ConvertSpecialLimitsEnhancement
**What it does**: Converts Special Limits Enhancement endorsement to CSIO coverages.
**When it runs**: When a SpecialLimitsEnhancement endorsement is found in outbound conversion.
**Rules**:
- If coverage type is "Prestige" AND coverage options exist:
  - Split options by pipe delimiter "|"
  - For each option: LifestyleOptionA -> csio:CCBUS, OptionB -> csio:CCCOL, OptionC -> csio:CCFAM, OptionD -> csio:CCHRC
  - Each option becomes a separate PCCOVERAGE element with a unique ID suffix
- If NOT Prestige or no options: sends standard EnhancedInternalLimits code

### ConvertEquipmentBreakdownandServiceLineCoverage
**What it does**: Sends two separate coverages for the combined endorsement.
**Rules**:
- First PCCOVERAGE: PowerFluctuation code (standard) with deductible
- Second PCCOVERAGE: csio:SLEXT (Service Line Coverage) with same deductible

### ConvertCommercialExposureSurchargeCoverage
**What it does**: Adds commercial exposure surcharge coverage for tenant policies.
**When it runs**: Only on Tenant policy type, when CommercialBuildingType field is present.
**Rules**:
- None: no surcharge sent
- Bank or Office: csio:SUREL (Low)
- Store: csio:SUREM (Medium)
- Garage or Restaurant: csio:SUREH (High)

### ConvertRightHandDriveVehicleSurcharge
**What it does**: Adds a surcharge coverage for right-hand drive vehicles.
**When it runs**: When SteeringWheelPosition field = "Right".
**Codes sent**: csio:SURRH

### ConvertUSExposureSurcharge
**What it does**: Adds US exposure surcharge.
**When it runs**: When UsExposure field > 0.
**Codes sent**: standard SurchargeUsNonCanadianExposure

### ConvertIPromiseProgram
**What it does**: Always sends iPromise Program coverage with a Yes/No option.
**When it runs**: For every vehicle.
**Rules**:
- If IPromiseProgram field = True: option YesNoIndicator1
- If False: option YesNoIndicator2
**Codes sent**: standard DiscountIPromiseProgramParentTeenMutualSafeDrivingContract

### SkipEndorsements
**What it does**: Determines which endorsements should NOT be sent.
**Rules**:
- BearDamage is skipped unless coverage type is Pak I, Pak II, Pak I Plus, or Pak II Plus
- BoatAndMotor liability is always skipped (handled via watercraft conversion instead)
- JetSki liability is always skipped (handled via watercraft conversion instead)

### ConvertReplacementCost
**What it does**: Adds Replacement Cost Building coverage.
**When it runs**: When the Replacement field is True on a dwelling.
**Codes sent**: V134 IHabPackageAndOtherForms.ReplacementCostBuilding

---

## Outbound Coverage Converter (PcCoverageConverter.vb)

### ConvertEarthquakeLimit
**What it does**: Calculates earthquake limit based on coverage option.
**Rules**:
- DwellingAndPersonalProperty, DwellingAnd0PercentPersonalProperty, or "100% personal property": limit = dwelling value * 100%
- DwellingAnd75PercentPersonalProperty: limit = dwelling value * 75%
- DwellingAnd50PercentPersonalProperty: limit = dwelling value * 50%
- DwellingAnd25PercentPersonalProperty: limit = dwelling value * 25%

### ConvertEndorsementCoverageDesc
**What it does**: Sets earthquake coverage description text.
**Rules**:
- If earthquake coverage option = "100% dwelling, 0% personal property": description = "Earthquake - Dwelling"
- All other earthquake options: description = "Earthquake - Belongings"

### ConvertWatercraftLiability
**What it does**: Sends watercraft liability coverage.
**Rules**:
- For JetSki: sends liability with JetSki-specific limit
- For other watercraft: sends liability with policy TPL limit
**Codes sent**: standard WatercraftLiabilityA

### ConvertWatercraftHull
**What it does**: Combines boat hull and motor values into a single coverage limit.
**Rules**:
- Starts with base hull value
- If MotorCoverage field > 0: adds motor value to hull limit
**Codes sent**: standard AdditionalMiscellaneousEquipmentAllRisks

---

## Policy Type Mapping (PolicyTypeConverter.vb)

### TryConvertToCsio
**What it does**: Converts TBW policy type to CSIO policy type code.
**Rules**:
- If Farm policy: delegates to TryConvertHomeToCsio
- If Rented Condo: uses carrier-specific codes csio:2K (Comprehensive) or csio:2I (Standard)
- If Rented Dwelling: Standard/FEC/Comprehensive mapped to standard forms
- Otherwise: delegates to base converter

### TryConvertHomeToCsio
**What it does**: Maps home coverage types.
**Rules**:
- Standard -> HomeownersStandardForm
- Broad -> HomeownersBroadForm
- "Prestige" -> HomeownersInsuranceMinimumProtection
- ComprehensiveLongForm -> HomeownersComprehensiveForm

### TryConvertToFramework (reverse)
**What it does**: Maps CSIO policy type codes back to TBW coverage types.
**Rules**:
- All Comprehensive forms -> ComprehensiveLongForm
- Limited forms -> FireAndExtendedCoverage
- Standard forms -> Standard
- Broad forms -> Broad
- HomeownersInsuranceMinimumProtection -> "Prestige"
- csio:2K and csio:2I included in their respective groups

---

## Dwelling Converter (DwellConverter.vb)

### ConvertPolicyTypeCd
**What it does**: Overrides policy type for rented condos, rented dwelling, and additional residences.
**Rules**:
- If Additional Residence Condo with Comprehensive + Tenant occupancy: csio:2K
- If Additional Residence Condo with Standard + Tenant occupancy: csio:2I
- If Primary Item Condo with Comprehensive + Tenant occupancy: csio:2K
- If Primary Item Condo with Standard + Tenant occupancy: csio:2I
- If Additional Residence House with Tenant occupancy: RentedDwellingStandardForm
- If Rented Condo with Unoccupied: Standard -> CondominiumPackageStandardForm, Comprehensive -> ComprehensiveCondominiumForm

---

## Construction Converter (ConstructionConverter.vb)

### ConvertConstructionCd
**What it does**: Selects the dominant construction type by highest percentage.
**Rules**:
- Evaluates all construction type fields on the coverage item
- Picks the one with the highest percentage value
- Carrier-specific types: PostBeamWood (csio:5), Sectional (CC:Sectional), Panabode (CC:Panabode), LogHandHewn (csio:6), LogManufactured (csio:1), Modular (CC:Modular)
- Standard types: Brick, ConcreteBlockMasonryFrame (V132), Frame, Masonry, Steel, Stone, Log
- Log types (Log, LogHandHewn, LogManufactured) compete with each other - the last one set wins unless a higher percentage is found later

---

## Cause of Loss Mapping (CauseOfLossConverter.vb)

### ConvertToCsio (Auto)
**What it does**: Maps auto claim perils to CSIO cause of loss codes.
**Rules**:
- AccidentBenefits -> CollisionOther
- Fire -> FireDamageTotalLoss
- Smoke -> Other
- Earthquake -> standard Earthquake
- FallingObjects -> standard FallingObject
- Collision types (DirectCompensation, ChargeableAccident, LiabilityAndPhysicalDamage, LiabilityOnly, PhysicalDamageOnly, HitAndRun):
  - If minor accident (see criteria below): code 38 (MinorAtFaultCollision)
  - If PhysicalDamageOnly or ChargeableAccidentNotSpecified (not minor): CollisionOther
  - Otherwise: falls to generic base

### IsMinorAccident
**What it does**: Determines if a collision qualifies as "minor at-fault".
**Criteria** (ALL must be true):
- Claim date >= June 1, 2016
- All estimated payments (collision, TPL, comprehensive, AB, DCPD) are zero
- Amount paid is zero
- At-fault percentage >= 25%
- Insured payment fields are NOT empty (at least one has a value > 0)
- Total insured payment (collision + TPL PD by insured) <= $2,000

### ConvertToCsio (Hab/Property)
**What it does**: Maps property claim perils to CSIO cause of loss codes.
**Rules**:
- Fire -> FireDamageTotalLoss
- Smoke -> Other
- Wind -> WindHailCarriedSpray
- SurfaceWater -> 643
- ExteriorSewerLineBreakage -> 645
- ExteriorWaterLineBreakage -> 644
- GroundWater -> 646
- FloodWater -> 647
- WaterDamageInfiltration -> V130 WaterDamageInfiltration
- All other property perils: strip csio: prefix from generic result

---

## Rated Response Processing (CsioToFramework/Rated)

### IsDiscount / IsSurcharge
**What it does**: Classifies coverage codes as discounts or surcharges in rated responses.
**Rules**:
- Discount: code starts with "DIS" or "csio:DIS"
- Surcharge: code starts with "SUR" or "csio:SUR"

### ConvertFromPersVeh (Rated)
**What it does**: Processes vehicle-level coverage codes from rated response.
**Rules**:
- Prefixes csio: to coverage code if missing (less than 5 chars or no csio: prefix)
- csio:ABODO: AccidentBenefitsOccasionalDriver processing
- csio:UAODO: UninsuredMotoristOccasionalDriver processing
- All other codes: fall through to generic base

### ConvertDwellCoverage (Rated)
**What it does**: Processes dwelling-level coverage codes in rated response.
**Rules**:
- Coverage type values (DWELL, PP, OS, HSL, ARIB, ARAP, ARLA, LLLA, NPIB, NPLA, ALVE, CBLLA): treated as hab coverage items
- CPL, PL: treated as third-party liability
- CCLA, RCBLD: treated as additional hab coverage
- All other values: fall through to generic base

### ConvertAutoEndorsement (Rated, Alberta)
**What it does**: Special handling for Alberta auto endorsements.
**Rules**:
- Alberta (AB): custom endorsement conversion that checks for "NOT RATED" in description
- Non-Alberta: standard base conversion
- If endorsement description contains "NOT RATED": sets company field CoverageGiven = -1
- Otherwise: converts limit to CoverageText field

---

## Watercraft Rules

### ConvertToWatercraft
**What it does**: Converts watercraft items to CSIO coverage elements.
**Rules**:
- Coverage type CodeC (All Risks): all risks conversion
- BroadNamedPerils: broad named perils conversion
- CodeB (Named Perils): named perils conversion
- No coverage type: defaults to all risks
- Liability is sent separately via ConvertWatercraftLiability

### ConvertWatercraftLiability
**What it does**: Sends watercraft liability coverage.
**Rules**:
- JetSki: sends WatercraftLiabilityA + PersonalWatercraftPassengerHazardLiability
- Other watercraft: sends only WatercraftLiabilityA
