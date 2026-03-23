# Echelon CZO Business Rules

**Carrier**: Echelon
**Version**: v043 (only version)
**Type**: Auto-only carrier
**Date**: 2026-03-22

---

## Overview

Echelon is an auto-only carrier that exists exclusively in v043. It has NO habitation (home) coverage codes. The carrier has 7 company-specific CSIO codes in CompanyConstants, all related to Ontario accident benefits (SABS). There are ZERO Z-codes (carrier-proprietary codes). All endorsement, discount, and surcharge mappings are inherited entirely from the v043/Generic CoverageCodeConverter base class.

The company-specific customizations are focused on:
1. Ontario accident benefits conversion (SABS date-split logic)
2. TPL premium splitting (combined vs. BI/PD split)
3. OPCF 44 limit sourcing
4. Address format flattening
5. Named insured name concatenation
6. Payment option splitting
7. Rated coverage migration (LOB to vehicle level)

---

## ConvertAccidentBenefits (PcCoverageCollectionConverter)

**What it does**: Converts Ontario increased accident benefits selections into individual CSIO coverage entries.

**When it runs**: Called from PersVehConverter.ConvertCoverage for each vehicle, after the base coverage conversion.

**Rules**:

### Post-June 1, 2016 (SABS Reform)
- If calculation date >= June 1, 2016:
  - If MedicalAttendantCatastrophic is selected: send csio:CATIM with $1,000,000 limit
  - If MedicalAttendantNonCatastrophic is selected: send csio:MRB with $130,000 limit
  - If MedicalAttendantNonCatastrophic1M is selected: send csio:CIMRB with $1,000,000 limit

### Pre-June 1, 2016 (Legacy SABS)
- If calculation date < June 1, 2016:
  - If AttendantCare is selected: send csio:ACB (no limit)
  - If MedicalRehabilitation is selected: send csio:MEDRH (no limit)
  - If MedicalRehabilitationAndAttendantCare is selected: send csio:MRAC (standard enum value, no limit)

### Date-Independent Benefits
- If Caregiver is selected: send csio:CHHMB (always, regardless of date)
- If DependantCare is selected: send csio:DCB (always, regardless of date)
- If IncomeReplacementCoverage > $400/week: send csio:IR with the actual weekly amount as the limit
- If IndexationBenefit is selected: send csio:INDX
- If DeathAndFuneral is selected: send csio:DFNRL

**Codes sent**: csio:CATIM, csio:MRB, csio:CIMRB, csio:ACB, csio:MEDRH, csio:MRAC, csio:CHHMB, csio:DCB, csio:IR, csio:INDX, csio:DFNRL

---

## ConvertEndorsementLimit (PcCoverageConverter)

**What it does**: Overrides how the endorsement limit is set for specific endorsement codes.

**When it runs**: When converting endorsement limits during coverage building.

**Rules**:
- If endorsement is Opcf44 or End44: set the limit from the parent vehicle's Liability field (DynamicFieldNameConstants.Liability), NOT from the endorsement's own limit.
- For all other endorsements: fall through to the base class (Generic) implementation.

**Codes affected**: csio:44R (Ontario), csio:44 (non-Ontario)

---

## ConvertTPL / ConvertPropertyDamage / ConvertBodilyInjury (PcCoverageCollectionConverter)

**What it does**: Controls whether TPL is sent as a combined coverage or split into BI and PD.

**When it runs**: During vehicle coverage conversion.

**Rules**:
- **ConvertTPL**: Only sends combined TPL if TPL premium is non-zero AND neither BI nor PD has a separate premium. If split premiums exist, combined TPL is suppressed.
- **ConvertPropertyDamage**: Sends PD coverage if the PD-specific premium is non-zero, OR if the combined TPL premium is zero (meaning we need the split coverages).
- **ConvertBodilyInjury**: Sends BI coverage if the BI-specific premium is non-zero, OR if the combined TPL premium is zero.

**Logic summary**: If Echelon provides split BI/PD premiums, send BI and PD separately. If only combined TPL premium exists, send TPL as one coverage.

---

## ConvertCoverage - Unrated PersAutoLineBusinessConverter

**What it does**: Initializes an empty Coverage collection on the PersAutoLineBusiness output without calling the base class converter.

**When it runs**: During unrated request building at the policy line-of-business level.

**Rules**:
- If output.Coverage is Nothing: create a new empty LooseTypedList of PCCOVERAGE.
- Does NOT call MyBase.ConvertCoverage, which means the generic policy-level coverage conversion is skipped entirely.

**Effect**: Echelon only sends coverages at the vehicle level, not at the line-of-business level in the unrated direction.

---

## ConvertCoverage - Rated PersAutoLineBusinessConverter

**What it does**: After base conversion, migrates specific accident benefits and increased benefits coverages from the line-of-business level to the first vehicle.

**When it runs**: During rated request building (after base rated conversion populates coverages).

