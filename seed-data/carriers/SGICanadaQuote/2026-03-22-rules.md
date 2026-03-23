# SGICanadaQuote Business Rules

Extracted: 2026-03-22
Versions: v043, V126, V133, V134, V135 (latest)

---

## Coverage Code Converter (CoverageCodeConverter.vb)

### TryConvertToCsioHomeEndorsement
**What it does**: Converts framework home endorsement codes to CSIO coverage codes for outbound requests.
**When it runs**: When building a hab coverage XML and an endorsement is present on the policy.
**Rules**:
- If endorsement = EquipmentBreakdownCoverage: send standard PowerFluctuation code
- If endorsement = SolidFuelWarranty: send csio:ZSFW
- If endorsement = ServiceLineCoverage: send csio:SLEXT
- If endorsement = BearDamage: send standard DamageCausedbyWildLife code
- If endorsement = WaterCoverage: send standard FloodDamage code
- If endorsement = CondoDeductibleAssessment: send csio:ZDBU
- If endorsement = ClaimsProtector: send standard ClaimFreeProtection code
- If endorsement = LegalExpense (v043 only): send standard LegalAssistance code
- Otherwise: delegate to generic base converter
**Codes sent**: csio:ZSFW, csio:SLEXT, csio:ZDBU, plus standard codes

### TryConvertToFrameworkHomeEndorsement
**What it does**: Converts incoming CSIO coverage codes back to framework endorsement codes.
**When it runs**: When parsing a response from SGI and identifying endorsements.
**Rules**:
- If code is csio:ZLIFA, csio:ZLIFB, csio:ZLIFC, or csio:ZLIFD: map to SpecialLimitsEnhancement
- If code is standard PowerFluctuation: map to EquipmentBreakdownCoverage
- If code is csio:ZSFW: map to SolidFuelWarranty
- If code is csio:SLEXT: map to ServiceLineCoverage
- If code is standard FloodDamage: map to WaterCoverage
- If code is csio:ZDBU: map to CondoDeductibleAssessment
- If code is standard ClaimFreeProtection: map to ClaimsProtector
- If code does not start with "csio:" prefix, prepend it before matching
**Codes handled**: csio:ZLIFA, csio:ZLIFB, csio:ZLIFC, csio:ZLIFD, csio:ZSFW, csio:SLEXT, csio:ZDBU

### TryConvertToCsioOntarioAutoEndorsement
**What it does**: Maps Ontario-specific auto endorsements to CSIO codes.
**When it runs**: When province is Ontario and auto endorsements are present.
**Rules**:
- If endorsement = DrivingRecordProtectorClaims: send csio:ZAFW
- If endorsement = Opcf49 (V135 only): send csio:49
- Otherwise: delegate to generic base
**Codes sent**: csio:ZAFW, csio:49

### TryConvertToCsioAutoEndorsement (V135)
**What it does**: Maps non-Ontario auto endorsements to CSIO codes (added V134+).
**When it runs**: For non-Ontario auto endorsements.
**Rules**:
- End19A maps to csio:19A (via V134 ICoveragesValues interface)
- End19B maps to csio:19
- End5B maps to csio:5
- End28C maps to csio:28
- End39A maps to csio:39
- End30B maps to csio:30
- Otherwise: delegate to generic base
**Codes sent**: csio:19A, csio:19, csio:5, csio:28, csio:39, csio:30

### TryConvertToFrameworkAutoDiscount (V135)
**What it does**: Maps incoming auto discount codes to framework.
**When it runs**: When parsing auto discount from response.
**Rules**:
- If code = csio:DISCR: map to CreditScore discount
- Otherwise: delegate to base
**Codes handled**: csio:DISCR

### TryConvertToFrameworkAutoSurcharge
**What it does**: Maps incoming auto surcharge codes to framework.
**When it runs**: When parsing auto surcharge from response.
**Rules**:
- If code = csio:SURC2: map to ClaimConviction surcharge
- If code does not start with "csio:", prepend prefix before delegating to base
**Codes handled**: csio:SURC2

### TryConvertToCsioHomeLiability
**What it does**: Maps home liability codes.
**When it runs**: When hab liability coverage is being sent.
**Rules**:
- AdditionalResidenceCondo, AdditionalResidenceHouse, AdditionalResidenceTenant, RentedCondo, RentedDwelling all map to standard AdditionalResidencesPropertiesAcreage code
- Otherwise: delegate to generic base

