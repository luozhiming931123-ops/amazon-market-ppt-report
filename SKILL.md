---
name: amazon-market-ppt-report
description: Use when creating or revising Amazon marketplace analysis PPTX reports from SellerSprite/SIF MCP data, especially for category entry, competitor, keyword, price-band, brand-share, review-risk, and annual business-target analysis.
---

# Amazon Market PPT Report

## Overview

Use this skill to turn Amazon US market research into a reusable, data-backed PPTX report. The report must preserve the full chain: data path, MCP calls, cleaning/filtering, analysis logic, visualization choices, PPTX style, export, and verification.

## 中文输出契约

- 默认以简体中文交付全部面向用户的内容：PPT 标题与副标题、图表和表格标签、数据口径、结论、策略建议、风险提示、项目说明及最终回复。
- 保留必要的行业或数据术语及专有名词，例如 Amazon、US、ASIN、BSR、SKU、PPC、GMV、RGB/RGBW、品牌名、产品型号和 MCP 工具名；其余内容不要整页使用英文。
- 原始 MCP 返回数据可按原语言保存于 `data/`，但 `analysis/` 中的解释和 PPT 中的可读文本必须为中文。
- 仅当用户明确要求英文、双语或其他语言时，才覆盖此默认规则。

## Trigger Fit

Use for requests like:
- "用 sellersprite-mcp 分析某个 Amazon 类目并生成 PPTX"
- "补充市场竞争度、价格带、品牌市占、评价信息"
- "把市场分析报告做成年度目标/业务规划输入"
- "参考某个 PPT 风格，生成或重做市场报告"

Do not use for quick one-paragraph market opinions without data collection.

## Core Workflow

1. **Clarify input only when blocking.** Default marketplace to `US`. Capture keyword(s), product/category, target brand, positioning, price posture, required output format, and any style reference PPTX.
2. **Load MCP tools.** Use `tool_search` to expose SellerSprite tools when not already callable. Use SIF tools only as supplemental market/traffic validation.
3. **Collect raw data.** Save or summarize enough raw MCP output to reconstruct the conclusion. Use the data path in `references/data-path-and-mcp.md`.
4. **Clean the market sample.** Filter unrelated ASINs, replacement parts, single-color items, bundles, and non-core products before calculating price bands or brand share. Always state sample size and exclusions.
5. **Analyze with explicit dimensions.** Cover market capacity, trend, keyword demand, TOP ASINs, competition degree, price band, brand share, product schemes, review risks, traffic structure, high-end entry, and business targets. Use `references/analysis-model.md`.
6. **Plan evidence visuals before layout.** Create `analysis/visual_plan.json` following `scripts/visual-plan.schema.json`. Every evidence visual must declare slide, role, type, source file, source fields, period, sample, and data points. Read `references/visualization-and-output-contract.md` before building.
7. **Build the PPTX with evidence primitives.** Use `scripts/pptx_visual_primitives.js` or an equivalent renderer that preserves its `[VISUAL ...]` metadata in each chart/matrix shape's `p:cNvPr name` or `descr`. Cards, icons, and a 2-4 row summary table do not count as evidence visuals.
8. **Translate without visual regression.** When localizing a deck, replace labels and narrative only. Preserve the chart type, data series, scale, visual role, source metadata, and page-level comparison. Do not replace a chart with cards or a short table.
9. **Export and verify.** For OOXML/zip-based PPTX generation, package entries with forward slashes and validate slide count/XML. Run `scripts/validate-pptx.ps1`, `scripts/audit-pptx-visuals.ps1`, and `scripts/render-pptx-preview.ps1` when available. Inspect the rendered key pages before delivery.

## ASIN Sampling Rule

Use this as the default market competitor sampling rule unless the user specifies a different scope:

- Small categories: collect TOP50 and fully filter the sample.
- Medium categories: collect TOP100 across 2 pages, then filter.
- Large or highly competitive categories: collect TOP150-200, then use stratified sampling by price band and brand.
- Deep competitor analysis: choose 2-3 ASINs from each meaningful price band/core brand, typically 12-20 ASINs total.

Always report `raw_count`, `effective_count`, and the deep-analysis ASIN count separately.

## Required Data Artifacts

For non-trivial reports, create a project folder in the workspace:

```text
{brand}_{category}_market_report/
  data/
    01_keyword_trends.json
    02_top_asins.json
    03_asin_details.json
    04_reviews.json
    05_traffic_stats.json
  analysis/
    data_notes.md
    calculation_notes.md
    visual_plan.json
  output/
    report.pptx
```

If the user only wants the PPTX, still keep enough notes in the script or `analysis/` folder to audit the logic later.

## Evidence Rules

- Distinguish observation from conclusion. MCP data is raw observation; the report's conclusion must explain the mechanism.
- Brand share should default to brand-level sales units or sales amount aggregated from effective ASINs. Use ASIN-count share only as a fallback when sales data is unavailable, and label it as "按相关 ASIN 数粗略估算".
- Never calculate competition from unfiltered TOP50 if the keyword returns accessories, generic lights, truck-bed strips, or non-automotive products.
- For premium brands, explicitly compare against high-end competitors, not only low-price sellers.
- Every chart must have a stated data口径: keyword/month, filtered sample, brand sales units, brand sales amount, ASIN count fallback, review sample, or sales trend.
- A table counts as an evidence visual only when it compares 6+ rows and 3+ numeric metrics. Summary cards, decorative shapes, and topic words are never counted as visuals.
- Competitive Enhanced reports must contain at least 12 distinct visual roles and evidence visuals on at least 60% of slides. Deep Product Reports require at least 16 roles.
- Do not claim visual completion from XML validity, keyword hits, or the number of PowerPoint shapes. The visual audit must match `visual_plan.json` against chart metadata embedded in the PPTX.

## References

- Data path and MCP calls: `references/data-path-and-mcp.md`
- Analysis logic and decision rules: `references/analysis-model.md`
- PPTX structure, style, and visualization: `references/pptx-style-and-visuals.md`
- Visual contract and role library: `references/visualization-and-output-contract.md`
- Visual-plan schema: `scripts/visual-plan.schema.json`
- Reusable evidence components: `scripts/pptx_visual_primitives.js`
- Visual audit: `scripts/audit-pptx-visuals.ps1`
- Rendered preview: `scripts/render-pptx-preview.ps1`
