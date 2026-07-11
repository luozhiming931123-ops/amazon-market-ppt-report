# Visual Manifest Spec

Every non-trivial report should produce a `visual-manifest.json` next to the PPTX. The manifest makes visual output auditable before the user opens the deck.

## Required Shape

```json
{
  "version": "1.0",
  "tier": "CompetitiveEnhanced",
  "report_context": {
    "marketplace": "US",
    "category_label": "generic category",
    "target_brand_label": "target brand"
  },
  "slides": [
    {
      "slide": 4,
      "title": "Market capacity",
      "visual_type": "keyword_capacity_bar",
      "chart_kind": "bar",
      "data_source": "SellerSprite keyword_research_trends",
      "data_basis": "monthly keyword demand, filtered seed set",
      "required_fields": ["keyword", "search_volume", "purchase_rate"],
      "fallback_label": null,
      "business_implication": "Broad demand is large enough, but exact demand requires long-tail capture."
    }
  ]
}
```

## Visual Type Vocabulary

Core visual types:

- `keyword_capacity_bar`
- `keyword_trend`
- `top_asin_competitor_matrix`
- `price_band_distribution`
- `price_product_positioning_map`
- `brand_share_chart`
- `traffic_mix_stacked_bars`
- `product_scheme_matrix`
- `review_risk_cluster`
- `keyword_opportunity_matrix`
- `sku_ladder`
- `annual_target_chart`
- `execution_roadmap`

Allowed support types:

- `cover`
- `one_page_conclusion`
- `data_scope`
- `appendix_data_table`
- `competitor_group_detail`
- `keyword_family_detail`
- `listing_proof_audit`
- `product_teardown`
- `compliance_risk`
- `inventory_launch_plan`

## Tier Rules

| Tier | Required core visuals | Minimum visual slides |
| --- | --- | ---: |
| QuickBrief | capacity, trend, TOP ASIN matrix, price band, review risk, target chart | 6 |
| CompetitiveEnhanced | all 13 core visual types | 13 |
| DeepProductReport | all 13 core visual types plus 3+ support/deep visuals | 16 |

## Field Rules

- Every visual slide must include `visual_type`, `chart_kind`, `data_source`, `data_basis`, `required_fields`, and `business_implication`.
- `required_fields` must contain the data columns needed to reproduce the visual.
- Any fallback calculation must be explicitly labeled with `fallback_label`, such as `BSR proxy`, `ASIN-count fallback`, or `sales coverage <70%`.
- If `visual_type` is `brand_share_chart`, `required_fields` must include either `sales_amount` or `sales_units`, unless `fallback_label` is present.
- If `visual_type` is `traffic_mix_stacked_bars`, `required_fields` must include `natural_keywords` and at least one paid/recommendation source such as `ad_keywords`, `video_keywords`, or `brand_keywords`.
- If `visual_type` is `annual_target_chart`, `required_fields` must include `units`, `asp`, `revenue`, and `quarter`.
