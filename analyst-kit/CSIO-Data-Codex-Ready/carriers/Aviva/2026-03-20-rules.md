# Aviva CZO Business Rules
**Extracted**: 2026-03-20
**Versions**: V132 (Legacy), V134 (BAU), V148 (Guidewire)

---

## Auto Endorsements

### ConvertEndorsementCoverageCd (PcCoverageConverter)
**What it does**: Determines which CZO coverage code to send for each auto endorsement
**When it runs**: For every auto endorsement on a vehicle being sent outbound

**Rules**:
- Endorsement 43RL:
  - If province = AB: send csio:43L (V148) or csio:43RL (V134)
  - Otherwise: fall through to generic handler
- Endorsement 39 (Claims Protector):
  - If province = NS/PE/NB AND coverage type = "Occasional Operators": send csio:ZOCP
  - If province = NS/PE/NB AND coverage type = "Principal Operators" or "Principal + Occasional Operators": send standard Claims Protection Plan code
  - If province = NS/PE/NB AND form number = csio:ZPR2: send csio:ZPR2 (Extended Claim Protector)
  - If other province AND coverage type = "Occasional Operators": send csio:ZOCC (V134) or standard End39 (V148)
  - V148 always sends standard End39 code regardless of coverage type
- Driving Record Protector Convictions:
  - If coverage type = "Occasional Operator": send csio:MCPOD
  - Otherwise: send csio:MCP
- Emergency Assistance Package:
  - V134: Uses form number to distinguish ZRPS vs ZRRA vs ZRPP; first vehicle gets SRAP, subsequent get ZRPS
  - V148: If parent = Private Passenger Vehicle: send standard Enhanced Roadside Assistance Program code; If parent = Motorcycle: send csio:35 (OPCF 35)
- Short Term Rental: Uses CoverageType to select csio:ZSTR1 (90 days), csio:ZSTR2 (180 days), or csio:ZSTR3 (365 days)
- Disappearing Deductible (Auto):
  - V148: Always sends standard End26 code
  - V134: If province = AB/NB/ON: send csio:26; otherwise send csio:LWD
- OPCF 43: V148 sends standard End43 code; V134 uses coverage type to select csio:18 (NPCF43O) or csio:Z096 (NPCF096)
- OPCF 43A: V148 sends standard End43A code; V134 uses coverage type for csio:43S
- Vehicle Sharing: V148 sends standard PermissionToRentOrLeaseTheVehicleForCarsharing; V134 sends csio:Z05S

**Codes sent**: csio:43L, csio:43RL, csio:ZOCP, csio:ZOCC, csio:ZPR2, csio:MCPOD, csio:MCP, csio:ZRPP, csio:ZRPS, csio:SRAP, csio:ZRRA, csio:ZSTR1-3, csio:26, csio:LWD, csio:18, csio:Z096, csio:43S, csio:Z05S, csio:5CS, csio:35

---

### ConvertToPersVeh (PcCoverageCollectionConverter)
**What it does**: Adds vehicle-level coverages, discounts, and surcharges to the outbound XML
**When it runs**: For every vehicle being processed for outbound submission

**Rules**:
- If province = NS/PE/NB AND endorsement 39 exists AND coverage type = "Principal + Occasional Operators": add extra ZOCP coverage
- If vehicle = Motorcycle AND province = AB/ON: swap proprietary PersonalEffects (Z091) to standard PEPRE code
  - V148 no longer swaps AccessoriesExtension (handled by CoverageCodeConverter override)
- Right Hand Drive: If province is not AB AND steering wheel position = "Right": add csio:ZRHDS (V134) or csio:SURRH (V148)
- Web Discount: If company field "WebDiscount" = "Yes": add csio:ZINTD
  - V148 does NOT add web discount (removed from ConvertToPersVeh)
