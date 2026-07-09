# MCP Call Playbook

Use this file as the data-collection SOP for SellerSprite/SIF-backed Amazon reports.

## General Sequence

| Step | Primary MCP | Inputs | Use For | Must Record |
| --- | --- | --- | --- | --- |
| Keyword demand | `keyword_research_trends`, `aba_research_trend` | keyword, marketplace, month/granularity | Search volume, purchase volume/rate, trend, seasonality | keyword list, month, searches, purchases, purchase rate, rank |
| Demand validation | SIF `market_get_keyword_history` | 1-10 keywords, country, granularity | ABA history, Top3 click/conversion concentration | latest volume/rank, concentration, top ASINs |
| TOP ASIN pool | `traffic_source` | q, marketplace, month, page, size | TOP ASINs, first-pass competitor pool, traffic word mix | raw_count, returned rows, ASINs, keyword/ad/video counts |
| Related listings | `traffic_listing` | seed ASINs, relations, marketplace | Competitor network when keyword output is noisy | relation types, ASIN list, rank/traffic fields |
| ASIN details | `asin_detail`, `asin_detail_with_coupon_trend`, `keepa_info` | asin, marketplace | Price, rating, reviews, BSR, category, variations, bullets, package/product details | ASIN, brand, title, price, rating/reviews, BSR, category, variations |
| ASIN sales and GMV | `asin_prediction` | asin, marketplace | Monthly/daily units, amount, price, BSR trend when available | `monthItemList.sales`, `monthItemList.amount`, month coverage, partial-month caveat |
| Sales fallback | `bsr_prediction` | BSR + categoryId | Directional units when ASIN-level sales prediction is unavailable | BSR category, estimate caveat, fallback label |
| Traffic structure | `traffic_source`, `traffic_keyword_stat` | asin or keyword, marketplace, month | Natural vs ad vs video vs brand keyword moat | keyword counts by source |
| Reviews | `review` | asin, marketplace, starList `[1,2,3]`, size | Low-star pain points and root causes | review count, stars, title/body availability |

## Fallback Rules

- If `traffic_source` is noisy, filter first, then supplement with `traffic_listing` from seed ASINs.
- For deep ASINs, call `asin_prediction` before using BSR fallback. First call it without custom `returnFields`; some field aliases return null when requested explicitly. Extract `monthItemList.sales` and `monthItemList.amount` from the raw response.
- If `asin_prediction` returns usable `monthItemList`, use it as the primary monthly units/GMV source.
- If monthly units/GMV coverage is below 70% after `asin_prediction`, do not calculate brand sales share. Use BSR proxy or ASIN-count fallback and label it.
- If `review` returns titles but no content, cluster titles and mark "review body unavailable".
- If price is missing, retry with `asin_detail_with_coupon_trend`. Do not invent price.
- If an ASIN is variation-heavy, treat BSR/rating as parent or variation aggregate unless tool output proves child-level scope.
- If SellerSprite and SIF disagree, state the source difference and use one as primary and the other as validation.

## Module-To-MCP Binding

| Analysis Module | Required MCP Evidence | Prohibited Shortcut |
| --- | --- | --- |
| Market capacity | `aba_research_trend` or SIF ABA history | Do not use Amazon result count as demand. |
| Competition degree | Filtered `traffic_source` + ASIN details | Do not calculate from unfiltered TOP50. |
| Price band | ASIN price from detail/source tools | Do not mix unrelated products into price bands. |
| Brand share | Sales/GMV coverage >=70% or labeled fallback | Do not call ASIN-count share "market share". |
| Traffic moat | Source keyword counts by ASIN/keyword | Do not infer traffic health from BSR alone. |
| Product scheme | ASIN details, bullets, title, overview, variants | Do not rely only on title keywords. |
| Review risk | 1-3 star review sample | Do not quote pain points without root-cause clustering. |
| Annual target | ASP + unit model + `asin_prediction` month trend, then BSR fallback if needed | Do not create revenue targets without unit assumptions. |

## Raw Data Notes

Every report must preserve enough of the MCP outputs to reconstruct the conclusion:

- tool name
- exact input parameters
- date/month/granularity
- raw rows and filtered rows
- excluded rows by category
- missing fields and fallback used
- caveats for estimates
