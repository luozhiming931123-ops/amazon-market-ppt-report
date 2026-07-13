"use strict";

const assert = require("assert");
const visual = require("../scripts/pptx_visual_primitives");

const commands = [];
const ctx = {
  shape: (kind, options) => commands.push({ kind, options }),
  text: (value, options) => commands.push({ kind: "text", value, options }),
};

function spec(role, type, points) {
  return { role, type, source: "data/fixture.json", sample: "test sample", period: "2026-06", dataPoints: points };
}

visual.barChart(ctx, spec("price_band", "bar", 3), [{ label: "Low", value: 20 }, { label: "Mid", value: 40 }, { label: "High", value: 30 }], { x: 0.3, y: 0.3, w: 5.4, h: 3.0 });
visual.lineChart(ctx, spec("keyword_trend", "line", 6), [1, 2, 3, 4, 5, 6].map((value) => ({ label: `M${value}`, value })), { x: 6.0, y: 0.3, w: 5.4, h: 3.0 });
visual.stackedBar(ctx, spec("traffic_mix", "stacked_bar", 3), ["A", "B", "C"].map((label) => ({ label, segments: [{ value: 60 }, { value: 40 }] })), { x: 0.3, y: 3.6, w: 5.4, h: 3.0 });
visual.scatterPlot(ctx, spec("positioning", "scatter", 6), [0, 1, 2, 3, 4, 5].map((i) => ({ label: `P${i}`, x: i / 5, y: 1 - i / 5 })), { x: 6.0, y: 3.6, w: 5.4, h: 3.0 });
visual.heatmap(ctx, spec("review_risk", "heatmap", 16), ["A", "B", "C", "D"], ["1", "2", "3", "4"], Array.from({ length: 4 }, () => [0.1, 0.4, 0.7, 1]), { x: 0.3, y: 6.9, w: 5.4, h: 3.0 });
visual.funnel(ctx, spec("sample_funnel", "funnel", 3), [{ label: "Raw", value: 100 }, { label: "Relevant", value: 70 }, { label: "Effective", value: 57 }], { x: 6.0, y: 6.9, w: 5.4, h: 3.0 });
visual.timeline(ctx, spec("roadmap", "timeline", 3), [{ label: "Q1" }, { label: "Q2" }, { label: "Q3" }], { x: 0.3, y: 10.2, w: 11.1, h: 2.0 });

assert(commands.length > 70, "expected chart primitives to emit substantial drawing commands");
assert(commands.every((command) => command.options.name.includes("[VISUAL role=")), "every emitted command must carry visual metadata");
assert(commands.some((command) => command.options.name.includes("role=price_band;type=bar")), "bar metadata missing");
assert(commands.some((command) => command.options.name.includes("role=keyword_trend;type=line")), "line metadata missing");
console.log("PASS visual primitives emit tagged chart geometry");
