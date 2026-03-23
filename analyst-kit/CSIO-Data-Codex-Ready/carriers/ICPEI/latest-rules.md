# ICPEI Business Rules - CZO/CSIO Converter

Extracted: 2026-03-22
Version: V146 (only version)
Inheritance: V146 ICPEI -> V145 Generic -> V137 Generic -> V136 Generic -> V133 Generic -> V128 Generic -> V043 Generic

## Key Characteristic

ICPEI uses exclusively standard CSIO codes. There are zero proprietary Z-codes. All code mappings come from the standard XML enum factory interfaces.

---

## Auto Coverage Rules

### ConvertDeductibleType (PcCoverageConverter)
**What it does**: Sets the deductible type to "Flat" for physical damage coverages.
**When it runs**: When converting any auto coverage to CZO format.
**Rules**:
- If coverage is AllPerils (csio:AP), Collision (csio:COL), Comprehensive (csio:CMP), or SpecifiedPerils (csio:SP): deductible type = Flat
- For all other coverages: no deductible type is sent

### ConvertEndorsementEffectiveDt (PcCoverageConverter)
**What it does**: Sends the CalculationDate as the endorsement effective date.
**When it runs**: When converting any endorsement.
**Rules**:
- If the coverage item has a CalculationDate dynamic field, send it as the EffectiveDt on the endorsement
- If no CalculationDate, no effective date is sent

### ConvertEndorsementLimit (PcCoverageConverter)
**What it does**: Overrides how limits are set for OPCF44/End44 endorsements.
**When it runs**: When converting endorsement limits.
**Rules**:
- If endorsement is Opcf44 or End44: take the limit from the Liability company field (not the standard limit field)
- For all other endorsements: use the standard Generic base limit logic

### ConvertCostNewAmt (PcVehConverter)
**What it does**: Gets the vehicle cost from the OPCF19/End19 endorsement's StatedValue.
**When it runs**: When converting the CostNewAmt for a vehicle.
**Rules**:
- Scan all endorsements for OPCF19 or End19
- If found and the endorsement belongs to this vehicle, use the StatedValue field as CostNewAmt
- If no OPCF19/End19 endorsement or StatedValue is zero: fall back to Generic base logic

---

## Vehicle Coverage Collection Rules

### IsVehicleEligibleForLiabilityCoverages (PcCoverageCollectionConverter)
**What it does**: Checks if a vehicle should receive liability coverages.
**When it runs**: Before adding liability coverages to a vehicle.
**Rules**:
- The Liability company field must have a value greater than 0
- If no Liability value or Liability = 0: the vehicle does NOT get liability coverages
- If Liability > 0: also check the Generic base eligibility rules

### ConvertTPL (PcCoverageCollectionConverter / CommlCoverageCollectionConverter)
**What it does**: Suppresses Third Party Liability output.
**When it runs**: When the Generic base would normally send a TPL coverage.
**Rules**:
- TPL is NOT sent for either personal or commercial vehicles
- The method body is empty, meaning TPL is completely suppressed

### ConvertAccidentBenefits (PcCoverageCollectionConverter / CommlCoverageCollectionConverter)
**What it does**: Sends a simplified Accident Benefits coverage.
**When it runs**: When adding Accident Benefits to a vehicle.
**Rules**:
- Sends csio:AB as a simple coverage element with no limit/deductible/premium
- Same behavior for both personal and commercial vehicles
**Codes sent**: csio:AB

### ConvertUninsuredAutomobile (PcCoverageCollectionConverter / CommlCoverageCollectionConverter)
**What it does**: Sends a simplified Uninsured Automobile coverage.
**When it runs**: When adding Uninsured Automobile to a vehicle.
**Rules**:
- Sends csio:UA as a simple coverage element with no amount
**Codes sent**: csio:UA

---

## Auto Endorsement Mapping (CoverageCodeConverter)

### TryConvertToCsioAutoEndorsement
**What it does**: Maps framework endorsement codes to CSIO codes (outbound, non-Ontario).
**When it runs**: When building the CZO request for an endorsement.
**Rules (ICPEI-specific overrides)**:
- End8B -> csio:8 (maps to standard End8)
- End19B -> csio:19 (maps to standard End19)
- End28C -> csio:28 (maps to standard End28)
- End30B -> csio:30 (maps to standard End30)
- End5B -> csio:5B
- End21B -> csio:21B
- AccessoriesExtension -> csio:37 (maps to standard End37)
- End39 -> csio:39
- All other endorsements: fall through to Generic base (V145 -> V137 -> v043)

