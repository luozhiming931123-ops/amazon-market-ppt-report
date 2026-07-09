---
name: amazon-market-ppt-report
description: Use when creating or revising Amazon marketplace analysis PPTX reports from SellerSprite/SIF MCP data, especially for category entry, competitor, keyword, price-band, brand-share, product-scheme, review-risk, visualization-heavy reports, and annual business-target analysis.
---

# Amazon Market PPT Report

## Overview

Use this skill to turn Amazon marketplace research into a reusable, data-backed PPTX report. The report must preserve the full chain: data path, MCP calls, cleaning/filtering, category-specific product analysis, visualization choices, PPTX style, export, and verification.

Core principle: a market report is not a text dump. Every major conclusion must be carried by data, a mechanism explanation, and a chart/table/matrix/roadmap that makes the conclusion scannable.

## Trigger Fit

Use for requests like:

- "用 sellersprite-mcp 分析某个 Amazon 类目并生成 PPTX"
- "补充市场竞争度、价格带、品牌份额、评价信息"
- "把市场分析报告做成年度目标/业务规划输入"
- "参考某个 PPT 风格，生成或重做市场报告"
- "做新品开发报告，需要容量、包装、适用人群、产品方案和可视化"

Do not use for quick one-paragraph market opinions without data collection.

## Core Workflow

1. **Clarify input only when blocking.** Default marketplace to `US`. Capture keyword(s), product/category, target brand, positioning, price posture, depth tier, required output format, and any style reference PPTX.
2. **Choose report depth.** If the user asks for a market report or product-development report and does not specify "quick", default to `Competitive Enhanced`, not a brief.
3. **Choose category taxonomy.** Use the generic product taxonomy in `references/analysis-model.md`. Load private/local category adapters only when they are available in the user's environment; do not publish client- or category-specific adapters into this public skill repo.
4. **Load MCP tools.** Use `tool_search` to expose SellerSprite tools when not already callable. Follow the call sequence and fallback rules in `references/mcp-call-playbook.md`. Use SIF only as supplemental market/traffic validation.
5. **Collect raw data.** Save or summarize enough raw MCP output to reconstruct conclusions. Record tool name, inputs, month/period, raw count, filtered count, and missing fields.
6. **Clean the market sample.** Filter unrelated products before calculating price bands, brand share, product schemes, or review risks. Always state sample size and exclusions.
7. **Analyze with explicit mechanisms.** Every core conclusion must follow: `data observation -> mechanism -> implication for target brand -> product/operation action`.
8. **Build a visualization-first PPTX.** Use `references/visualization-and-output-contract.md` and `references/pptx-style-and-visuals.md`. Pure text pages must stay below 20% of total slides.
9. **Run depth and PPTX verification.** Use `scripts/validate-pptx.ps1` and `scripts/audit-pptx-depth.ps1` when available. Fix missing required visuals, prices, ASIN evidence, or category-specific terms before final delivery.

## Report Depth Tiers

| Tier | Slides | Minimum visuals | Use when |
| --- | ---: | ---: | --- |
| Quick Brief | 10-14 | 6 | User asks for a quick decision memo. |
| Competitive Enhanced | 18-26 | 10 | Default for market reports, competitor analysis, and product-development input. |
| Deep Product Report | 28-40 | 16 | User asks for annual planning, category entry, R&D requirements, or detailed launch roadmap. |

## ASIN Sampling Rule

Use this as the default competitor sampling rule unless the user specifies a different scope:

- Small categories: collect TOP50 and fully filter the sample.
- Medium categories: collect TOP100 across 2 pages, then filter.
- Large or highly competitive categories: collect TOP150-200, then use stratified sampling by price band, brand, and product scheme.
- Deep competitor analysis: choose 2-3 ASINs from each meaningful price band/core brand or product scheme, typically 12-20 ASINs total.

Always report `raw_count`, `effective_count`, exclusion categories, and the deep-analysis ASIN count separately.

## Required Data Artifacts

For non-trivial reports, create a project folder in the workspace:

```text
{brand}_{category}_market_report/
  data/
    01_keyword_trends.json
    02_top_asins.json
    03_asin_details.json
    04_asin_predictions.json
    05_reviews.json
    06_traffic_stats.json
  analysis/
    data_notes.md
    calculation_notes.md
  output/
    report.pptx
```

If the user only wants the PPTX, still keep enough notes in the script or `analysis/` folder to audit the logic later.

## Evidence Rules

- Distinguish observation from conclusion. MCP data is raw observation; the report's conclusion must explain the mechanism.
- Brand share should default to brand-level sales units or sales amount aggregated from effective ASINs. For SellerSprite, use `asin_prediction.monthItemList` as the primary monthly units/GMV source for deep ASINs. Use ASIN-count share only as a fallback when sales data is unavailable, and label it as `按相关 ASIN 数粗略估算`.
- Never calculate competition from an unfiltered TOP sample if the keyword returns accessories, non-core products, bundles, or wrong-category listings.
- For premium brands, explicitly compare against high-end competitors, not only low-price sellers.
- Every chart must have a stated data口径: keyword/month, filtered sample, brand sales units, brand sales amount, ASIN-count fallback, review sample, traffic-source month, BSR proxy, or sales trend.
- If sales coverage is below 70% after attempting `asin_prediction`, do not present brand GMV/unit share. Use BSR proxy or ASIN-count fallback and label it.
- Do not conclude SellerSprite lacks sales/GMV because `traffic_source` or `asin_detail` omits sales fields; those interfaces are not the primary sales prediction source.
- Do not let page count substitute for depth. A report with many text-heavy pages and few evidence visuals fails this skill.

## Mandatory References

Read only the files needed for the task, but for a PPTX report always read:

- MCP call SOP: `references/mcp-call-playbook.md`
- Data path and artifacts: `references/data-path-and-mcp.md`
- Analysis logic: `references/analysis-model.md`
- Visualization contract: `references/visualization-and-output-contract.md`
- Depth rubric: `references/report-depth-rubric.md`
- PPTX style: `references/pptx-style-and-visuals.md`

Category-specific adapters may be kept privately in local installs, but this public version intentionally contains only the generic workflow.
