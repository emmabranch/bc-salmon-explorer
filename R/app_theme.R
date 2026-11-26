# R/app_theme.R
# Look and feel for the app, matching Emma Branch's other portfolio sites
# (shared brand kit: /Users/ecox/projects/_brand-kit). The "portfolio edition"
# of the Flash sheet look: paper background, ink outlines, hard shadows,
# Bricolage Grotesque and Space Mono, a framed hero with stripes made from the
# app's own data, the salmon motif, and the shared ink footer.
# Project colour: salmon.
# Everything is in this one file so the deploy script picks it up (it deploys
# app.R, renv.lock, R/, and www/). Shiny loads this file automatically because it is in R/.
# The motif and browser tab icon live in www/ (served as motif.svg and favicon.png).

# ---- Colours ----------------------------------------------------------------

# Shared palette (same as the brand kit's _brand.yml)
pal_ink    <- "#111111"
pal_paper  <- "#F3EEE3"
pal_cobalt <- "#2340FF"
pal_muted  <- "#5A544A"

# Project colours: salmon
salmon_accent       <- "#c2415e"   # heading bars, stat box strips, active tab
salmon_accent_2     <- "#f08aa0"   # a second shade
salmon_accent_light <- "#ffb0c0"   # hero accent words and the main hero button

# ---- bslib theme --------------------------------------------------------------
# Fonts come from Bunny Fonts: the same open fonts as Google Fonts, without tracking

app_theme <- bslib::bs_theme(
  version   = 5,
  bg        = pal_paper,
  fg        = pal_ink,
  primary   = pal_cobalt,
  secondary = pal_muted,
  base_font = bslib::font_link(
    "Bricolage Grotesque",
    href = "https://fonts.bunny.net/css?family=bricolage-grotesque:400,700,800&display=swap"
  ),
  heading_font = bslib::font_link(
    "Bricolage Grotesque",
    href = "https://fonts.bunny.net/css?family=bricolage-grotesque:400,700,800&display=swap"
  ),
  code_font = bslib::font_link(
    "Space Mono",
    href = "https://fonts.bunny.net/css?family=space-mono:400,700&display=swap"
  ),
  "headings-font-weight" = 800,
  "headings-color"       = pal_ink,
  "link-color"           = pal_cobalt,
  "border-radius"        = "0",
  "border-radius-sm"     = "0",
  "border-radius-lg"     = "0"
)

# ---- Extra CSS ----------------------------------------------------------------