- Multi-Vehicle Discount: If field "MultiVehicleDiscountOverride" = "Yes": add standard DiscountMultiVehicle code
- Car and Home Discount: If field "DualPolicyDiscountOverride" = "Yes": add standard DiscountMultipleLine code
- Advanced Safety Feature Discount:
  - If province = ON AND anti-theft device = True: add csio:ZASFO
  - If province = AB AND anti-theft device = True: add DISAL with id "DIS-9"
  - V148 does NOT add this discount (removed)
- Anti-Lock Brakes Discount:
  - If province = ON/AB AND override = "Override (Apply Discount)": add ZASFO with id "DIS-8"
  - V148 does NOT add this discount (removed)
- US Exposure Surcharge: If province is not ON AND not recreational vehicle AND US exposure > 0: add standard SurchargeUsNonCanadianExposure
- Motorcycle and Home Discount: If field "Multiline" = "True": add standard DiscountMultipleLine code
- Stand-Alone Surcharge: Check deviations for "Standalone Surcharge" -> add csio:SURML; "All Terrain Surcharge" -> add ZSTAS
- Continuous Prior Insurance Discount: NB only - if FormNo = csio:ZCPID: add csio:ZCPID
- Anti-Theft Discount (PE only for Aviva Traders): Check alarm devices, send standard DiscountAlarmSystem

**Codes sent**: csio:ZOCP, csio:ZRHDS, csio:SURRH, csio:ZINTD, csio:ZASFO, DISAL, ZASFO, csio:SURML, ZSTAS, csio:ZCPID

---

### ConvertAutoDeviations
**What it does**: Converts custom motorcycle discounts/surcharges from deviation entries
**When it runs**: For motorcycle deviations with category = CustomDiscountSurcharge

**Rules**:
- If deviation mapping code = DriverTraining AND description = "Rider Training Discount": send csio:ZRTDS
- If deviation mapping code = DriverTraining AND description = "Advanced Rider Training Discount": send csio:ZARTD
- If deviation mapping code = MultiLine AND description = "Motorcycle and Home Discount - Family Members": send ZMHFM

**Codes sent**: csio:ZRTDS, csio:ZARTD, ZMHFM

---

## Auto Discount/Surcharge Mapping (CoverageCodeConverter)

### TryConvertToCsioAutoDiscount (V134)
**What it does**: Maps framework DiscountCode values to CZO discount codes for outbound
**When it runs**: For motorcycle policies via V134 CoverageCodeConverter

**Rules**:
- DriverTraining -> csio:ZARTD (Advanced Rider Training)
- MultiMotorcycle -> csio:DISMM
- Miscellaneous -> csio:ZVMDS (Vintage Discount)
- MultiLine -> ZMHFM (Motorcycle and Home - Family Members)

### TryConvertToFrameworkAutoDiscount (V134)
**What it does**: Maps CZO discount codes back to framework DiscountCode values for inbound
**When it runs**: When parsing responses from Aviva

**Rules**:
- csio:ZT2, csio:ZT0 -> Territory discount
- csio:ZT3 -> Territory discount
- csio:ZINTD -> Web discount
- csio:DISCP, csio:ZCOMB -> Combined Policy discount
- csio:DISAB, csio:ZAEBS -> Automatic Emergency Braking discount
- csio:DISSV, csio:ZSTBL -> Stability discount
- csio:ZNB0 -> New Business discount
- csio:ZCFD7, ZCFD8, ZCFD3, ZCFD5 -> Claims Free discount
- csio:ZEXP1-6, ZEXP9, ZEX10-14, ZEXPM -> Experience discount
- csio:ZLOY1-3 -> Loyalty discount
- csio:ZFOY3-5, ZFFY3-5, ZFFN0-2, ZFMY2-5 -> First Chance discount
- csio:ZFON0-2 -> First Chance Occasional discount
- csio:ZSAFE -> Stay Safe discount
- csio:ZPKDI -> Package discount
- csio:DISMI -> Mature Citizen discount
- csio:ZCLSD -> New Driver (Clean Start) discount
- csio:ZSHC2 -> Short Commute discount
- csio:ZCPID -> Continuous Prior Insurance discount
- csio:DISEM -> Occupation (Employee) discount
- csio:DISTE -> Usage Based Insurance (Telematics) discount
- csio:ZASFO -> Anti-Theft discount
- csio:ZASFI -> Anti-Lock Brakes discount
- csio:DISHY, csio:HYDS -> Hybrid discount
- csio:DISEL, csio:EVDS -> Electric discount
- csio:DISAD -> Theft Recovery Device discount (Anti-Theft)
- csio:DISTR -> Territorial discount
- DISAL -> Anti-Theft discount
- ZASFO -> Anti-Lock Brakes discount