---

## Policy Type Converter (PolicyTypeConverter.vb)

### TryConvertHomeToCsio
**What it does**: Determines the CSIO policy type code for homeowner policies.
**When it runs**: When building outbound hab policy XML.
**Rules**:
- Pak A: HomeownersLimitedForm
- Pak B: HomeownersBroadForm. If limit increased AND province is NOT MB, use HomeownersBroadExpandedForm
- Pak I: HomeownersStandardForm. If limit increased, use HomeownersStandardExpandedForm
- Pak II (Ontario): HomeownersBroadForm or BroadExpandedForm if limit increased
- Pak II (Other): HomeownersBroadReverseForm. If limit increased AND not MB, use BroadReverseExpandedForm
- Pak III (Ontario): HomeownersComprehensiveForm or ComprehensiveExpandedForm if limit increased
- Pak III (Other): HomeownersComprehensiveForm. If limit increased AND not MB, use ComprehensiveExpandedForm
- Pak B Plus: always HomeownersBroadExpandedForm
- Pak I Plus: always HomeownersStandardExpandedForm
- Pak II Plus: always HomeownersBroadReverseExpandedForm
- Pak III Plus: always HomeownersComprehensiveExpandedForm
- Code A: csio:72 (Basic Residential Standard Form)
- Code AE: BasicResidentialFireECForm
- Code B: BasicResidentialForm
- Code C: csio:75 (Basic Residential Comprehensive Form)
- Code H: csio:75 (Basic Residential Comprehensive Form)
- Prestige: HomeownersInsuranceMinimumProtection

### TryCheckLimitIncreased
**What it does**: Determines if limits have been increased (triggers "Expanded" form).
**When it runs**: Before selecting policy type.
**Rules**:
- Returns true if SpecialLimitsEnhancement endorsement is present in the endorsement collection
- Also returns true if the "SpecialLimitsEnhancement" company field equals "Yes"

### TryConvertTenantToCsio
**What it does**: Maps tenant policy types.
**Rules**:
- Pak A: TenantsPackageLimitedForm
- Pak I: TenantsPackageBroadForm. If limit increased AND not MB: csio:1A (TenantsBroadExpanded)
- Pak II: TenantsComprehensiveForm. If limit increased AND not MB: TenantsComprehensiveExpandedForm
- Special Senior's Pak: TenantsSeniorsPackage

### TryConvertCondoToCsio
**What it does**: Maps condo policy types.
**Rules**:
- Pak A: CondominiumPackageLimitedForm
- Pak I: CondominiumPackageBroadForm. If limit increased: CondominiumBroadExpandedForm
- Pak II: ComprehensiveCondominiumForm. If limit increased: CondominiumComprehensiveExpandedForm

### TryConvertSeasonalToCsio
**What it does**: Maps seasonal dwelling policy types.
**Rules**:
- Code A: csio:72
- Code B: BasicResidentialForm
- Code C: csio:75
- Pak A: SeasonalDwellingLimitedForm
- Pak B: SeasonalDwellingBroadForm
- Pak I: SeasonalDwellingStandardForm
- Pak II: SeasonalDwellingBroadReverseForm
- Pak III: SeasonalDwellingComprehensiveForm

### Farm Policy Handling
**What it does**: Farm policies use the same converter as their equivalent dwelling type.
**Rules**: Framework farm policy type is mapped to its equivalent dwelling type via PolicyTypeHelper before standard conversion.

---

## PcCoverageCollectionConverter (FrameworkToCsio/Unrated)

### ConvertSpecialLimitsEnhancement
**What it does**: Converts the SpecialLimitsEnhancement endorsement differently for Prestige vs other coverage types.
**When it runs**: When a SpecialLimitsEnhancement endorsement is on a dwelling.
**Rules**:
- If parent coverage type = "Prestige": parse the pipe-delimited CoverageOptions field (e.g., "Option A (Business)|Option B (Collectibles & Treasures)"), and for each option generate a separate PCCOVERAGE with the matching Lifestyle code (csio:ZLIFA, csio:ZLIFB, csio:ZLIFC, csio:ZLIFD)
- If NOT Prestige: send standard EnhancedInternalLimits code
**Codes sent**: csio:ZLIFA, csio:ZLIFB, csio:ZLIFC, csio:ZLIFD, or standard EnhancedInternalLimits

