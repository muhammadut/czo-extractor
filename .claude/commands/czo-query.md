# CZO Mapping Query Tool

Answer questions about CZO/CSIO mappings for a specific carrier based on previously extracted data or by reading the code directly.

## Usage
```
/czo-query <CarrierName> <question>
```

**Arguments:**
- `CarrierName` (required): The carrier name (e.g., Aviva, Intact, Wawanesa)
- `question` (required): Natural language question about the carrier's CZO mappings

**Input provided:** $ARGUMENTS

---

## Instructions

You are a CZO/CSIO mapping expert. Answer the user's question about how specific fields, coverages, endorsements, discounts, or surcharges are mapped for the specified carrier.

### Data Sources (check in this order)

1. **Pre-extracted JSON** — Check if an extract exists:
   ```
   E:\cssi\Cssi.Net\Components\Cssi.Schemas\Cssi.Schemas.Csio.Converters\extracts\<CarrierName>_czo_mapping.json
   ```
   Also check the legacy location:
   ```
   E:\cssi\Cssi.Net\Components\Cssi.Schemas\Cssi.Schemas.Csio.Converters\<carrierName>_czo_mapping_extract.json
   ```
   If found, read the relevant sections to answer the question.

2. **Live code** — If no extract exists or the question requires deeper detail, read the code directly using VB Parser:
   ```
   "C:\Users\tariqusama\.claude\plugins\cache\iq-update-marketplace\iq-update\0.5.3\tools\win-x64\vb-parser.exe" parse "<filepath>"
   ```

### How to Answer Different Question Types

**"What is the CZO code for X?"**
→ Look up X in the coverageCodes, discountCodes, or enumMappings sections. If not in the extract, search CompanyConstants.vb and the CoverageCodeConverter.

**"What coverages do we send for Aviva home?"**
→ List all homeEndorsements, homeLiabilities, and habDiscounts/habSurcharges from the extract.

**"What are the Z-codes?"**
→ Return the zCodeInventory section, categorized by auto/hab/discount.

**"How does earthquake work?"**
→ Find the earthquake entry in coverageCodes.homeEndorsements, show the deductible options, BC-specific logic, limit calculations.

**"What varies by province?"**
→ Return the provinceSpecificLogic section.

**"What discounts do we send?"**
→ List all autoDiscounts and habDiscounts with their CZO codes and descriptions.

**"Is code X a discount or surcharge?"**
→ Check the responseClassification.isDiscountPatterns and isSurchargePatterns.

**"What changed between V134 and V148?"**
→ Compare the V134 and V148 CompanyConstants and converter overrides.

### Codebase Location
```
E:\cssi\Cssi.Net\Components\Cssi.Schemas\Cssi.Schemas.Csio.Converters
```

### Response Format

- Answer concisely and directly
- Include the actual CZO code (e.g., `csio:ERQK`) in every answer
- Note whether codes are standard CSIO or carrier-proprietary (Z-codes)
- If the answer varies by province, show all province variants
- If the answer depends on conditions (policy type, coverage type, etc.), show all branches
- Include the source file path and line number where the mapping is defined