### TryConvertToFrameworkAutoEndorsement
**What it does**: Maps CSIO codes back to framework endorsement codes (inbound, non-Ontario).
**When it runs**: When parsing a CZO response with endorsement codes.
**Rules (ICPEI-specific overrides)**:
- csio:5B -> End5B (V134 cast)
- csio:21B -> End21B (V134 cast)
- csio:8 -> End8B (note: different framework code than Generic)
- csio:19 -> End19B (note: different framework code than Generic)
- csio:28 -> End28C (note: different framework code than Generic)
- csio:30 -> End30B (note: different framework code than Generic)
- csio:39 -> End39
- All other codes: fall through to Generic base

---

## Auto Discount Mapping (CoverageCodeConverter)

### TryConvertToCsioAutoDiscount
**What it does**: Maps framework discount codes to CSIO codes (outbound).
**Rules (ICPEI-specific overrides)**:
- MoreAutosThanOperators -> csio:DISVO (Vehicle to Operator Ratio)
- Renewal -> csio:DISRN
- ClaimsFree -> csio:DISNC (No Claims)
- Experience -> csio:DISED (Experienced Driver)
- PreferredCustomer -> csio:DISVC (Valued/Preferred Customer)
- All other discounts: fall through to V145/V137/v043 Generic base

### TryConvertToFrameworkAutoDiscount
**What it does**: Maps CSIO discount codes back to framework (inbound).
**Rules (ICPEI-specific overrides)**:
- csio:DISVO -> MoreAutosThanOperators
- csio:DISRN -> Renewal
- csio:DISNC -> ClaimsFree
- csio:DISED -> Experience
- csio:DISVC -> PreferredCustomer
- All other codes: fall through to Generic base

---

## Auto Surcharge Mapping (CoverageCodeConverter)

### TryConvertToCsioAutoSurcharge
**What it does**: Maps framework surcharge codes to CSIO codes (outbound).
**Rules (ICPEI-specific overrides)**:
- TowsNonOwnedTrailer -> csio:SURTN
- SURCHARGE_ANTIQUEVEHICLE -> csio:SURAV
- RightHandDriveVehicle -> csio:SURRH
- HighKilometersDriven -> csio:SURHK
- All other surcharges: fall through to Generic base

### TryConvertToFrameworkAutoSurcharge
**What it does**: Maps CSIO surcharge codes back to framework (inbound).
**Rules (ICPEI-specific overrides)**:
- csio:SURTN -> TowsNonOwnedTrailer
- csio:SURAV -> SURCHARGE_ANTIQUEVEHICLE
- csio:SURRH -> RightHandDriveVehicle
- csio:SURHK -> HighKilometersDriven
- All other codes: fall through to Generic base

---

## Vehicle Rules

### ConvertTerritoryCd (PcVehConverter)
**What it does**: Suppresses the territory code on outbound vehicle data.
**When it runs**: When building the vehicle element in CZO XML.
**Rules**:
- Territory code is NOT sent (method body is empty)
- On inbound (response parsing), territory code IS read and stored as LocationFactorGenerated and LocationFactor

### ConvertLengthTimeVehOutsideCountry (PcVehConverter)
**What it does**: Calculates the number of days a vehicle spends outside the country.
**When it runs**: When building vehicle data.
**Rules**:
- Sum all province exposure percentages (AB, BC, MB, NB, NS, NL, NU, NT, ON, PE, QC, SK, YT)
- Convert to days: ceil((totalPercent / 100) * 365)
- If total exposure = 0: send 0 days

### ConvertOtherIdForTrailer (PcVehConverter)
**What it does**: Links a trailer to its parent vehicle via OtherId.
**When it runs**: When the vehicle is a Trailer or CommercialTrailer with a parent.
**Rules**:
- If vehicle code is Trailer or CommercialTrailer AND has a parent vehicle
- Send an OtherIdentifier with the parent vehicle's CSIO ID

### ConvertAntiTheftDeviceInfoID (PcVehConverter)
**What it does**: Assigns unique IDs to anti-theft device info entries.
**When it runs**: After the base Convert runs.
**Rules**:
- For each AntiTheftDeviceInfo on the vehicle, set its ID to a new GUID-based CSIO vehicle ID

### ConvertTelematicsVehInfo (PcVehConverter)
**What it does**: Suppresses telematics vehicle info.
**Rules**:
- Telematics info is NOT sent (method body is empty)

---

## Vehicle Body Type Mapping

### TryConvertToCsioPrivatePassenger
**What it does**: Maps private passenger vehicle body types to CSIO codes.
**Rules (ICPEI overrides)**:
- Antique -> csio:AH (Antique Auto Historic Plate)
- Classic -> csio:CL (Classic/Customized Auto Rated by Price)
- All others: fall through to Generic base

