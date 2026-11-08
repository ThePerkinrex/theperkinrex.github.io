// Light/dark switch. The initial theme is set by an inline script in <head> (site/layout.typ) so the
// page never flashes; this only wires up the header button.
(() => {
	const root = document.documentElement;
	const media = window.matchMedia("(prefers-color-scheme: dark)");
	const stored = () => {
		try {
			return localStorage.getItem("theme");
		} catch {
			return null;
		}
	};
	const apply = (theme) => {
		root.dataset.theme = theme;
		for (const button of document.querySelectorAll(".theme-toggle")) {
			button.setAttribute("aria-pressed", String(theme === "dark"));
		}
	};

	apply(root.dataset.theme || (media.matches ? "dark" : "light"));

	// Follow the system until the visitor picks a theme themselves.
	media.addEventListener("change", (event) => {
		if (!stored()) apply(event.matches ? "dark" : "light");
	});

	for (const button of document.querySelectorAll(".theme-toggle")) {
		button.addEventListener("click", () => {
			const next = root.dataset.theme === "dark" ? "light" : "dark";
			apply(next);
			try {
				// Picking the system's own theme goes back to following the system.
				if (next === (media.matches ? "dark" : "light")) localStorage.removeItem("theme");
				else localStorage.setItem("theme", next);
			} catch {}
		});
	}
})();

// Sticky header: show the post title in the header once the post's own <h1> has scrolled under it.
(() => {
	const header = document.querySelector(".site-header");
	const heading = document.querySelector("main h1");
	if (!header || !heading || !header.querySelector(".header-title")) return;
	if (!("IntersectionObserver" in window)) return;

	let observer;
	const observe = () => {
		observer?.disconnect();
		observer = new IntersectionObserver(
			([entry]) => {
				const above = entry.boundingClientRect.top < header.offsetHeight;
				header.classList.toggle("show-title", !entry.isIntersecting && above);
			},
			{ rootMargin: `-${header.offsetHeight}px 0px 0px 0px` },
		);
		observer.observe(heading);
	};
	observe();
	window.addEventListener("resize", observe, { passive: true });
})();
