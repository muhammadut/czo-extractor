# PeaceHills Business Rules

**Carrier**: PeaceHills
**Latest Version**: V131
**Extracted**: 2026-03-22
**Versions**: v043, V128, V131

---

## Overview

PeaceHills is one of the simplest carriers in the codebase. It has **zero proprietary Z-codes** and uses the Generic base for all CSIO coverage, endorsement, discount, and surcharge mappings. All company-specific overrides are behavioral (response parsing logic), not code-mapping overrides.

PeaceHills has **no FrameworkToCsio (outbound/request) overrides** at all -- it relies entirely on the Generic outbound converters.

---

## CoverageCodeConverter (EnumConverters)

### TryConvertToFrameworkHomeEndorsement
**What it does**: Filters out the MassEvacuationEndorsement code before delegating to Generic base.
**When it runs**: When parsing inbound home endorsement codes from CSIO XML.
**Rules**:
- If the coverage code is MassEvacuationEndorsement: return False (endorsement is not supported)
- For all other codes: delegate to the Generic base (V129.Generic.EnumConverters.CoverageCodeConverter)

**Codes affected**: MassEvacuationEndorsement CSIO code is blocked.

---

## PcCoverageConverter (CsioToFramework/Unrated)

### ConvertFromLineBusiness
**What it does**: Maps specific CSIO auto coverage codes to Increased Accident Benefits Ontario flags.
**When it runs**: When parsing inbound auto coverages from the PersAuto section of the CSIO XML.
**Rules**:
- If coverage code = "csio:ACB": set AttendantCare = True
- If coverage code = "csio:DCB": set DependantCare = True
- If coverage code = "csio:MEDRH": set MedicalRehabilitation = True
- For all other codes: delegate to Generic base

**Codes sent**: csio:ACB, csio:DCB, csio:MEDRH (standard CSIO codes, not Z-codes)

---

## PcCoverageConverter (CsioToFramework/Rated)

### ConvertAutoEndorsement
**What it does**: Makes End27 and Opcf27 policy-level endorsements by clearing the vehicle ID.
**When it runs**: When parsing rated auto endorsements from carrier response.
**Rules**:
- If endorsement code = End27 OR Opcf27: call base ConvertAutoEndorsement with vehicleID = Nothing (policy-level)
- For all other endorsements: call base ConvertAutoEndorsement with the actual vehicleID

**Codes affected**: End27, Opcf27

---

## DefaultEndorsementConverter (CsioToFramework/Unrated/EndorsementConverters)

### ConvertForVehicle
**What it does**: Same End27/Opcf27 policy-level handling as rated converter.
**When it runs**: When parsing unrated auto endorsements per vehicle.
**Rules**:
- If endorsement code = End27 OR Opcf27: pass parentID as Nothing (policy-level)
- For all other endorsements: pass actual parentID

### ConvertForPrimaryDwelling
**What it does**: Handles sewer backup endorsement limit logic for primary dwelling.
**When it runs**: When parsing home endorsements for the primary dwelling.
**Rules**:
- First: delegate to Generic base to do standard conversion
- Then: if endorsement = SewerBackup AND endorsement limit equals dwelling coverage limit, set endorsement coverage value to "PolicyLimit"

### ConvertForAdditionalResidence
**What it does**: Same sewer backup logic for additional residences.
**When it runs**: When parsing home endorsements for additional residences.
**Rules**:
- Same as ConvertForPrimaryDwelling above

---

## CoverageConverterHelper (CsioToFramework/Unrated)

### ConvertLimit
**What it does**: Special limit handling for sewer backup coverage.
**When it runs**: When converting coverage limits from inbound CSIO XML.
**Rules**:
- If coverage code = SewerBackupCoverage: extract limit as integer and set as string (not currency)
- For all other coverages: use standard currency conversion from Generic base

---

## DwellConverter (CsioToFramework/Unrated)

### ConvertID
**What it does**: Maps dwelling ID from LocationRef instead of standard mapping.
**When it runs**: When parsing dwelling data from CSIO XML.
**Rules**:
- Set dwelling ID = idConverter.GetFrameworkLocationId(input.LocationRef)

