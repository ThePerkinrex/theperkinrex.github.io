// Interactive charts for the `chart` component (site/chart.typ). Each `.chart` holds its
// description as JSON; this draws every panel with uPlot (vendor/uplot, loaded once, on demand),
// with a shared cursor whose values show in each panel's legend, the chart's events and bands, and
// the site's theme colours (redrawn when the theme changes). The PDF draws the same description
// with Lilaq, so a feature added here belongs there too.

const DAY = 86400;
const NARROW = 520; // px: below this, short titles and labels, a year label every other year
const root = document.documentElement;

let uplot;
const loadUPlot = (js, css) =>
	(uplot ??= new Promise((resolve, reject) => {
		const link = Object.assign(document.createElement("link"), { rel: "stylesheet", href: css });
		const script = Object.assign(document.createElement("script"), { src: js });
		script.onload = () => resolve(window.uPlot);
		script.onerror = reject;
		document.head.append(link, script);
	}));

/// The site's colours and font, read from its CSS tokens, plus the palette for the current theme.
const theme = (spec) => {
	const css = getComputedStyle(root);
	const token = (name) => css.getPropertyValue(name).trim();
	const dark = root.dataset.theme
		? root.dataset.theme === "dark"
		: matchMedia("(prefers-color-scheme: dark)").matches;
	return {
		text: token("--text"),
		muted: token("--muted"),
		line: token("--line"),
		band: token("--code-bg"),
		font: token("--font-body") || "sans-serif",
		series: spec.palette[dark ? "dark" : "light"],
	};
};

const decodeX = (x) =>
	Array.isArray(x) ? x : Array.from({ length: x.count }, (_, i) => x.start + i * x.step);

// Rounds half up on the decimal value (1.595 → 1.60), as Typst does, not on its binary float.
const round = (v, digits) => Math.round(+(v * 10 ** digits).toPrecision(12)) / 10 ** digits;
const format = (v, f, digits = f.digits) =>
	v == null ? "–" : f.prefix + round(v, digits).toFixed(digits) + f.suffix;

const utc = (seconds) => new Date(seconds * 1000);
const dayLabel = new Intl.DateTimeFormat("en-GB", {
	day: "numeric",
	month: "short",
	year: "numeric",
	timeZone: "UTC",
});
const monthLabel = new Intl.DateTimeFormat("en-GB", {
	month: "short",
	year: "numeric",
	timeZone: "UTC",
});

/// Year ticks for a long axis (every other one when narrow), month ticks for a short one.
const timeTicks = (min, max, narrow) => {
	const [y0, y1] = [utc(min).getUTCFullYear(), utc(max).getUTCFullYear()];
	const ticks = [];
	if (y1 - y0 >= 3) {
		for (let y = y0; y <= y1; y++) {
			const t = Date.UTC(y, 0, 1) / 1000;
			if (t >= min && t <= max) ticks.push([t, String(y)]);
		}
		return ticks.map(([t, s], i) => [t, narrow && i % 2 ? "" : s]);
	}
	for (let d = new Date(Date.UTC(y0, utc(min).getUTCMonth(), 1)); d / 1000 <= max; d.setUTCMonth(d.getUTCMonth() + 1)) {
		if (d / 1000 >= min) ticks.push([d / 1000, monthLabel.format(d)]);
	}
	return ticks;
};

/// The panel's series as uPlot data: one shared x column (seconds), one y column per series.
/// A step series holds its last value until the end of the axis.
const panelData = (uPlot, panel, xMax) => {
	const tables = panel.series.map((s) => {
		const xs = decodeX(s.x).map((d) => d * DAY);
		const ys = [...s.y];
		if (s.kind === "step") {
			xs.push(xMax);
			ys.push(ys.at(-1));
		}
		return [xs, ys];
	});
	return tables.length === 1 ? tables[0] : uPlot.join(tables);
};

/// Index of the last x at or before `x`: where a step line's value is read.
const floorIndex = (xs, x) => {
	let [lo, hi] = [0, xs.length - 1];
	if (x < xs[0]) return null;
	while (lo < hi) {
		const mid = (lo + hi + 1) >> 1;
		if (xs[mid] <= x) lo = mid;
		else hi = mid - 1;
	}
	return lo;
};

