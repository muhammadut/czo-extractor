# CZO Extractor Plugin

Extract and query CZO/CSIO mapping codes from VB.NET converter codebases for any insurance carrier.

## Installation

```bash
# Add marketplace
claude plugin marketplace add https://github.com/muhammadut/czo-extractor/.claude-plugin/marketplace.json

# Install plugin
claude plugin install czo-extractor@czo-extractor-marketplace
```

Or for local development:
```bash
claude --plugin-dir ./path/to/czo-extractor
```

## Skills

### `/czo-extractor:extract <CarrierName>`
Extracts ALL CZO mapping codes for a carrier. Runs as an isolated subagent using the VB Parser. Produces a comprehensive JSON with coverages, endorsements, discounts, surcharges, Z-codes, and enum mappings.

```
/czo-extractor:extract Aviva
/czo-extractor:extract Intact
/czo-extractor:extract Wawanesa
/czo-extractor:extract PortageMutual
```

Output: `extracts/<CarrierName>_czo_mapping.json`

### `/czo-extractor:query <CarrierName> <question>`
Answer questions about a carrier's CZO mappings from extracted data or live code.

```
/czo-extractor:query Aviva What earthquake codes do we send in BC?
/czo-extractor:query Aviva List all Z-codes
/czo-extractor:query Aviva What discounts do we send for home?
```

## Dependency

Requires the VB Parser tool (bundled with the `iq-update` plugin). The agent auto-detects the parser location from the iq-update plugin cache. If not found, install iq-update first or provide the path manually.

## Architecture Quick Reference

The converter codebase uses versioned folders with inheritance:
- **v043/** = base version (1400+ files, all carriers inherit from here)
- **V044/** through **V149/** = incremental overrides via class inheritance
- **Generic/** = shared code for all carriers
- **Companies/\<CarrierName\>/** = carrier-specific overrides
- **FrameworkToCsio/** = TBW to CZO XML (outbound request)
- **CsioToFramework/** = CZO XML to TBW (inbound response)
- **EnumConverters/** = value-to-value lookup tables
- **CompanyConstants.vb** = carrier's CZO code dictionary
