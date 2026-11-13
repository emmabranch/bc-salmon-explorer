# app.R
# BC Salmon Explorer: interactive map and trends of BC salmon spawner abundance
# Data: Carturan & Peacock (2026), Pacific Salmon Foundation, Cleaned spawner survey
#       data (v4), https://doi.org/10.5281/zenodo.19959144, CC BY 4.0. Derived from DFO NuSEDS.

library(shiny)
library(bslib)
library(leaflet)
library(dplyr)

# ---- Data -----------------------------------------------------------------

salmon  <- readRDS("data/salmon_app.rds")
streams <- salmon$streams
counts  <- salmon$counts

species_choices <- sort(unique(as.character(streams$species)))
region_choices  <- sort(unique(as.character(streams$region)))
year_min <- min(counts$year)
year_max <- max(counts$year)

# Colour-blind-friendly palette (Okabe-Ito), one colour per species
species_pal <- colorFactor(
  palette = c("#E69F00", "#56B4E9", "#009E73", "#CC79A7", "#D55E00"),
  levels  = species_choices
)

# ---- UI -------------------------------------------------------------------

ui <- page_sidebar(
  title = "BC Salmon Explorer",
  theme = bs_theme(version = 5, bootswatch = "flatly"),

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

  navset_card_tab(
    nav_panel("Map",
              leafletOutput("map", height = 600),
              textOutput("n_streams")),
    nav_panel("Trends",
              p("Coming next: spawner abundance over time and mixed-effects trend estimates.")),
    nav_panel("Methods and data quality",
              p("Coming soon."))
  )
)

# ---- Server ---------------------------------------------------------------

server <- function(input, output, session) {

  # CU choices depend on the species and region selected
  observe({
    cus <- streams |>
      filter(species %in% input$species,
             input$region == "" | region == input$region) |>
      distinct(cuid, cu_name, species) |>
      arrange(cu_name)

    choices <- c("All CUs" = "",
                 setNames(cus$cuid, paste0(cus$cu_name, " (", cus$species, ")")))

    keep <- if (isTRUE(input$cu %in% cus$cuid)) input$cu else ""
    updateSelectInput(session, "cu", choices = choices, selected = keep)
  })

  # Streams matching the filters, with at least one estimate in the year range
  filtered_streams <- reactive({
    active <- counts |>
      filter(between(year, input$years[1], input$years[2])) |>
      distinct(streamid)

    streams |>
      filter(species %in% input$species,
             input$region == "" | region == input$region,
             input$cu == ""     | cuid == as.numeric(input$cu),
             streamid %in% active$streamid)
  })

  # Base map, drawn once
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(preferCanvas = TRUE)) |>
      addProviderTiles(providers$Esri.WorldGrayCanvas) |>
      setView(lng = -126, lat = 54, zoom = 5) |>
      addLegend("bottomright", pal = species_pal,
                values = species_choices, title = "Species")
  })

  # Redraw the points whenever the filters change
  observe({
    d <- filtered_streams()
    map <- leafletProxy("map") |> clearMarkers()
    if (nrow(d) == 0) return()

    map |>
      addCircleMarkers(
        data = d, lng = ~lon, lat = ~lat,
        radius = 4, stroke = FALSE, fillOpacity = 0.7,
        fillColor = ~species_pal(as.character(species)),
        label = ~paste0(stream_name, " (", species, ")"),
        popup = ~paste0(
          "<b>", htmltools::htmlEscape(stream_name), "</b><br>",
          species, "<br>",
          "CU: ", htmltools::htmlEscape(cu_name), "<br>",
          "Region: ", region, "<br>",
          "Years with estimates: ", n_years,
          " (", first_year, " to ", last_year, ")"
        )
      )
  })

  output$n_streams <- renderText({
    paste(format(nrow(filtered_streams()), big.mark = ","), "streams shown")
  })
}

shinyApp(ui, server)