function render(container, spec, uPlot) {
	const t = theme(spec);
	const pr = uPlot.pxRatio;
	const [xMin, xMax] = [spec.x.min * DAY, spec.x.max * DAY];
	const key = `chart-${Math.random()}`;
	const width = () => container.clientWidth;
	const narrow = () => width() < NARROW;
	const font = (px) => `${Math.round(px * pr)}px ${t.font}`;
	const plots = [];
	// Every panel keeps the same room on the right, so their plot areas line up.
	const rightPad = spec.panels.some((p) => p["end-labels"]) ? 56 : 12;

	container.replaceChildren();
	spec.panels.forEach((panel, k) => {
		const first = k === 0;
		const last = k === spec.panels.length - 1;
		const steps = panel.series.some((s) => s.kind === "step");
		const data = panelData(uPlot, panel, xMax);
		const xs = data[0];
		// The last real point: a step series' closing point only extends the line.
		const lastIdx = xs.length - 1 - (steps ? 1 : 0);
		const xLabel = steps ? monthLabel : dayLabel;
		const realXs = xs.slice(0, lastIdx + 1);

		const title = document.createElement("p");
		title.className = "chart-title";
		const wrap = document.createElement("div");
		container.append(title, wrap);

		// Bands, behind the grid and lines.
		const drawBands = (u) => {
			const { ctx, bbox } = u;
			ctx.save();
			ctx.fillStyle = t.band;
			for (const b of spec.bands) {
				const x0 = u.valToPos(b.from * DAY, "x", true);
				const x1 = u.valToPos(b.to == null ? xMax : b.to * DAY, "x", true);
				ctx.fillRect(x0, bbox.top, x1 - x0, bbox.height);
			}
			ctx.restore();
		};

		// Event rules, their labels (first panel), and each series' last value (if asked).
		const drawMarks = (u) => {
			const { ctx, bbox } = u;
			const short = narrow();
			ctx.save();
			ctx.strokeStyle = t.muted;
			ctx.lineWidth = pr;
			ctx.setLineDash([2 * pr, 2 * pr]);
			for (const e of spec.events) {
				const x = Math.round(u.valToPos(e.x * DAY, "x", true)) + 0.5;
				ctx.beginPath();
				ctx.moveTo(x, bbox.top);
				ctx.lineTo(x, bbox.top + bbox.height);
				ctx.stroke();
			}
			ctx.setLineDash([]);
			ctx.textBaseline = "middle";
			ctx.font = font(12);
			ctx.fillStyle = t.muted;
			if (first) {
				const y = bbox.top + 10 * pr;
				for (const e of spec.events) {
					const x = u.valToPos(e.x * DAY, "x", true);
					ctx.textAlign = e.side === "left" ? "right" : "left";
					ctx.fillText(short ? e.short : e.label, x + (e.side === "left" ? -4 : 4) * pr, y);
				}
				for (const b of spec.bands.filter((b) => b.label)) {
					ctx.textAlign = "right";
					ctx.fillText(short ? b.short : b.label, u.valToPos(b.from * DAY, "x", true) - 4 * pr, y);
				}
			}
			if (panel["end-labels"]) {
				const ends = panel.series.map((s, i) => {
					let j = lastIdx;
					while (j > 0 && data[i + 1][j] == null) j--;
					const v = data[i + 1][j];
					return { x: u.valToPos(xs[j], "x", true), y: u.valToPos(v, "y", true), v, color: t.series[s.color] };
				});
				const ys = ends.map((e) => e.y);
				const order = ys.map((_, i) => i).sort((a, b) => ys[a] - ys[b]);
				for (let i = 1; i < order.length; i++) {
					const gap = 15 * pr;
					if (ys[order[i]] - ys[order[i - 1]] < gap) ys[order[i]] = ys[order[i - 1]] + gap;
				}
				ctx.font = font(13);
				ctx.textAlign = "left";
				ends.forEach((e, i) => {
					ctx.fillStyle = e.color;
					ctx.beginPath();
					ctx.arc(e.x, e.y, 3 * pr, 0, 2 * Math.PI);
					ctx.fill();
					ctx.fillStyle = t.text;
					ctx.fillText(format(e.v, panel.format), e.x + 7 * pr, ys[i]);
				});
			}
			ctx.restore();
		};

		const axis = { stroke: t.muted, font: font(12), grid: { stroke: t.line, width: 1 } };
		const plot = new uPlot(
			{
				width: width(),
				height: panel.height,
				padding: [first ? 8 : 4, rightPad, 0, 0],
				cursor: {
					sync: { key, scales: ["x", null] },
					drag: { x: false, y: false, setScale: false },
					y: false,
					points: { size: 7, width: 2 },
					...(steps && { dataIdx: (u, _s, _closest, x) => floorIndex(realXs, x) }),
				},
				select: { show: false },
				legend: { live: true },
				scales: {
					x: { time: false, range: () => [xMin, xMax] },
					y: { range: () => panel.y.lim },
				},
				axes: [
					{
						...axis,
						ticks: { stroke: t.line, width: 1, size: 4 },
						splits: (u) => timeTicks(xMin, xMax, narrow()).map(([v]) => v),
						values: (u, splits) => {
							const labels = new Map(timeTicks(xMin, xMax, narrow()));
							return splits.map((v) => (last ? labels.get(v) : ""));
						},
						size: last ? 30 : 6,
						gap: 4,
					},
					{
						...axis,
						size: 60,
						gap: 6,
						ticks: { show: false },
						splits: () => panel.y.ticks,
						values: (u, splits) => splits.map((v) => format(v, panel.format)),
					},
				],
				series: [
					{ label: steps ? "Month" : "Day", value: (u, v) => (v == null ? "–" : xLabel.format(utc(v))) },
					...panel.series.map((s) => ({
						label: s.name,
						stroke: t.series[s.color],
						width: 1.5,
						spanGaps: true,
						points: { show: false },
						...(s.kind === "step" && { paths: uPlot.paths.stepped({ align: 1 }) }),
						value: (u, v) => format(v, panel.format, panel.format["readout-digits"]),
					})),
				],
				hooks: {
					drawClear: [drawBands],
					draw: [drawMarks],
					// With no cursor, the legend shows the latest values.
					setCursor: [(u) => u.cursor.idx == null && u.setLegend({ idx: lastIdx })],
				},
			},
			data,
			wrap,
		);
		plot.setLegend({ idx: lastIdx });
		plot.over.style.touchAction = "pan-y";
		plots.push({ plot, panel, title, xs, lastIdx });
	});

	const titles = () => {
		for (const { panel, title } of plots) title.textContent = narrow() ? panel["short-title"] : panel.title;
	};
	titles();

	// Moves every panel's cursor to x (seconds), or hides it when x is null.
	const moveTo = (x) => {
		for (const { plot } of plots) {
			plot.setCursor({
				left: x == null ? -10 : plot.valToPos(x, "x"),
				top: x == null ? -10 : plot.over.clientHeight / 2,
			});
		}
	};

	// Touch: follow the finger across any panel, without stopping the page from scrolling.
	for (const { plot } of plots) {
		const follow = (event) => {
			const rect = plot.over.getBoundingClientRect();
			moveTo(plot.posToVal(event.touches[0].clientX - rect.left, "x"));
		};
		plot.over.addEventListener("touchstart", follow, { passive: true });
		plot.over.addEventListener("touchmove", follow, { passive: true });
	}

	// Keyboard: arrow keys step through the first panel's points (Shift: a month at a time).
	const { xs, lastIdx } = plots[0];
	let idx = null;
	container.tabIndex = 0;
	container.onkeydown = (event) => {
		const step = event.shiftKey ? 30 : 1;
		const moves = {
			ArrowLeft: () => (idx ?? lastIdx + 1) - step,
			ArrowRight: () => (idx ?? -1) + step,
			Home: () => 0,
			End: () => lastIdx,
			Escape: () => null,
		};
		if (!(event.key in moves)) return;
		event.preventDefault();
		idx = moves[event.key]();
		if (idx != null) idx = Math.max(0, Math.min(lastIdx, idx));
		moveTo(idx == null ? null : xs[idx]);
	};
	container.onblur = () => {
		idx = null;
		moveTo(null);
	};

	return {
		resize: () => {
			for (const { plot, panel } of plots) plot.setSize({ width: width(), height: panel.height });
			titles();
		},
		destroy: () => plots.forEach(({ plot }) => plot.destroy()),
	};
}

async function setup(container) {
	const spec = JSON.parse(container.querySelector('script[type="application/json"]').textContent);
	const uPlot = await loadUPlot(container.dataset.uplotJs, container.dataset.uplotCss);
	await document.fonts.ready;
	container.classList.add("chart-live");
	let chart = render(container, spec, uPlot);

	let lastWidth = container.clientWidth;
	new ResizeObserver(() => {
		if (container.clientWidth === lastWidth) return;
		lastWidth = container.clientWidth;
		chart.resize();
	}).observe(container);

	// Canvas colours are fixed once drawn: redraw on a theme change (the header toggle or the system).
	const redraw = () => {
		chart.destroy();
		chart = render(container, spec, uPlot);
	};
	new MutationObserver(redraw).observe(root, { attributes: true, attributeFilter: ["data-theme"] });
	matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => root.dataset.theme || redraw());
}

for (const container of document.querySelectorAll(".chart:not(.chart-live)")) {
	setup(container).catch((error) => console.error("chart:", error));
}
