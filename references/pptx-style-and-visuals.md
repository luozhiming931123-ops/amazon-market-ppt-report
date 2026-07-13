# PPTX Style And Visualization

## Style Baseline

Use a business research style extended from the user's reference deck:
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

## Recommended Slide Structure

Use 12-16 slides depending on scope:

1. Cover and conclusion
2. Core conclusion and annual target
3. Data口径 and analysis framework
4. Market capacity / keyword demand
5. Demand trend / seasonality
6. TOP ASIN competitive landscape
7. Competition degree: price bands + brand share
8. Competitor product schemes and review risks
9. Traffic structure / keyword moat
10. Keyword opportunity matrix
11. Product route / SKU ladder
12. Market entry and positioning
13. Annual target and quarterly split
14. Ads and content plan
15. Execution roadmap and risks
16. Appendix, if needed

## Visualization Map

| Analysis | Visual |
| --- | --- |
| Keyword capacity | vertical bar chart |
| Trend | line chart |
| Price band distribution | bar chart or histogram |
| Brand share | bar chart by brand sales amount or units; ASIN-count chart only as fallback |
| TOP ASIN | table with ASIN, brand, price, rating/reviews, scheme, implication |
| Traffic mix | stacked horizontal bars |
| Product scheme | comparison matrix |
| Review risk | cluster table or risk cards |
| Positioning | 2x2 matrix or ladder |
| Annual target | quarterly bar chart and target table |
| Roadmap | quarterly swimlane |

## Page-Level Rules

- Every chart title must include the口径: date/month, filtered sample, brand sales amount, brand units, ASIN-count fallback, review sample, or sales trend.
- Put business implication next to the chart, not several slides later.
- For premium positioning, always show high-end competitor evidence and low-price risk separately.
- Use exact numbers in charts; use approximate labels only when the source itself is filtered/estimated.
- Keep long conclusions in cards under 2 lines where possible.
- If a table is dense, reduce font size rather than deleting core evidence, but keep row height readable.

## Export Pattern

Preferred output names:

```text
{brand}_{category}_Amazon_US_市场分析报告_{YYYYMMDD}.pptx
{brand}_{category}_Amazon_US_市场分析报告_竞争格局增强版.pptx
```

If generating PPTX through OOXML:
- copy/extract a valid template deck
- replace slide XML or generate slides consistently
- package zip entries with forward slashes (`ppt/slides/slide1.xml`)
- include `[Content_Types].xml`
- verify there are no backslash entries

## Verification Checklist

Before final response:
- PPTX exists and is non-empty
- expected slide count exists
- each `ppt/slides/slide*.xml` parses as XML
- zip entries use forward slashes
- key requested terms appear in slide XML
- final answer states any data口径 limitations
- `analysis/visual_plan.json` matches the evidence metadata embedded in the deck; run `scripts/audit-pptx-visuals.ps1`
- render the key pages to PNG and inspect visual hierarchy, clipping, labels, and chart comparability; see `references/visualization-and-output-contract.md`
