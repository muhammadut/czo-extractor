# Dominion Business Rules - CZO Extraction

**Carrier**: Dominion of Canada General Insurance (Travelers Canada)
**Version**: v043 (base, only version)
**Extracted**: 2026-03-22

---

## Coverage Code Converter (EnumConverters/CoverageCodeConverter.vb)

### TryConvertToCsioHabDiscount
**What it does**: Converts framework hab discount codes to CSIO coverage codes for outbound requests.
**When it runs**: When sending hab discount codes to Dominion.
**Rules**:
- If discount is SecuritySystem: use PremisesAlarmFireorIntrusionSystem (overrides generic HomeSecurity)
- All other discounts: fall back to generic base converter

### TryConvertToCsioHomeEndorsement
**What it does**: Converts framework home endorsement codes to CSIO coverage codes.
**When it runs**: When sending home endorsement data to Dominion.
**Rules**:
- If endorsement is GlassReducedDeductible: send GlassBreakage code (overrides generic GlassDeductibleEndorsement)
- If endorsement is GroundWaterEndorsement: send csio:GRNDW
- If endorsement is FloodEndorsement: send csio:OVWAT (overland water/flood)
- All other home endorsements: fall back to generic base converter

### TryConvertToCsioOntarioAutoEndorsement
**What it does**: Converts Ontario-specific auto endorsements to CSIO.
**When it runs**: When province is Ontario.
**Rules**:
- If endorsement is DrivingRecordProtectorClaims: send csio:39 (overrides generic ClaimsProtectionPlan)
- If endorsement is Opcf49: send csio:49
- All other Ontario endorsements: fall back to generic base converter

### TryConvertToCsioAutoEndorsement
**What it does**: Converts non-Ontario auto endorsements to CSIO.
**When it runs**: When province is NOT Ontario.
**Rules**:
- If endorsement is DrivingRecordProtectorClaims: send csio:39
- If endorsement is End39: send csio:39
- If endorsement is End8B: send standard End8 code
- If endorsement is End19B: send standard End19 code
- If endorsement is End28C: send standard End28 code
- If endorsement is End30B: send standard End30 code
- All other non-Ontario endorsements: fall back to generic base converter

### TryConvertToFrameworkAutoDiscount (response parsing)
**What it does**: Converts CSIO auto discount codes from response back to framework.
**When it runs**: When parsing Dominion responses.
**Rules**:
- If CSIO code is csio:DISSN (DiscountSnowTires): map to WinterTire discount
- If CSIO code is csio:DISTE (DiscountUsageBasedInsurance): map to UsageBasedInsurance discount
- All other discount codes: fall back to generic base converter

### TryConvertToCsioAutoDiscount
**What it does**: Converts framework auto discount codes to CSIO for outbound.
**When it runs**: When sending auto discount data to Dominion.
**Rules**:
- If discount is UsageBasedInsurance: send csio:DISTE
- All other discounts: fall back to generic base converter
- Note: WinterTire discount is NOT overridden here (uses generic csio:DISSN via CsioConstants)

### TryConvertToFrameworkHomeEndorsement (response parsing)
**What it does**: Parses home endorsement codes from Dominion response.
**Rules**:
- If CSIO code is csio:GRNDW: map to GroundWaterEndorsement
- All other home endorsements: fall back to generic base converter

### TryConvertToFrameworkAutoEndorsement (response parsing, non-Ontario)
**What it does**: Parses auto endorsement codes from Dominion response.
**Rules**:
- If CSIO code is csio:39: map to End39
- All other: fall back to generic base converter

### TryConvertToFrameworkOntarioAutoEndorsement (response parsing, Ontario)
**What it does**: Parses Ontario auto endorsement codes from Dominion response.
**Rules**:
- If CSIO code is csio:39: map to DrivingRecordProtectorClaims
- All other: fall back to generic base converter

---

## Accident Benefits (PcCoverageCollectionConverter.vb)

### ConvertAccidentBenefits
**What it does**: Sends Ontario increased accident benefits coverages based on effective date.
**When it runs**: When processing Ontario auto policies with increased accident benefits.
**Rules (post June 1, 2016)**:
- If MedicalAttendantCatastrophic is true: send csio:CATIM with limit $1,000,000
- If MedicalAttendantNonCatastrophic is true: send csio:MRB with limit $130,000
- If MedicalAttendantNonCatastrophic1M is true: send csio:CIMRB with limit $1,000,000

**Rules (pre June 1, 2016)**:
- If AttendantCare is true: send csio:ACB (no limit)
- If MedicalRehabilitation is true: send csio:MEDRH (no limit)
- If MedicalRehabilitationAndAttendantCare is true: send standard MedicalRehabAttendantCare

