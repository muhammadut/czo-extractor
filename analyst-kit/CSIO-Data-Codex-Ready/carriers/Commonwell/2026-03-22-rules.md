# Commonwell Mutual Insurance - CZO Business Rules

**Carrier**: Commonwell Mutual Insurance Group
**Version**: V134 (BAU - current active service)
**Extracted**: 2026-03-22

---

## Overview

Commonwell is a lightweight carrier with minimal carrier-specific code. It inherits the vast majority of its CZO/CSIO mappings from the Generic base (v043 through V134). The carrier has only 3 custom CompanyConstants and no proprietary Z-codes. Its customizations focus on fire protection classification, policy type form mappings, a few endorsement/liability overrides, and behavioral adjustments to address formatting, driver info, and loss payment handling.

---

## EnumConverter Rules

### CoverageCodeConverter

#### TryConvertToCsioHomeEndorsement
**What it does**: Maps framework home endorsement codes to CSIO coverage codes for outbound requests.
**When it runs**: When building the CSIO XML for a hab endorsement.
**Rules**:
- If endorsement = RoofDamageExclusionEndorsement: use V134 RoofReplacementCostValue property
- If endorsement = VandalismMaliciousActsExtensionEndorsement: use MaliciousDamageonBuilding property
- Otherwise: fall through to the Generic base mapping (v043)
**Codes sent**: V134 RoofReplacementCostValue, MaliciousDamageonBuilding

#### TryConvertToCsioHomeLiability
**What it does**: Maps framework liability codes to CSIO coverage codes for outbound requests.
**When it runs**: When building CSIO XML for a hab liability extension.
**Rules**:
- If liability = PremisesLiabilityRestriction: use V134 PremisesCoverageLimitation property
- If liability = FosterCareLiability: use V134 FosterCareHomeExtension property
- Otherwise: fall through to Generic base mapping (v043)
**Codes sent**: V134 PremisesCoverageLimitation, FosterCareHomeExtension

#### TryConvertToFrameworkHomeEndorsement (inbound)
**What it does**: Maps CSIO coverage codes from responses back to framework endorsement codes.
**When it runs**: When parsing inbound CSIO XML responses.
**Rules**:
- If CSIO code = V134 PremisesCoverageLimitation: map to LiabilityCodes.PremisesLiabilityRestriction
- If CSIO code = V134 FosterCareHomeExtension: map to LiabilityCodes.FosterCareLiability
- If CSIO code = V134 RoofReplacementCostValue: map to EndorsementCodes.RoofDamageExclusionEndorsement
- If CSIO code = MaliciousDamageonBuilding: map to EndorsementCodes.VandalismMaliciousActsExtensionEndorsement
- Otherwise: fall through to Generic base mapping
**Note**: The first two liabilities (PremisesCoverageLimitation, FosterCareHomeExtension) are checked before the endorsement codes in the Select Case block.

#### TryConvertToFrameworkAutoEndorsement (inbound, non-Ontario)
**What it does**: Maps CSIO auto endorsement codes from responses to framework codes for non-Ontario provinces.
**When it runs**: When parsing inbound auto endorsement responses outside Ontario.
**Rules**:
- If CSIO code = End13C value: map to EndorsementCodes.End13C
- Otherwise: fall through to Generic base mapping
**Note**: This override ensures End13C is correctly handled for non-Ontario in Commonwell responses.

### PolicyTypeConverter

#### TryConvertToCsio (main entry point)
**What it does**: Routes policy type conversion based on coverage item code.
**When it runs**: For every hab coverage item conversion.
**Rules**:
- First checks if the limit has been increased (via insco fields and endorsement codes)
- If coverage item = COVITEM_RENTEDCONDO: route to TryConvertRentedCondoToCsio
- If coverage item = COVITEM_RENTEDDWELLING: route to TryConvertRentedDwellingToCsio
- Otherwise: fall through to base V118 Generic converter

#### TryConvertRentedCondoToCsio
**What it does**: Maps rented condo coverage types to CSIO policy types.
**Rules**:
- If coverage type = LimitedForm: use CondominiumPackageLimitedForm
- Otherwise: return false (not supported)

