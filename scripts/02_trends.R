# scripts/02_trends.R
# Estimate recent spawner abundance trends for every Conservation Unit (CU)
#
# Input:  data/salmon_app.rds (made by scripts/01_clean.R)
# Output: data/cu_trends.rds
#
# Run from the project root. Takes a minute or two.

library(dplyr)
library(lme4)

source("R/fit_trend.R")

salmon  <- readRDS("data/salmon_app.rds")
streams <- salmon$streams
counts  <- salmon$counts

# ---- Settings -------------------------------------------------------------

trend_start <- 1995   # roughly 6 to 7 salmon generations
trend_end   <- 2024
min_years   <- 5      # a stream needs this many years of estimates to be used
centre_year <- 2010   # centring year makes the intercepts interpretable

# ---- Model data -----------------------------------------------------------

cu_info <- streams |>
  group_by(cuid) |>
  summarise(cu_name           = first(cu_name),
            species           = first(species),
            species_qualified = first(species_qualified),
            region            = first(region),
            .groups = "drop")

model_data <- counts |>
  filter(between(year, trend_start, trend_end)) |>
  inner_join(select(streams, streamid, cuid), by = "streamid") |>
  group_by(streamid) |>
  filter(n_distinct(year) >= min_years) |>
  ungroup() |>
  mutate(log_spawners = log1p(spawners),
         year_c       = year - centre_year)

# Quick look at what goes into the models
model_data |>
  summarise(streams = n_distinct(streamid),
            cus     = n_distinct(cuid),
            rows    = n())

# ---- Fit one model per CU -------------------------------------------------

cu_trends <- model_data |>
  group_by(cuid) |>
  group_modify(~ fit_trend(.x)) |>
  ungroup() |>
  left_join(cu_info, by = "cuid") |>
  mutate(
    trend_class = case_when(
      pct_high < 0 ~ "Declining",
      pct_low  > 0 ~ "Increasing",
      TRUE         ~ "No clear trend"
    ),
    trend_class = factor(trend_class,
                         levels = c("Declining", "No clear trend", "Increasing"))
  )

# ---- Checks (paste this output) -------------------------------------------

cu_trends |> count(trend_class)
cu_trends |> count(method)
cu_trends |>
  group_by(species) |>
  summarise(cus = n(),
            median_pct_change = round(median(pct_change), 1))

# ---- Save -------------------------------------------------------------------

saveRDS(
  list(
    trends   = cu_trends,
    settings = list(trend_start = trend_start, trend_end = trend_end,
                    min_years = min_years, centre_year = centre_year)
  ),
  "data/cu_trends.rds"
)
