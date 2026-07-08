# Amazon Market PPT Report Skill

Reusable Codex skill for creating data-backed Amazon marketplace analysis PPTX reports from SellerSprite/SIF MCP data.

## What It Does

This skill standardizes the full workflow for Amazon category analysis reports:

- MCP data path for SellerSprite and optional SIF validation
- ASIN sampling rules for small, medium, and high-competition categories
- market capacity, keyword trend, TOP ASIN, price band, brand sales share, review risk, and traffic structure analysis
- premium brand entry logic and annual business target planning
- PPTX page structure, visual style, chart口径, export, and verification

It was created for reports such as `RGB rock light`, `LED pod light`, `switch panel`, and `LED headlight bulb`, but the workflow can be reused for other Amazon US categories.

## Skill Structure

```text
amazon-market-ppt-report/
  SKILL.md
  agents/
    openai.yaml
  references/
    analysis-model.md
    data-path-and-mcp.md
    pptx-style-and-visuals.md
  scripts/
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
- Large/high-competition categories: TOP150-200, then stratified sampling by price band and brand
- Deep competitor analysis: 12-20 ASINs, normally 2-3 per price band/core brand

Brand share:

- Prefer brand sales amount share when sales coverage is >=70%
- Use brand unit share when sales amount is missing but unit coverage is >=70%
- Use ASIN-count share only as a fallback, clearly labeled as rough estimation

## Verify PPTX Output

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-pptx.ps1 `
  -PptxPath .\report.pptx `
  -ExpectedSlides 15 `
  -RequiredText "竞争度拆解","价格带分布","品牌份额"
```

## License

MIT

