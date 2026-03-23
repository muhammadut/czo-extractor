# Jevco CZO Business Rules

**Carrier**: Jevco
**Extraction Date**: 2026-03-22
**Version**: v043 (base version only)
**Line of Business**: Auto only

---

## Overview

Jevco is an auto-only carrier that exists solely in the v043 base version folder. It has NO CompanyConstants.vb and NO CoverageCodeConverter override, meaning it inherits all standard CSIO coverage, discount, and surcharge codes from the Generic base without modification.

Jevco's carrier-specific overrides are purely behavioral -- they change HOW data is formatted and WHERE it is placed in the CSIO XML, but do NOT introduce any proprietary Z-codes.

---

## Carrier-Specific Rules

### ConvertEndorsementLimit (PcCoverageConverter.vb)
**What it does**: Custom limit handling for OPCF 27 endorsement.
**When it runs**: When converting endorsement limits for any endorsement.
**Rules**:
- If endorsement is End27 or Opcf27: clear any existing limits, then re-convert the limit from the company-specific coverage fields (DynamicFieldNameConstants.Coverage)
- All other endorsements: use the standard Generic base logic

**Codes affected**: csio:27

---

### ConvertTPL (PcCoverageCollectionConverter.vb)
**What it does**: Suppresses Third Party Liability conversion.
**When it runs**: When converting vehicle coverages.
**Rules**:
- Do nothing (TPL is handled differently by Jevco)

---

### ConvertAccidentBenefits (PcCoverageCollectionConverter.vb - ICoverageItemCompany overload)
**What it does**: Sends the standard AccidentBenefits coverage code when a TPL limit exists on the coverage item.
**When it runs**: When processing accident benefits from a coverage item company.
**Rules**:
- Call the base implementation first
- If the coverage item has a Liability field with a non-zero value: ensure AccidentBenefits coverage is present in output

**Codes sent**: Standard AccidentBenefits code (from enumValuesFactory)

---

### ConvertAccidentBenefits (PcCoverageCollectionConverter.vb - IIncreasedAccidentBenefitsOntario overload)
**What it does**: Converts individual increased accident benefit flags to separate CSIO coverage codes.
**When it runs**: When processing Ontario increased accident benefits.
**Rules**:
- If AttendantCare is true: send csio:ACB
- If Caregiver is true: send csio:CHHMB
- If DependantCare is true: send csio:DCB
- If MedicalRehabilitation is true: send csio:MEDRH
- If IncomeReplacementCoverage > 400: send IncomeReplacement code with a currency limit equal to the coverage amount
- If IndexationBenefit is true: send Indexation code
- If MedicalRehabilitationAndAttendantCare is true: send MedicalRehabAttendantCare code
- If DeathAndFuneral is true: send DeathAndFuneralBenefits code

**Codes sent**: csio:ACB, csio:CHHMB, csio:DCB, csio:MEDRH, plus IncomeReplacement, Indexation, MedicalRehabAttendantCare, DeathAndFuneralBenefits (from enumValuesFactory)

---

### ConvertPersonalVehicles (PersAutoLineBusinessConverter.vb)
**What it does**: Two post-processing steps after standard vehicle conversion.
**When it runs**: After all personal vehicles have been converted.
**Rules**:
1. **Unassigned Driver Assignment**: For every vehicle, find all drivers NOT already assigned to that vehicle. Add each unassigned driver as a DriverVeh entry with 0% usage.
2. **Accident Benefits Distribution**: Scan all coverages for optional increased AB codes (csio:ACB, csio:CHHMB, csio:DCB, csio:MEDRH, IncomeReplacement, Indexation, MedicalRehabAttendantCare, DeathAndFuneralBenefits). Copy these coverages to every vehicle's coverage collection.

---

### QuestionAnswer Migration (PersAutoPolicyQuoteInqRqConverter.vb & PersAutoPolInfoConverter.vb)
**What it does**: Moves certain policy-level QuestionAnswers to vehicle or driver level.
**When it runs**: After the full PersAutoPolicyQuoteInqRq or PersAutoPolInfo conversion.
**Rules**:
- Move to first vehicle:
  - CarryPassengersForCompensation
  - MaterialMisrepresentation
  - ApplicantBothRegisteredAndActualOwner (rename to RegisteredOwner at destination)
