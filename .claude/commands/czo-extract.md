# CZO Mapping Extractor

Extract all CZO/CSIO mapping codes for a given insurance carrier from the converter codebase.

## Usage
```
/czo-extract <CarrierName> [outputPath]
```

**Arguments:**
- `CarrierName` (required): The carrier folder name (e.g., Aviva, Intact, Wawanesa, PortageMutual)
- `outputPath` (optional): Where to write the JSON output. Defaults to `E:\cssi\Cssi.Net\Components\Cssi.Schemas\Cssi.Schemas.Csio.Converters\extracts\<CarrierName>_czo_mapping.json`

**Input provided:** $ARGUMENTS

---

## Instructions

You are an enterprise-grade CZO/CSIO mapping extractor. Your job is to produce a **complete, verified** JSON file containing every CZO code, coverage mapping, discount, surcharge, endorsement, and enum value that gets sent to or received from the specified carrier.

### Tool Available

**VB Parser** (MUST use for all VB.NET file reading — it is the most reliable method):
```
"C:\Users\tariqusama\.claude\plugins\cache\iq-update-marketplace\iq-update\0.5.3\tools\win-x64\vb-parser.exe" parse "<filepath>"
```
Returns JSON with: functions, parameters, selectCases, assignments, localVariables, complexity metrics.

### Codebase Location
```
E:\cssi\Cssi.Net\Components\Cssi.Schemas\Cssi.Schemas.Csio.Converters
```

### Architecture Overview

The converter codebase uses **versioned folders with inheritance**:
- `v043/` = base version (1400+ files, ALL carriers inherit from here)
- `V044/` through `V149/` = incremental overrides
- Each version has `Generic/` (shared) and `Companies/<CarrierName>/` (carrier-specific)
- **Latest version wins**: system checks latest version first, falls back to earlier versions
- Company-specific code overrides Generic code at the same version level

Each version/company folder contains:
- `FrameworkToCsio/Unrated/` — TBW → CZO XML (outbound request)
- `FrameworkToCsio/Rated/` — TBW → CZO XML (rated request, usually empty for companies)
- `CsioToFramework/Unrated/` — CZO XML → TBW (inbound response parsing, unrated)
- `CsioToFramework/Rated/` — CZO XML → TBW (inbound response parsing, rated)
- `EnumConverters/` — Value-to-value lookup tables
- `CompanyConstants.vb` — All carrier-specific CZO code constants
- `CsioConstants.vb` — Additional CSIO constants
- `CommonConverters/`, `BaseTypeConverters/`, `Helpers/` — Supporting code

### Extraction Methodology (Execute ALL Steps)

**PHASE 1: Discovery — Find all carrier-specific files**

1. Search ALL version folders for the carrier's company directory:
   ```
   ls E:/cssi/Cssi.Net/Components/Cssi.Schemas/Cssi.Schemas.Csio.Converters/*/Companies/<CarrierName>/ 2>/dev/null
   ```

2. For each version found, list ALL .vb files recursively:
   ```
   find "E:/cssi/Cssi.Net/Components/Cssi.Schemas/Cssi.Schemas.Csio.Converters/<Version>/Companies/<CarrierName>/" -name "*.vb"
   ```

3. Check which versions actively route this carrier by reading ConverterFactoryLoader.vb in the latest versions (V149, V148, V146, V145, V141, V137, V134).

**PHASE 2: Extract Constants — The Code Dictionary**

4. Parse ALL CompanyConstants.vb files (each version that has one):
   ```
   vb-parser.exe parse "<version>/Companies/<CarrierName>/CompanyConstants.vb"
   ```
   Extract every `Public Const` — these are the carrier's CZO code values.

5. Parse ALL CsioConstants.vb files:
   ```
   vb-parser.exe parse "<version>/Companies/<CarrierName>/CsioConstants.vb"
   ```

**PHASE 3: Extract EnumConverters — The Value Mapping Tables**

6. Parse EVERY EnumConverter file for the carrier across ALL versions. Priority order:
   - `CoverageCodeConverter.vb` (MOST IMPORTANT — contains coverage, endorsement, discount, surcharge mappings)
   - `MultiPolicyDiscountConverter.vb`
   - `PolicyTypeConverter.vb`
   - `OccupancyTypeConverter.vb`
   - ALL other enum converters