app_css <- "
:root {
  --eb-accent: #c2415e;
  --eb-accent-2: #f08aa0;
  --eb-accent-light: #ffb0c0;
  --eb-line: 3px solid #111111;
}
h1, h2, h3, h4, h5 { letter-spacing: -0.03em; }
a:focus-visible, button:focus-visible, .btn:focus-visible { outline: 3px solid #2340FF; outline-offset: 3px; }

/* ---------- Title bar: paper with an ink underline, like the other sites ---------- */
.bslib-page-sidebar > .navbar,
.bslib-page-sidebar > .app-title {
  background: #F3EEE3 !important;
  color: #111111 !important;
  box-shadow: none;
  border-bottom: var(--eb-line) !important;
  position: relative;
  z-index: 20;
}
.bslib-page-sidebar > .app-title { padding: 0.7rem 1.25rem; }
.app-title {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.1rem 0.8rem;
  color: #111111;
  font-weight: 800;
  font-size: 1.3rem;
  letter-spacing: -0.02em;
}
.app-title .app-logo { height: 34px; width: auto; margin-right: 0.15rem; }
.app-title .app-subtitle {
  font-family: 'Space Mono', monospace;
  font-weight: 700;
  font-size: 0.78rem;
  letter-spacing: 0.02em;
  color: #5A544A;
}

/* ---------- Let the main area scroll as one page ----------
   By default the tab card squeezes everything into the window height, which
   shrinks the map. As one scrolling page, the map keeps its full height and the
   footer sits at the end. The sidebar stays in place. */
.bslib-sidebar-layout > .main { display: block !important; }
.bslib-sidebar-layout > .main > .card,
.bslib-sidebar-layout > .main > .card > .card-body,
.bslib-sidebar-layout > .main > .card .tab-content,
.bslib-sidebar-layout > .main > .card .tab-pane.active {
  display: block !important;
  height: auto !important;
  max-height: none !important;
  overflow: visible !important;
}
.bslib-sidebar-layout > .main > .card .tab-pane > * + * { margin-top: 1rem; }

/* ---------- Sidebar and panels: white, ink outlines, hard shadows ---------- */
.bslib-sidebar-layout > .sidebar {
  background: #ffffff;
  border-right: var(--eb-line);
}
.card {
  --bs-card-bg: #ffffff;
  background-color: #ffffff;
  border: 2px solid #111111;
  border-radius: 0;
  box-shadow: 4px 4px 0 #111111;
}
.card-header { background: #ffffff; border-bottom: 2px solid #111111; }
.card .accordion-item, .card .accordion-button { background-color: #ffffff !important; border-radius: 0 !important; }
.nav-tabs .nav-link { font-weight: 700; color: #111111; border-radius: 0; }
.nav-tabs .nav-link.active {
  font-weight: 800;
  color: #111111;
  box-shadow: inset 0 -5px 0 var(--eb-accent);
}
.form-control, .form-select, .selectize-input { border: 2px solid #111111 !important; border-radius: 0 !important; box-shadow: none !important; }
.irs--shiny .irs-bar { background: var(--eb-accent); border-color: #111111; }
.irs--shiny .irs-handle { border: 2px solid #111111; }

/* Section headings get a short, thick salmon bar */
.section-title { margin-top: 1.6rem; font-weight: 800; }
.section-title::after {
  content: '';
  display: block;
  width: 56px;
  height: 6px;
  margin-top: 0.45rem;
  background: var(--eb-accent);
}

/* ---------- Hero: framed, like the other sites ---------- */
.hero-full {
  position: relative;
  overflow: hidden;
  background-color: #111111;
  color: #ffffff;
  border: var(--eb-line);
  box-shadow: 8px 8px 0 #111111;
  margin: 0.25rem 0.5rem 0 0;
}
.hero-full::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 1;
  background:
    radial-gradient(circle at 82% 20%, rgba(240, 138, 160, 0.22) 0%, rgba(0, 0, 0, 0) 42%),
    linear-gradient(100deg, rgba(17, 17, 17, 0.96) 0%, rgba(17, 17, 17, 0.84) 45%, rgba(17, 17, 17, 0.35) 100%);
}
.hero-full .hero-bg { position: absolute; inset: 0; z-index: 0; }
.hero-full .hero-bg svg { display: block; width: 100%; height: 100%; }
.hero-full .hero-bg rect {
  stroke: rgba(17, 17, 17, 0.9);
  stroke-width: 2px;
  vector-effect: non-scaling-stroke;
}
.hero-full .hero-inner {
  position: relative;
  z-index: 2;
  padding: 3rem clamp(2rem, 10vw, 9rem) 6rem 2.2rem;
}
.hero-full .eyebrow {
  display: inline-block;
  font-family: 'Space Mono', monospace;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  font-size: 0.75rem;
  font-weight: 700;
  color: #111111;
  background: #F3EEE3;
  border: 2px solid #111111;
  padding: 0.2rem 0.6rem;
}
.hero-full h1 {
  color: #ffffff;
  font-size: clamp(2rem, 3.8vw, 3.3rem);
  font-weight: 800;
  line-height: 1.02;
  letter-spacing: -0.035em;
  margin: 0.8rem 0 1.1rem;
  text-wrap: balance;
}
.hero-full h1 .accent { display: block; color: var(--eb-accent-light); }
.hero-full p { font-size: 1.05rem; line-height: 1.55; max-width: 44rem; opacity: 0.95; }
.hero-full .btn {
  margin: 0.8rem 0.8rem 0 0; border-radius: 0; font-weight: 800; padding: 0.5rem 1.2rem;
  border: var(--eb-line); box-shadow: 4px 4px 0 #F3EEE3;
  transition: transform 0.12s ease, box-shadow 0.12s ease;
}
.hero-full .btn:hover, .hero-full .btn:focus { transform: translate(2px, 2px); box-shadow: 2px 2px 0 #F3EEE3; }
.btn-accent, .btn-accent:hover, .btn-accent:focus { background: var(--eb-accent-light); color: #111111; }
.btn-ghost, .btn-ghost:focus { background: #ffffff; color: #111111; }
.btn-ghost:hover { background: #FFD23F; color: #111111; }
.hero-full .hero-note { font-family: 'Space Mono', monospace; font-size: 0.74rem; line-height: 1.5; opacity: 0.8; margin: 1.6rem 0 0 !important; max-width: 52rem; }
.hero-full .hero-note + .hero-note { margin-top: 0.3rem !important; }

/* Salmon motif: a round paper badge, top right of the hero */
.hero-motif {
  position: absolute; top: 1.4rem; right: 1.4rem; z-index: 3;
  width: clamp(80px, 8vw, 112px); height: auto; aspect-ratio: 1; object-fit: contain;
  background: #F3EEE3; border: var(--eb-line); border-radius: 50%; padding: 14px;
  box-shadow: 5px 5px 0 var(--eb-accent-light); transform: rotate(-6deg);
}

/* ---------- Stat boxes, lifted over the bottom of the hero ---------- */
.stat-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 18px;
  margin: 0 0 1.2rem;
}
.stat-row.lift { position: relative; z-index: 10; margin: -3.4rem 1.6rem 1.4rem !important; }
.stat-box {
  background: #ffffff;
  border: var(--eb-line);
  border-top: 10px solid var(--eb-accent);
  padding: 1rem 1.1rem;
  box-shadow: 6px 6px 0 #111111;
}
.stat-box:nth-child(2) { border-top-color: #FF5A36; }   /* the declining count */
.stat-box:nth-child(3) { border-top-color: var(--eb-accent-2); }
.stat-box .num {
  display: block;
  font-size: 2.1rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: #111111;
  line-height: 1.05;
  white-space: nowrap;
}
.stat-box .lab { display: block; font-size: 0.88rem; color: #3a352d; margin-top: 0.35rem; line-height: 1.4; }

/* ---------- Map, plots, and tables ---------- */
.leaflet-container { border: 2px solid #111111; border-radius: 0; }
.leaflet-control-layers, .leaflet-bar, .info.legend { border: 2px solid #111111 !important; border-radius: 0 !important; box-shadow: 3px 3px 0 #111111 !important; }
.radio-inline, .form-check-inline { margin-right: 1.5rem; }
.shiny-table { font-size: 0.88rem; }
.shiny-table thead th { background: #F3EEE3; border-bottom: 2px solid #111111; }
.js-plotly-plot .plotly text { font-family: 'Bricolage Grotesque', sans-serif !important; }

/* ---------- Shared footer (same as the other sites) ---------- */
.eb-footer {
  background: #111111; color: #F3EEE3;
  border-top: var(--eb-line);
  margin: 1.5rem calc(-1 * var(--bslib-sidebar-padding, 1.5rem)) calc(-1 * var(--bslib-sidebar-padding, 1.5rem));
  padding: 2.2rem 1.4rem 2.4rem;
  font-size: 0.9rem; line-height: 1.6;
}
.eb-footer.eb-footer-page { margin: 0; }
.eb-footer-inner { max-width: 1100px; margin: 0 auto; }
.eb-footer a { color: #F3EEE3; text-decoration: underline; text-decoration-color: rgba(243, 238, 227, 0.35); text-underline-offset: 0.2em; }
.eb-footer a:hover, .eb-footer a:focus { color: #FFD23F; text-decoration-color: #FFD23F; }
.eb-footer-name { font-weight: 800; font-size: 1.35rem; letter-spacing: -0.02em; color: #ffffff; }
.eb-footer-tag { margin-bottom: 1.1rem; }
.eb-footer-heading { font-family: 'Space Mono', monospace; font-size: 0.75rem; font-weight: 700; letter-spacing: 0.08em;
                     text-transform: uppercase; color: #FFD23F; margin-bottom: 0.4rem; }
.eb-footer-projects { display: flex; flex-wrap: wrap; gap: 0.25rem 1.3rem; margin-bottom: 1.2rem; }
.eb-footer-contact { display: flex; flex-wrap: wrap; gap: 0.2rem 1.3rem;
                     border-top: 1px solid rgba(243, 238, 227, 0.2); padding-top: 0.9rem; }

/* ---------- Phones ---------- */
@media (max-width: 575.98px) {
  /* The page flows top to bottom (main area, then filters, then footer) */
  html, body.bslib-page-sidebar,
  .bslib-page-main,
  .bslib-page-main > .bslib-sidebar-layout,
  .bslib-sidebar-layout > .main,
  .bslib-sidebar-layout > .sidebar {
    display: block !important;
    height: auto !important;
    min-height: 0 !important;
    max-height: none !important;
    overflow: visible !important;
  }
  .eb-footer.eb-footer-page { position: relative; z-index: 30; }
  .bslib-sidebar-layout > .sidebar { border-right: none; border-top: var(--eb-line); }
}
@media (max-width: 900px) {
  .stat-row, .stat-row.lift { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .stat-box .num { font-size: 1.5rem; }
  .stat-box { padding: 0.85rem 0.9rem; }
}
@media (max-width: 700px) {
  .app-title { font-size: 1.1rem; }
  .app-title .app-subtitle { font-size: 0.72rem; }
  .app-title .app-logo { height: 28px; }
  .hero-full { margin-right: 0.3rem; box-shadow: 5px 5px 0 #111111; }
  .hero-full::before {
    background: linear-gradient(180deg, rgba(17, 17, 17, 0.92) 0%, rgba(17, 17, 17, 0.82) 100%);
  }
  .hero-full .hero-inner { padding: 5.5rem 1.2rem 5rem; }
  .hero-motif { width: 64px; padding: 9px; top: 1rem; right: 1rem; box-shadow: 3px 3px 0 var(--eb-accent-light); }
  .hero-full p { font-size: 0.98rem; }
  .stat-row.lift { margin: -2.4rem 0.6rem 1rem !important; gap: 12px; }
  .stat-row.lift .stat-box:last-child { grid-column: 1 / -1; }
  .eb-footer { padding: 1.4rem 1.1rem 1.6rem; font-size: 0.82rem; line-height: 1.4; }
  .eb-footer-name { font-size: 1.15rem; }
  .eb-footer-tag { margin-bottom: 0.9rem; }
  .eb-footer-projects { display: grid; grid-template-columns: 1fr 1fr; gap: 0.55rem 1rem; }
  .eb-footer-contact { gap: 0.4rem 1.1rem; }
}
@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; animation: none !important; }
  .hero-full .btn:hover { transform: none; }
}
"

# ---- Shared footer ------------------------------------------------------------
# Same links as footer.html in the brand kit.

app_footer <- function() {
  a <- shiny::tags$a
  shiny::tags$footer(
    class = "eb-footer", role = "contentinfo",
    shiny::div(
      class = "eb-footer-inner",
      shiny::div(class = "eb-footer-name", "Emma Branch"),
      shiny::div(class = "eb-footer-tag", "Epidemiologist and data analyst, British Columbia"),
      shiny::div(class = "eb-footer-heading", "Portfolio projects"),
      shiny::tags$nav(
        class = "eb-footer-projects", `aria-label` = "Portfolio projects",
        a(href = "https://emmabranch.github.io/redcap-starter-kit/", "REDCap starter kit"),
        a(href = "https://emmabranch.github.io/bc-housing-indicators/", "BC housing indicators"),
        a(href = "https://emmabranch.github.io/bc-fish-stock-status/", "BC fish stock status"),
        a(href = "https://emmabranch.github.io/bc-lightstation-qc/", "BC lightstation sea temperatures"),
        a(href = "https://emmabranch.github.io/bc-wildfire-bigquery/", "BC wildfire history"),
        a(href = "https://emmabranch.github.io/vch-climate-equity-profile/", "VCH climate equity profile"),
        a(href = "https://emmabranch.shinyapps.io/bc-salmon-explorer", "BC Salmon Explorer"),
        a(href = "https://emmabranch.github.io/ontario-claims-caribou/", "Ontario mining claims and caribou"),
        a(href = "https://emmabranch.github.io/salish-sea-whales/", "Salish Sea whales"),
        a(href = "https://emmabranch.github.io/bike-recall-surveillance/", "Bike recall surveillance"),
        a(href = "https://emmabranch.github.io/gravel-geometry/", "Gravel geometry explorer"),
        a(href = "https://emmabranch.github.io/scotland-seas-indicators/", "State of Scotland's Seas")
      ),
      shiny::div(
        class = "eb-footer-contact",
        a(href = "https://github.com/emmabranch", "GitHub"),
        a(href = "https://www.linkedin.com/in/embranch/", "LinkedIn"),
        a(href = "mailto:emma.branch@gmail.com", "emma.branch@gmail.com")
      )
    )
  )
}

# ---- Browser tab icon, CSS, and footer ------------------------------------------
# app.R places app_head() at the top of the main area. The footer starts there
# too, and a small script moves it to the end of the main area.

app_head <- function() {
  shiny::tagList(
    shiny::tags$head(
      shiny::tags$link(
        rel  = "icon",
        type = "image/png",
        href = "favicon.png"
      ),
      shiny::tags$style(shiny::HTML(app_css))
    ),
    app_footer(),
    shiny::tags$script(shiny::HTML("
      document.addEventListener('DOMContentLoaded', function () {
        var foot = document.querySelector('.eb-footer');
        var main = foot && foot.closest('.main');
        if (!main) return;
        var layout = main.closest('.bslib-sidebar-layout');
        var phone = window.matchMedia('(max-width: 575.98px)');
        /* On computers: at the end of the main area. On phones the filters
           drop below the main area, so the footer goes after them instead. */
        function place() {
          if (phone.matches && layout) {
            layout.parentNode.insertBefore(foot, layout.nextSibling);
            foot.classList.add('eb-footer-page');
          } else {
            main.appendChild(foot);
            foot.classList.remove('eb-footer-page');
          }
        }
        place();
        phone.addEventListener('change', place);
      });
    "))
  )
}

# ---- Hero ---------------------------------------------------------------------------
# Built from the app's own data: the background stripes show how many streams had
# a spawner estimate each year since 1950 (brighter means more streams surveyed),
# so the decline in monitoring is visible at a glance.

hero_banner <- function(streams, counts, cu_trends, trend_settings) {

  per_year <- counts |>
    dplyr::filter(year >= 1950) |>
    dplyr::count(year, name = "n_streams") |>
    dplyr::arrange(year)

  peak   <- per_year[which.max(per_year$n_streams), ]
  latest <- per_year[which.max(per_year$year), ]

  # Near black for few streams, through salmon, to light pink for the most
  stripe_col <- scales::col_numeric(c("#241a1d", "#7a3a5a", "#c2415e", "#f08aa0"),
                                    domain = range(per_year$n_streams))
  rects <- paste0(
    sprintf('<rect x="%d" y="0" width="1" height="1" fill="%s"/>',
            seq_len(nrow(per_year)) - 1, stripe_col(per_year$n_streams)),
    collapse = ""
  )
  stripes_svg <- sprintf(
    '<svg viewBox="0 0 %d 1" preserveAspectRatio="none" aria-hidden="true">%s</svg>',
    nrow(per_year), rects
  )


  n_streams   <- format(nrow(streams), big.mark = ",")
  n_cus       <- nrow(cu_trends)
  n_declining <- sum(cu_trends$trend_class == "Declining")
  window      <- paste(trend_settings$trend_start, "to", trend_settings$trend_end)

  shiny::tagList(
    shiny::div(
      class = "hero-full",
      shiny::div(class = "hero-bg", shiny::HTML(stripes_svg)),
      shiny::tags$img(class = "hero-motif", src = "motif.svg", alt = ""),
      shiny::div(
        class = "hero-inner",
        shiny::span(class = "eyebrow", "Portfolio project · R · Shiny · leaflet"),
        shiny::h1(paste(n_streams, "spawning streams."),
                  shiny::span(class = "accent", "One map of how BC's salmon are doing.")),
        shiny::p(paste0(
          "Explore Pacific Salmon Foundation and DFO spawner survey data by species, region, ",
          "and Conservation Unit. Of the ", n_cus, " Conservation Units with an estimated trend, ",
          n_declining, " show a statistically clear decline from ", window, "."
        )),
        shiny::actionLink("go_trends",  "Explore the trends", class = "btn btn-accent"),
        shiny::actionLink("go_methods", "How it was built",   class = "btn btn-ghost"),
        shiny::a("Code on GitHub", class = "btn btn-ghost", target = "_blank",
                 href = "https://github.com/emmabranch/bc-salmon-explorer"),
        shiny::p(class = "hero-note",
                 paste("Background: one stripe per year since 1950, brighter when more streams",
                       "were surveyed.")),
        shiny::p(class = "hero-note",
                 paste("An independent portfolio project. Not produced or endorsed by the Pacific Salmon",
                       "Foundation or Fisheries and Oceans Canada."))
      )
    ),

    # At a glance, lifted over the bottom of the hero
    shiny::div(
      class = "stat-row lift",
      shiny::div(class = "stat-box",
                 shiny::span(class = "num", n_streams),
                 shiny::span(class = "lab", "streams with spawner estimates")),
      shiny::div(class = "stat-box",
                 shiny::span(class = "num", paste(n_declining, "of", n_cus)),
                 shiny::span(class = "lab", paste("Conservation Units declining,", window))),
      shiny::div(class = "stat-box",
                 shiny::span(class = "num", format(latest$n_streams, big.mark = ",")),
                 shiny::span(class = "lab",
                             paste0("streams surveyed in ", latest$year, ", down from ",
                                    format(peak$n_streams, big.mark = ","), " in ", peak$year)))
    )
  )
}