**Rules**:
- If PersVeh collection is not empty, take the first vehicle.
- For each of the following codes, move the coverage from lineOfBusinessCoverages to vehicleCoverages (copy CurrentTermAmt, remove from LOB):
  - csio:ACB, csio:CHHMB, csio:DCB, csio:MEDRH
  - csio:CATIM (CompanyConstants), csio:MRB (CompanyConstants), csio:CIMRB (CompanyConstants)
  - Income Replacement, Indexation, Medical Rehab + Attendant Care, Death and Funeral (standard enum values)

**Effect**: All accident benefits premiums end up on the first vehicle rather than at the policy level.

---

## Address Conversion (AddrConverter)

**What it does**: Converts addresses to a flat/simple format instead of the structured detail address format.

**When it runs**: For all address conversions (insured addresses, risk addresses, legal addresses).

**Rules**:
- After calling base Convert: null out DetailAddr.
- Call ConvertSimpleAddress with suite, street number, street name, street type, street direction, and PO Box.
- For legal addresses: also null out LegalAddr after converting to simple format.

**Effect**: Echelon receives flat address strings rather than structured address components.

---

## Name Conversion (NameInfoConverter)

**What it does**: Concatenates named insureds into a single CommercialName.

**When it runs**: When building policy name info.

**Rules**:
- If both NamedInsured1 and NamedInsured2 are present: combine as "Name1 & Name2"
- If only one is present: use that name
- If neither is present: skip (exit sub)
- Output goes to CommlName.CommercialName (not PersonName)
- Mortgagee names also go to CommlName.CommercialName

---

## Payment Options (PaymentOptionCollectionConverter)

**What it does**: Splits payment information into two separate payment option entries.

**When it runs**: After base payment option conversion.

**Rules**:
- If output has payment options:
  - First payment gets id = "PMTINFO" (contains all payment info except deposit)
  - Create second payment with id = "PMTDOWN" (contains only the deposit amount)
  - Move DepositAmt from first payment to second payment, null it on first

---

## Insured/Principal Collection (InsuredOrPrincipalCollectionConverter)

**What it does**: Custom primary/secondary insured processing with specific ID assignments.

**When it runs**: During insured/principal conversion.

**Rules**:
- Primary insured gets id "CSC_FLDS"
- Secondary insured gets id "ADD_INS"
- Iterates through non-insured persons; first becomes primary, second becomes secondary
- If no matched persons found, falls back to base implementation using Insured role type
- Sets PrimaryPrincipal address type on all insured addresses
- Clones primary address to all other insureds if no address is available

---

## Insured/Principal Info (InsuredOrPrincipalInfoConverter)

**What it does**: Adds "Insured" role description to all insured entries.

**When it runs**: During insured info conversion.

**Rules**:
- After base conversion, always set InsuredOrPrincipalRoleDesc = "Insured"

---

## Insured/Principal Converter (InsuredOrPrincipalConverter)

**What it does**: Custom handling for time-known and credit score.

**When it runs**: During insured conversion.

**Rules**:
- **LengthOfTimeKnownByAgentBroker**: If KnownApplicantSinceDate has a value and the year difference is 0, use months instead of years. Otherwise fall through to base.
- **CreditScoreInfo**: Always ensures CreditScoreInfo is initialized (not Nothing) before calling ConvertFromPolicyInsuredOrPrincipal.

---

## Driver Record Rating (DriverRecordRatingInfoCollectionConverter + Converter)

**What it does**: Defines which coverages get driver record rating info and how the records are formatted.

**When it runs**: During driver record conversion.

**Rules**:
- **Coverage selection**: Always returns TPLBI, TPLPD, Coll regardless of vehicle code or rating region.
- **ID format**: Each record's id is formatted as "{driverId}-{coverageType}" (e.g., "DRV-1-TPLBI").
- **Vehicle reference**: Uses the coverage item ID to set VehRef.

---

## SignonRq Converter

**What it does**: Adds proxy client conversion after base signon.

**When it runs**: During signon request building.

**Rules**:
- After base Convert: call ConvertProxyClient to add proxy client information to the signon request.

---

## Company Product Mapping

**What it does**: Maps Echelon's company code to the CSIO company product identifier.

**Rules**:
- InsuranceCompanyCode.Echelon maps to "ECHE"
- All other company codes fall through to base Generic converter

---

## ID Conversion (IdConverter)

**What it does**: Custom ID generation with prefix-based formatting and delimiter-separated hierarchical IDs.

**When it runs**: Whenever CSIO IDs need to be generated for entities (vehicles, drivers, coverages, etc.).

**Rules**:
- Uses "-" as index delimiter
- ID ref prefixes: ACV (accident/violation), COV (coverage), DRV (driver), DWL (dwelling), LOC (location), LOS (loss), VEH (vehicle), WAT (watercraft)
- Coverage IDs try to find a parent mapping first; if not found, use the coverage code as part of the ID
- Endorsement IDs similarly check for parent mappings
- The 314-line IdConverter is the largest Echelon-specific file, handling complex ID generation logic with parent-child relationships
