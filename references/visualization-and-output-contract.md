# Visualization And Output Contract

Enhanced reports must be visual-first. A slide deck that is mostly text cards fails this skill even when the analysis is directionally correct.

## Required Visual Toolbox

| Visual | Purpose | Required In Enhanced |
| --- | --- | --- |
| Keyword capacity bar chart | Compare broad, exact, scene, and attribute demand | Yes |
| Keyword trend line chart/table | Show 12-24 month trend and seasonality | Yes |
| TOP ASIN competitor matrix | Compare brand, ASIN, price, rating, reviews, BSR, scheme | Yes |
| Price-band distribution | Show low-price crowding and premium space | Yes |
| Price-product positioning map | Show where target brand should compete | Yes |
| Brand share chart | Prefer GMV/units; fallback ASIN-count labeled | Yes |
| Traffic mix stacked bars | Natural, ad, video, brand keyword mix | Yes |
| Product scheme matrix | Specs, capacity, formula/materials, packaging, use cases | Yes |
| Review risk cluster | Pain point, root cause, opportunity, proof | Yes |
| Keyword opportunity matrix | Demand, purchase intent, competition, action | Yes |
| SKU ladder | Entry, core, premium, bundle/refill | Yes |
| Annual target chart | Quarterly units/revenue/review milestones | Yes |
| Execution roadmap | Product, content, ad, operations, risks by quarter | Yes |

Competitive Enhanced reports require all 13 core visual types above. Deep Product Reports require all 13 core visual types plus at least 3 support/deep visual types from `visual-manifest-spec.md`.

## Visual Manifest Requirement

For Competitive Enhanced and Deep Product Report outputs, create `output/visual-manifest.json` before generating the final PPTX. The manifest is the machine-checkable contract for visual coverage.

Required workflow:

1. Draft the manifest from `references/visual-manifest-spec.md`.
2. Use `examples/competitive-enhanced.visuals.json` or `examples/deep-product-report.visuals.json` as the generic layout pattern.
3. Replace placeholder data with MCP-backed observations, filtered sample sizes, metrics, fallback labels, conclusions, and actions.
4. Run `scripts/validate-visual-manifest.ps1` with the matching tier.
5. Generate or revise the PPTX so every important visual in the manifest appears in the deck.

Do not deliver a report that passes the text depth audit but fails the visual manifest check.

## Visual Rules

- Every visual title must include a data口径: source, month/period, filtered sample, fallback, or estimate basis.
- Every major conclusion must be adjacent to its supporting visual, not several slides later.
- Pure text slides must stay below 20% of total slides.
- Dense tables are acceptable, but each table must have a clear business implication.
- Use fallback labels visibly: `ASIN-count fallback`, `BSR proxy`, `review title only`, `sales coverage <70%`.
- Do not use decorative charts without numbers. If a chart has no exact values, use a labeled matrix instead.

## Minimum Slide Mix

| Tier | Slides | Minimum Visuals | Maximum Pure Text Slides |
| --- | ---: | ---: | ---: |
| Quick Brief | 10-14 | 6 core visuals | 3 |
| Competitive Enhanced | 18-26 | 13 core visuals | 5 |
| Deep Product Report | 28-40 | 13 core + 3 support/deep visuals | 8 |

## PPTX Generation Guardrails

- Escape currency values when generating with PowerShell (`'$24.99'` or XML-escaped literal), otherwise `$24.99` may be parsed as a variable.
- Keep chart/table data visible in the slide XML, not only as an image.
- If using OOXML, package zip entries with forward slashes.
- Validate required terms: `$`, `%`, ASIN, BSR, review, traffic, capacity/size/category-specific terms.
- Validate the visual manifest with `validate-visual-manifest.ps1` before claiming the report is complete.