**Always (regardless of date)**:
- If Caregiver is true: send csio:CHHMB
- If DependantCare is true: send csio:DCB
- If IncomeReplacementCoverage > $400: send standard IncomeReplacement with the coverage amount
- If IndexationBenefit is true: send standard Indexation
- If DeathAndFuneral is true: send standard DeathAndFuneralBenefits

**Codes sent**: csio:CATIM, csio:MRB, csio:CIMRB, csio:ACB, csio:MEDRH, csio:CHHMB, csio:DCB

---

## Dwelling Coverage (PcCoverageCollectionConverter.vb)

### ConvertToDwell
**What it does**: Converts dwelling coverage including septic system and filtering out excluded endorsements.
**When it runs**: When processing habitational dwelling coverage.
**Rules**:
- Call base converter first, then add septic system if applicable
- If SepticTank field is true on the dwelling: add csio:ZSEPS coverage
- Remove Mass Evacuation and Single Limit endorsements from output (Dominion assumes these are included)

**Codes sent**: csio:ZSEPS (conditional)

### ConvertToWatercraft
**What it does**: Converts watercraft coverage.
**Rules**:
- Dominion watercrafts are always converted as All Risk (overrides base which checks risk type)

### ConvertToPersVeh
**What it does**: Converts personal vehicle coverage.
**Rules**:
- Call base converter, then for New Brunswick applications: add Health Services Levy coverage

---

## Sewer Backup Logic (PcCoverageConverter.vb)

### ConvertAdditionalResidenceSewerBackupEndorsement
**What it does**: Handles sewer backup endorsement for additional residences.
**Rules**:
- If SewerBackupLimit field exists and > 0: set coverage code to "SEWER" (no csio: prefix)
- If SewerBackup field exists with numeric value: set coverage code to "ZCWAT"
- Also converts the sewer backup location factor

### ConvertEndorsementLimit (Sewer Backup)
**What it does**: Handles limit calculation for sewer backup endorsements.
**Rules**:
- If Coverage field value = "Policy Limit": use the parent coverage value as the limit
- If Coverage field has a numeric value: use that as the limit
- If CoverageType field = "Policy Limit" or "Broad": use parent coverage value as limit

---

## Earthquake Logic (PcCoverageConverter.vb)

### ConvertEarthquakeLimit
**What it does**: Sets the earthquake coverage valuation type.
**Rules**:
- If EarthquakeCoverage = "Building Only": valuation code = "EB"
- Otherwise: valuation code = "EA" (Building and/or Contents)

---

## Endorsement Skip Rules (PcCoverageCollectionConverter.vb)

### SkipEndorsements
**What it does**: Determines which endorsements to skip based on province.
**When it runs**: Before converting vehicle endorsements.
**Rules**:
- Always skip: Opcf47, CondoExtension
- Alberta: skip End28A
- Nova Scotia: skip Pak endorsements (Pak03, Pak05, Pak06)
- New Brunswick: skip Pak endorsements AND End28A
- Ontario: skip Pak endorsements
- Prince Edward Island: skip Pak endorsements AND End28A
- When Pak endorsements are NOT skipped (AB, other provinces): send parent Pak and skip child endorsements

---

## Endorsement Limit Overrides (PcCoverageConverter.vb)

### ConvertEndorsementLimit
**What it does**: Handles special limit behavior for specific endorsements.
**Rules**:
- SewerBackup and BuildingBylawsExtension: suppress base limit conversion (no limit from base), then handle separately
- End19/Opcf19: clear limits, then set limit from PurchasePrice or ListPrice field
- End44/Opcf44: clear limits, then set limit from Liability field in company fields
- Earthquake: convert earthquake-specific limit (building only vs building+contents)
- End19B: set limit from StatedValue field
- All other endorsements: use base limit conversion

---

## Company Code Routing (CompanyCodeConverter.vb)

### TryConvertToCsio
**What it does**: Maps framework company codes to CSIO company codes by region.
**Rules**:
- IntactInsurance in Quebec (QC): use company code "GC"
- IntactInsurance in Atlantic (PE, NS, NL, NB): use company code "HAL"
- IntactInsurance in all other provinces: use company code "WU"
- UnicaInsurance: use standard YorkFire company code
- All other companies: fall back to generic converter

---

## Policy Type Converter (PolicyTypeConverter.vb)

### TryConvertHomeToCsio
**What it does**: Maps homeowner coverage types to CSIO policy types.
**Rules**:
- "Canadian Classic": HomeownersComprehensiveExpandedForm
- All others: fall back to generic

