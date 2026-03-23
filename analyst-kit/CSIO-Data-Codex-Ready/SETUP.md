# CSIO Mapping Analyst Kit — Setup Guide

## What You're Getting

A folder of JSON files containing every CSIO code our system sends to each insurance carrier. You can use Codex to query this data, create Excel reports, compare carriers, and answer mapping questions — without touching any code.

## Setup (One Time)

### Step 1: Unzip the package

Unzip the file you received to a folder, for example:
```
CSIO-Data-Codex-Ready/
```

You should see:
```
CSIO-Data-Codex-Ready/
├── AGENTS.md                    ← Codex reads this automatically
├── SETUP.md                     ← This file
├── inventory.json               ← All carriers and their status
├── .codex/skills/csio-query/    ← Slash command for Codex
└── carriers/
    ├── Aviva/
    │   ├── latest.json          ← Aviva's CSIO mappings
    │   └── history.json
    ├── Intact/
    │   ├── latest.json
    │   └── history.json
    └── ...
```

### Step 2: Open Codex in that folder

```bash
cd CSIO-Data-Codex-Ready
codex
```

Codex will automatically read AGENTS.md and understand the data structure.

## Usage

### Ask questions in plain English

Just type your question. Codex knows the JSON structure and will find the answer.

```
What earthquake codes does Aviva send?
List all Z-codes for Aviva
What home discounts does Intact offer?
What codes are only in V148 Guidewire for Aviva?
```

### Use the slash command

Type `/csio-query` followed by your question for a more structured experience:
```
/csio-query What building bylaw options exist for Aviva?
```

### Create Excel reports

```
Create an Excel file with all Aviva home endorsement codes
Make a spreadsheet comparing Aviva vs Intact auto discounts
Export all Z-codes across all carriers to a CSV
```

### Compare carriers

```
Compare earthquake coverage between Aviva and Wawanesa
What endorsements does Intact have that Aviva doesn't?
Show a side-by-side of all home liability codes for Aviva vs Intact
```

### Filter by version (BAU vs Guidewire)

For carriers like Aviva that have multiple service versions:
```
What codes are only in V148 (Guidewire)?
What codes exist in V134 (BAU) but were dropped from V148?
Show all codes shared between BAU and Guidewire
```

### Understand specific codes

```
What is csio:ERQK?
What does Z-code csio:ZCS1 mean?
Is csio:DISAB a standard code or Aviva-specific?
```

## Glossary

| Term | Meaning |
|------|---------|
| **CZO/CSIO** | Canadian insurance XML standard — the format we send data to carriers |
| **TBW** | The Broker's Workstation — the frontend where brokers enter policy data |
| **Z-code** | A carrier-proprietary code (starts with Z after csio:). Not part of the CSIO standard |
| **Standard code** | A CSIO-defined code all carriers understand |
| **BAU** | Business As Usual — the current production service (typically V134) |
| **Guidewire** | The new service being built (typically V148) |
| **Endorsement** | An add-on to a base policy (e.g., earthquake, building bylaw) |
| **OPCF** | Ontario Policy Change Form — standardized auto endorsements (OPCF 5, 8, 19, etc.) |
| **Coverage code** | The csio: string that identifies a specific coverage in the XML |
| **availableIn** | Which service versions include this code |
