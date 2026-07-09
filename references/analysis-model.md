# Analysis Model

Use this as the category-neutral Amazon report model. Load a category adapter when one exists.

## Market Capacity

Analyze demand at three levels:

- Broad demand: root terms with high volume.
- Segment/scene demand: use case, audience, vehicle/body part, hair type, room type, etc.
- Exact/attribute demand: color, material, capacity, size, feature, bundle, or compatibility terms.

Judge:

- Search volume and purchase volume/rate.
- Trend and seasonality.
- Whether exact demand is concentrated or dispersed into long-tail variants.
- Whether one broad term hides multiple product jobs that must be separated.

## Competition Degree

Use a multi-factor view instead of one number:

| Dimension | Signal | Interpretation |
| --- | --- | --- |
| SKU density | keyword result count, effective TOP sample count | High count means discovery competition and ad pressure. |
| Price crowding | price-band distribution | Crowded low bands create commoditization risk. |
| Brand concentration | sales/GMV share, unit share, or labeled fallback | Concentrated markets require sharper differentiation. |
| Review moat | top review counts and rating depth | 1K+ reviews creates trust barrier; 4K+ is a strong moat. |
| Traffic moat | natural keyword count vs ad keyword count | Natural keyword depth means hard-to-displace SEO. |
| Product maturity | repeated schemes across brands | Mature schemes require real product proof, not generic claims. |
| Content moat | A+, video, badges, bundles, proof images | Content maturity affects conversion and ad efficiency. |

## Price Band Distribution

Adapt bands to the category ASP. Always show:

- count or percentage
- effective sample size
- low/mid/premium/flagship meaning
- whether bundles or multi-packs were normalized
- price-per-unit when capacity/quantity differs materially

## Brand Share

Preferred口径:

- `按月销量估算`: sum effective ASIN monthly units by normalized brand.
- `按月销售额估算`: sum effective ASIN monthly sales amount by normalized brand.
- `按近30天销量/销售额估算`: use rolling-period metric when returned.

Fallback口径:

- `按相关 ASIN 数粗略估算`: only when sales units and sales amount are unavailable or too incomplete.
- `按 BSR proxy 粗略估算`: only when BSR prediction is used consistently and limitations are stated.

Rules:

- Use brand sales amount share when sales amount coverage is >=70%.
- Use unit share when sales amount is missing but unit coverage is >=70%.
- If coverage is <70%, collect more data or use a clearly labeled fallback.
- Do not mix ASIN-count share with unit/GMV share in one chart.
- For parent/child variation data, choose one consistent level and state it.

ASIN prediction rule:

- For deep-analysis ASINs, use SellerSprite `asin_prediction` as the primary monthly units/GMV source.
- First call `asin_prediction` without custom `returnFields`; then parse `monthItemList.sales`, `monthItemList.amount`, and `monthItemList.price`.
- Do not treat missing sales fields in `traffic_source` or `asin_detail` as proof that SellerSprite lacks sales estimates; those tools are not the primary sales interface.
- Use `bsr_prediction` only as a labeled fallback when `asin_prediction` is unavailable or the usable ASIN coverage remains below 70%.

## Product Scheme Comparison

For any category, compare:

- product job/use case
- core specs/capacity/size
- form factor and package format
- differentiating technology/material/formula
- included accessories or bundle contents
- compatibility/audience/usage limitations
- proof assets in listing: A+, video, badges, before/after, install/use images
- price and value metric, such as price per oz, per pod, per count, per application
- service/warranty/after-sales promise
- review risks and root causes

Load category-specific attributes from `references/category-adapters/` when applicable.

## Review Mining

Cluster 1-3 star reviews into product-mechanism groups:

`review signal -> root problem -> product opportunity -> listing/content proof`

Do not stop at "users complain about quality." Convert complaints into R&D, packaging, content, or support actions.

## Traffic And Keyword Moat

Compare:

- total traffic keywords
- natural search keywords
- sponsored product / brand / video keywords
- brand keywords
- Amazon official recommendation badges
- keyword purchase rate and PPC bid when available

Interpretation:

- High natural keyword depth = SEO moat.
- High ad/video keyword share = paid acquisition dependence.
- High brand keyword share = brand demand or defensive traffic.
- Low traffic word count with good BSR = likely strong off-keyword or external/brand traffic; validate before concluding.

## Entry And Business Target

Market entry is acceptable only when:

- demand is stable or seasonal with clear launch window
- there is a price band that supports target positioning
- high-end competitors prove willingness to pay
- target brand has demonstrable differentiators
- initial review and content plan reduces trust barrier

Tie annual targets to:

- SKU ladder
- ASP range
- units needed
- quarter ramp
- review milestone
- ad/content plan
- inventory and launch risk

Use:

`Revenue = target units * ASP`

Then split by quarter according to seasonality, launch timing, and review accumulation.