### GetPolicyTypeOverride
**What it does**: Normalizes policy type codes by stripping leading zeros from numeric values.
**When it runs**: When determining the policy type for a dwelling.
**Rules**:
- Get policy type from Generic base
- If policy type value starts with "csio:0" and is numeric: strip the leading zero (e.g., "csio:01" becomes "csio:1")
- If not numeric: return as-is

---

## ValuationProductConverter (EnumConverters)

### TryConvertToCsio
**What it does**: Maps evaluator types to PeaceHills-specific valuation product codes.
**When it runs**: When building outbound CSIO XML valuation product field.
**Rules**:
- If evaluator type = EZITV: set valuation product = "7"
- If evaluator type = IClarify: set valuation product = "8"
- For all other types: delegate to Generic base

### TryConvertToFramework
**What it does**: Reverse mapping of valuation product codes to evaluator types.
**When it runs**: When parsing inbound CSIO XML valuation product field.
**Rules**:
- If valuation product = "8": set evaluator type = IClarify
- If valuation product = "7": set evaluator type = EZITV
- For all other values: delegate to Generic base

---

## RateClassConverter (EnumConverters)

### Convert
**What it does**: Maps rate class codes to type of rating.
**When it runs**: When processing rate class from inbound CSIO XML.
**Rules**:
- If rate class = "66" or "67": set TypeOfRating = PurchasePrice
- For all other rate classes: set TypeOfRating = Vicc

---

## LineOfBusinessCodeConverter (EnumConverters)

### TryConvertToFramework
**What it does**: Filters out unsupported line of business codes.
**When it runs**: When parsing line of business from inbound CSIO XML.
**Rules**:
- If line of business = PackagePolicy or CommercialMisc: return False (not supported)
- For all other values: delegate to Generic base

---

## OtherPolicyConverter (CsioToFramework/Unrated)

### ConvertSupportingAutoPolicy / ConvertSupportingHabPolicy / ConvertSupportingMiscAutoPolicy
**What it does**: Forces supporting policy company to PeaceHills when unknown.
**When it runs**: When parsing supporting (other) policies from inbound CSIO XML.
**Rules**:
- First: delegate to Generic base for standard conversion
- Then: if company = None or Unknown, set company = PeaceHills
- Ticket reference: PHI-454

---

## PersDriverConverter (CsioToFramework/Unrated)

### ConvertFromPersAuto
**What it does**: Enriches driver data by matching with insured records and copying missing information.
**When it runs**: When parsing driver data from the PersAuto section.
**Rules**:
- First: do standard Generic base conversion
- Then: try to match the driver to an insured using the PeaceHillsDriverNameMatcher
- If matched: copy address, phone numbers, email, and occupation from insured to driver; if driver is not marked as insured, set relationship to Insured
- If no match but driver IS the insured: copy data from the first insured record
- Always: clear MVR date (force broker to re-set)

---

## PeaceHillsDriverNameMatcher (CsioToFramework/Unrated)

### IsMatch
**What it does**: Matches driver names to insured names using multiple strategies.
**When it runs**: Called by PersDriverConverter when trying to match drivers to insureds.
**Rules**:
- Strategy 1 (Perfect match): Given name + surname must match exactly
- Strategy 2 (Family match): Parse family name with "and"/"&" separators, match any combination
- Strategy 3 (Supplementary match): Parse supplementary name info and match as first/last name pair
- Given name matching allows partial matches (first word only, ignoring middle names)
- Surname matching requires exact match

---

## LossConverter (CsioToFramework/Unrated)

### ConvertChargableInd
**What it does**: Maps chargeable indicator to PeaceHills claim company record.
**When it runs**: When parsing claim chargeability from inbound CSIO XML.
**Rules**:
- Find existing PeaceHills claim company in the claim record
- If not found: create new PeaceHills claim company entry
- Set ChargeableAccident on the PeaceHills company record

---

## LossPaymentConverter (CsioToFramework/Unrated)

