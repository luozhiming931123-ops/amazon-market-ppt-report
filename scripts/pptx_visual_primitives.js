"use strict";

/*
 * Renderer-agnostic evidence visual primitives for PPTX generators.
 *
 * Supply an adapter with `shape(kind, options)` and `text(value, options)`.
 * The adapter must preserve `name` and `descr` on the resulting p:cNvPr node.
 * This allows pptxgenjs, custom OOXML, or another renderer to use the same
 * chart geometry while the audit script verifies the source metadata.
 */

const COLORS = {
  navy: "14263D", blue: "1F6FEB", teal: "0F8B8D", gold: "D99A22",
  red: "C44747", gray: "667085", light: "E9EEF5", dark: "101828",
};

function invariant(condition, message) {
  if (!condition) throw new Error(message);
}

function esc(value) {
  return String(value ?? "").replace(/[;=\[\]]/g, " ").trim();
}

function visualMeta(spec) {
  for (const field of ["role", "type", "source", "sample", "period"]) {
    invariant(spec[field], `visual metadata requires ${field}`);
  }
  const points = Number(spec.dataPoints ?? 0);
  invariant(Number.isFinite(points) && points > 0, "visual metadata requires dataPoints > 0");
  return `[VISUAL role=${esc(spec.role)};type=${esc(spec.type)};source=${esc(spec.source)};sample=${esc(spec.sample)};period=${esc(spec.period)};points=${points}]`;
}

function tagged(base, spec, suffix) {
  const marker = visualMeta(spec);
  return { ...base, name: `${marker} ${suffix || "evidence"}`, descr: marker };
}

function title(ctx, spec, box, heading) {
  ctx.text(heading, tagged({ x: box.x, y: box.y, w: box.w, h: 0.28, fontSize: 15, bold: true, color: COLORS.dark }, spec, "title"));
  ctx.text(`口径：${spec.period} · ${spec.sample}`, tagged({ x: box.x, y: box.y + 0.30, w: box.w, h: 0.18, fontSize: 7.5, color: COLORS.gray }, spec, "method"));
}

function valueScale(values, min, max) {
  const lo = min ?? 0;
  const hi = max ?? Math.max(...values, 1);
  return (value) => lo === hi ? 0 : (value - lo) / (hi - lo);
}

function barChart(ctx, spec, data, box, options = {}) {
  invariant(data.length >= 3, "barChart requires at least 3 data points");
  title(ctx, spec, box, options.title || "对比分析");
  const plot = { x: box.x + 0.45, y: box.y + 0.72, w: box.w - 0.55, h: box.h - 1.02 };
  const max = Math.max(...data.map((d) => d.value), 1);
  const gap = 0.10, barW = (plot.w - gap * (data.length - 1)) / data.length;
  ctx.shape("line", tagged({ x: plot.x, y: plot.y + plot.h, w: plot.w, h: 0, line: { color: COLORS.gray, width: 0.6 } }, spec, "axis"));
  data.forEach((d, i) => {
    const h = Math.max(0.04, (d.value / max) * plot.h);
    const x = plot.x + i * (barW + gap), y = plot.y + plot.h - h;
    ctx.shape("rect", tagged({ x, y, w: barW, h, fill: { color: d.color || COLORS.blue }, line: { color: d.color || COLORS.blue } }, spec, `bar-${i + 1}`));
    ctx.text(String(d.value), tagged({ x, y: y - 0.20, w: barW, h: 0.16, fontSize: 7.5, align: "center", color: COLORS.dark }, spec, `value-${i + 1}`));
    ctx.text(d.label, tagged({ x, y: plot.y + plot.h + 0.06, w: barW, h: 0.28, fontSize: 7, align: "center", color: COLORS.gray, breakLine: false }, spec, `label-${i + 1}`));
  });
}

