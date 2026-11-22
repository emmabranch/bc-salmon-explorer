# R/app_theme.R
# Look and feel for the app, matching Emma Branch's other portfolio sites
# (shared brand kit: /Users/ecox/projects/_brand-kit). Fraunces headings, Inter
# text, a warm off-white page, a navy title bar, a full-width wavy hero with
# stripes made from the app's own data, and the shared navy footer.
# Project colour: salmon.
# Everything is in this one file so the deploy script picks it up (it deploys
# app.R, renv.lock, and R/). Shiny loads this file automatically because it is in R/.

# ---- Colours ----------------------------------------------------------------

# Shared palette (same as the brand kit's _brand.yml)
pal_navy   <- "#0b2233"
pal_ocean  <- "#1f4e79"
pal_blue   <- "#1f6fb2"
pal_slate  <- "#5b7083"
pal_ink    <- "#1f2a33"
pal_paper  <- "#f6f4ef"

# Project colours: salmon
salmon_accent       <- "#c2415e"   # underlines, borders, active tab
salmon_accent_2     <- "#f08aa0"   # second colour in the underline gradient
salmon_accent_light <- "#ffb0c0"   # hero accent words and solid buttons on navy

# ---- bslib theme --------------------------------------------------------------

app_theme <- bslib::bs_theme(
  version   = 5,
  bg        = pal_paper,
  fg        = pal_ink,
  primary   = pal_ocean,
  secondary = pal_slate,
  base_font = bslib::font_link(
    "Inter",
    href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
  ),
  heading_font = bslib::font_link(
    "Fraunces",
    href = "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,600;9..144,700;9..144,800&display=swap"
  ),
  "headings-font-weight" = 700,
  "headings-color"       = pal_navy,
  "link-color"           = pal_blue,
  "border-radius"        = "10px"
)

# ---- Extra CSS ----------------------------------------------------------------

app_css <- "
:root {
  --eb-accent: #c2415e;
  --eb-accent-2: #f08aa0;
  --eb-accent-light: #ffb0c0;
  --eb-hero-glow: rgba(240, 138, 160, 0.28);
  --eb-hero-shade: 8, 26, 40;
}

