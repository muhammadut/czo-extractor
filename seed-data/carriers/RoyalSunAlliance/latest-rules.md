# RoyalSunAlliance CZO Business Rules

**Carrier**: RoyalSunAlliance (RSA), including CNS and Western Assurance sub-brands
**Version**: V128
**Extracted**: 2026-03-22

---

## Sub-Brands and Product Routing

**What it does**: Routes transactions to the correct RSA sub-brand based on insurance company code.
**Rules**:
- If company = CNS: product code = "CPH"
- If company = RoyalSunAlliance AND policy type = Auto: product code = "PER"
- If company = RoyalSunAlliance AND policy type = Property: product code = "PPL"
- If company = WesternAssurance: product code = "WAH"

**Multi-Policy Discount**: Supporting policies must be from "Quote All", "Royal SunAlliance", or "Western Assurance" to qualify.

---

## Home Coverage Code Routing

### ConvertHabCoverageCd
**What it does**: Maps framework dwelling coverage categories to RSA-specific CZO codes based on policy type.
**When it runs**: For every hab coverage item being sent outbound.
**Rules**:
- Dwelling (Home/Seasonal/FEC/MobileHome): sends code ZHBLG (Building)
- Dwelling (Condo/Tenant): sends code ZHPRO (Contents/Personal Property)
- Contents: always sends ZHPRO
- Outbuildings: always sends csio:BLDG
- Additional Living Expenses: always sends ZHLOU
- Personal Liability: always sends ZHLIA
- Medical Payments: always sends ZHVMP
- Improvements & Betterments (FEC only): uses standard Named Perils Unit Owners code instead of the default

---

## Building Bylaws Extension (Province-Specific)

### TryConvertToCsioHomeEndorsement - BuildingBylawsExtension
**What it does**: Selects the correct Building Bylaws code based on province.
**When it runs**: When a Building Bylaws Extension endorsement is being converted outbound.
**Rules**:
- If province = Ontario (ON): send ZHBY3
- If province = British Columbia (BC):
  - If policy type = Condo AND coverage type = "Fire and E.C.": send ZHBY6
  - Otherwise: send ZHBY5
- All other provinces: send ZHBYL (default)

**Codes sent**: ZHBYL, ZHBY3, ZHBY5, ZHBY6

---

## Earthquake Coverage

### TryConvertToCsioHomeEndorsement - Earthquake
**What it does**: Selects earthquake coverage code based on contents coverage option selected by the insured.
**When it runs**: When an earthquake endorsement is being converted outbound.
**Rules**:
- Default code: csio:Earthquake
- If contents option = "100% Building, 100% Contents and 100% Outbuildings": override to ZHECF
- If contents option = "100% Building and 100% Outbuildings" (no contents): override to ZHECX
- If contents option = "100% Building, 50% Contents and 100% Outbuildings": override to ZHECP
- If contents option = "Contents Only": no override (stays csio:Earthquake)

### ConvertEarthquakeContentsCoverage (in PcCoverageCollectionConverter)
**What it does**: Generates a separate earthquake contents coverage line item in addition to the main earthquake endorsement.
**When it runs**: When earthquake endorsement is being processed and has a contents coverage selection.
**Rules**:
- Reads "EarthquakeCoverage" field from the endorsement company data
- Maps to ZHECF, ZHECX, or ZHECP based on same rules as above
- Generates a separate PCCOVERAGE XML node with the contents code

**Codes sent**: csio:Earthquake, ZHECF, ZHECX, ZHECP

---

## Short Term Rental Endorsement

### ConvertShortTermRentalEndorsement
**What it does**: Selects the correct short-term rental code based on policy type and rental duration.
**When it runs**: When a ShortTermRentalEndorsement is being converted outbound.
**Rules**:
- **Mobile Home**: always ZHRE0
- **Seasonal**:
  - Coverage type = SeasonalHomeshield: if weeks <= 24 then ZHRE3
  - Coverage type = Homeowners: ZHRE3
  - Coverage type = Fire & E.C. / Landlord / LandlordPlus: ZHRE4
- **Home**: if weeks <= 24 then ZHRE0
- **Condo**:
  - If weeks <= 24: ZHRE1
  - If weeks <= 48: ZHRE2
  - Via field: "48 Weeks" = ZHRE2, "24 Weeks" = ZHRE1
- **Default (other policy types)**:
  - If weeks >= 48: ZHRE2
  - If weeks >= 24: ZHRE1
  - Via field: "24 Weeks" = ZHRE1, else ZHRE2

**Codes sent**: ZHRE0, ZHRE1, ZHRE2, ZHRE3, ZHRE4

---

## Driving Record Protector / Claims Protection Plan

### ConvertDrivingRecordProtector
**What it does**: Routes the claims protection endorsement based on driver coverage type.
**When it runs**: When DrivingRecordProtectorClaims or End39 endorsements are being converted.
**Rules**:
- If coverage type = "Principal Only": use standard claims protection plan code
- If coverage type = "Occasional Only":
  - If parent has DriverClass5Surcharge: send rsa:CP05
  - Else: send rsa:CP06
