#import "@tola/source:0.0.0": tola-meta
#import "/site/components.typ": *

#tola-meta((
  title: "I just wanted to know where to fill up",
  description: "A daily map of every Spanish petrol station's prices that kept growing: a route planner, forecasts and price alerts, all on a Raspberry Pi.",
  date: "2026-11-12",
  tags: ("rust", "web", "forecasting", "raspberry-pi", "self-hosting"),
  hero: "/assets/images/fuel-price-tracker.svg",
  draft: true,
))

This is the story of my journey in creating a tool for myself, but mostly, an example of scope creep
at its peak.

= My problem

The latest few months (and years) have been a bit crazy in terms of prices changes in Spain,
specially when it comes to fuel prices. The volatility has gone through the roof, thanks to
inflation, the wars in Ukraine and the Middle East, and tariffs.

#todo[
  A graph of the recent fuel prices in Spain / volatility
]

So, given this situation, I wanted to find out what gas stations in Spain had the cheapest prices,
close to where I was, or when planning a trip, to find where to stop, because the differences from
different stations and regions were and are quite big. So I decided to make a tool for myself.

= The plan
Make something, probably a web page, where I could see on a map the current diesel and gasoline
prices for each station. Having a historical record of the prices could be useful, but it was
strictly necessary. This should be usable from my phone, as when planning a trip I don't usually
have a computer on hand.

The service was going to be hosted on my #link(
  "https://www.raspberrypi.com/products/raspberry-pi-3-model-b/",
)[Raspberry Pi model 3b], so reducing its memory footprint was essential, and just to make sure it
wasn't overloaded, and only the users I actually wanted had access, I planned to hide it behind
#link("https://en.wikipedia.org/wiki/Mutual_authentication#mTLS")[mTLS] with a custom certificate
authority, so that the authentication is just using the mTLS cert provided, validated with #link(
  "https://nginx.org/",
)[NGINX].

Did I need anything else? I didn't think so. That would be an upgrade to just searching on Google
Maps, or brand specific apps. With that I could just speed up my current workflow, which was what I
wanted.

= First stage: the map

So first, I needed to get the data, which was not obvious. I knew that some brands had the data
shown on their app on their website: for example, Repsol has a #link(
  "https://www.repsol.es/buscador-eess-y-puntos-de-recarga/",
)[similar map] for its stations, where prices are shown, but only if you clicked on a station, which
was inconvenient, but I could scrape some data from there. It wasn't the best, but could work.

Still I wanted something that was preferably public (and legal to use), and covered all stations,
not just a single brand. I searched for a while, until I found #link(
  "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/help",
)[an API] that the _Ministerio de Industria y Turismo_, the Spanish Industry and Tourism Ministry,
published, with supposedly updated price data for all stations in Spain, as stations are legally
obligated since 2007 to send their prices to the Spanish government.#footnote[
  #link("https://www.boe.es/buscar/doc.php?id=BOE-A-2007-14592")[Orden ITC/2308/2007], de 25 de
  julio, which sets how fuel suppliers must report their prices to the ministry. The same data
  powers the ministry's own map, the #link("https://geoportalgasolineras.es/")[Geoportal de
    Gasolineras].
]

That actually gave be both prices and info about the stations: the name, address, and coordinates.
One thing that the API lacked was speed in the response. A query was very slow, so I decided to use
it, but to make a cache of the data that just downloaded it a few times a day, and then served it.
And given I was already caching it, I decided to actually store the historical data, just in case I
ever wanted to do something with that, like showing historic data in a graph, or trying to make
predictions.

Did you catch that? Just there I had made the first error that was going to lead me into the scope
creep rabbit hole. But I didn't know. At that moment I just wanted my map.

So having the gas station data, I continued working on this, creating a server in #link(
  "https://www.rust-lang.org/",
)[Rust], using #link("https://github.com/tokio-rs/axum")[Axum], to serve the data and the map web
page.

Why Rust? I like the language quite a lot, once you understand it (which is not easy, but it clicks
once, and you never look back), it makes development quite enjoyable, and keeps your code safe. It
also helps quite a lot in keeping the memory footprint down, as the whole language is designed to
make you think about how you work with memory, unlike most modern languages.

I'm not an expert frontend developer, but I know my way around the web stack, so I made a simple
page that just used #link("https://leafletjs.com/")[Leaflet] to show the #link(
  "https://www.openstreetmap.org/",
)[OpenStreetMap], and just added some markers on top to show the prices, with the info about each
station on a popup. Simple but it worked like a charm. I had completed my original goal, and I
actually left it like this for a while, using it when I needed to fill up.

But, as I used it I kept coming up with ways to change my flow, or improve things. Thanks to not
having the overhead of having to look up and click stations, I had just freed my brain to think of
things I didn't even contemplate before, as I now had the canvas where I could actually implement
it.