### ConvertEquipmentBreakdownandServiceLineCoverage
**What it does**: Splits the combined EquipmentBreakdown+ServiceLine endorsement into two separate coverages.
**When it runs**: When EquipmentBreakdownandServiceLineCoverage endorsement is present.
**Rules**:
- Creates one PCCOVERAGE with standard PowerFluctuation code
- Creates a second PCCOVERAGE with csio:SLEXT (ServiceLineCoverage)
- Both share the same deductible from the endorsement
**Codes sent**: standard PowerFluctuation, csio:SLEXT

### ConvertCommercialExposureSurchargeCoverage
**What it does**: Sends a commercial exposure surcharge based on building type (tenant policies only).
**When it runs**: When a tenant dwelling has a CommercialBuildingType field.
**Rules**:
- None: no surcharge sent
- Bank, Office: send csio:SUREL (Low)
- Store: send csio:SUREM (Medium)
- Garage, Restaurant: send csio:SUREH (High)
**Codes sent**: csio:SUREL, csio:SUREM, csio:SUREH

### ConvertRightHandDriveVehicleSurcharge
**What it does**: Adds surcharge for right-hand drive vehicles.
**When it runs**: When vehicle SteeringWheelPosition = "Right".
**Rules**:
- Send csio:SURRH surcharge coverage
**Codes sent**: csio:SURRH

### ConvertIPromiseProgram
**What it does**: Sends the iPromise program discount indicator for all vehicles.
**When it runs**: Always for each vehicle (always sends, with Yes/No indicator).
**Rules**:
- If iPromise field = true: send OptionBenefit = YesNoIndicator1
- If iPromise field = false: send OptionBenefit = YesNoIndicator2
**Codes sent**: standard DiscountIPromiseProgramParentTeenMutualSafeDrivingContract

### SkipEndorsements
**What it does**: Determines which endorsements to skip based on coverage type.
**Rules**:
- BearDamage is SKIPPED if coverage type is NOT Pak I, Pak II, Pak I Plus, or Pak II Plus
- All other endorsements pass through

---

## PcCoverageConverter (FrameworkToCsio/Unrated)

### ConvertEndorsementLimit
**What it does**: Determines how to calculate the limit sent with each endorsement.
**Rules**:
- SewerBackup: tries CoverageType field first, then Coverage, then SewerBackup field. If value = "Policy Limit", uses the parent dwelling Coverage value.
- End30B, End5B, End19B: uses StatedValue field first, falls back to Coverage company field
- Opcf44/End44: uses parent Liability field
- Earthquake: uses custom calculation (dwelling amount * personal property percent)

### ConvertEarthquakeLimit
**What it does**: Calculates earthquake limit based on coverage option.
**Rules**:
- DwellingAndPersonalProperty or DwellingAnd0PercentPersonalProperty: limit = dwelling * 1.0
- DwellingAnd75PercentPersonalProperty: limit = dwelling * 0.75
- DwellingAnd50PercentPersonalProperty: limit = dwelling * 0.5
- DwellingAnd25PercentPersonalProperty: limit = dwelling * 0.25

### ConvertEndorsementCoverageDesc
**What it does**: Sets the CoverageDesc text for earthquake endorsements.
**Rules**:
- If earthquake coverage = "100% dwelling, 0% personal property": description = "Earthquake - Dwelling"
- All other earthquake options: description = "Earthquake - Belongings"

### ConvertHabCoverage (V135 override)
**What it does**: Override for condo and tenant dwelling coverage codes.
**Rules**:
- For Condo and Tenant policy types: dwelling coverage code = PersonalPropertyHomeownersForm (instead of standard DWELL)

---

## CsioToFramework Rated PcCoverageConverter

### IsDiscount / IsSurcharge
**What it does**: Classifies response coverage codes as discounts or surcharges.
**Rules**:
- Discount: code starts with "DIS" or "csio:DIS"
- Surcharge: code starts with "SUR" or "csio:SUR"

### ConvertFromPersVeh
**What it does**: Processes vehicle-level coverages from rated response.
**Rules**:
- If coverage code does not start with "csio:", prepend the prefix
- csio:ABODO: convert as Accident Benefits Occasional Driver
- csio:UAODO: convert as Uninsured Motorist Occasional Driver
- Other codes: delegate to base