---

## Hab Endorsements

### ConvertHabCoverages (PcCoverageCollectionConverter)
**What it does**: Adds hab-level coverages, discounts, and surcharges
**When it runs**: For every dwelling being processed

**Rules**:
- If bare land condo AND policy type = Home/Seasonal/FEC: add csio:ZHCEL (Loss Assessment Endorsement)
- If endorsement ClaimsPreventionDisappearingDeductible exists: add csio:CLFRE (Claims Protector) + csio:LWD (Disappearing Deductible) if those individual endorsements are not already present
- If endorsement ClaimsPreventionHomeRepair exists: add csio:ZLPE (Claims Prevention) + csio:ZREP1 (Home Repair) if not already present
- If endorsement WaterCoverage exists: check for reverse slope driveway surcharge -> add csio:ZRSDS
- If seasonal dwelling AND coverage type = "Fire and E.C.":
  - If Burglary field = True: add csio:BURG with contents limit
  - If Vandalism field = True: add csio:VMBC with combined limit
- Basement Apartment Surcharge: If suite type has value: add csio:ZBAP1
- Centrally Monitored Water Alarm Discount: add csio:ZCWAD
- Septic System Discount: add csio:DISSS
- Non-Smoker Discount: add csio:DISNS
- Multi-Residence Discount: add standard codes
- Broker Discretionary Discount: add csio:ZSB05/ZSB10/ZSB15 or csio:ZSBDD

**Codes sent**: csio:ZHCEL, csio:CLFRE, csio:LWD, csio:ZLPE, csio:ZREP1, csio:ZRSDS, csio:BURG, csio:VMBC, csio:ZBAP1, csio:ZCWAD, csio:DISSS, csio:DISNS, csio:ZSB05/10/15, csio:ZSBDD

---

### ConvertEarthquakeCoverageCd
**What it does**: Sets the earthquake coverage code and deductible
**When it runs**: When earthquake endorsement is being converted

**Rules**:
- Base earthquake code is always csio:ERQK
- Deductible determination:
  - EQH2/EQN2/EQT2: deductible = 2%
  - EQH5/EQN5/EQT5: deductible = 5%
- BC-specific earthquake codes (additional deductible tiers):
  - EQTC/EQ1T/EQ1A/EQA2/EQA3/EQA4: deductible = 5%
  - EQ3T/EQ3A/EQB2/EQB3/EQB4/EQT8: deductible = 8%
  - EQ2T/EQ2A/EQC2/EQC3/EQC4/EQT1: deductible = 10%
  - EQ4A/EQ4T/EQD2/EQD3/EQD4/EQTF: deductible = 15%
  - EQ5A/EQ5T/EQD5/EQD6/EQD7/EQTG: deductible = 20%
- BC earthquake option codes:
  - Codes ending in "A": OptionCd = Building
  - Codes ending in "T": OptionCd = Building + Contents + Other (3 options)
  - All other codes: OptionCd = Contents
- Earthquake limits (BC):
  - EQD2/EQD5: 75% of property value
  - EQD3/EQA3/EQB3/EQC3/EQD6: 50% of property value
  - EQD4/EQA4/EQC4/EQD7: 25% of property value

**Codes sent**: csio:ERQK, csio:ZEQLE

---

### ConvertBuildingBylawsExtension
**What it does**: Selects building bylaw code based on province and coverage type
**When it runs**: When building bylaws endorsement is being converted

