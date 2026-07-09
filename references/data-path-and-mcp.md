# Data Path And MCP Calls

Use this file for data artifacts and sampling. Use `mcp-call-playbook.md` for exact MCP call sequence and fallback rules.

## Input Contract

Capture:

- `marketplace`: default `US`
- `category`: product/category name
- `keywords`: 6-10 seed keywords for Competitive Enhanced reports; include broad, segment/scene, attribute, and exact terms
- `brand`: target brand
- `positioning`: low-price, mid-range, premium, or high-end
- `seed_asins`: optional known competitors or own ASINs
- `depth_tier`: Quick Brief, Competitive Enhanced, or Deep Product Report
- `style_reference`: optional PPTX/image path

## Data Collection Flow

1. Identify product jobs and category adapter.
2. Build seed keyword set.
3. Collect keyword demand/trend.
4. Collect TOP ASIN pool with `traffic_source`.
5. Filter sample and record exclusions.
6. Select deep competitor sample across price bands, brands, and product schemes.
7. Collect ASIN details, `asin_prediction` monthly sales/GMV, BSR fallback, traffic structure, and low-star reviews.
8. Normalize product attributes for the category.
9. Calculate price bands, value metrics, traffic mix, review clusters, SKU ladder, and targets.

## Data Cleaning Rules

For keyword and TOP ASIN outputs, create an effective sample:

- Exclude unrelated products, accessories, replacement parts, wrong-category products, and bundles that cannot be normalized.
- Separate product jobs that share the same keyword but solve different needs.
- Normalize brand names and duplicate variants.
- Keep variants visible but avoid letting one brand's variant spam become a false monopoly conclusion.
- Record `raw_count`, `effective_count`, `deep_sample_count`, and exclusion categories.

## Competitor Sampling Rules

| Market type | Initial collection | Filtering | Deep analysis sample |
| --- | --- | --- | --- |
| Small category | TOP50 | Fully filter all returned ASINs | 8-12 core ASINs if the category is narrow |
| Medium category | TOP100, 2 pages | Fully filter all returned ASINs | 12-16 ASINs across price bands, brands, schemes |
| Large/high-competition category | TOP150-200, 3-4 pages | Filter first, then stratify | 16-24 ASINs, 2-3 per price band/core brand/scheme |

Use stratified sampling when the effective sample is large:

- 2-3 ASINs from each meaningful price band
- 2-3 ASINs from each core brand or seller cluster
- at least one premium/high-end competitor when target brand is premium
- at least one low-price head listing to define price-war baseline
- at least one own/target brand ASIN if available

## Required Data Artifacts

For non-trivial reports, create:

```text
{brand}_{category}_market_report/
  data/
    01_keyword_trends.json
    02_top_asins_raw.json
    03_top_asins_filtered.json
    04_asin_details.json
    05_asin_predictions.json
    06_reviews.json
    07_traffic_stats.json
    08_category_attributes.json
  analysis/
    data_notes.md
    calculation_notes.md
    exclusions.md
  output/
    report.pptx
```

## Minimum Effective ASIN Table

For each effective ASIN, capture:

```text
asin | brand | title | segment/product_job | price | rating | review_count
bsr | category | variations | capacity_or_size | package_format | value_metric
core_attributes | month_sales | month_amount | traffic_total | natural_keywords | ad_keywords | video_keywords
review_risks | data_limitations
```

Use the category adapter to expand `core_attributes`.

## Brand Sales Share Data Rule

1. Normalize brand names after ASIN filtering.
2. Use `asin_prediction.monthItemList.sales` and `asin_prediction.monthItemList.amount` when available.
3. Calculate coverage:

```text
coverage_rate = ASINs with usable sales data / effective ASINs
```

4. Prefer sales amount share when coverage is >=70%.
5. Use unit share when sales amount is missing but unit coverage is >=70%.
6. Use ASIN-count or BSR proxy only when `asin_prediction` coverage is insufficient; label fallback clearly.

## ASIN Prediction Rule

- Do not assume SellerSprite has no sales/GMV just because `traffic_source` or `asin_detail` omits those fields; those interfaces are not the primary sales source.
- For every deep-analysis ASIN, call `asin_prediction` first without custom `returnFields`.
- Parse `monthItemList` for monthly units/GMV and `dailyItemList` only when a recent partial-month view is needed.
- Mark the latest incomplete month as partial if the current date is inside that month.
