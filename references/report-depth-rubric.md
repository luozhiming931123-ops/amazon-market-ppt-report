# Report Depth Rubric

Use this rubric before claiming a report is complete.

## Minimum Evidence Coverage

| Area | Quick Brief | Competitive Enhanced | Deep Product Report |
| --- | ---: | ---: | ---: |
| Seed keywords | 3-6 | 6-10 | 10-20 |
| Keyword trend periods | latest + key comparisons | 12-24 months | 24+ months if available |
| Raw TOP ASIN rows | 30-50 | 50-100 | 100-200 |
| Effective ASINs after filtering | 15+ | 30+ | 50+ |
| Deep ASINs | 6-8 | 10-16 | 16-24 |
| ASIN sales prediction coverage | check target/core ASINs | 70%+ deep sample if using brand share | 70%+ effective deep sample if using brand share |
| Low-star review ASINs | 1-2 | 2-4 | 4-8 |
| Product attributes compared | 5+ | 8+ | 12+ |
| Visual components | 6+ | 13 core visuals | 13 core + 3 support/deep visuals |

## Conclusion Quality Gate

Each core recommendation must include:

1. Data observation
2. Mechanism/root cause
3. Implication for target brand
4. Product, content, pricing, or ad action

Bad: "High-end positioning is possible."

Good: "A premium competitor sustains a higher ASP with high review depth and clear professional-positioning proof; this indicates willingness to pay exists only when the product mechanism is visible. The target brand should not raise price on a generic format alone; it should create a differentiated SKU with measurable proof assets."

## Failure Conditions

A report fails this skill if any of the following are true:

- It has many pages but fewer than the required visual components.
- It lacks `visual-manifest.json` for a Competitive Enhanced or Deep Product Report.
- `visual-manifest.json` fails the matching tier check in `validate-visual-manifest.ps1`.
- It lacks raw_count, effective_count, and deep_sample_count.
- It calculates brand share from unfiltered ASINs.
- It presents ASIN-count fallback as market share.
- It uses BSR proxy for sales/GMV without first attempting `asin_prediction` on the deep ASIN sample.
- It gives product recommendations without category-specific attributes.
- It has no low-star review root-cause analysis.
- It has annual revenue targets without units, ASP, and ramp assumptions.
- It does not state data limitations and missing fields.