**Rules**:
- Default code: csio:BYLAW
- If province = BC/AB AND company = Aviva Traders:
  - Coverage = "BYLW - Dolce Vita": send csio:ZBYLW
  - Coverage = "BYLS - Dolce Vita": send csio:ZBYLS
  - Otherwise: send csio:BYLAW

**Codes sent**: csio:BYLAW, csio:ZBYLW, csio:ZBYLS

---

### ConvertBusinessUseOfHomeCoverageCd
**What it does**: Selects the business-use-of-home liability code based on profession type
**When it runs**: When home-based business liability is being converted (ON only)

**Rules**:
- If province = ON:
  - Type = "Accountant": send csio:ZACT
  - Type = "Dentist": send csio:ZDNT
  - Type = "Doctor": send csio:ZDOC
  - Type = "Insurance Agent": send csio:ZAGT

**Codes sent**: csio:ZACT, csio:ZDNT, csio:ZDOC, csio:ZAGT

---

### ConvertSolarEnergySystemCoverageCd / ConvertWindEnergySystemCoverageCd
**What it does**: Selects green energy liability codes
**When it runs**: When solar/wind energy liability endorsements are converted

**Rules**:
- Solar: If leased = True: send csio:ZGSL; If connected to grid = True: send csio:ZGSR
- Wind: If leased = True: send csio:ZGWL; If connected to grid = True: send csio:ZGWD

**Codes sent**: csio:ZGSL, csio:ZGSR, csio:ZGWL, csio:ZGWD

---

## Group Discount Tier Mapping (PcPolicyConverter)

### GetGroupDiscount
**What it does**: Maps group discount names to tier codes by province and policy type
**When it runs**: When TierCd is being set on the policy

**Rules** (selected examples):
- Home Hardware (7875):
  - AB Auto: G2 | AB Hab: H2
  - BC Auto: No Discount | BC Hab: D3
  - ON Auto: TF | ON Hab: D3
- Home Hardware Alberta (1050) / Home Hardware (1050):
  - AB Auto: G2 | AB Hab: H2
  - ON Auto: T3 | ON Hab: D2
- Home Hardware VIP (20473):
  - AB Auto: G4 | AB Hab: H5
  - ON Auto: TF | ON Hab: D3
- WinSPORT Full-Time (2483):
  - AB Auto: K0 | AB Hab: H4
- WinSPORT Affinity (2484):
  - AB Auto: K0 | AB Hab: B3
- Non-Member Group (784):
  - AB Auto: No Discount | AB Hab: H2
  - ON Auto: No Discount | ON Hab: D0
- PIB/RAM Group (957) / Employees (958):
  - ON Auto: TF | ON Hab: D3

---

## Hab Discount/Surcharge Mapping (CoverageCodeConverter)

### TryConvertToFrameworkHabDiscount (V134)
**What it does**: Maps CZO hab discount codes to framework DiscountCode values

**Rules**:
- csio:ZNH03-ZNH20 -> New Home discount (13 tiers by year)
- csio:ZML05 -> Multi-Line discount
- csio:ZML10, csio:DISCP, csio:ZCOMB -> Combined Policy discount
- csio:ZD1-ZD3 -> Territory discount (hab tier)
- csio:ZLOYD, ZLOY1-3 -> Loyalty discount
- csio:ZE1, ZNE-ZNH, csio:DISGD -> Group Rate discount
- csio:ZRDNW, csio:ZRFDS -> Roof discount
- csio:ZPV -> Occupation (Employee) discount
- csio:ZNB0, ZNBD1-2, ZYR01 -> New Business discount
- csio:DISWS -> Water Alarm Device discount
- csio:ZSB05/10/15, csio:ZSBDD -> Discretionary discount
- csio:DISSS -> Septic System discount
- csio:ZBKUP -> Backwater Valve discount
- csio:ZCWAD -> Water Leak Detection System discount
- csio:ZASMP -> Automatic Sump Pump discount
- csio:DISNS -> Non-Smoker discount
- csio:DISMA -> Age of Home discount
- csio:DISEV, csio:ZHEDR -> Evaluator discount