- Move to first driver:
  - LicenseSuspendedCancelledLapsed
  - InsuranceCancelledDeclinedRefused
- If the question already exists at the destination, remove the existing one before adding the migrated question

---

### Custom QuestionAnswers (QuestionAnswerCollectionConverter.vb)
**What it does**: Adds 3 Jevco-specific custom questions and removes one standard question.
**When it runs**: When converting QuestionAnswers for a PersVeh (vehicle).
**Rules**:
- **Remove**: RegisteredOwner question (Jevco uses this field for a different purpose)
- **Add Question 130 - Lapses For Non Payment In Three Years**: Calculate number of insurance lapses due to NonPaymentOfPremium within the last 3 years for the Insured person. Answer is Yes if count >= 3, No otherwise.
- **Add Question 131 - Racing/Speed Events**: Read from DynamicFieldNameConstants.RacingSpeedEvents field. Defaults to false.
- **Add Question 132 - Prototype/Experimental**: Read from DynamicFieldNameConstants.PrototypeExperimental field. Defaults to false.

---

### Address Conversion (AddrConverter.vb)
**What it does**: Uses simple address format instead of detailed parsed address.
**When it runs**: When converting any address (regular or legal).
**Rules**:
- Call base conversion first
- Clear DetailAddr (set to Nothing)
- Re-convert using ConvertSimpleAddress with: Suite, StreetNumber, StreetName, StreetType, StreetDirection, PoBox
- For legal addresses: use Legal-prefixed fields (LegalSuite, LegalStreetNum, etc.) plus LegalLot, LegalBlock, LegalPlan

---

### Vehicle Conversion (PcVehConverter.vb)
**What it does**: Custom altered indicator and rate group suppression.
**When it runs**: When converting vehicle information.
**Rules**:
- **AlteredInd**: Read CustomizedVehicle field. If empty or "No" (case-insensitive): set AlteredInd to false. Otherwise: set to true.
- **VehRateGroupInfo**: Do nothing (suppressed). Jevco does not send vehicle rate group information.

---

### Rated Coverage Suppression (FrameworkToCsio/Rated/PcCoverageCollectionConverter.vb)
**What it does**: Suppresses separate Bodily Injury and Property Damage coverage output in rated responses.
**When it runs**: When building rated (premium) coverage collections.
**Rules**:
- ConvertBodilyInjury: Do nothing
- ConvertPropertyDamage: Do nothing

---

### Company Code Mapping (EnumConverters/CompanyCodeConverter.vb)
**What it does**: Maps InsuranceCompanyName enum values to Jevco's numeric company codes.
**When it runs**: When identifying the prior/other insurance company.
**Rules**:
- 55 company mappings defined (see enumMappings.companyCode in the extraction JSON)
- Jevco's own code is "828"
- ING companies (Halifax, Novex, WesternUnion) all map to "222"
- Aviva, Elite, TradersGeneral all map to "48"
- Unmapped companies return False (not supported)

---

### Conviction Code Mapping (EnumConverters/ConvictionCodeConverter.vb)
**What it does**: Maps framework conviction enum values to Jevco's numeric conviction codes.
**When it runs**: When converting driving conviction records.
**Rules**:
- 97 conviction mappings defined (see enumMappings.convictionCodes in the extraction JSON)
- Some convictions share the same code (e.g., Suspended and SuspendedForLife both map to "274"; NoDriversLicenseOrImproperClass and NoDriversLicenseRecreationalVehicle both map to "242")
- Unmapped convictions return False

---

### Vehicle Liability Card (EnumConverters/VehLiabilityCardConverter.vb)
**What it does**: Maps insurance card type to Jevco's string values.
**When it runs**: When converting vehicle liability card information.
**Rules**:
- None -> "None"
- Permanent -> "Perm"
- Temporary -> "Temp"
- Other values return False