/* ---------- Title bar: navy, like the other project sites ---------- */
.bslib-page-sidebar > .navbar,
.bslib-page-sidebar > .app-title {
  background: #0b2233 !important;
  color: #ffffff !important;
  box-shadow: 0 2px 14px rgba(0, 0, 0, 0.18);
  border-bottom: none !important;
  position: relative;
  z-index: 20;
}
.bslib-page-sidebar > .app-title { padding: 0.75rem 1.25rem; }
.app-title {
  display: flex;
  align-items: baseline;
  flex-wrap: wrap;
  gap: 0.1rem 0.8rem;
  color: #ffffff;
  font-family: 'Fraunces', Georgia, serif;
  font-weight: 800;
  font-size: 1.3rem;
  letter-spacing: -0.01em;
}
.app-title .app-subtitle {
  font-family: 'Inter', sans-serif;
  font-weight: 500;
  font-size: 0.85rem;
  color: #c9d6e0;
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

/* ---------- Sidebar and panels: white with soft shadows ---------- */
.bslib-sidebar-layout > .sidebar {
  background: #ffffff;
  border-right: 1px solid #e8e4dc;
}
.card {
  --bs-card-bg: #ffffff;
  background-color: #ffffff;
  border: none;
  border-radius: 14px;
  box-shadow: 0 4px 18px rgba(15, 42, 63, 0.08);
}
.card-header { background: #ffffff; }
.card .accordion-item, .card .accordion-button { background-color: #ffffff !important; }
.nav-tabs .nav-link { font-weight: 500; }
.nav-tabs .nav-link.active {
  font-weight: 600;
  color: #0b2233;
  box-shadow: inset 0 -3px 0 var(--eb-accent);
}

/* Section headings get a short salmon underline */
.section-title { margin-top: 1.6rem; }
.section-title::after {
  content: '';
  display: block;
  width: 44px;
  height: 4px;
  border-radius: 2px;
  margin-top: 0.45rem;
  background: linear-gradient(90deg, var(--eb-accent), var(--eb-accent-2));
}

/* ---------- Wavy hero (same design as the other sites) ---------- */
.hero-full {
  position: relative;
  overflow: hidden;
  background-color: #0b2233;
  color: #ffffff;
  /* run to the edges of the Map card, just under the tabs */
  margin: calc(-1 * var(--bs-card-spacer-y, 1rem)) calc(-1 * var(--bs-card-spacer-x, 1rem)) 0;
}
.hero-full::before {
  content: '';
  position: absolute;
  inset: 0;
  z-index: 1;
  background:
    radial-gradient(circle at 82% 20%, var(--eb-hero-glow) 0%, rgba(0, 0, 0, 0) 42%),
    linear-gradient(100deg, rgba(var(--eb-hero-shade), 0.97) 0%, rgba(var(--eb-hero-shade), 0.86) 45%, rgba(var(--eb-hero-shade), 0.42) 100%);
}
.hero-full .hero-bg { position: absolute; inset: 0; z-index: 0; }
.hero-full .hero-bg svg { display: block; width: 100%; height: 100%; }
.hero-full .hero-bg rect {
  stroke: rgba(8, 26, 40, 0.9);
  stroke-width: 2px;
  vector-effect: non-scaling-stroke;
}
.hero-full .hero-inner {
  position: relative;
  z-index: 2;
  padding: 3rem 2.2rem 8rem;
}
.hero-full .eyebrow {
  display: block;
  text-transform: uppercase;
  letter-spacing: 0.16em;
  font-size: 0.78rem;
  font-weight: 600;
  opacity: 0.85;
}
.hero-full h1 {
  color: #ffffff;
  font-size: clamp(1.9rem, 3.6vw, 3.1rem);
  font-weight: 800;
  line-height: 1.06;
  letter-spacing: -0.015em;
  margin: 0.6rem 0 1.1rem;
  text-wrap: balance;
}
.hero-full h1 .accent { display: block; color: var(--eb-accent-light); }
.hero-full p { font-size: 1.05rem; line-height: 1.6; max-width: 44rem; opacity: 0.94; }
.hero-full .btn { margin: 0.8rem 0.6rem 0 0; border-radius: 999px; font-weight: 600; padding: 0.55rem 1.25rem; }
.btn-accent { background: var(--eb-accent-light); color: #0b2233; border: none; }
.btn-accent:hover, .btn-accent:focus { background: var(--eb-accent-light); color: #0b2233; filter: brightness(1.08); }
.btn-ghost { background: rgba(255, 255, 255, 0.08); color: #ffffff; border: 1px solid rgba(255, 255, 255, 0.5); }
.btn-ghost:hover, .btn-ghost:focus { background: rgba(255, 255, 255, 0.18); color: #ffffff; }
.hero-full .hero-note { font-size: 0.78rem; line-height: 1.5; opacity: 0.72; margin: 1.8rem 0 0 !important; max-width: 52rem; }
.hero-full .hero-note + .hero-note { margin-top: 0.3rem !important; }
.hero-wave {
  position: absolute;
  left: 0;
  right: 0;
  bottom: -1px;
  width: 100%;
  height: 96px;
  z-index: 3;
}
.hero-wave path { fill: #ffffff; }  /* matches the white card */

/* ---------- Stat boxes, lifted over the bottom of the hero ---------- */
.stat-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
  gap: 14px;
  margin: 0 0 1.2rem;
}
/* Lifted only a little, so the top of the wave stays visible above the boxes */
.stat-row.lift { position: relative; z-index: 10; margin: -3.6rem 1.2rem 1.2rem !important; }
.stat-box {
  background: rgba(255, 255, 255, 0.97);
  border-radius: 14px;
  padding: 1rem 1.1rem;
  border-top: 4px solid var(--eb-accent);
  box-shadow: 0 1px 3px rgba(16, 42, 67, 0.08), 0 8px 20px rgba(16, 42, 67, 0.06);
}
.stat-box .num {
  display: block;
  font-family: 'Fraunces', Georgia, serif;
  font-size: 2rem;
  font-weight: 800;
  color: #0b2233;
  line-height: 1.05;
}
.stat-box .lab { display: block; font-size: 0.86rem; color: #5b6770; margin-top: 0.3rem; line-height: 1.4; }

/* ---------- Map, plots, and tables ---------- */
.leaflet-container { border-radius: 12px; }
.radio-inline, .form-check-inline { margin-right: 1.5rem; }
.shiny-table { font-size: 0.88rem; }
.shiny-table thead th { background: #f1f4f7; }

/* ---------- Shared footer (same as the other sites) ---------- */
.eb-footer {
  background: #0b2233; color: #c9d6e0;
  margin: 1.5rem calc(-1 * var(--bslib-sidebar-padding, 1.5rem)) calc(-1 * var(--bslib-sidebar-padding, 1.5rem));
  padding: 2rem 1.4rem 2.2rem;
  font-size: 0.88rem; line-height: 1.6;
}
.eb-footer.eb-footer-page { margin: 0; }
.eb-footer-inner { max-width: 1100px; margin: 0 auto; }
.eb-footer a { color: #9fe3d8; text-decoration: none; }
.eb-footer a:hover, .eb-footer a:focus { color: #ffffff; text-decoration: underline; }
.eb-footer-name { font-family: 'Fraunces', Georgia, serif; font-weight: 800; font-size: 1.15rem; color: #ffffff; }
.eb-footer-tag { margin-bottom: 1rem; }
.eb-footer-heading { font-size: 0.72rem; font-weight: 700; letter-spacing: 0.12em; text-transform: uppercase;
                     color: #9fe3d8; margin-bottom: 0.35rem; }
.eb-footer-projects { display: flex; flex-wrap: wrap; gap: 0.2rem 1.3rem; margin-bottom: 1.1rem; }
.eb-footer-contact { display: flex; flex-wrap: wrap; gap: 0.2rem 1.3rem;
                     border-top: 1px solid rgba(255, 255, 255, 0.14); padding-top: 0.9rem; }

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
}
@media (max-width: 900px) {
  .stat-row, .stat-row.lift { grid-template-columns: repeat(2, minmax(0, 1fr)); }
  .stat-box .num { font-size: 1.5rem; }
  .stat-box { padding: 0.85rem 0.9rem; }
}
@media (max-width: 700px) {
  .app-title { font-size: 1.1rem; }
  .app-title .app-subtitle { font-size: 0.78rem; }
  .hero-full::before {
    background: linear-gradient(180deg, rgba(var(--eb-hero-shade), 0.9) 0%, rgba(var(--eb-hero-shade), 0.8) 100%);
  }
  .hero-full .hero-inner { padding: 2rem 1.2rem 6rem; }
  .hero-wave { height: 60px; }
  .hero-full p { font-size: 0.98rem; }
  .stat-row.lift { margin: -2.4rem 0.6rem 1rem !important; gap: 10px; }
  .stat-row.lift .stat-box:last-child { grid-column: 1 / -1; }
  .eb-footer { padding: 1.4rem 1.1rem 1.6rem; font-size: 0.8rem; line-height: 1.4; }
  .eb-footer-name { font-size: 1.05rem; }
  .eb-footer-tag { margin-bottom: 0.9rem; }
  .eb-footer-projects { display: grid; grid-template-columns: 1fr 1fr; gap: 0.55rem 1rem; }
  .eb-footer-contact { gap: 0.4rem 1.1rem; }
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
        a(href = "https://emmabranch.github.io/bike-recall-surveillance/", "Bike recall surveillance")
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
        href = "data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🐟</text></svg>"
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

  # Dark slate for few streams, through salmon, to light pink for the most
  stripe_col <- scales::col_numeric(c("#22324a", "#7a3a5a", "#c2415e", "#f08aa0"),
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

  wave_svg <- paste0(
    '<svg class="hero-wave" viewBox="0 0 1440 80" preserveAspectRatio="none" aria-hidden="true">',
    '<path d="M0,40 C240,80 480,0 720,30 C960,60 1200,10 1440,40 L1440,80 L0,80 Z"></path></svg>'
  )

  n_streams   <- format(nrow(streams), big.mark = ",")
  n_cus       <- nrow(cu_trends)
  n_declining <- sum(cu_trends$trend_class == "Declining")
  window      <- paste(trend_settings$trend_start, "to", trend_settings$trend_end)

  shiny::tagList(
    shiny::div(
      class = "hero-full",
      shiny::div(class = "hero-bg", shiny::HTML(stripes_svg)),
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
      ),
      shiny::HTML(wave_svg)
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