function lineChart(ctx, spec, data, box, options = {}) {
  invariant(data.length >= 6, "lineChart requires at least 6 time points");
  title(ctx, spec, box, options.title || "趋势分析");
  const plot = { x: box.x + 0.48, y: box.y + 0.72, w: box.w - 0.65, h: box.h - 1.02 };
  const values = data.map((d) => d.value), min = Math.min(...values), max = Math.max(...values);
  const scale = valueScale(values, min, max);
  for (let row = 0; row < 4; row += 1) {
    const y = plot.y + (plot.h / 3) * row;
    ctx.shape("line", tagged({ x: plot.x, y, w: plot.w, h: 0, line: { color: COLORS.light, width: 0.5 } }, spec, `grid-${row + 1}`));
  }
  const points = data.map((d, i) => ({ x: plot.x + (i / (data.length - 1)) * plot.w, y: plot.y + plot.h - scale(d.value) * plot.h }));
  points.slice(1).forEach((p, i) => ctx.shape("line", tagged({ x: points[i].x, y: points[i].y, w: p.x - points[i].x, h: p.y - points[i].y, line: { color: options.color || COLORS.teal, width: 2.2 } }, spec, `segment-${i + 1}`)));
  points.forEach((p, i) => {
    ctx.shape("ellipse", tagged({ x: p.x - 0.045, y: p.y - 0.045, w: 0.09, h: 0.09, fill: { color: options.color || COLORS.teal }, line: { color: options.color || COLORS.teal } }, spec, `point-${i + 1}`));
    ctx.text(data[i].label, tagged({ x: p.x - 0.25, y: plot.y + plot.h + 0.06, w: 0.5, h: 0.16, fontSize: 6.5, align: "center", color: COLORS.gray }, spec, `label-${i + 1}`));
  });
}

function stackedBar(ctx, spec, data, box, options = {}) {
  invariant(data.length >= 3, "stackedBar requires at least 3 categories");
  invariant(data.every((d) => Array.isArray(d.segments) && d.segments.length >= 2), "stackedBar requires 2+ segments per category");
  title(ctx, spec, box, options.title || "结构占比");
  const plot = { x: box.x + 1.05, y: box.y + 0.72, w: box.w - 1.22, h: box.h - 0.92 };
  const rowH = plot.h / data.length;
  data.forEach((row, i) => {
    const total = row.segments.reduce((sum, s) => sum + s.value, 0) || 1;
    let cursor = plot.x;
    ctx.text(row.label, tagged({ x: box.x, y: plot.y + i * rowH + 0.08, w: 0.95, h: 0.18, fontSize: 8, align: "right", color: COLORS.gray }, spec, `row-${i + 1}`));
    row.segments.forEach((segment, j) => {
      const w = (segment.value / total) * plot.w;
      ctx.shape("rect", tagged({ x: cursor, y: plot.y + i * rowH + 0.05, w, h: rowH - 0.12, fill: { color: segment.color || [COLORS.blue, COLORS.teal, COLORS.gold][j % 3] }, line: { color: "FFFFFF", width: 0.4 } }, spec, `segment-${i + 1}-${j + 1}`));
      if (w > 0.45) ctx.text(`${segment.value}%`, tagged({ x: cursor, y: plot.y + i * rowH + 0.12, w, h: 0.16, fontSize: 7, align: "center", color: "FFFFFF" }, spec, `segment-label-${i + 1}-${j + 1}`));
      cursor += w;
    });
  });
}

function scatterPlot(ctx, spec, data, box, options = {}) {
  invariant(data.length >= 6, "scatterPlot requires at least 6 points");
  title(ctx, spec, box, options.title || "定位图");
  const plot = { x: box.x + 0.55, y: box.y + 0.72, w: box.w - 0.80, h: box.h - 1.05 };
  ctx.shape("line", tagged({ x: plot.x, y: plot.y + plot.h / 2, w: plot.w, h: 0, line: { color: COLORS.light, width: 0.8 } }, spec, "x-axis"));
  ctx.shape("line", tagged({ x: plot.x + plot.w / 2, y: plot.y, w: 0, h: plot.h, line: { color: COLORS.light, width: 0.8 } }, spec, "y-axis"));
  data.forEach((d, i) => {
    const x = plot.x + Math.max(0, Math.min(1, d.x)) * plot.w;
    const y = plot.y + (1 - Math.max(0, Math.min(1, d.y))) * plot.h;
    ctx.shape("ellipse", tagged({ x: x - 0.06, y: y - 0.06, w: 0.12, h: 0.12, fill: { color: d.color || COLORS.gold }, line: { color: "FFFFFF", width: 0.8 } }, spec, `point-${i + 1}`));
    ctx.text(d.label, tagged({ x: x + 0.07, y: y - 0.08, w: 0.72, h: 0.16, fontSize: 6.5, color: COLORS.dark }, spec, `label-${i + 1}`));
  });
}

