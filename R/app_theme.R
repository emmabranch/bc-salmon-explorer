# R/app_theme.R
# Look and feel for the app, matching the style of the bc-fish-stock-status and
# bc-housing-indicators sites: Fraunces headings, Inter text, a warm off-white
# page, a deep navy title bar, white panels with soft shadows, and a banner with
# a stripe ribbon made from the app's own data.
# Shiny loads this file automatically because it is in R/.

# ---- Colours ----------------------------------------------------------------

pal_navy   <- "#0b2233"
pal_blue   <- "#1f4e79"
pal_teal   <- "#16a085"
pal_page   <- "#fbfaf7"
pal_ink    <- "#1f2a33"

# ---- bslib theme --------------------------------------------------------------

app_theme <- bslib::bs_theme(
  version   = 5,
  bg        = pal_page,
  fg        = pal_ink,
  primary   = pal_blue,
  secondary = "#5b7083",
  base_font = bslib::font_link(
    "Inter",
    href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;800&display=swap"
  ),
  heading_font = bslib::font_link(
    "Fraunces",
    href = "https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,600;9..144,800&display=swap"
  ),
  "headings-font-weight" = 700,
  "link-color"           = "#1f6fb2",
  "border-radius"        = "10px"
)

# ---- Extra CSS ----------------------------------------------------------------

app_css <- "
/* Title bar: deep navy, like the other project sites.
   Newer bslib wraps the title in a .navbar; older versions place it directly
   in the page, so both are styled. */