- If coverage type = "Principal And Occasional": send rsa:CPPPO
- Otherwise: use standard claims protection plan code

**Codes sent**: rsa:CPPPO, rsa:CP05, rsa:CP06

---

## Seasonal Dwelling FEC Add-Ons

### ConvertHabCoverages - Seasonal FEC
**What it does**: For seasonal dwellings with Fire & E.C. coverage type, adds optional Burglary and Vandalism coverage nodes.
**When it runs**: When processing a seasonal dwelling primary item or seasonal additional residence.
**Rules**:
- Only for Seasonal policy type with coverage type = "Fire and E.C." or "Fire & E.C."
- If Burglary field = True: add coverage node with code csio:BURG
- If Vandalism field = True: add coverage node with code ZHVAN

**Codes sent**: csio:BURG, ZHVAN

---

## Loss Assessment Logic

### ConvertHabCoverages - Loss Assessment
**What it does**: Generates loss assessment coverage nodes for condos and bare-land condos.
**When it runs**: When processing dwelling coverages for condos or bareland condos.
**Rules**:
- Applied automatically for: Rented Condo, Condo additional residences
- Applied for Primary Item/Tenant/House/MobileHome/RentedDwelling/SeasonalDwelling IF policy type = Condo
- Applied for Home/Seasonal/MobileHome/FEC IF BarelandCondo = True
- If LossAssessment field > 0:
  - If coverage type = Fire & E.C.: use Named Perils Loss Assessment code
  - Otherwise: use All Risk Loss Assessment code
- If CondoIncludedCoverageLimit > 0: send code ZHHAL with that limit

**Codes sent**: ZHHAL, plus generic AllRisk/NamedPerils loss assessment codes

---

## Auto Endorsement Routing

### TryConvertToCsioOntarioAutoEndorsement
**What it does**: Maps Ontario-specific auto endorsements.
**Rules**:
- Pak06: send rsa:2027
- Permission to Carry Passengers for Transportation Network (Ontario): send Z6TNC
- OPCF 5C: send Z5CS
- All others: fall back to generic base

### TryConvertToCsioAutoEndorsement (non-Ontario)
**What it does**: Maps non-Ontario auto endorsements.
**Rules**:
- Permission to Carry Passengers for Transportation Network: send Z1TNC
- End19A: use standard End19A code
- End28A: send 28OD
- End39: use standard Claims Protection Plan code
- End43R: use standard End43 code
- End18: use standard End18 code (V126+)
- All others: fall back to generic base

---

## Hab Discount Classification (Response Parsing)

### TryConvertToFrameworkHabDiscount
**What it does**: Classifies incoming hab discount/credit codes from RSA responses into framework discount types.
**Rules**:
- HDRFD -> Foundation
- GRR -> GroupRate
- HDRLF -> MortgageFree
- HDRAG, HDWDE -> NewHome
- HDISN -> NewBusiness
- HDPCF -> ClaimsFree
- HDOCU -> Occupation
- HDRSC -> MatureCitizen
- HDISL -> Loyalty
- HDPPL, LTDIS -> LongTermPolicy
- HDBL -> LoyaltyBroker
- HDQR -> CreditScore
- HDPPD -> PostalCode
- HDRCT -> Evaluator
- HDRPD, HDRNW -> SecuritySystem
- HDCIP -> CombinedPolicy
- HDHHO -> OilTankLocation
- HDHHE -> Heating
- MLTPD, HDRLL -> MultiLine
- WEBDS -> Web
- HDRLD -> MobileHomeTiedDown
- HDWAD -> WaterAlarmDevice
- HDG&S, HDUPS, HPCD -> Miscellaneous

---

## Hab Surcharge Classification (Response Parsing)

### TryConvertToFrameworkHabSurcharge
**What it does**: Classifies incoming hab surcharge codes from RSA responses.
**Rules**:
- HDHHP -> PrimaryHeating
- HDHHB, HDHHW -> AuxiliaryHeating
- HFAM -> MultiFamily
- HSRLF -> Mortgage
- HDHF1, HDHF2, HDHP1, HDHP2 -> Heating
- HDHAL, HSEQS, HSEQY, NSF, HSNPY -> Miscellaneous
- HDRLG -> MobileHome

---

## Auto Discount Classification (Response Parsing)

