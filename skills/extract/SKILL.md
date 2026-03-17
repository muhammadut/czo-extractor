---
description: Extract all CZO/CSIO mapping codes for an insurance carrier. Output saved to .czo-extraction/carriers/<CarrierName>/<date>.json
---

Extract CZO mappings for carrier: $ARGUMENTS

Launch the `czo-extractor` agent to perform this extraction. The agent is defined in this plugin's `agents/czo-extractor.md`. Invoke it as a subagent using the Agent tool so the extraction runs in an isolated context.

The agent will:
1. Auto-detect the VB Parser (bundled with this plugin at `tools/win-x64/vb-parser.exe`)
2. Auto-detect the converter codebase (look for `v043/` folder in current directory)
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