#### TryConvertRentedDwellingToCsio
**What it does**: Maps rented dwelling coverage types to CSIO policy types.
**Rules**:
- If coverage type = LimitedForm: use RentedDwellingLimitedForm
- Otherwise: return false

#### TryConvertCondoToCsio
**What it does**: Maps condo coverage types to CSIO policy types.
**Rules**:
- If coverage type = SecurityPlusComp: use CondominiumComprehensiveExpandedForm
- Otherwise: return false

#### TryConvertFecToCsio
**What it does**: Maps FEC (Farm/Estate/Country) coverage types to CSIO policy types.
**Rules**:
- If coverage type = LimitedForm: use RentedDwellingLimitedForm
- Otherwise: return false
**Note**: FEC Limited Form is mapped to the same CSIO code as Rented Dwelling Limited Form.

#### TryConvertHomeToCsio
**What it does**: Maps homeowner coverage types to CSIO policy types.
**Rules**:
- HomeBroadForm -> HomeownersBroadForm
- SelectCottageLimitedForm -> SeasonalDwellingStandardForm
- HomeStandardForm -> HomeownersStandardForm
- SecurityPlusComp -> HomeownersComprehensiveForm
- Otherwise: return false

#### TryConvertMobileHomeToCsio
**What it does**: Maps mobile home coverage types to CSIO policy types.
**Rules**:
- StandardForm -> MobileHomeStandardForm
- LimitedForm -> MobileHomeLimitedForm
- Otherwise: return false

#### TryConvertSeasonalToCsio
**What it does**: Maps seasonal dwelling coverage types to CSIO policy types.
**Rules**:
- SelectCottageLimitedForm -> SeasonalDwellingStandardForm
- LimitedForm -> SeasonalDwellingLimitedForm
- SeasonalComprehensiveForm -> SeasonalDwellingComprehensiveForm
- SeasonalBroadForm -> SeasonalDwellingBroadForm
- Otherwise: return false

#### TryConvertTenantToCsio
**What it does**: Maps tenant coverage types to CSIO policy types.
**Rules**:
- StandardForm -> TenantsPackageStandardForm
- SecurityPlusComp -> V123 BasicResidentialComprehensiveForm
- Otherwise: return false

#### TryConvertToFramework (inbound)
**What it does**: Maps CSIO policy types back to framework coverage types from responses.
**Rules**:
- HomeownersBroadForm -> HomeBroadForm
- SeasonalDwellingStandardForm -> SelectCottageLimitedForm
- HomeownersStandardForm -> HomeStandardForm
- HomeownersComprehensiveForm OR V123 BasicResidentialComprehensiveForm -> SecurityPlusComp
- MobileHomeStandardForm OR TenantsPackageStandardForm -> StandardForm
- MobileHomeLimitedForm OR SeasonalDwellingLimitedForm OR CondominiumPackageLimitedForm OR RentedDwellingLimitedForm -> LimitedForm
- SeasonalDwellingComprehensiveForm -> SeasonalComprehensiveForm
- SeasonalDwellingBroadForm -> SeasonalBroadForm
- Otherwise: return false

### CompanyCodeConverter

#### TryConvertToCsio
**What it does**: Maps framework company names to CSIO company codes.
**Rules**:
- If company name = "No Previous Insurance": use CSIO code "NONE"
- Otherwise: fall through to V134 Generic mapping

### ExteriorWallMaterialCodeConverter

#### TryConvertToCsio
**What it does**: Maps framework exterior wall material field names to CSIO types.
**Rules**:
- If field = OutsideWallCoveringLog: use V132 ConstructionTypeValues().Log code
- Otherwise: fall through to V132 Generic mapping

#### TryConvertToFramework (inbound)
**What it does**: Maps CSIO exterior wall material types back to framework field names.
**Rules**:
- If CSIO value matches ConstructionTypeValues().Log: map to OutsideWallCoveringLog
- Otherwise: fall through to base mapping

### OccupancyTypeConverter