### TryConvertToFrameworkAutoDiscount
**What it does**: Classifies incoming auto discount codes from RSA responses.
**Rules**:
- ATVD, SNOWD -> RecreationalVehicle
- BRYRS, BRYR5, BRYR6 -> LoyaltyBroker
- LDIS -> Loyalty
- LDIS5, LDIS6 -> LoyaltyOccasional
- CONAT, CONSN, CONVF -> ConvictionFree
- CON5F, CON6F -> ConvictionFreeOccasional
- DRTD -> DriverTraining
- DRTD5, DRTD6 -> DriverTrainingOccasional
- FARM -> FarmTPL
- FARM1, FARM1XX -> Farm
- GRAD -> GraduatedLicense
- GRAD05, GRAD06 -> GraduatedLicenseOccasional
- LTDIS -> LongTermPolicy
- LTD5D -> LongTermPolicy05
- LTD6D -> LongTermPolicy06
- MLTPD -> MultiLine
- MLT5D -> MultiLine05
- MLT6D -> MultiLine06
- MVD -> MultiVehicle
- MV5D -> MultiVehicle05
- MV6D -> MultiVehicle06
- NEWVH -> NewVehicle
- NEWV5 -> NewVehicle05
- NEWV6 -> NewVehicle06
- OWNOP -> Miscellaneous
- RETIR -> Retiree
- STNB -> Stability
- STNB5 -> Stability05
- STNB6 -> Stability06
- STUDT -> AwayAtSchool
- TRAIL -> TrailPermit
- WINT, WINA -> WinterTire
- WIN5, WINA5 -> WinterTire05
- WIN6, WINA6 -> WinterTire06
- EXPD, EXPN1, EXPN -> Experience
- STAFF -> NotIdentified
- GRRSA -> GroupRate

---

## Golf Equipment Province Override

### RiskConverter - GolfEquipment
**What it does**: Overrides golf equipment code to sports equipment for certain provinces.
**When it runs**: When a golf equipment scheduled property item is being converted.
**Rules**:
- Default: ZIAGE (All Risk) or ZINGE (Named Perils)
- If province is AB, MB, SK, NS, NB, or PE: override to ZIAEQ (Sports Equipment All Risk) or ZINEQ (Sports Equipment Named Perils)

---

## PAK Endorsement Skipping

### SkipEndorsements
**What it does**: Prevents duplicate endorsement codes when a PAK bundle is present.
**When it runs**: For Ontario and Alberta auto policies only.
**Rules**:
- If a coverage item is identified as a PAK endorsement, retrieve the child endorsements it includes
- Those child endorsements are added to a skip list so they are not sent individually
- This prevents double-counting of PAK-bundled endorsements

---

## Policy Type Mapping

### TryConvertHomeToCsio
**What it does**: Maps framework coverage types to CSIO policy type codes for homeowner policies.
**Rules**:
- Broad Homeshield -> HomeownersBroadForm
- Comp. Homeshield -> HomeownersComprehensiveForm
- Platinum Plus, Comp. Plus -> HomeownersBroadExpandedForm
- Fire and E.C., Fire & E.C. -> BasicResidentialFireECForm

### TryConvertCondoToCsio
**Rules**:
- Basic -> CondominiumPackageStandardForm
- Broad -> CondominiumPackageBroadForm
- Comprehensive, Comp. Condo -> ComprehensiveCondominiumForm
- Fire & Extended Coverage -> BasicResidentialFireECForm
- Platinum -> CondominiumComprehensiveExpandedForm
- Named Perils -> CondominiumPackageStandardForm
- Comp. Plus -> CondominiumComprehensiveExpandedForm
- Platinum Plus -> CondominiumComprehensiveExpandedForm
- Landlordshield -> rsa:2

### TryConvertTenantToCsio
**Rules**:
- Basic, Tenantshield -> TenantsPackageStandardForm
- Broad -> TenantsPackageBroadForm
- Comprehensive -> TenantsComprehensiveForm
- Fire & Extended Coverage -> BasicResidentialFireECForm
- Named Perils -> TenantsPackageStandardForm
- Platinum, Platinum Plus, Comp. Plus -> TenantsComprehensiveExpandedForm
- Tenant Program 65 -> rsa:10
- Comp. Tenant -> TenantsComprehensiveForm

### TryConvertSeasonalToCsio
**Rules**:
- Seasonal Homeshield, Seasonal Comp. Homeshield -> SeasonalDwellingComprehensiveForm
- Named Perils -> SeasonalDwellingLimitedForm
- Homeowners -> SeasonalDwellingComprehensiveForm
- Fire & E.C. -> SeasonalDwellingStandardForm

### Rented Condo
**Rules**:
- Fire & E.C. -> rsa:1
- Landlordshield, Landlord Plus -> rsa:2

### Rented Dwelling
**Rules**:
- Fire & E.C. -> csio:62
- Landlordshield, Landlord Plus -> rsa:5

### FEC
**Rules**:
- Landlordshield, Landlord Plus -> rsa:5
- Fire and E.C. -> csio:62

### Mobile Home
**Rules**:
- Basic -> MobileHomeStandardForm
- Broad -> MobileHomeBroadForm
- Comprehensive -> MobileHomeComprehensiveForm
- Fire & Extended Coverage -> BasicResidentialFireECForm
- Mobile Homeshield -> MobileHomeStandardForm
