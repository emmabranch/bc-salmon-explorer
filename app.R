# app.R
# BC Salmon Explorer: interactive map and trends of BC salmon spawner abundance
# Data: Carturan & Peacock (2026), Pacific Salmon Foundation, Cleaned spawner survey
#       data (v4), https://doi.org/10.5281/zenodo.19959144, CC BY 4.0. Derived from DFO NuSEDS.

library(shiny)
library(bslib)
library(leaflet)
library(dplyr)
library(ggplot2)
library(plotly)

# ---- Data -----------------------------------------------------------------

salmon  <- readRDS("data/salmon_app.rds")
streams <- salmon$streams
counts  <- salmon$counts

trend_file     <- readRDS("data/cu_trends.rds")
cu_trends      <- trend_file$trends
trend_settings <- trend_file$settings

# The low-data flag needs the newer trend file
if (!"low_data" %in% names(cu_trends)) {
  stop("data/cu_trends.rds is out of date: rerun scripts/02_trends.R")
}
trend_label    <- paste0("CU trend (", trend_settings$trend_start, " to ",
                         trend_settings$trend_end, ")")

# Add each stream's CU trend class, for colouring the map
streams <- streams |>
  left_join(select(cu_trends, cuid, trend_class), by = "cuid") |>
  mutate(trend_class = as.character(trend_class),
         trend_class = ifelse(is.na(trend_class), "Not estimated", trend_class))

# Flag coordinates outside a generous BC, Yukon, and transboundary box.
# These are kept in the trends but left off the map (see Methods tab).
streams <- streams |>
  mutate(coords_ok = between(lon, -142, -110) & between(lat, 45, 70))
map_bounds <- streams |>
  filter(coords_ok) |>
  summarise(lng1 = min(lon), lat1 = min(lat), lng2 = max(lon), lat2 = max(lat))

species_choices <- sort(unique(as.character(streams$species)))
region_choices  <- sort(unique(as.character(streams$region)))
year_min <- min(counts$year)
year_max <- max(counts$year)

# Colour-blind-friendly palettes (Okabe-Ito)
species_pal <- colorFactor(
  palette = c("#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00"),
  levels  = species_choices
)
trend_levels <- c("Declining", "No clear trend", "Increasing", "Not estimated")
trend_pal <- colorFactor(
  palette = c("#D55E00", "#999999", "#0072B2", "#E8E8E8"),  # "Not estimated" is pale fill with a dark outline
  levels  = trend_levels
)

# ---- UI -------------------------------------------------------------------

ui <- page_sidebar(
  title = div(class = "app-title", "🐟 BC Salmon Explorer",
              span(class = "app-subtitle", "Spawner surveys and population trends")),
  window_title = "BC Salmon Explorer",
  theme = app_theme,   # fonts, colours, and styles are in R/app_theme.R

  sidebar = sidebar(
    checkboxGroupInput("species", "Species",
                       choices = species_choices,
                       selected = species_choices),
    selectInput("region", "Region",
                choices = c("All regions" = "", region_choices)),
    selectInput("cu", "Conservation Unit",
                choices = c("All CUs" = "")),
    sliderInput("years", "Years with estimates",
                min = year_min, max = year_max,
                value = c(max(1950, year_min), year_max),
                sep = "")
  ),

  app_head(),   # browser tab icon and extra CSS

  navset_card_tab(
    id = "tabs",
    nav_panel("Map",
              hero_banner(streams, counts, cu_trends, trend_settings),
              radioButtons("colour_by", "Colour points by",
                           choices = c("Species" = "species",
                                       setNames("trend", trend_label)),
                           inline = TRUE),
              leafletOutput("map", height = 600),
              textOutput("n_streams")),
    nav_panel("Trends",
              uiOutput("trend_summary"),
              uiOutput("trend_plot_ui"),
              h5("CU trend estimates", class = "section-title"),
              p(em("Trends marked ", strong("Low data"), " are based on fewer than ",
                   trend_settings$low_data_years, " years of estimates and are less reliable.")),
              tableOutput("trend_table")),
    nav_panel("Methods and data quality",
              methods_tab_ui(
                n_streams      = nrow(streams),
                n_cus          = n_distinct(streams$cuid),
                n_obs          = nrow(counts),
                year_min       = year_min,
                year_max       = year_max,
                trend_settings = trend_settings
              ))
  )
)

# ---- Server ---------------------------------------------------------------

