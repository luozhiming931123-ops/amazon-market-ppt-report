# Data Path And MCP Calls

## Input Contract

Capture:
- `marketplace`: default `US`
- `category`: product/category name
- `keywords`: 3-10 seed keywords, including broad, scene, attribute, and exact terms
- `brand`: target brand, e.g. Auxbeam
- `positioning`: low-price, mid-range, premium, or high-end
- `seed_asins`: optional known competitors or own ASINs
- `style_reference`: optional PPTX/image path

## SellerSprite MCP Tool Path

Use `tool_search` with "sellersprite" if tools are not loaded.

Recommended call sequence:

1. **Keyword demand and trend**
   - `keyword_research_trends`
   - Inputs: `keyword`, `marketplace`, `month`
   - Use for searches, purchases, purchase rate, YoY/MoM, 3-month growth.

2. **ABA trend validation**
   - `aba_research_trend`
   - Inputs: `keyword`, `marketplace`, `timeGranularity`
   - Use for ABA rank/search trend validation.

3. **TOP ASIN / keyword traffic source**
   - `traffic_source`
   - Inputs:
     ```json
     {
       "request": {
         "q": "{keyword}",
         "marketplace": "US",
         "page": 1,
         "size": 50,
         "order": { "field": "searches", "desc": true }
       }
     }
     ```
   - Use for TOP ASINs, price, reviews, keyword count, natural/ad mix hints, and first-pass competitor list.
   - Sampling size:
     - small categories: `page: 1, size: 50`
     - medium categories: `page: 1-2, size: 50` for TOP100
     - large/high-competition categories: `page: 1-3/4, size: 50` for TOP150-200

4. **ASIN detail**
   - `asin_detail` or `asin_detail_with_coupon_trend`
   - Inputs: `asin`, `marketplace`
   - Use for title, brand, category, price, rating, reviews, seller, variants, badges, listing score, coupon.

5. **Sales trend**
   - `asin_sales_trend`
   - Inputs: `asin`, `marketplace`
   - Use for monthly units, sales amount, average price, seasonality, parent/child effects.
   - Brand share requirement: run this for the effective ASIN sample or at least the deep competitor sample plus head listings until sales coverage reaches >=70%.

6. **Traffic structure**
   - `traffic_keyword_stat`
   - Inputs: `asin`, `marketplace`, `month`
   - Use for natural vs Amazon recommendation vs SP/SB/SBV/HR traffic keyword scale.

7. **Review mining**
   - `review`
   - Inputs: `asin`, `marketplace`, `starList: [1,2,3]`, `size`
   - Use for low-star pain points, product defects, installation barriers, quality risk, control/app issues.

8. **Related listings**
   - `traffic_listing`
   - Inputs: target ASIN list, `relations`, `marketplace`
   - Use for related competitor network and category structure when keyword TOP50 is too noisy.

## Optional SIF Validation

Use only when it improves the confidence of market-level keyword judgment:
- `market_get_keyword_history`: ABA search volume, rank, Top3 click/conversion concentration.
- `market_get_keyword_root_trend`: exact keyword vs root demand coverage.
- `market_get_keyword_competition`: top ASIN traffic share and keyword competition position.

## Data Cleaning Rules

For keyword output, create an effective sample:
- Exclude unrelated products, accessories, replacement single parts, non-core bundles, non-automotive lights, and obviously wrong-category listings.
- Flag but separate single-color products when analyzing RGB market.
- Normalize brand names (`MICTUNING C2`, `MICTUNING`, etc.) before share counts.
- Keep variants visible but avoid letting one brand's variant spam become a false monopoly conclusion.
- Record `raw_count`, `effective_count`, and exclusion categories.

## Competitor Sampling Rules

Default competitor sampling:

| Market type | Initial collection | Filtering | Deep analysis sample |
| --- | --- | --- | --- |
| Small category | TOP50 | Fully filter all returned ASINs | 8-12 core ASINs if the category is narrow |
| Medium category | TOP100, 2 pages | Fully filter all returned ASINs | 12-16 ASINs across price bands and brands |
| Large/high-competition category | TOP150-200, 3-4 pages | Filter first, then stratify | 12-20 ASINs, 2-3 per price band/core brand |

Use stratified sampling when the effective sample is large:
- Pick 2-3 ASINs from each meaningful price band.
- Pick 2-3 ASINs from each core brand or dominant seller cluster.
- Include at least one premium/high-end competitor when the target brand is premium.
- Include at least one low-price head listing to define the price-war baseline.
- Mark sampled ASINs as "deep analysis" so readers know which ASINs received detail/review/sales/traffic calls.

## Minimum Data Table

For each effective ASIN, capture:

```text
asin | brand | title | price | rating | review_count | bsr/rank | units | sales_amount
pods_or_format | control | material | waterproof | app/rf/remote | brake_or_sync
keyword_total | natural_keywords | ad_keywords | video_keywords | review_risks
```

When a field is not available, mark it as unknown instead of inventing it.

## Brand Sales Share Data Rule

Brand share should be based on sales, not listing count:

1. Normalize brand names after ASIN filtering.
2. Use `asin_sales_trend` to collect monthly units and sales amount for effective ASINs.
3. Aggregate by brand:
   - `brand_units = sum(totalUnits or monthly units)`
   - `brand_sales = sum(totalAmount or monthly sales amount)`
4. Prefer sales amount share for PPT charts when coverage is >=70%.
5. Use unit share if sales amount is missing but units coverage is >=70%.
6. Use ASIN-count share only when sales coverage is unavailable; label it as a fallback, not market share.
