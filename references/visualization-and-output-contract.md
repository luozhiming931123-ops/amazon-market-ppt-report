# Visualization and Output Contract

## Required workflow

Create `analysis/visual_plan.json` before building slides. Use `examples/visual-plan-led-whip-good.json` as the model and validate the completed deck with:

```powershell
./scripts/validate-pptx.ps1 -PptxPath output/report.pptx
./scripts/audit-pptx-visuals.ps1 -PptxPath output/report.pptx -VisualPlanPath analysis/visual_plan.json -Tier 'Competitive Enhanced'
./scripts/render-pptx-preview.ps1 -PptxPath output/report.pptx -OutputDir output/preview -Slides 1,4,5,8,9,10,11,13,14,17,19
```

Use `-AllowShortTrend` only when fewer than 12 months exist and label the limited time range on the slide.

## Evidence visual rules

- Use `[VISUAL role=...;type=...;source=...;sample=...;period=...;points=...]` in `p:cNvPr name` or `descr` for every evidence visual.
- State the date/month, sample, source file, and calculation scope in or beside the chart.
- Keep one decision question per slide. Put the implication beside the visual in no more than two lines.
- Preserve evidence visual type and data series when translating a deck. Chinese labels must not convert a chart into a card layout.
- Count only these as evidence visuals: bar, line, stacked bar, scatter, heatmap, matrix, funnel, timeline, or a table with 6+ rows and 3+ numeric metrics.
- Do not count summary cards, icons, decorative shapes, topic-keyword text, or a 2-4 row table.

## Competitive Enhanced role library

Declare at least 12 distinct roles. The normal LED/automotive-lighting composition uses the following 14:

| Role | Preferred visual | Decision enabled |
| --- | --- | --- |
| `sample_funnel` | funnel | Which listings are in scope? |
| `keyword_capacity` | bar | Where is demand concentrated? |
| `keyword_trend` | line | When should inventory and launch occur? |
| `keyword_opportunity_matrix` | scatter | Which terms merit PPC/SEO investment? |
| `top_asin_matrix` | table/matrix | Who sets the competitive bar? |
| `price_band` | bar | Which price bands are crowded or open? |
| `sample_sales_concentration` | bar | How concentrated is the observed sample? |
| `traffic_mix` | stacked bar | Is traffic organic, ad-led, or external? |
| `product_scheme_matrix` | matrix | Which configurations are commoditized? |
| `review_risk_heatmap` | heatmap | Which defects need design proof? |
| `price_product_positioning` | scatter | Where can the target brand differentiate? |
| `sku_ladder` | matrix | How should good-better-best be structured? |
| `annual_target` | bar | What units and GMV are required by quarter? |
| `roadmap` | timeline | What must happen before launch and scale? |

## Data-granularity gate

- Bar/stacked bar/funnel/timeline: at least 3 categories or stages.
- Line: 12 time points by default; a documented short-period exception requires at least 6.
- Scatter: at least 6 plotted entities.
- Heatmap/matrix: at least 4 rows × 4 columns.
- Evidence table: at least 6 compared rows × 3 numeric metrics.

## Render review gate

Inspect exported PNGs for cover, market capacity, trend, price band, competition, traffic, product scheme, review risk, positioning, SKU ladder, annual target, and roadmap pages. Fix before delivery when any one of these occurs:

- labels, axis values, data notes, or implications are clipped or illegible;
- a slide contains text/copy but no visible comparison mechanism;
- scale, ordering, or colors conceal the intended comparison;
- a conclusion has no source, period, or sample label;
- visual density differs materially between source-language and translated decks.