server <- function(input, output, session) {

  # Banner buttons switch tabs
  observeEvent(input$go_trends,  nav_select("tabs", "Trends"))
  observeEvent(input$go_methods, nav_select("tabs", "Methods and data quality"))

  # CU choices depend on the species and region selected
  observe({
    cus <- streams |>
      filter(species %in% input$species,
             input$region == "" | region == input$region) |>
      distinct(cuid, cu_name, species) |>
      arrange(cu_name)

    # Guard: with no CUs left (e.g. no species ticked), paste0() would return
    # one stray label for zero CUs and setNames() would error
    choices <- c("All CUs" = "")
    if (nrow(cus) > 0) {
      choices <- c(choices,
                   setNames(cus$cuid, paste0(cus$cu_name, " (", cus$species, ")")))
    }

    keep <- if (isTRUE(input$cu %in% cus$cuid)) input$cu else ""
    updateSelectInput(session, "cu", choices = choices, selected = keep)
  })

  # Streams matching the filters, with at least one estimate in the year range
  filtered_streams <- reactive({
    # Wait until the inputs exist (they are briefly NULL while the app starts)
    req(input$years, !is.null(input$region), !is.null(input$cu))

    active <- counts |>
      filter(between(year, input$years[1], input$years[2])) |>
      distinct(streamid)

    streams |>
      filter(species %in% input$species,
             input$region == "" | region == input$region,
             input$cu == ""     | cuid == as.numeric(input$cu),
             streamid %in% active$streamid)
  })

  # ---- Map ----

  output$map <- renderLeaflet({
    # zoomSnap = 0.25 lets fitBounds() use quarter zoom steps, so the map fits
    # the data closely instead of jumping out a whole level (4x the area)
    leaflet(options = leafletOptions(preferCanvas = TRUE,
                                     zoomSnap = 0.25, zoomDelta = 0.5)) |>
      addProviderTiles(providers$Esri.WorldGrayCanvas) |>
      # Open on the full extent of the streams, with a little padding at the edges
      fitBounds(lng1 = map_bounds$lng1, lat1 = map_bounds$lat1,
                lng2 = map_bounds$lng2, lat2 = map_bounds$lat2,
                options = list(padding = c(20, 20)))
  })

  observe({
    d <- filter(filtered_streams(), coords_ok)
    by_trend <- input$colour_by == "trend"

    map <- leafletProxy("map") |>
      clearMarkers() |>
      clearMarkerClusters() |>
      clearControls()

    # opacity = 1 makes the legend swatches match the points
    map <- if (by_trend) {
      addLegend(map, "bottomright", pal = trend_pal, values = trend_levels,
                title = trend_label, opacity = 1)
    } else {
      addLegend(map, "bottomright", pal = species_pal, values = species_choices,
                title = "Species", opacity = 1)
    }

    if (nrow(d) == 0) return()

    fill <- if (by_trend) trend_pal(d$trend_class) else species_pal(as.character(d$species))

    # Cluster overlapping points in species view; clusters split apart at zoom 8.
    # Trend view stays unclustered so the trend colours are always visible.
    clusters <- if (by_trend) NULL else markerClusterOptions(disableClusteringAtZoom = 8)

    map |>
      addCircleMarkers(
        data = d, lng = ~lon, lat = ~lat,
        radius = 3, fillOpacity = 0.8, fillColor = fill,
        # thin dark outline keeps pale points visible on the grey basemap
        stroke = TRUE, color = "#444444", weight = 0.5, opacity = 0.8,
        clusterOptions = clusters,
        label = ~paste0(stream_name, " (", species, ")"),
        popup = ~paste0(
          "<b>", htmltools::htmlEscape(stream_name), "</b><br>",
          species, "<br>",
          "CU: ", htmltools::htmlEscape(cu_name), "<br>",
          "Region: ", region, "<br>",
          "CU trend: ", trend_class, "<br>",
          "Years with estimates: ", n_years,
          " (", first_year, " to ", last_year, ")"
        )
      )
  })

  output$n_streams <- renderText({
    d <- filtered_streams()
    if (nrow(d) == 0) {
      return("No streams match these filters. Try selecting more species or widening the year range.")
    }
    n_bad <- sum(!d$coords_ok)
    paste0(format(sum(d$coords_ok), big.mark = ","), " streams shown",
           if (n_bad > 0) paste0(" (", n_bad, " not mapped: implausible coordinates)") else "")
  })

  # ---- Trends ----

  selected_trend <- reactive({
    req(input$cu != "")
    filter(cu_trends, cuid == as.numeric(input$cu))
  })

  # All CU trends matching the species and region filters (overview view)
  filtered_trends <- reactive({
    req(!is.null(input$region))
    cu_trends |>
      filter(species %in% input$species,
             input$region == "" | region == input$region)
  })

  output$trend_summary <- renderUI({
    if (input$cu == "") {
      n <- nrow(filtered_trends())
      return(p(
        sprintf("Average %% change per year in spawner abundance, %d to %d, for the %d CUs matching your filters. ",
                trend_settings$trend_start, trend_settings$trend_end, n),
        em("Lines show 95% confidence intervals. Hollow points and dashed lines mark low-data trends. ",
           "Choose a Conservation Unit in the sidebar to see its streams.")
      ))
    }
    tr <- selected_trend()
    if (nrow(tr) == 0) {
      return(p(em("Not enough data to estimate a trend for this CU in ",
                  trend_settings$trend_start, " to ", trend_settings$trend_end, ".")))
    }
    p(
      strong(paste0(tr$trend_class, ": ")),
      sprintf("%+.1f%% per year (95%% CI %+.1f%% to %+.1f%%), ",
              tr$pct_change, tr$pct_low, tr$pct_high),
      sprintf("%d to %d, based on %d streams and %d annual estimates. ",
              trend_settings$trend_start, trend_settings$trend_end,
              tr$n_streams, tr$n_obs),
      em(tr$method, "."),
      if (tr$low_data) {
        div(class = "alert alert-warning mt-2 mb-0",
            strong("Low data: "),
            sprintf("this trend is based on only %d years of estimates (fewer than %d), so treat it with caution. ",
                    tr$n_years, trend_settings$low_data_years),
            "The trend line is dashed.")
      }
    )
  })

  # Taller plot area for the overview, so every CU gets its own row
  output$trend_plot_ui <- renderUI({
    h <- if (input$cu == "") max(400, 16 * nrow(filtered_trends())) else 500
    plotlyOutput("trend_plot", height = paste0(h, "px"))
  })

  output$trend_plot <- renderPlotly({

    # Overview: one row per CU, ordered by estimated trend
    if (input$cu == "") {
      d <- filtered_trends()
      validate(need(nrow(d) > 0,
                    "No CU trends match these filters. Try selecting more species or another region."))
      d <- d |>
        mutate(label = make.unique(paste0(cu_name, " (", species_qualified, ")")),
               label = reorder(label, pct_change),
               reliability = factor(ifelse(low_data, "Low data", "Adequate data"),
                                    levels = c("Adequate data", "Low data")),
               text  = sprintf("%s<br>%+.1f%% per year (%+.1f to %+.1f)<br>%d streams, %d years%s",
                               label, pct_change, pct_low, pct_high, n_streams, n_years,
                               ifelse(low_data, "<br><b>Low data: less reliable</b>", "")))

      # Low-data trends: hollow points and dashed interval lines
      p <- ggplot(d, aes(pct_change, label, colour = trend_class, text = text)) +
        geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60") +
        geom_linerange(aes(xmin = pct_low, xmax = pct_high, linetype = reliability)) +
        geom_point(aes(shape = reliability), size = 1.8) +
        scale_colour_manual(values = c("Declining" = "#D55E00",
                                       "No clear trend" = "#999999",
                                       "Increasing" = "#0072B2"),
                            name = NULL) +
        scale_shape_manual(values = c("Adequate data" = 16, "Low data" = 1),
                           name = NULL, drop = FALSE) +
        scale_linetype_manual(values = c("Adequate data" = "solid", "Low data" = "dashed"),
                              name = NULL, drop = FALSE) +
        coord_cartesian(xlim = c(-25, 25)) +
        labs(x = "% change per year", y = NULL) +
        theme_minimal(base_size = 11) +
        theme(axis.text.y = element_text(size = 8))

      pl <- ggplotly(p, tooltip = "text")

      # ggplotly names traces like "(Declining,Low data,1)". Keep just the trend
      # class in the legend, and show each class once.
      seen <- character(0)
      for (i in seq_along(pl$x$data)) {
        nm <- pl$x$data[[i]]$name
        if (is.null(nm) || nm == "") next
        clean <- sub("^\\(([^,]*),.*$", "\\1", nm)
        pl$x$data[[i]]$name        <- clean
        pl$x$data[[i]]$legendgroup <- clean
        pl$x$data[[i]]$showlegend  <- !(clean %in% seen)
        seen <- c(seen, clean)
      }
      return(pl |> layout(font = list(family = "Inter, sans-serif")))
    }

    # Single CU: every stream's counts, plus the CU-level trend line
    cu_counts <- counts |>
      inner_join(select(filter(streams, cuid == as.numeric(input$cu)),
                        streamid, stream_name),
                 by = "streamid") |>
      filter(between(year, input$years[1], input$years[2]))
    validate(need(nrow(cu_counts) > 0,
                  "This CU has no estimates in the selected years. Try widening the year range."))

    p <- ggplot(cu_counts, aes(year, spawners, group = streamid,
                               text = paste0(stream_name, "<br>", year, ": ",
                                             format(spawners, big.mark = ",")))) +
      geom_line(colour = "grey70", linewidth = 0.4) +
      geom_point(colour = "grey50", size = 0.8) +
      scale_y_continuous(transform = "log1p", labels = scales::comma) +
      labs(x = NULL, y = "Spawner estimate (log scale)") +
      theme_minimal(base_size = 13)

    # Overlay the CU-level trend line, drawn through the mean of the model data
    tr <- selected_trend()
    if (nrow(tr) == 1) {
      line <- tibble(year = trend_settings$trend_start:trend_settings$trend_end) |>
        mutate(year_c   = year - trend_settings$centre_year,
               spawners = expm1(tr$mean_log + tr$slope * (year_c - tr$mean_year_c)))
      p <- p + geom_line(data = line, aes(year, spawners), inherit.aes = FALSE,
                         colour = "#0072B2", linewidth = 1.2,
                         linetype = if (tr$low_data) "dashed" else "solid")
    }

    ggplotly(p, tooltip = "text")
  })

  # Table of CU trends: the selected CU, or all CUs matching the filters
  output$trend_table <- renderTable({
    d <- if (input$cu == "") filtered_trends() else selected_trend()
    validate(need(nrow(d) > 0, "No CU trends to show for these filters."))

    d |>
      arrange(pct_change) |>
      transmute(
        `Conservation Unit` = cu_name,
        Species             = as.character(species),
        Region              = as.character(region),
        `% change per year` = sprintf("%+.1f", pct_change),
        `95% CI`            = sprintf("%+.1f to %+.1f", pct_low, pct_high),
        Trend               = as.character(trend_class),
        Streams             = n_streams,
        Years               = n_years,
        Reliability         = ifelse(low_data, "Low data", "")
      )
  }, striped = TRUE, hover = TRUE, spacing = "s")

  # ---- Methods and data quality ----

  # Counts for the species and region filters (CU filter ignored here)
  quality_counts <- reactive({
    req(input$years, !is.null(input$region))
    ids <- streams |>
      filter(species %in% input$species,
             input$region == "" | region == input$region) |>
      pull(streamid)
    counts |>
      filter(streamid %in% ids,
             between(year, input$years[1], input$years[2]))
  })

  output$coverage_plot <- renderPlot({
    d <- quality_counts() |> count(year, name = "n_streams")
    validate(need(nrow(d) > 0, "No estimates match these filters."))
    ggplot(d, aes(year, n_streams)) +
      geom_col(fill = "#2471a3", width = 1) +
      labs(title = "Streams with an estimate, by year",
           x = NULL, y = "Streams") +
      theme_minimal(base_size = 13)
  })

  output$quality_plot <- renderPlot({
    quality_levels <- c("High", "Medium-High", "Medium", "Medium-Low", "Low", "Unknown")
    d <- quality_counts() |>
      mutate(decade  = floor(year / 10) * 10,
             quality = factor(ifelse(is.na(survey_quality), "Unknown",
                                     as.character(survey_quality)),
                              levels = quality_levels)) |>
      count(decade, quality)
    validate(need(nrow(d) > 0, "No estimates match these filters."))
    ggplot(d, aes(factor(decade), n, fill = quality)) +
      geom_col(position = "fill") +
      scale_y_continuous(labels = scales::percent) +
      scale_fill_manual(values = c("High" = "#0072B2", "Medium-High" = "#56B4E9",
                                   "Medium" = "#009E73", "Medium-Low" = "#E69F00",
                                   "Low" = "#D55E00", "Unknown" = "#CCCCCC"),
                        name = "Survey quality") +
      labs(title = "Survey quality of estimates, by decade",
           x = NULL, y = "Share of estimates") +
      theme_minimal(base_size = 13)
  })
}

shinyApp(ui, server)
