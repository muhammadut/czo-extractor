---
description: Extract all CZO/CSIO mapping codes for an insurance carrier. Output saved to .czo-extraction/carriers/<CarrierName>/<date>.json
---

Extract CZO mappings for carrier: $ARGUMENTS

You MUST launch the `czo-extractor` agent as a subagent to perform this extraction. Use the Agent tool with `subagent_type: "czo-extractor"` or spawn a general-purpose agent and paste the full extraction methodology from the czo-extractor agent definition.

The agent should:
1. Auto-detect the VB Parser from the iq-update plugin cache (search `$HOME/.claude/plugins/cache`)
2. Auto-detect the converter codebase (look for `v043/` folder)
3. Find all version folders with carrier-specific code for the specified carrier
4. Execute the full 7-phase extraction: Discovery → Constants → EnumConverters → Generic Base → FrameworkToCsio → CsioToFramework → Compile & Verify
5. Write output to `.czo-extraction/carriers/<CarrierName>/<today's date>.json`
6. Copy to `.czo-extraction/carriers/<CarrierName>/latest.json`
7. Update `history.json`, `inventory.json`, and `config.json`

After the agent completes, report back with:
- Carrier name
- Total CZO codes found (carrier-specific + generic inherited)
- Z-code count (carrier-proprietary codes)
- Files processed
- Versions covered
- Output file path
- Any verification warnings