### TryConvertToFrameworkHabSurcharge (V134)
**What it does**: Maps CZO hab surcharge codes to framework SurchargeCode values

**Rules**:
- csio:ZCS30, ZCS45, ZCS60, csio:SURCL -> Claims surcharge
- csio:ZS1-S3 -> Tier surcharge
- ZVACP -> Vacancy surcharge
- csio:ZRSDS -> Reverse Slope Driveway surcharge
- csio:ZBAP1 -> Suites (Basement Apartment) surcharge
- csio:SURUC -> Under Construction surcharge

---

## Version Differences (V148 vs V134)

### Codes Added in V148
- csio:28C, csio:19B (standard endorsement codes added)
- csio:CDEDE (Condominium Deductible Assessment Earthquake Excluded)
- csio:SURRH (Right Hand Drive standard code, replaces csio:ZRHDS)
- csio:5CS (Vehicle Sharing standard code, replaces csio:Z05S)
- csio:35 (OPCF 35 for motorcycle emergency assistance)
- csio:UAOD (Uninsured Automobile Occasional Driver - inline, not in constants)
- csio:HYDS, csio:EVDS (Hybrid/Electric Vehicle Discount standard codes)
- csio:DISEL, csio:DISAD (Electric/Theft Recovery standard discount codes)
- csio:ZYR01 (New Business Discount Year 1)
- Sump pump types now use csio: prefix codes (csio:01, csio:02, csio:04)

### Codes Removed from V148 (present only in V134)
- csio:Z43S (Replacement/Repair Cost - V148 uses standard ReplacementCostSpecifiedLessee)
- csio:Z05S (Vehicle Sharing proprietary - V148 uses standard 5CS via PermissionToRentOrLeaseTheVehicleForCarsharing)
- csio:Z098 (Accessories Extension proprietary - V148 uses standard 25A)
- csio:Z092 (Vacation Expense - V148 uses standard MotorcycleVacationExpense)
- csio:ZRHDS (Right Hand Drive proprietary - V148 uses standard SurchargeRightHandDrive)
- csio:LWD (Disappearing Deductible proprietary - V148 uses standard DecreasingDeductibleEndorsement)

### Logic Changes in V148
- Emergency Assistance Package: V148 distinguishes by parent vehicle type (PPV vs motorcycle); V134 uses form number
- Endorsement 39: V148 always sends standard End39 code; V134 sends province-specific proprietary codes
- OPCF 43/43A: V148 sends standard codes; V134 maps to proprietary csio:18/csio:Z096/csio:43S based on coverage type
- Disappearing Deductible: V148 always uses standard End26 for auto; V134 varies by province
- Environmental Friendly Replacement: V148 uses standard EnvironmentallyFriendlyHomeReplacementLossSettlement; V134 uses csio:ZGRNE
- Roof/Siding Limitation: V148 uses standard LimitedRoofSurface; V134 uses csio:ZRSLE
- Golf Cart: V148 uses standard GolfCarts code; V134 uses csio:GOLFC
- Web Discount: V148 does NOT add web discount at vehicle level (removed from ConvertToPersVeh)
- Advanced Safety Feature / Anti-Lock Brakes: V148 removes these discounts from ConvertToPersVeh
- V148 CoverageCodeConverter inherits from V134 and adds GroupRateOccasional, AntiTheftDevice, AntiTheft discount mappings via standard CSIO enum values
- V148 adds Opcf08 mapping using End8A for Ontario auto endorsements

### Inheritance Chain
- V148 CoverageCodeConverter -> V134.Companies.Aviva.EnumConverters.CoverageCodeConverter -> V134.Generic.EnumConverters.CoverageCodeConverter -> v043 Generic base
- V148 PcCoverageConverter -> V134.Companies.Aviva.FrameworkToCsio.Unrated.PcCoverageConverter -> V128.Generic
- V148 PcCoverageCollectionConverter -> V136.Generic (skips V134 company-specific!)
- V148 PolicyTypeConverter -> V118.Generic (skips V134 company-specific!)