function heatmap(ctx, spec, rows, columns, values, box, options = {}) {
  invariant(rows.length >= 4 && columns.length >= 4, "heatmap requires at least 4 rows and 4 columns");
  invariant(values.length === rows.length && values.every((r) => r.length === columns.length), "heatmap value dimensions must match rows and columns");
  title(ctx, spec, box, options.title || "风险热力图");
  const x0 = box.x + 1.15, y0 = box.y + 0.80, cellW = (box.w - 1.25) / columns.length, cellH = (box.h - 1.05) / rows.length;
  columns.forEach((label, j) => ctx.text(label, tagged({ x: x0 + j * cellW, y: y0 - 0.24, w: cellW, h: 0.20, fontSize: 7, align: "center", color: COLORS.gray }, spec, `column-${j + 1}`)));
  rows.forEach((label, i) => {
    ctx.text(label, tagged({ x: box.x, y: y0 + i * cellH + 0.06, w: 1.05, h: 0.18, fontSize: 7, align: "right", color: COLORS.gray }, spec, `row-${i + 1}`));
    columns.forEach((_, j) => {
      const intensity = Math.max(0, Math.min(1, values[i][j]));
      const color = intensity > 0.66 ? COLORS.red : intensity > 0.33 ? COLORS.gold : "A9D8D6";
      ctx.shape("rect", tagged({ x: x0 + j * cellW, y: y0 + i * cellH, w: cellW - 0.02, h: cellH - 0.02, fill: { color }, line: { color: "FFFFFF", width: 0.5 } }, spec, `cell-${i + 1}-${j + 1}`));
    });
  });
}

function funnel(ctx, spec, data, box, options = {}) {
  invariant(data.length >= 3, "funnel requires at least 3 stages");
  title(ctx, spec, box, options.title || "样本筛选漏斗");
  const max = Math.max(...data.map((d) => d.value), 1), h = (box.h - 0.72) / data.length;
  data.forEach((d, i) => {
    const w = Math.max(1.0, (d.value / max) * (box.w - 0.4));
    const x = box.x + (box.w - w) / 2, y = box.y + 0.62 + i * h;
    ctx.shape("trapezoid", tagged({ x, y, w, h: h - 0.06, fill: { color: [COLORS.blue, COLORS.teal, COLORS.gold, COLORS.red][i % 4] }, line: { color: "FFFFFF", width: 0.8 } }, spec, `stage-${i + 1}`));
    ctx.text(`${d.label}  ${d.value}`, tagged({ x, y: y + (h - 0.06) / 2 - 0.09, w, h: 0.18, fontSize: 8, bold: true, align: "center", color: "FFFFFF" }, spec, `stage-label-${i + 1}`));
  });
}

function matrix(ctx, spec, rows, columns, values, box, options = {}) {
  return heatmap(ctx, { ...spec, type: "matrix" }, rows, columns, values, box, { title: options.title || "产品方案矩阵" });
}

function timeline(ctx, spec, data, box, options = {}) {
  invariant(data.length >= 3, "timeline requires at least 3 milestones");
  title(ctx, spec, box, options.title || "执行路线图");
  const y = box.y + box.h / 2 + 0.10, x0 = box.x + 0.45, width = box.w - 0.9;
  ctx.shape("line", tagged({ x: x0, y, w: width, h: 0, line: { color: COLORS.blue, width: 1.5 } }, spec, "axis"));
  data.forEach((d, i) => {
    const x = x0 + (i / (data.length - 1)) * width;
    ctx.shape("ellipse", tagged({ x: x - 0.07, y: y - 0.07, w: 0.14, h: 0.14, fill: { color: d.color || COLORS.gold }, line: { color: "FFFFFF", width: 0.8 } }, spec, `milestone-${i + 1}`));
    ctx.text(d.label, tagged({ x: x - 0.48, y: y - 0.55, w: 0.96, h: 0.30, fontSize: 8, bold: true, align: "center", color: COLORS.dark }, spec, `milestone-label-${i + 1}`));
    ctx.text(d.detail || "", tagged({ x: x - 0.52, y: y + 0.16, w: 1.04, h: 0.30, fontSize: 6.5, align: "center", color: COLORS.gray }, spec, `milestone-detail-${i + 1}`));
  });
}

module.exports = { COLORS, visualMeta, tagged, barChart, lineChart, stackedBar, scatterPlot, heatmap, funnel, matrix, timeline };
