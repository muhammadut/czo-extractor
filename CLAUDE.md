# CZO Converter Project

## Available Commands

This project has custom slash commands for extracting and querying CZO/CSIO mapping codes from the converter codebase:

### `/czo-extract <CarrierName>`
Extracts ALL CZO mapping codes for a given insurance carrier. Produces a comprehensive JSON file with coverages, endorsements, discounts, surcharges, Z-codes, and enum mappings.

```
/czo-extract Aviva           # Already done — see extracts/Aviva_czo_mapping.json
/czo-extract Intact           # Extract for Intact
/czo-extract Wawanesa         # Extract for Wawanesa
/czo-extract PortageMutual    # Extract for Portage Mutual
```

Output goes to `extracts/<CarrierName>_czo_mapping.json`.

### `/czo-query <CarrierName> <question>`
Answer questions about a carrier's CZO mappings based on extracted data or by reading the code directly.

```
/czo-query Aviva What earthquake codes do we send in BC?
/czo-query Aviva List all Z-codes
/czo-query Aviva What discounts do we send for home?
/czo-query Aviva What changed between V134 and V148?
```

## Tool Dependency

These commands use the VB Parser for reliable VB.NET code analysis:
```
C:\Users\tariqusama\.claude\plugins\cache\iq-update-marketplace\iq-update\0.5.3\tools\win-x64\vb-parser.exe
```

## Extracted Data

- `extracts/Aviva_czo_mapping.json` — Complete Aviva extraction (carrier-specific + generic base + response classification)
- `extracts/carrier_inventory.json` — All 23 carriers with custom code + 27 generic-only carriers

## Architecture Quick Reference

- **v043/** = base version (1400+ files, all carriers inherit from here)
- **V044/** through **V149/** = incremental overrides via class inheritance
- **Generic/** = shared code for all carriers
- **Companies/<CarrierName>/** = carrier-specific overrides
- **FrameworkToCsio/** = TBW → CZO XML (outbound request)
- **CsioToFramework/** = CZO XML → TBW (inbound response)
- **EnumConverters/** = value-to-value lookup tables
- **CompanyConstants.vb** = carrier's CZO code dictionary