### ConvertDwellCoverage
**What it does**: Routes dwelling coverage codes to appropriate conversion logic.
**Rules**:
- DWELL, PP, OS, HSL, PL, ARIB, ARAP, ARLA, LLLA, NPIB, NPLA, ALVE: all treated as hab coverage items with specific field mappings
- Other codes: delegate to base

### ConvertDwellingEndorsement
**What it does**: Handles lifestyle option endorsement premium aggregation.
**Rules**:
- csio:ZLIFA, csio:ZLIFB, csio:ZLIFC, csio:ZLIFD: if a SpecialLimitsEnhancement endorsement already exists, add the premium to it. This aggregates multiple lifestyle options into one endorsement.
- Other endorsements: delegate to base

### ConvertDiscountSurcharge
**What it does**: Routes discount/surcharge codes during rated response parsing.
**Rules**:
- ZPMSB (PreventativeMeasures): treated as a discount
- Other codes: delegate to base

---

## CsioToFramework Unrated PcCoverageConverter

### ConvertFromLineBusiness
**What it does**: Converts increased accident benefit codes.
**Rules**:
- csio:ACB: AttendantCare = true
- csio:DCB: DependantCare = true
- csio:MEDRH: MedicalRehabilitation = true

### ConvertFromDwell
**What it does**: Prevents duplicate SpecialLimitsEnhancement endorsements.
**Rules**:
- If coverage code is csio:ZLIFA, csio:ZLIFB, csio:ZLIFC, or csio:ZLIFD AND a SpecialLimitsEnhancement endorsement already exists in output: skip (return without processing)
- Otherwise: delegate to base

---

## Cause of Loss Converter

### ConvertToCsio (Auto claims)
**What it does**: Maps framework claim perils to SGI-specific cause of loss codes.
**Rules**:
- Ontario only: check if claim ID is in MinorAccidentIds for any vehicle. If yes: cause = 38 (MinorAtFaultCollision)
- AccidentBenefits, CollisionDirectCompensation, ChargeableAccidentNotSpecified, CollisionPhysicalDamageOnly, CollisionLiabilityOnly, CollisionLiabilityAndPhysicalDamage, CollisionWildlife: cause = 8 (CollisionOther)
- Earthquake, Explosion, FallingObjects, Other: cause = 999 (Other)
- Fire: cause = 16
- GlassStoneChipRepair: cause = 18
- Smoke: cause = 999 (Other)
- Theft: standard TheftEntireVehicle code
- Liability: cause = 103 (LiabilityAccidentCircumstances)
- V135 addition: CollisionWildlife now overrides to cause = 3 (regardless of the case above)

### ConvertToCsio (Hab claims)
**Rules**:
- SurfaceWater: 643
- ExteriorSewerLineBreakage: 645
- ExteriorWaterLineBreakage: 644
- GroundWater: 646
- FloodWater: 647
- Other: delegate to base, strip "csio:" prefix from result

---

## Version Differences (V135 vs V134)

### Added in V135
- **CompanyConstants**: Added CompanySpecificConstants.CollisionWildlife = "3", CreditScoreDiscount = "csio:DISCR", OPCF49 = "csio:49", PPV = 1
- **CoverageCodeConverter**: Added TryConvertToFrameworkAutoDiscount (maps csio:DISCR to CreditScore). Added OPCF49 mapping in TryConvertToCsioOntarioAutoEndorsement. Added 6 new auto endorsement mappings (End19A/B, End5B, End28C, End39A, End30B). LegalExpense endorsement REMOVED from TryConvertToCsioHomeEndorsement.
- **CauseOfLossConverter**: V135 adds override for CollisionWildlife peril (sets cause = "3" after all other logic runs)
- **NatureOfInterestConverter**: New in V135 - maps Assignee to Lienholder
- **CsioToFramework/Unrated/LossConverter.vb**: New in V135
- **FrameworkToCsio/Unrated/PhoneInfoCollectionConverter.vb**: New in V135
- **FrameworkToCsio/Unrated/VehicleAlterationsInfoConverter.vb**: New in V135
- **PostalInstallationConstants**: Added Station = "S", RetailPostalOutlet = "R"