#### TryConvertToCsio
**What it does**: Maps dwelling occupancy information to CSIO occupancy types.
**Rules**:
- If dwelling is under construction: set occupancy to UnderConstruction
- Else if dwelling is a tenant dwelling (determined by IsDwellingTenant check): set occupancy to RentedToThirdParty
- If neither condition applies (csioValue is still empty): fall through to v043 Generic base

---

## FrameworkToCsio Converter Rules

### BldgProtectionConverter

#### ConvertDistanceToHydrant
**What it does**: Sets the distance-to-hydrant measurement on the building protection element.
**Rules**:
- If HydrantProtectionHab field exists and is true: set distance to 300 meters (within range)
- If HydrantProtectionHab field exists and is false: set distance to 301 meters (out of range)
**Note**: 300m is the threshold - at or under means protected.

#### ConvertFireProtectionClassCd
**What it does**: Determines fire protection classification (Protected vs Unprotected).
**Rules**:
- Step 1: Check RespondingFirehallHab field
  - If value = ProtectedUrban: fireProtected = true
  - If value is a valid numeric distance: fireProtected = true
  - Otherwise: fireProtected stays false
- Step 2: If still not protected, check HydrantProtectionHab
  - If hydrant within 300m: fireProtected = true
- Step 3: Set the code
  - If fireProtected = true: use CompanyConstants.CompanyValue.FireHallProtected ("P")
  - If fireProtected = false: use CompanyConstants.CompanyValue.FireHallUnprotected ("U")
**Codes sent**: "P" or "U" as FireProtectionClassCd

### DwellConverter

#### ConvertBusinessOnPremisesCd
**What it does**: Sets the business-on-premises classification for the dwelling.
**Rules**:
- Iterate through all endorsements on the coverage item
- If an endorsement has code = HomeBasedBusiness:
  - Get the HomeBusinessType field value from the endorsement's company fields
  - Convert it using MercantileBusinessTypeConverter to a CSIO MercantileBusinessType
  - Set it as the BusinessOnPremisesCd on the dwelling output

#### ConvertNumEmployeesFullTimeResidence
**What it does**: Sets the number of full-time employees at the residence.
**Rules**:
- Read HowManyFullTimeEmployees field from the coverage item
- If it exists: set NumEmployeesFullTimeResidence on the output

### DwellOccupancyConverter

#### ConvertOwnerOccupiesUnitInd
**What it does**: Sets whether the owner occupies the unit.
**Rules**:
- Read the Occupancy field from the coverage item
- If occupancy = Owner: set OwnerOccupiesUnitInd to true
- Otherwise: do not set the indicator (leave it unset)
**Note**: Only sets true, never explicitly sets false.

### PcCoverageCollectionConverter

#### ConvertAccidentBenefits
**What it does**: Sends accident benefits as a standalone PCCOVERAGE element.
**Rules**:
- Creates a new PCCOVERAGE element
- Delegates to the pcCoverageConverter to populate it with AB data
- Adds it to the output collection
**Note**: This is different from Generic which may not add AB as a standalone element.

#### ConvertUninsuredAutomobile
**What it does**: Sends uninsured automobile coverage as a standalone element.
**Rules**:
- Creates a new PCCOVERAGE element
- Sets CoverageCd to the standard UninsuredAutomobile CSIO code
- Adds it to the output collection

### LossPaymentCollectionConverter

#### Convert
**What it does**: Maps individual claim payment types to CSIO coverage codes for loss payment reporting.
**Rules**:
- First calls base Convert (from V118 Generic)
- If AccidentBenefitsPayment or EstimatedAccidentBenefitsPayment is non-zero:
  - Create payment with AccidentBenefits coverage code
- If CollisionPayment or EstimatedCollisionPayment is non-zero:
  - Create payment with Collision coverage code
- If ComprehensivePayment or EstimatedComprehensivePayment is non-zero:
  - Create payment with PropertyDamage coverage code (Note: comprehensive maps to PropertyDamage)
- If ThirdPartyLiabilityPayment or EstimatedThirdPartyLiabilityPayment is non-zero:
  - Create payment with BodilyInjury coverage code
