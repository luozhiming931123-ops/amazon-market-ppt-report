# Amazon Market PPT Report Skill

Reusable Codex skill for creating data-backed Amazon marketplace analysis PPTX reports from SellerSprite/SIF MCP data.

## What It Does

This skill standardizes a generic workflow for Amazon marketplace reports:

- MCP data path for SellerSprite and optional SIF validation
- keyword demand, trend, TOP ASIN, price band, brand share, review risk, and traffic structure analysis
- `asin_prediction`-first monthly units/GMV handling with BSR fallback rules
- visualization-first PPTX structure and chart/table/matrix requirements
- visual manifest examples and validation for chart/table/matrix coverage
- report depth audit, PPTX XML validation, and evidence coverage checks

This public version intentionally excludes client-specific products, categories, ASINs, datasets, and category adapters. Keep those in private/local installs only.

## Skill Structure

```text
amazon-market-ppt-report/
  SKILL.md
  agents/
    openai.yaml
  references/
    analysis-model.md
    data-path-and-mcp.md
    mcp-call-playbook.md
    pptx-style-and-visuals.md
    report-depth-rubric.md
    visual-manifest-spec.md
    visualization-and-output-contract.md
  examples/
    competitive-enhanced.visuals.json
    deep-product-report.visuals.json
  scripts/
    audit-pptx-depth.ps1
    validate-visual-manifest.ps1
    validate-pptx.ps1
```

## Install

Copy this folder into your Codex skills directory:

```powershell
Copy-Item -Recurse amazon-market-ppt-report "$env:USERPROFILE\.codex\skills\amazon-market-ppt-report"
```

Then start a new Codex session and ask:

```text
Use $amazon-market-ppt-report to analyze an Amazon US category and generate a PPTX report.
```

## Key Defaults

ASIN sampling:

- Small categories: TOP50, fully filtered
- Medium categories: TOP100 across 2 pages
- Large/high-competition categories: TOP150-200, then stratified sampling by price band, brand, and product scheme
- Deep competitor analysis: 12-20 ASINs, normally 2-3 per price band/core brand/product scheme

Sales and brand share:

- For SellerSprite, call `asin_prediction` for deep ASINs before using BSR fallback
- Parse `monthItemList.sales` and `monthItemList.amount` for monthly units/GMV
- Prefer brand sales amount share when sales coverage is >=70%
- Use brand unit share when sales amount is missing but unit coverage is >=70%
- Use BSR proxy or ASIN-count share only as a labeled fallback

Visual output:

- Competitive Enhanced reports must include all 13 core visual types in `references/visual-manifest-spec.md`
- Deep Product Reports must include all 13 core visual types plus at least 3 support/deep visual types
- Every slide in the PPTX should map to a `visual-manifest.json` entry with data source, metrics, evidence basis, and action
- Use `examples/competitive-enhanced.visuals.json` and `examples/deep-product-report.visuals.json` as generic templates

## Verify Visual Manifest

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-visual-manifest.ps1 `
  -ManifestPath .\examples\competitive-enhanced.visuals.json `
  -Tier CompetitiveEnhanced
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-visual-manifest.ps1 `
  -ManifestPath .\examples\deep-product-report.visuals.json `
  -Tier DeepProductReport
```

## Verify PPTX Output

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-pptx.ps1 `
  -PptxPath .\report.pptx `
  -ExpectedSlides 22 `
  -RequiredText "price band","brand share","asin_prediction"
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\audit-pptx-depth.ps1 `
  -PptxPath .\report.pptx `
  -Tier CompetitiveEnhanced `
  -RequiredText "price,ASIN,BSR,traffic,review,asin_prediction"
```

## License

MIT
