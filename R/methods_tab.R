# R/methods_tab.R
# Content for the "Methods and data quality" tab.
# Shiny loads this file automatically because it is in R/.

methods_tab_ui <- function(n_streams, n_cus, n_obs, year_min, year_max, trend_settings) {

  ts <- trend_settings

  bslib::layout_columns(
    col_widths = c(7, 5),

    # ---- Left: text ----
    bslib::accordion(
      open = "About the data",

      bslib::accordion_panel(
        "About the data",
        p("This app uses the Pacific Salmon Foundation's ",
          a("Cleaned spawner survey data (v4)",
            href = "https://doi.org/10.5281/zenodo.19959144", target = "_blank"),
          " (Carturan & Peacock, 2026). PSF built this dataset from Fisheries and Oceans Canada's ",
          "New Salmon Escapement Database System (NuSEDS), cleaned the records, and matched each ",
          "survey site to a Conservation Unit (CU) as defined in the Pacific Salmon Explorer."),
        p(sprintf("After preparation for this app, the data cover %s streams in %s CUs, with %s annual estimates from %d to %d.",
                  format(n_streams, big.mark = ","), format(n_cus, big.mark = ","),
                  format(n_obs, big.mark = ","), year_min, year_max)),
        tags$ul(
          tags$li(strong("Stream: "), "a unique combination of CU and survey site (PSF's ", code("streamid"),
                  "). The same river can appear more than once if it supports several species or CUs."),
          tags$li(strong("Conservation Unit: "), "a group of wild salmon that is distinct enough that, if lost, ",
                  "it would be unlikely to recolonize naturally within an acceptable timeframe. CUs are the ",
                  "unit of assessment under Canada's Wild Salmon Policy."),
          tags$li(strong("Map location: "), "the mouth of the waterbody if it flows, or its centre if not.")
        )
      ),

      bslib::accordion_panel(
        "What the counts measure",
        p("Abundance is PSF's ", code("MAX_ESTIMATE"), " field: for each stream and year, the largest ",
          "available value among the NuSEDS fields for natural adult spawners, natural jack spawners, total ",
          "natural spawners, broodstock removals, other removals, and total return to river."),
        p("This makes it the most complete single measure in the dataset, but it is ", em("not strictly a spawner count"),
          ". In some streams and years it reflects the total return to the river, which includes fish removed ",
          "for hatchery broodstock or other purposes. It is labelled \"spawner estimate\" in the app for simplicity.")
      ),

      bslib::accordion_panel(
        "Data preparation",
        tags$ol(
          tags$li("Read the 21 columns needed from the PSF file (about 315,000 rows)."),
          tags$li("Removed rows not matched to a current CU (about 2,100 rows, mostly early Fraser sockeye series)."),
          tags$li("Removed stream-years with no estimate. PSF keeps these in the file so gaps in monitoring are ",
                  "visible, but they carry no count. The coverage chart on this page shows how the number of streams ",
                  "with estimates has changed over time."),
          tags$li("Kept observed zeros, which are real counts in this version of the data."),
          tags$li("Checked that each stream has exactly one estimate per year and a single CU and location.")
        ),
        p("The code is in ", code("scripts/01_clean.R"), " in the GitHub repository.")
      ),

      bslib::accordion_panel(
        "Trend model",
        p(sprintf("Trends are estimated separately for each CU over %d to %d, using streams with at least %d years of estimates in that window.",
                  ts$trend_start, ts$trend_end, ts$min_years),
          " The window starts in 1995, when DFO moved salmon enumeration to its Science section and began ",
          "recording how each estimate was made, and covers roughly six to seven salmon generations."),
        tags$ul(
          tags$li(strong("CUs with 3 or more streams: "), "a linear mixed-effects model (lme4), ",
                  code("log(spawners + 1) ~ year + (1 + year | stream)"),
                  ". Each stream has its own baseline and slope, and the fixed year effect is the CU-level trend. ",
                  "If that model is singular, a random-intercept-only model is used."),
          tags$li(strong("CUs with 1 or 2 streams: "), "ordinary linear regression, with a separate intercept for each stream.")
        ),
        p("The slope is converted to an average percent change per year, 100 * (exp(slope) - 1), with a 95% Wald ",
          "confidence interval. CUs are labelled ", em("Declining"), " if the whole interval is below zero, ",
          em("Increasing"), " if it is above zero, and ", em("No clear trend"), " otherwise."),
        p("The code is in ", code("R/fit_trend.R"), " and ", code("scripts/02_trends.R"), ".")
      ),

      bslib::accordion_panel(
        "Limitations",
        tags$ul(
          tags$li(strong("Not a status assessment. "), "A trend label describes the direction of change in survey ",
                  "estimates. It is not a biological status assessment, which compares abundance with benchmarks ",
                  "(as in the Pacific Salmon Explorer or COSEWIC assessments)."),
          tags$li(strong("Confidence intervals are probably too narrow. "), "The models assume independent errors, ",
                  "but abundance in neighbouring years is correlated. Adding an autoregressive error term (for ",
                  "example with glmmTMB) would be a natural next step."),
          tags$li(strong("Survey coverage changes over time. "), "Which streams are surveyed varies from year to year, ",
                  "and monitoring effort has declined in recent decades (see the chart on this page). Stream-level ",
                  "random effects reduce, but do not remove, the bias this can cause."),
          tags$li(strong("Survey quality is mostly unknown. "), "PSF's survey quality rating, based on DFO's estimate ",
                  "classification, is 'Unknown' for most stream-years, so quality cannot be used to filter the data reliably. ",
                  "This largely reflects history: DFO notes that before 1995 the database stored only one summary estimate ",
                  "per population, without the number of observations or the method used, and many of these older ",
                  "estimates are labelled 'Unspecified Returns'."),
          tags$li(strong("Mixed measures. "), "The abundance field can include total returns as well as spawners (see above)."),
          tags$li(strong("Log transformation. "), "Using log(spawners + 1) handles zero counts, but compresses ",
                  "differences between small counts."),
          tags$li(strong("Small CUs. "), "About half of CUs have fewer than 3 qualifying streams, so their trends ",
                  "come from simpler models and rest on less data.")
        )
      ),

      bslib::accordion_panel(
        "Citation and licence",
        p("Please cite the data as:"),
        tags$ul(
          tags$li("Carturan, B. & Peacock, S. (2026). Cleaned spawner survey data (v4). Pacific Salmon Foundation. ",
                  "Zenodo. ", a("https://doi.org/10.5281/zenodo.19959144",
                                href = "https://doi.org/10.5281/zenodo.19959144", target = "_blank"),
                  ". Licensed under CC BY 4.0."),
          tags$li("Fisheries and Oceans Canada. NuSEDS - New Salmon Escapement Database System. ",
                  "Open Government Portal. ",
                  a("https://open.canada.ca/data/en/dataset/c48669a3-045b-400d-b730-48aafe8c5ee6",
                    href = "https://open.canada.ca/data/en/dataset/c48669a3-045b-400d-b730-48aafe8c5ee6",
                    target = "_blank"),
                  ". Contains information licensed under the Open Government Licence - Canada.")
        ),
        p("Data cleaning methods: Pacific Salmon Foundation, ",
          a("Pacific Salmon Explorer Technical Report, Appendix 2: NuSEDS Data Processing",
            href = "https://salmonexplorer.ca/methods/appendix-2.html", target = "_blank"), "."),
        p("This app is an independent portfolio project. It is not produced or endorsed by the Pacific Salmon ",
          "Foundation or Fisheries and Oceans Canada.")
      )
    ),

    # ---- Right: data quality charts ----
    bslib::card(
      bslib::card_header("Data coverage and quality"),
      p(em("These charts follow the species and region filters in the sidebar.")),
      plotOutput("coverage_plot", height = 280),
      plotOutput("quality_plot", height = 280)
    )
  )
}
