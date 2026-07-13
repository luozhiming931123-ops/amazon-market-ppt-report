# Analysis Model

## Functional / Semi-Standard Product Decision Model

Use this model before applying a category-specific lens. A professional report must connect five layers:

```text
buyer job and compatibility boundary
-> multi-keyword observed sample
-> normalized price and product-value comparison
-> product / content / SKU decision
-> launch scenario and validation gates
```

For each core conclusion, state `observation -> mechanism -> implication -> action -> scope limit`.

| Decision | Required evidence | Do not overclaim |
| --- | --- | --- |
| Entry | demand trend, effective sample, price/value opening, competitive barrier | observed sample is not total market size |
| Positioning | normalized price, configuration, functional proof, high-end alternatives | Listing claim is not verified performance |
| Product/SKU | compatibility, installation, review failures, service evidence | market data cannot certify fitment/compliance |
| Launch | keyword intent, traffic mix, content proof, seasonality | unit/GMV scenario is not a profit model |

### Normalized price and value

Set the denominator from the buyer's functional unit before calculating price bands. Use price per installed set, compatible platform, capacity/output step, length, count, or coverage as appropriate. Separate bundle value from core product price. Never average incomparable configurations into a single ASP.

### Product value versus feature count

Score or compare only decision-relevant dimensions: functional performance, compatibility, configuration, installation, reliability, and service. Feature count alone is not value. A premium position is credible only when the Listing, product configuration, reviews, and support evidence consistently reduce a buyer risk that cheaper offers leave unresolved.

### Validation gates

Place unverified claims in a named gate, not in the conclusion. Typical gates include product test, compatibility/fitment check, regulatory/compliance check, landed-cost/FBA/PPC model, and warranty/return-rate validation.

## Market Capacity

Analyze at three levels:
- Broad demand: high-volume root terms such as `rock lights`.
- Scene demand: `rock lights for trucks`, `jeep rock lights`, `off road lights`.
- Exact/attribute demand: `rgb rock lights`, `rgb rock lights for trucks`, `rgbw rock lights`.

Judge:
- Search volume and purchase volume.
- Purchase rate and trend.
- Whether exact demand is concentrated or dispersed into long-tail variants.
- Seasonal timing by month/quarter.

## Competition Degree

Use a multi-factor view instead of one number:

| Dimension | Signal | Interpretation |
| --- | --- | --- |
| SKU density | keyword result count, effective TOP50 count | High count means discovery competition and ad pressure |
| Price crowding | price-band distribution | If >50% below a band, that band is crowded |
| Brand concentration | brand sales units or sales amount share | Use ASIN-count share only as fallback |
| Review moat | top review counts and rating depth | 1K+ reviews creates trust barrier; 4K+ is a strong moat |
| Traffic moat | natural keyword count vs ad keyword count | Natural keyword depth means hard-to-displace SEO |
| Product maturity | repeated schemes across brands | Mature schemes require real differentiation |

Optional scoring:

```text
competition_score =
  price_crowding * 0.25 +
  review_moat * 0.25 +
  traffic_moat * 0.20 +
  brand_concentration * 0.15 +
  product_homogeneity * 0.15
```

Use the score internally; present the mechanism in business language.

## Price Band Distribution

Suggested bands for automotive accessory reports:
- `<$40`
- `$40-$59`
- `$60-$89`
- `$90-$129`
- `$130+`

Adapt bands when ASP is materially different. Always show:
- count or percentage
- effective sample size
- whether the band is low-price, mid-range, premium, or flagship

## Brand Share

Preferred口径:
- "按月销量估算": sum effective ASIN monthly units by normalized brand.
- "按月销售额估算": sum effective ASIN monthly sales amount by normalized brand.
- "按近30天销量/销售额估算": use when the tool returns a rolling-period metric instead of monthly history.

Fallback口径:
- "按相关 ASIN 数粗略估算": only when sales units and sales amount are unavailable or too incomplete.

Calculation:

```text
brand_unit_share = sum(units for brand effective ASINs) / sum(units for all effective ASINs)
brand_sales_share = sum(sales_amount for brand effective ASINs) / sum(sales_amount for all effective ASINs)
coverage_rate = ASINs with usable sales data / effective ASINs
```

Rules:
- Default the PPT brand share chart to `brand_sales_share` when sales amount coverage is >=70%.
- Use `brand_unit_share` when sales amount is missing but units coverage is >=70%.
- If coverage is <70%, either collect more `asin_sales_trend` data or present ASIN-count share as a clearly labeled fallback.
- Do not mix ASIN-count share with unit/GMV share in one chart.
- If parent/child variation data causes duplication, choose one consistent level and state it in the chart口径.

## Product Scheme Comparison

For each major competitor, compare:
- pods/count/form factor
- LED type: RGB, RGBW, RGB+IC, segmented, chase/dreamcolor
- control: app, RF remote, Bluetooth, hardwired switch, dual-zone
- electrical方案: fuse, controller, memory, expansion, brake sync
- structure: aluminum, PC lens, tempered glass, waterproof rating, potting
- installation: harness length, connectors, adhesive/mounting, extension cable
- service: warranty, replacement parts, support content
- review risk: app, brightness, color accuracy, waterproof, cable, missing parts

For premium brands, make the conclusion specific: "premium price requires evidence in X", not "make quality better".

## Review Mining

Cluster 1-3 star reviews into:
- APP/Bluetooth/controller failure
- brightness or color accuracy
- water ingress, durability, heat
- wiring, connectors, installation length
- missing parts, QC, after-sales
- listing promise mismatch

Turn each cluster into:
`review signal -> root problem -> product opportunity -> listing/content proof`.

## Entry And Business Target

Market entry is acceptable only when:
- demand is stable or seasonal with clear launch window
- there is a price band that supports target positioning
- high-end competitors prove willingness to pay
- target brand has differentiators that can be demonstrated
- initial review and content plan reduces trust barrier

For annual targets, tie revenue to:
- SKU ladder
- ASP range
- units needed
- quarter ramp
- ad/content plan
- review milestone

Example:
`Revenue = target units * ASP`, then split by quarter according to seasonality and launch ramp.