### TryConvertToCsioMotorHome
**What it does**: Always maps motor homes to csio:MH.
**Rules**:
- All motor homes -> csio:MH (Motor Home Recreational Use), regardless of body type

### TryConvertToCsioTrailer
**What it does**: Maps trailer body types to CSIO codes.
**Rules**:
- FifthWheel, FifthWheelCabinTrailer -> csio:FW (V128 Cabin Home Fifth Wheel)
- Utility, Snowmobile -> csio:UT (Utility Trailer)
- TentTrailer -> csio:17 (Tank Trailer)
- BikeMiniBike -> csio:MK (Minibike/Trail Bike)
- Cabin, Home -> csio:NT (V135 Common Trailer Uses Tongue)
- Gooseneck -> csio:8 (Gooseneck Trailer)
- All others: fall through to Generic base

### TryConvertToCsioMotorcycle
**What it does**: Maps motorcycle body types to CSIO codes.
**Rules**:
- Maps 17 specific motorcycle body types to their respective CSIO codes (see enumMappings.vehicleBodyTypes in JSON)
- Notable: NakedSport, EntryNakedSport, and NakedSuperSportRoadster all map to csio:45
- Notable: EntrySport and SuperSport both map to csio:52
- Notable: Trike and ThreeWheelMotorcycle both map to csio:28
- All others: fall through to Generic base

### TryConvertToCsioATV
**What it does**: Maps ATV body types to CSIO codes.
**Rules**:
- AllTerrainVehicle or UtilityTerrainVehicle with 4 wheels -> csio:A4
- AllTerrainVehicle or UtilityTerrainVehicle with other wheel count -> csio:AT
- UtilityTerrainVehicle (second case branch) -> csio:59 (Utility, V128)
- All others: fall through to Generic base

---

## Vehicle Type Mapping

### TryConvertToCsioOther (VehicleTypeConverter)
**What it does**: Maps non-standard vehicle types.
**Rules**:
- ATV -> csio:22 (Unlicensed Recreational Vehicle)
- Snowmobile -> csio:20 (Unlicensed Auto)
- Motorcycle -> nothing sent (explicit suppression)
- MotorHome -> nothing sent (explicit suppression)
- All others: fall through to Generic base

### TryConvertToCsioTrailer
**Rules**:
- All personal trailers -> csio:23 (Unlicensed Trailer)

### TryConvertToCsioCommercialTrailer
**Rules**:
- All commercial trailers -> csio:10 (Trailer Open)

### TryConvertToCsioCommercialVehicle
**Rules**:
- All commercial vehicles -> csio:26 (Commercial Vehicle, V044 type)

---

## Driver Rules

### ConvertOccasionalDriverType (DriverVehConverter)
**What it does**: Determines the driver type for occasional drivers.
**When it runs**: When assigning occasional driver classification.
**Rules**:
- If driver has 8+ years experience OR vehicle is commercial: driver type = Secondary
- Otherwise:
  - Female or GenderX -> Occasional05
  - Male -> Occasional06
- Experience is calculated from the oldest of: DateLicensed (excluding class 4/6), DateLicensedG1, DateLicensedG2
- Experience threshold: more than 8 years between oldest license date and effective date

### ConvertCoverage (PersDriverInfoConverter)
**What it does**: Filters endorsements to only include those assigned to the current driver.
**When it runs**: When converting driver-level endorsements.
**Rules**:
- Only include endorsements that have no ParentID (driver-level, not vehicle-level)
- AND have a DriverID field matching the current person's ID

### ConvertCommlExperience (PersDriverInfoConverter)
**What it does**: Sets commercial driving experience from SimilarVehicleOwnershipSince.
**When it runs**: When converting commercial vehicle driver info.
**Rules**:
- Find the commercial vehicle where this person is the primary or occasional driver
- Use SimilarVehicleOwnershipSince field to calculate years of experience

---

## License Rules

### ConvertLicenseClass (LicenseConverter)
**What it does**: Maps license classes with province-specific logic.
**When it runs**: When converting license information.
**Rules**:
- New Brunswick (NB):
  - G1 or 7-1 -> "LN" (Learner)
  - G2 or 7-2 -> "PR" (Probationary)
  - Other classes -> standard mapping
- All other provinces: standard mapping

### AddLicenseG2 (LicenseCollectionConverter)
**What it does**: Handles G2 license conversion with NB-specific logic.
**Rules**:
- New Brunswick: sends G2 license using the standard G2 license class constant
- All other provinces: uses Generic base G2 license logic

### License Filtering (LicenseCollectionConverter)
**What it does**: Removes foreign licenses from the output.
**Rules**:
- After converting all licenses, remove any with LicenseClassCd = "FL" (foreign license)
- Do not add prior province licenses (suppressed)
- Do not add foreign licenses (suppressed)

