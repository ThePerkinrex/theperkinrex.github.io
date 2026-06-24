
#import "@preview/shadowed:0.3.0": shadow

#let math-bot-label = label("_math_bot_")
#let math-ref-bot-label = label("_math_ref_bot_")

#let y-shifts = state("y-shifts", ())
#let inline-math-count = counter("inline-math-count")

#let shift-inline-math(body) = context {
  let formula-cnt = inline-math-count.get().first()
  inline-math-count.step()
  let begin-loc = here()
  // The wrapper ensures that the viewbox of rendered SVG math matches its bounding box.
  let wrapper = text.with(top-edge: "bounds", bottom-edge: "bounds")
  // For debugging: draw red box around the wrapper
  // let wrapper = it => box(wrapper(it), stroke: red)
  html.elem(
    "span",
    (wrapper(
      // Add invisible elements below the math body to measure its bottom position.
      math.attach(math.limits(body.body), b: pad([#none#math-bot-label], -1em))
        + sym.wj
        + math.attach(math.limits([#none]), b: pad([#none#math-ref-bot-label], -1em)),
    )),
    attrs: (
      // Rendered SVG defines its width & height in "em" units,
      // so we also convert y-shift relative to text size in "em" units.
      style: "vertical-align: -"
        + str(calc.round(y-shifts.final().at(formula-cnt, default: 0pt) / text.size, digits: 2))
        + "em;",
      class: "typst-inline-math",
    ),
  )
}

#let html-export-template(doc) = context {
  if target() != "html" {
    return doc
  }
  show math.equation.where(block: false): it => {
    // The target() function can be used to apply html.frame selectively only
    // when the export target is HTML.
    // When html.frame is applied to a figure, the target() for all the elements
    // inside will be set to "paged" instead.
    // https://github.com/typst/typst/issues/721#issuecomment-3064895139
    if target() == "html" {
      shift-inline-math(it)
    } else {
      it
    }
  }
  show math.equation.where(block: true): it => {
    html.elem(
      "div",
      it,
      attrs: (class: "typst-display-math"),
    )
  }
  // Wrap code blocks in a div for styling
  show raw.where(block: true): it => {
    html.elem(
      "div",
      it,
      attrs: (class: "typst-code-block"),
    )
  }
  doc
  // After the whole document, calculate the y-shift for every inline math.
  // This reduces the number of `query` calls, improving performance.
  context {
    let math-bots = query(math-bot-label)
    let math-ref-bots = query(math-ref-bot-label)
    if math-bots.len() == inline-math-count.get().first() {
      assert(math-bots.len() == math-ref-bots.len())
      let new-y-shifts = math-bots
        .zip(math-ref-bots, exact: true)
        .map(pair => {
          let (math-bot, math-ref-bot) = pair
          let y1 = math-bot.location().position().y
          let y2 = math-ref-bot.location().position().y
          y1 - y2
        })
      y-shifts.update(old => new-y-shifts)
    }
  }
}

#let image_shadow(radius: 5pt, content) = {
	let chain = (
		shadow.with(radius: radius, dx: 0pt, dy: 2pt, blur: 6pt, fill: gray.transparentize(75%)),
		shadow.with(radius: radius, dx: 0pt, dy: 8pt, blur: 24pt, fill: gray.transparentize(66%)),
		shadow.with(radius: radius, dx: 0pt, dy: 16pt, blur: 32pt, fill: gray.transparentize(66%)),
	)
	
	// Apply all shadows by nesting boxes
  let result = box(radius: radius, clip: true, content)

  for s in chain.rev() {
    result = s(
      result,
    )
  }

  result
}

#let str2date(s) = {
	let split = s.split("-")
	datetime(year: int(split.at(0)),month: int(split.at(1)),day: int(split.at(2)))

}


#let conf(
  title: none,
  pubDate: none,
  description: none,
  heroImage: none,
  draft: false,
  updateDate: none,
  tags: (),
  body,
) = context [
  #if (title, pubDate, description, heroImage).any(it => it == none) {
    panic("title, description, pubDate, and heroImage should be set, theyre required")
  }


	#let pubDateDate = str2date(pubDate)

  #metadata((
    title: title,
    pubDate: pubDate,
    updateDate: updateDate,
    description: description,
    tags: tags,
    heroImage: heroImage,
    draft: draft,
  ))<post-meta>
  #set document(title: title, description: description)
  #set par(justify: true)
	#set page(margin: (x: 120pt))
  #set text(font: "Atkinson Hyperlegible")
  #show raw: set text(font: "Atkinson Hyperlegible Mono")

  #if target() != "html" {
    pad(x: -50pt, bottom: 20pt,image_shadow(radius: 5pt, image("blog/" + heroImage)))
    std.title()

	
		
		raw(pubDateDate.display())
		[ --- ]

    text(style: "italic", gray.darken(80%), description)
    line()
  }

  #html-export-template(body)
]