### Convert (v043 version)
**What it does**: Handles loss payments with missing coverage codes.
**When it runs**: When parsing loss payment amounts.
**Rules**:
- If coverage or coverage code is null: extract AmountPaid directly from LossPaymentAmt
- Otherwise: delegate to Generic base

### Convert (V128 version)
**What it does**: Same as v043 but checks via GetCoverageCd helper.
**When it runs**: When parsing loss payment amounts.
**Rules**:
- If GetCoverageCd returns empty/null: extract AmountPaid directly from LossPaymentAmt
- Otherwise: delegate to Generic base (V118.Generic)

---

## HeatingUnitInfoCollectionConverter (CsioToFramework/Unrated)

### Convert
**What it does**: Filters out heating units with "None" code.
**When it runs**: When parsing heating unit information from inbound CSIO XML.
**Rules**:
- For each heating unit: if HeatingUnitCd is null OR not equal to "None": process normally
- If HeatingUnitCd = "None": skip (do not add to output)

---

## PhoneInfoCollectionConverter (CsioToFramework/Unrated)

### ConvertBrokerPhones / ConvertPersonPhones / ConvertPolicyPhoneInfo
**What it does**: Reformats phone numbers to standard format.
**When it runs**: When parsing phone numbers from any section of inbound CSIO XML.
**Rules**:
- After standard Generic base conversion, reformat all phone numbers
- Format: ###-###-#### (extracted from patterns like +1-###-###-#### or ###-######)
- Applied to: phone1, phone2, cellphone, fax for persons; brokeragePhone1, brokeragePhone2, brokerageFax for brokers

---

## LicenseConverter (CsioToFramework/Unrated)

### ConvertLicenseClass
**What it does**: Concatenates motorcycle license class to existing license class.
**When it runs**: When parsing license class codes from inbound CSIO XML.
**Rules**:
- If license class is not set yet: set it directly
- If license class already has a value AND the new class is a motorcycle license: concatenate (e.g., "5" + "M" = "5M")
- Otherwise: do not overwrite existing license class

---

## LossCollectionConverter (CsioToFramework/Unrated)

### Convert
**What it does**: Processes each loss individually without the standard grouping/filtering.
**When it runs**: When parsing the loss collection from inbound CSIO XML.
**Rules**:
- For each loss: create a new claim and policy claim info, find matching driver, convert, and add to output
- No special filtering or grouping applied

---

## PersDriverCollectionConverter (CsioToFramework/Unrated)

### ConvertFromPersAuto
**What it does**: Adds supplementary name info as additional person records (business insureds).
**When it runs**: After standard driver collection conversion.
**Rules**:
- First: do standard Generic base conversion
- Then: for each insured with supplementary name info, create a person record with the supplementary name
- Strip "and"/"And"/"AND"/"&" from the name
- Check for duplicates before adding (match by concatenated first+last name, case-insensitive)
- If no match found, assign a new ID and add to output

---

## Version Differences

### V131 vs V128
- PcCoverageConverter (Unrated): Inherits from V130.Generic instead of V128.Generic
- PcCoverageConverter (Rated): Inherits from V130.Generic instead of V128.Generic
- ConverterFactoryFactory: Inherits from V131.Generic instead of V128.Generic
- DwellConverter: Unchanged (still uses V128 version)
- HeatingUnitInfoCollectionConverter: Unchanged (still uses V128 version)
- LossPaymentConverter: Removed from V131 (uses V128 version via factory)
- CoverageCodeConverter: Inherits from V129.Generic (adds DeductibleWaiver, DeletionOfHailCoverage, WaterAndSewerLinesCoverage, ServiceLineExtension)

### V128 vs v043
- DwellConverter: Added policy type normalization (leading zero stripping)
- HeatingUnitInfoCollectionConverter: Added "None" heating unit filtering
- LossPaymentConverter: Changed from null-check on Coverage/CoverageCd to using GetCoverageCd helper
- CoverageCodeConverter: Unchanged in company override (all three versions have identical 35-line file)
- Rated PcCoverageConverter: Unchanged (same End27/Opcf27 policy-level logic)