- If none of the above categories had payments but AmountPaid or EstimatedLossAmount is non-zero:
  - Create a generic payment without a coverage code

### PersDriverInfoConverter

#### ConvertSuspensionRevocationDt
**What it does**: Sets suspension/revocation date from driver lapse records.
**Rules**:
- Iterate through person's lapses
- For lapses of type InsuranceAndLicenseLapse or LicenseLapse:
  - If lapse has a date: set SuspensionRevocationDt to that date

#### ConvertSuspensionRevocationReasonCd
**What it does**: Sets suspension reason code from driver lapse records.
**Rules**:
- Same iteration pattern as above
- For InsuranceAndLicenseLapse or LicenseLapse with a date:
  - Convert lapse reason to CSIO code using suspensionReasonCodeConverter

#### ConvertReinstatementDt
**What it does**: Sets reinstatement date from driver lapse records.
**Rules**:
- Same iteration pattern
- For InsuranceAndLicenseLapse or LicenseLapse:
  - If lapse has an expiry date: set ReinstatementDt to that date

### PersVehConverter

#### ConvertCoverage
**What it does**: Extends base vehicle coverage conversion.
**Rules**:
- First calls base ConvertCoverage (from V133 Generic)
- Then additionally calls ConvertAccidentBenefits on the PcCoverageCollectionConverter
  - This adds the AB coverage collection to the vehicle's coverage list

#### ConvertAlternateDrivingStateProvUsePct
**What it does**: Sets US exposure percentage on the vehicle.
**Rules**:
- Read UsExposure field from coverage item
- If it exists: set AlternateDrivingStateProvUsePct to that percentage

#### ConvertOdometerReading
**What it does**: Sets odometer reading on the vehicle.
**Rules**:
- Read Odometer field from coverage item
- If it exists: set OdometerReadingAtPurchase in kilometers

### AddrConverter

#### ConvertLegalAddress / Convert
**What it does**: Formats addresses for Commonwell's expected format.
**Rules**:
- Call base conversion first
- Remove DetailAddr element (Commonwell does not use structured address components)
- Build a simple address from components (suite, street num, name, type, direction, lot, block, plan)
- Clear LegalAddr (set to Nothing)

#### ConvertAddressTypeCd
**What it does**: Sets address type code for legal addresses.
**Rules**:
- Always add PrimaryPrincipal as the address type

### PhoneInfoCollectionConverter

#### ConvertPolicyPhoneInfo
**What it does**: Maps phone numbers with proper CSIO type and use codes.
**Rules**:
- Phone1 (home phone): PhoneType=Phone, CommunicationUse=Home
- Phone2 (business phone): PhoneType=Phone, CommunicationUse=Business
- CellPhone: PhoneType=Cell, CommunicationUse=Home
- Fax: PhoneType=Fax, CommunicationUse=Business
- Each phone is only added if it passes the IsPhoneNumberValid check

---

## CsioToFramework Converter Rules

### PcVehConverter (Unrated)

#### ConvertTowingVehInd
**What it does**: Handles towing vehicle indicator from CSIO responses.
**Rules**:
- If towingVehInd is not Nothing AND its value is true:
  - Set the TowingVehicleID field on the output coverage item

---

## IdConverter Rules

### Fixed ID Generation
**What it does**: Generates deterministic fixed IDs for various entity types.
**Rules**:
- InsuredOrPrincipal: prefix "2" + random 3-digit number (4 chars total)
- Loss: prefix "3" + random 3-digit number
- Location: prefix "4" + random 3-digit number
- PcBasicDriver: prefix "5" + random 3-digit number
- PcBasicVeh: prefix "6" + random 3-digit number
- PcBasicWatercraft: prefix "7" + random 3-digit number
- Each generated ID is checked for uniqueness in a collection of 200 slots

### GetCsioCoverageId / GetCsioEndorsementId
**What it does**: Gets CSIO IDs for coverages and endorsements.
**Rules**:
- Uses GetCoverageCsioIdRefMapping with the coverage code
- Does NOT use parentId for the mapping (passes Nothing)
