# PPTX Style And Visuals

Use this with `visualization-and-output-contract.md`. This file controls slide style and page structure; the visualization contract controls mandatory chart/table/matrix coverage.

## Style Baseline

Use a business research style:

- 16:9 landscape
- dark navy/burgundy/blue/gold accents
- dense but readable tables
- restrained cards, thin borders, clear section headers
- Chinese business report titles with concise subtitles
- charts and tables as first-class evidence, not decoration

Avoid:

- marketing landing-page hero sections
- decorative gradients/orbs
- single-hue pages
- vague strategy pages without data
- unlabelled chart口径
- pure text pages that merely restate conclusions

## Recommended Competitive Enhanced Structure

Use 18-26 slides by default:

1. Cover and one-page conclusion
2. Core recommendations and business target
3. Data口径, MCP path, sample filtering
4. Market capacity: keyword demand visual
5. Demand trend and seasonality
6. Keyword opportunity matrix
7. TOP ASIN competitive landscape
8. Competition degree: price band + review/traffic moat
9. Brand share or fallback concentration chart
10. Traffic structure and keyword moat
11. Product scheme comparison
12. Category-specific product attributes
13. Packaging/capacity/value metric analysis
14. Review risk clusters and root causes
15. Price-product positioning map
16. SKU ladder and product route
17. Market entry positioning
18. Annual target and quarterly split
19. Ads/content plan
20. Execution roadmap and risks
21+. Appendix/data tables if needed

Before generating the PPTX, map this structure into `output/visual-manifest.json` and validate it with `scripts/validate-visual-manifest.ps1 -Tier CompetitiveEnhanced`.

## Deep Product Report Additions

For 28-40 slide reports, add:

- detailed keyword family pages
- one slide per major competitor group
- price-per-unit or value-metric normalization
- product teardown by scheme/formula/material/package
- listing proof audit: main image, A+, video, badges, review assets
- R&D requirements page
- packaging and instruction-card requirements
- compliance/regulatory risk page when relevant
- inventory and launch milestone plan

Deep Product Reports must validate with `scripts/validate-visual-manifest.ps1 -Tier DeepProductReport`, including all 13 core visuals and at least 3 support/deep visuals.

## Page-Level Rules

- Every chart title must include the口径: date/month, filtered sample, brand sales amount, brand units, ASIN-count fallback, review sample, traffic-source month, BSR proxy, or sales trend.
- Put business implication next to the chart, not several slides later.
- For premium positioning, always show high-end competitor evidence and low-price risk separately.
- Use exact numbers in charts; use approximate labels only when the source itself is filtered/estimated.
- If a table is dense, reduce font size rather than deleting core evidence, but keep row height readable.
- Currency must be escaped when generating with PowerShell so `$24.99` remains visible in slide text.

## Export Pattern

Preferred output names:

```text
{brand}_{category}_Amazon_US_visual-manifest_{YYYYMMDD}.json
{brand}_{category}_Amazon_US_市场分析报告_{YYYYMMDD}.pptx
{brand}_{category}_Amazon_US_市场分析报告_竞争格局增强版.pptx
{brand}_{category}_Amazon_US_新品开发深度报告_{YYYYMMDD}.pptx
```

If generating PPTX through OOXML:

- copy/extract a valid template deck or generate a complete package consistently
- package zip entries with forward slashes (`ppt/slides/slide1.xml`)
- include `[Content_Types].xml`
- verify there are no backslash entries

## Verification Checklist

Before final response:

- PPTX exists and is non-empty
- visual manifest exists and passes the matching tier validation
- expected slide count exists
- each `ppt/slides/slide*.xml` parses as XML
- zip entries use forward slashes
- required terms appear in slide XML
- visualization count meets the depth tier
- price, ASIN, percentage, BSR/review/traffic evidence appears where relevant
- final answer states data口径 limitations