### TryConvertCondoToCsio
**Rules**:
- "Canadian" or "Canadian Classic": ComprehensiveCondominiumForm
- "Standard": CondominiumPackageStandardForm
- All others: fall back to generic

### TryConvertSeasonalToCsio
**Rules**:
- "Homeowners - Standard": HomeownersStandardForm
- "Homeowners - Special": BasicResidentialFireECForm
- "Homeowners - Broad": HomeownersBroadForm
- "Residence - Standard": SeasonalDwellingStandardForm
- Special / "Residence - Special" / "Special Form - Package": SeasonalDwellingBroadForm
- Standard / "Standard Form - Package": SeasonalDwellingStandardForm
- All others: fall back to generic

### TryConvertTenantToCsio
**Rules**:
- "Canadian" or "Canadian Classic": TenantsComprehensiveForm
- "Standard": TenantsPackageStandardForm
- All others: fall back to generic

### TryConvertFecToCsio (Fire/Extended Coverage)
**Rules**:
- Standard: BasicResidentialFireECForm
- Broad: BasicResidentialForm
- All others: fall back to generic

---

## Group Discount Routing (PcPolicyConverter.vb)

### ConvertGroupId
**What it does**: Sends group discount tier as GroupId on auto policies.
**When it runs**: For auto policies only.
**Rules**:
- Scans all coverage items for the GroupDiscount company field
- If a group discount exists and is not "No Discount":
  - "Group Discount 5%" sends GroupId = "DOC5"
  - "Group Discount 10%" sends GroupId = "DOC10"
  - "Group Discount 15%" sends GroupId = "DOC15"
  - "Group Discount 20%" sends GroupId = "DOC20"

---

## Telematics (PcCoverageCollectionConverter.vb)

### ConvertTelematicsCompanySpecificField
**What it does**: Sends telematics enrollment status as a company-specific field.
**When it runs**: When IQDetails coverage item exists for a driver.
**Rules**:
- Sets CompanyCd to Dominion
- Sets FieldCd to "TelematicsCurrentlyEnrolledInd"
- If driver enrollment status is Enrolled: Value = "True"
- Otherwise: Value = "False"

---

## Response Classification (CsioToFramework/Rated/PcCoverageConverter.vb)

### IsDiscount
**What it does**: Determines if a coverage code is a discount in Dominion responses.
**Rules**: Coverage code value after ":" must start with "DIS" (e.g., csio:DISSN, csio:DISTE)

### IsSurcharge
**What it does**: Determines if a coverage code is a surcharge in Dominion responses.
**Rules**: Coverage code value after ":" must start with "SUR"

---

## Other Notable Behaviors

### Loss Converter
- Loss cause codes have "csio:" prefix stripped before sending to Dominion
- Damage amounts are rounded to whole dollars (Dominion service faults on decimals)

### Cause of Loss (CauseOfLossConverter.vb)
**Auto claims**:
- AccidentBenefits: empty tag (no cause code sent)
- CollisionDirectCompensation: empty tag
- ChargeableAccidentNotSpecified: CollisionOther
**Hab claims**:
- SurfaceWater: 643
- ExteriorSewerLineBreakage: 645
- ExteriorWaterLineBreakage: 644
- GroundWater: 646
- FloodWater: 647

### Residence Type (ResidenceTypeConverter.vb)
- ApartmentBuilding for TravelersEssential: sends HighRise (not Apartment)
- ApartmentBuilding for Dominion: sends Apartment
- Fourplex/Fiveplex/Sixplex: sends Multiplex4unitsormore
- EndRowHouse/InsideRowHouse: sends RowHouseUnspecified

### Vehicle Body Type (VehicleBodyTypeConverter.vb)
- MinibikeTrailBikeOffRoad motorcycles: converted to Motorcyclesover50cc

### Wiring Type (WiringTypeCodeConverter.vb)
- If base converter returns "None" for wiring type: suppress it (return False)

### Language Code (LanguageCodeConverter.vb)
- Language code values are uppercased before sending

### Occupancy Type (OccupancyTypeConverter.vb)
- If no match found: falls back to Owner occupancy
- RentedToThirdParty is converted to Rental (Dominion only supports "Rental" for rented dwellings)

### Territory Code (DwellRatingConverter.vb - Outbound)
- "Territory " prefix is stripped from territory codes before sending

### Territory Code (DwellRatingConverter.vb - Inbound)
- Territory codes starting with "M" get "Metro " prefix added
- Other territory codes get "Table " prefix added (if not already containing "Table")

### DCPD Opt-Out Logic
- If OptOutDCPD flag is true on a vehicle: suppress DCPD, Collision, and AllPerils coverages
- If OptOutDCPD is false or not present: send normally