.bslib-page-sidebar > .navbar,
.bslib-page-sidebar > .app-title {
  background: #0b2233 !important;
  color: #ffffff !important;
  box-shadow: 0 2px 14px rgba(0, 0, 0, 0.18);
  border-bottom: none !important;
}
.bslib-page-sidebar > .app-title { padding: 0.75rem 1.25rem; }
.app-title {
  display: flex;
  align-items: baseline;
  gap: 0.8rem;
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

/* Sidebar and main panels: white with soft shadows */
.bslib-sidebar-layout > .sidebar {
  background: #ffffff;
  border-right: 1px solid #e8e4dc;
}
.card {
  border: none;
  border-radius: 14px;
  box-shadow: 0 4px 18px rgba(15, 42, 63, 0.08);
}
.card-header { background: #ffffff; }
.nav-underline .nav-link.active, .nav-tabs .nav-link.active { font-weight: 600; }

/* Section headings get a short teal-blue accent bar */
.section-title { margin-top: 1.6rem; }
.section-title::after {
  content: '';
  display: block;
  width: 52px;
  height: 4px;
  border-radius: 2px;
  margin-top: 0.45rem;
  background: linear-gradient(90deg, #2471a3, #16a085);
}

/* Banner */
.hero {
  position: relative;
  overflow: hidden;
  background:
    radial-gradient(circle at 88% 12%, rgba(22, 160, 133, 0.35) 0%, rgba(22, 160, 133, 0) 45%),
    linear-gradient(135deg, #0b2233 0%, #1f4e79 55%, #2471a3 100%);
  color: #ffffff;
  border-radius: 14px;
  padding: 1.3rem 1.6rem 1rem;
  margin-bottom: 1rem;
}
.hero-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.7fr) minmax(0, 1fr);
  gap: 1.5rem;
  align-items: center;
}
@media (max-width: 900px) { .hero-grid { grid-template-columns: 1fr; } }
.hero .eyebrow {
  text-transform: uppercase;
  letter-spacing: 0.12em;
  font-size: 0.75rem;
  font-weight: 600;
  color: #9fd8cb;
  margin-bottom: 0.4rem;
}
.hero h2 {
  color: #ffffff;
  font-weight: 800;
  font-size: 1.75rem;
  line-height: 1.15;
  margin: 0 0 0.6rem;
}
.hero h2 .accent { display: block; color: #7fd6c2; }
.hero p { opacity: 0.92; max-width: 40rem; line-height: 1.55; margin: 0 0 0.9rem; }
.hero .pill {
  display: inline-block;
  padding: 0.35rem 0.9rem;
  margin: 0 0.4rem 0.4rem 0;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
  border: 1px solid rgba(255, 255, 255, 0.35);
  color: #ffffff;
  font-size: 0.85rem;
  font-weight: 600;
  text-decoration: none;
}
.hero .pill:hover { background: rgba(255, 255, 255, 0.26); color: #ffffff; }

/* 'At a glance' panel inside the banner */
.glance {
  background: rgba(255, 255, 255, 0.10);
  border: 1px solid rgba(255, 255, 255, 0.22);
  border-radius: 12px;
  padding: 0.9rem 1.1rem;
  backdrop-filter: blur(4px);
}
.glance .stat { padding: 0.35rem 0; }
.glance .stat + .stat { border-top: 1px solid rgba(255, 255, 255, 0.18); }
.glance .num {
  font-family: 'Fraunces', Georgia, serif;
  font-size: 1.45rem;
  font-weight: 800;
  line-height: 1.1;
}
.glance .lab { font-size: 0.8rem; color: #d6e2ec; }

/* Stripe ribbon: one stripe per year */
.stripes {
  display: flex;
  height: 26px;
  border-radius: 6px;
  overflow: hidden;
  margin-top: 0.9rem;
}
.stripes div { flex: 1; }
.stripes-caption { font-size: 0.78rem; color: #d6e2ec; margin-top: 0.35rem; }
.hero .disclaimer { font-size: 0.75rem; color: #b8c7d3; margin-top: 0.6rem; }

/* Map, plots, and tables */
.leaflet-container { border-radius: 12px; }
.radio-inline, .form-check-inline { margin-right: 1.5rem; }
.shiny-table { font-size: 0.88rem; }
.shiny-table thead th { background: #f1f4f7; }
"

# ---- Browser tab icon -----------------------------------------------------------

app_head <- function() {
  shiny::tags$head(
    shiny::tags$link(
      rel  = "icon",
      href = "data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🐟</text></svg>"
    ),
    shiny::tags$style(shiny::HTML(app_css))
  )
}

# ---- Banner -----------------------------------------------------------------------
# Built from the app's own data: the stripe ribbon shows how many streams had a
# spawner estimate each year since 1950, so the decline in monitoring is visible
# at a glance.

hero_banner <- function(streams, counts, cu_trends, trend_settings) {

  per_year <- counts |>
    dplyr::filter(year >= 1950) |>
    dplyr::count(year, name = "n_streams")

  peak   <- per_year[which.max(per_year$n_streams), ]
  latest <- per_year[which.max(per_year$year), ]

  stripe_col <- scales::col_numeric(c("#e8f1f8", "#7fb3d5", "#2471a3", "#0b2233"),
                                    domain = range(per_year$n_streams))

  stripes <- lapply(seq_len(nrow(per_year)), function(i) {
    shiny::div(
      style = paste0("background:", stripe_col(per_year$n_streams[i]), ";"),
      title = paste0(per_year$year[i], ": ",
                     format(per_year$n_streams[i], big.mark = ","), " streams surveyed")
    )
  })

  n_streams  <- format(nrow(streams), big.mark = ",")
  n_cus      <- nrow(cu_trends)
  n_declining <- sum(cu_trends$trend_class == "Declining")
  window     <- paste(trend_settings$trend_start, "to", trend_settings$trend_end)

  shiny::div(
    class = "hero",
    shiny::div(
      class = "hero-grid",

      # Left: headline, summary, and buttons
      shiny::div(
        shiny::div(class = "eyebrow", "BC salmon spawner surveys"),
        shiny::h2(paste(n_streams, "spawning streams."),
                  shiny::span(class = "accent", "One map of how BC's salmon are doing.")),
        shiny::p(paste0(
          "Explore Pacific Salmon Foundation and DFO spawner survey data by species, region, ",
          "and Conservation Unit. Of the ", n_cus, " Conservation Units with an estimated trend, ",
          n_declining, " show a statistically clear decline from ", window, "."
        )),
        shiny::actionLink("go_trends",  "Explore the trends", class = "pill"),
        shiny::actionLink("go_methods", "How it was built",   class = "pill"),
        shiny::a("Code on GitHub", class = "pill", target = "_blank",
                 href = "https://github.com/emmabranch/bc-salmon-explorer")
      ),

      # Right: at a glance
      shiny::div(
        class = "glance",
        shiny::div(class = "stat",
                   shiny::div(class = "num", n_streams),
                   shiny::div(class = "lab", "streams with spawner estimates")),
        shiny::div(class = "stat",
                   shiny::div(class = "num", paste(n_declining, "of", n_cus)),
                   shiny::div(class = "lab", paste("Conservation Units declining,", window))),
        shiny::div(class = "stat",
                   shiny::div(class = "num", format(latest$n_streams, big.mark = ",")),
                   shiny::div(class = "lab",
                              paste0("streams surveyed in ", latest$year, ", down from ",
                                     format(peak$n_streams, big.mark = ","), " in ", peak$year)))
      )
    ),

    shiny::div(class = "stripes", stripes),
    shiny::div(class = "stripes-caption",
               paste("Each stripe is one year since 1950. Darker means more streams were surveyed.",
                     "Hover to see the number.")),
    shiny::div(class = "disclaimer",
               paste("An independent portfolio project. Not produced or endorsed by the Pacific Salmon",
                     "Foundation or Fisheries and Oceans Canada."))
  )
}