7. For each enum converter, extract:
   - Inheritance chain (what base class it overrides)
   - Every Select Case block mapping: Framework value → CZO code
   - Every `Case Else → MyBase` fallthrough (indicates generic base is used)

**PHASE 4: Extract Generic Base — The Foundation Aviva Inherits**

8. Parse the GENERIC CoverageCodeConverter that the carrier inherits from. Trace the inheritance:
   - Read the carrier's CoverageCodeConverter to find `Inherits <BaseClass>`
   - Parse that base class file
   - Continue up the chain to v043

9. Parse the generic base `v043/Generic/EnumConverters/CoverageCodeConverter.vb` — this has ~2000 lines with ALL foundational coverage codes.

10. Also parse `v043/Generic/EnumConverters/CoverageOptionConverter.vb` for home business type codes.

**PHASE 5: Extract FrameworkToCsio Converters — Outbound Mapping Logic**

11. Parse ALL `FrameworkToCsio/Unrated/*.vb` files for the carrier across ALL versions. Key files:
    - `PcCoverageConverter.vb` — THE most important file (coverage code assignments, endorsement logic, limit/deductible calculations)
    - `PcCoverageCollectionConverter.vb` — Orchestrates vehicle and hab coverage collections, adds discounts/surcharges
    - `CreditOrSurchargeConverter.vb` — Credit/surcharge conversion
    - `DwellConverter.vb`, `DwellRatingConverter.vb`, `DwellOccupancyConverter.vb` — Dwelling details
    - `ConstructionConverter.vb` — Construction type mapping
    - `PcPolicyConverter.vb` — Group discount/tier mapping
    - `PersPolicyConverter.vb` — Combined policy / multi-line discount logic
    - ALL other converter files

12. For each converter, extract:
    - Class name and inheritance
    - Every Select Case mapping
    - Every assignment that sets a CZO field (CoverageCd, Limit, Deductible, etc.)
    - String literals containing "csio:" codes
    - Province-specific logic branches

**PHASE 6: Extract CsioToFramework Converters — Response Parsing**

13. Parse ALL `CsioToFramework/Rated/*.vb` files. Key file:
    - `PcCoverageConverter.vb` — Contains `IsDiscount()` and `IsSurcharge()` classification patterns

14. Parse ALL `CsioToFramework/Unrated/*.vb` files.

15. Extract:
    - IsDiscount prefix patterns (what patterns identify discounts in responses)
    - IsSurcharge prefix patterns
    - Any CZO codes not found in CompanyConstants
    - Driver record field mappings
    - Rate class / territory mappings

**PHASE 7: Compile and Verify**

16. Cross-reference all findings:
    - Every code in CompanyConstants should appear in at least one converter
    - Every converter that references CompanyConstants should have its codes captured
    - Flag any "orphan" codes (in constants but not used) or "undeclared" codes (in code but not in constants)

17. Produce the output JSON with these sections:
    - `_metadata` — carrier name, versions, extraction date, file counts
    - `coverageCodes` — organized by: autoEndorsements, homeEndorsements, homeLiabilities, watercraftLiability, scheduledPropertyItems
    - `discountCodes` — organized by: autoDiscounts, autoSurcharges, habDiscounts, habSurcharges, tierCodes
    - `genericBaseCodes` — the foundational codes inherited from generic base (NOT overridden by carrier)
    - `enumMappings` — policyTypes, vehicleBodyTypes, constructionTypes, fireProtection, convictionCodes, lapseReasons, etc.
    - `fieldMappings` — specific TBW fields to CZO XML element mappings with conditions
    - `responseClassification` — IsDiscount/IsSurcharge patterns
    - `zCodeInventory` — complete list of carrier-proprietary Z-codes
    - `provinceSpecificLogic` — any mappings that vary by province
    - `verificationReport` — orphan codes, undeclared codes, confidence assessment

18. Write the JSON to the output path.

### Important Rules

- Use VB Parser for ALL file parsing — never try to regex VB.NET code manually
- Launch up to 3 subagents in parallel to speed up extraction
- Parse files from the LATEST version first, then work backwards
- Always check the inheritance chain — a carrier may use 90% generic code
- Z-codes (starting with Z after csio:) are carrier-proprietary and MUST be captured
- Standard CSIO codes (resolved via _enumValuesFactory) should be noted as "standard" vs carrier-specific
- Province-specific logic is critical — note which codes vary by province
