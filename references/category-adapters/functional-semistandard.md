# Functional / Semi-Standard Product Adapter

Use this adapter for products whose core specification is standardized but whose buying decision depends on function, compatibility, configuration, installation, durability, accessories, or service. Examples include automotive accessories, tools, lighting, electronics accessories, replacement/upgrade kits, outdoor equipment, and appliance add-ons.

## 1. Define the buying job before collecting data

Record these fields in `data/00_research_scope.json`:

| Field | Required definition |
| --- | --- |
| Buyer and scene | Who uses it, in what task, and with what consequence of failure? |
| Installed object/platform | Vehicle, device, appliance, tool, environment, or mounting location. |
| Functional job | The outcome purchased: illuminate, protect, connect, measure, secure, extend, repair, or upgrade. |
| Compatibility boundary | Supported models, size/interface ranges, voltage/power, environment, and exclusions. |
| Functional unit | The comparable unit: installed set, compatible device, capacity, output, length, count, or coverage. |
| Product boundary | What counts as core product, accessory, replacement part, bundle, or unrelated result. |
| Evidence boundary | What MCP/listing data can show and which claims require first-party or external validation. |

## 2. Build the market universe

Use four keyword layers, then union and deduplicate the ranked ASIN results:

1. Root/product words: what the product is.
2. Scene/job words: the use case and buyer need.
3. Compatibility words: platform, model, size, interface, voltage, or material.
4. Attribute/value words: performance, configuration, quality, installation, control, and premium signals.

Document raw count, effective count, parent/child rule, and exclusions. Do not call a single-keyword TOP list the market.

## 3. Normalize price and product value

Use a comparable functional unit before creating price bands. Typical denominators include:

- price per installed set, compatible platform, capacity/output step, meter/foot, pod/unit, or coverage area;
- included accessories, controller/adapter, mounting/harness, and spare parts;
- standard versus bundled configuration; and
- observed deal price versus list price when both are visible.

State when a product cannot be normalized cleanly; keep it out of the price-band calculation or label it separately.

## 4. Build the competitor and product-value matrix

Select 12-20 deep ASINs stratified by normalized price band, brand, product form, and core configuration. Compare the dimensions relevant to the buying job:

| Dimension | Evidence to compare |
| --- | --- |
| Functional performance | Rated output/capacity, operating modes, measurable specification, and proof claimed in Listing. |
| Compatibility | Supported platform/model/interface, exclusions, adapters, and fitment caveats. |
| Configuration | Form factor, bundle contents, controls, connectivity, expandability, and variants. |
| Installation | Tools, wiring/assembly, mounting, instructions, time/complexity, and missing-part risk. |
| Reliability | Material, sealing/protection, thermal/load limits, failure complaints, and warranty evidence. |
| Service | Replacement parts, support content, warranty, returns signals, and seller response evidence. |

Convert the matrix into an entry thesis: repeated baseline features are table stakes; premium price requires visible proof on the functions that reduce buyer risk.

## 5. Mine reviews as product requirements

Use low-star review samples across core price bands/brands when available. Cluster into:

- compatibility/fitment mismatch;
- performance below expectation;
- installation, cable, connector, adapter, or missing-part failure;
- durability, water/heat/load, QC, or safety concern;
- control/app/software/usability failure; and
- service, warranty, or Listing-promise mismatch.

For every material cluster, write: `review signal -> likely failure mode -> product/control requirement -> Listing or support proof`.

## 6. Produce decision-ready outputs

The executive summary must answer:

1. Is entry justified within the observed sample, and what is the sample boundary?
2. What normalized price/value position is viable?
3. Which SKU/configuration should launch first, and what must be validated before launch?
4. What launch timing, content/PPC focus, and quarterly unit/GMV scenario follows from the evidence?

Use `product_value_matrix`, `compatibility_fitment_matrix`, `review_risk_heatmap`, `price_product_positioning`, `sku_ladder`, and `roadmap` as the category-adapted visual roles. Use a validation-gate table for claims that MCP data cannot prove.

## 7. Boundaries that must remain explicit

- Observed ASIN-sample concentration is not category market share or TAM.
- Listing specifications and reviews are market signals, not laboratory/product-compliance proof.
- Unit/GMV scenarios are not a profit model without landed cost, FBA fees, PPC, returns, warranty, and tax inputs.
- Compatibility, regulatory, safety, and certification conclusions require authoritative validation outside the marketplace data path.
