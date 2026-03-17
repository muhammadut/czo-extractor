---
description: List all carriers and their extraction status. Shows which carriers have been extracted, when, and which are pending.
---

List carriers: $ARGUMENTS

Read `.czo-extraction/inventory.json` if it exists. Also scan the converter codebase to find all carriers with custom code by listing `*/Companies/*/` directories.

Present a table:

| Carrier | Custom Code | Latest Version | Last Extracted | Total Codes | Status |
|---------|------------|----------------|---------------|-------------|--------|

For each carrier found in `*/Companies/*/`:
- Count .vb files across versions
- Check if it appears in inventory.json (extracted vs pending)
- Show the last extraction date if available

If arguments contain "pending" or "remaining", only show un-extracted carriers.
If arguments contain "done" or "extracted", only show extracted carriers.

End with a summary: "X of Y carriers extracted. Run `/czo-extractor:extract <Carrier>` to extract the next one."