---

## Insured/Principal Rules

### ConvertInsuredOrPrincipalID (InsuredOrPrincipalConverter)
**What it does**: Sets the InsuredOrPrincipal ID based on account type and role.
**Rules**:
- Insured role + Individual account type -> ID = "Desktop"
- Insured role + Corporation account type -> ID = "COMPANY"
- Any other role (JointInsured, etc.) -> ID = "COAPP"

### GetInsuredPrincipalRoleType (InsuredOrPrincipalCollectionConverter)
**What it does**: Maps insured status to role type.
**Rules**:
- Named Insured 1 -> "Insured" role type
- All others -> "JointInsured" role type

---

## Credit Score Rules

### ConvertFromPrincipalInfo (CreditScoreInfoConverter)
**What it does**: Converts credit score consent for ICPEI.
**Rules**:
- Default consent code = "0"
- Search for a matching person in the credit scores collection
- If found with consent = "Yes": code = "1"
- If found with consent = "No": code = "0"
- Only send CreditScoreInfo if a person was found with explicit consent
- Sends: CreditScoreDt, CreditScore, CSReasonCd, CSPolicyTypeCd all set to the consent code

---

## Response Parsing Rules

### ConvertLimit / ConvertDeductible (CsioToFramework/Rated/PcCoverageConverter)
**What it does**: Parses coverage limits and deductibles from the rated response.
**Rules**:
- Limit: uses both the base limit conversion AND stores the value in the Coverage field
- Deductible: stores value in the Deductible field (overrides base to use helper directly)

### ConvertTerritoryCd (CsioToFramework/Rated/PcVehConverter)
**What it does**: Parses territory code from the response.
**Rules**:
- If territory code is null/nothing: set LocationFactorGenerated to null
- Otherwise: set both LocationFactorGenerated and LocationFactor to the territory value

### ConvertRateClassCd (CsioToFramework/Rated/PcVehConverter)
**What it does**: Parses rate class code from the response.
**Rules**:
- If present: store in the DriverClass field

### DriverRecordRatingInfoConverter
**What it does**: Maps driving record codes to the correct driver record fields.
**Rules**:
- Primary driver: stores in DriverRecordCollision and DriverRecordTPL
- Occasional Female driver: stores in Class5DriverRecordCollision and Class5DriverRecordTPL
- Occasional Male / Secondary driver: stores in Class6DriverRecordCollision and Class6DriverRecordTPL

### ConvertSeverity (RemarksInfoConverter)
**What it does**: Maps remark priority to alert severity.
**Rules**:
- Priority 1 -> Critical
- Priority 2 -> Exclamation
- Priority 3 -> Information
- No priority -> Information (default)

---

## Address Rules

### AddrConverter
**What it does**: Builds addresses in a simplified format for ICPEI.
**Rules**:
- Removes DetailAddr elements (V127 format cleared)
- Builds a single-line address using suite, street number, street name, street type, street direction
- Appends route type/number and installation type/name to Addr1
- Appends quarter/section/township/range for legal addresses
- If Addr1 is empty but Addr2 has a value: copies Addr2 to Addr1
- Sends AddrValidationdInd (true/false) based on address validation status
- Appends AdditionalAddressInfo to Addr1 if present

---

## Policy Rules

### ConvertContractTerm (PcPolicyConverter)
**What it does**: Adds start and end times to the contract term.
**Rules**:
- Calls Generic base ContractTerm conversion first
- Additionally sends StartTime and EndTime (not just start/end dates)

---

## Commercial Vehicle Rules

### ConvertPreviousPolicyCompanyCd (OtherOrPriorPolicyConverter)
**What it does**: Resolves previous insurer company code.
**Rules**:
- If previous insco code is unknown or unparseable:
  - If CSIO code = "0": send as "Other" company
  - If CSIO code is present: send the code directly
  - If no CSIO code: send as "Other" company
- Otherwise: use standard company code converter

### ConvertPriorPolicyCancellation (OtherOrPriorPolicyConverter)
**What it does**: Converts prior policy cancellation information.
**Rules**:
- Only processes cancellations for non-auto policies (auto = skip)
- Sends policy type, cancellation reason, date, description, and non-payment count
- If non-payment count >= 1: sends Nonpayment as the CancelledDeclinedCd
- If non-payment count = 0: sends Other as the CancelledDeclinedCd
- Always sends PolicyTerminatedCd = CancelledByInsurer

---

## Item Modification Rules

### ItemModificationCollectionConverter
**What it does**: Filters item modifications by appraisal date.
**Rules**:
- Converts the coverage item's modification info
- Only includes modifications that have a valid appraisal date (not Jan 1, 0001)
- Skips modifications with no cost, description, or appraisal date
