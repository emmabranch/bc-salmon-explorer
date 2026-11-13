# 01_clean.R
# Build a compact, app-ready dataset from PSF's Cleaned spawner survey data (v4)
#
# Input:  data-raw/2_nuseds_cuid_streamid_2026-02-20.csv (not in Git; see data-raw/README.md)
# Output: data/salmon_app.rds, a list with two tables:
#           $streams  one row per stream (streamid): species, CU, region, name, coordinates
#           $counts   one row per stream per year: spawner estimate and data-quality fields
#
# Source: Carturan & Peacock (2026), Pacific Salmon Foundation, Zenodo
#         https://doi.org/10.5281/zenodo.19959144 (CC BY 4.0), derived from DFO NuSEDS.

library(readr)
library(dplyr)

raw_path <- "data-raw/2_nuseds_cuid_streamid_2026-02-20.csv"

# ---- 0. Read only the columns the app needs -------------------------------
# Reading 21 of 90 columns makes this much faster and lighter on memory.

keep_cols <- c(
  # what and where
  "SPECIES", "SPECIES_QUALIFIED", "RUN_TYPE",
  "region", "regionid", "cuid", "cu_name_pse",
  "streamid", "GFE_ID", "POP_ID", "IndexId", "sys_nm",
  "Y_LAT", "X_LONGT", "IS_INDICATOR",
  # when and how many
  "Year", "MAX_ESTIMATE", "NATURAL_SPAWNERS_TOTAL",
  # data quality
  "ESTIMATE_CLASSIFICATION", "ESTIMATE_METHOD", "stream_survey_quality"
)

raw <- read_csv(raw_path,
                col_select = all_of(keep_cols),
                guess_max = 100000,
                show_col_types = FALSE)

# ---- 1. Sanity checks (run these and paste the output) --------------------

# Species codes (expect CK, CM, CO, PKE, PKO, SEL, SER or similar)
raw |> count(SPECIES, SPECIES_QUALIFIED)

# Year range
range(raw$Year, na.rm = TRUE)

# Rows per region
raw |> count(region, sort = TRUE)

# Is there exactly one row per stream per year? (want 0)
raw |> count(streamid, Year) |> filter(n > 1) |> nrow()

# Does each stream map to one CU and one location? (want 0)
raw |>
  group_by(streamid) |>
  summarise(n_cu  = n_distinct(cuid),
            n_loc = n_distinct(Y_LAT, X_LONGT)) |>
  filter(n_cu > 1 | n_loc > 1) |>
  nrow()

# Missing values and zeros in the key fields
raw |>
  summarise(
    rows          = n(),
    na_estimate   = sum(is.na(MAX_ESTIMATE)),
    zero_estimate = sum(MAX_ESTIMATE == 0, na.rm = TRUE),
    na_cuid       = sum(is.na(cuid)),
    na_coords     = sum(is.na(Y_LAT) | is.na(X_LONGT))
  )

# How often MAX_ESTIMATE differs from NATURAL_SPAWNERS_TOTAL
raw |>
  summarise(
    both_present = sum(!is.na(MAX_ESTIMATE) & !is.na(NATURAL_SPAWNERS_TOTAL)),
    differ       = sum(MAX_ESTIMATE != NATURAL_SPAWNERS_TOTAL, na.rm = TRUE)
  )

# Survey quality categories
raw |> count(stream_survey_quality, sort = TRUE)


# ---- 1b. Investigate duplicates and the odd stream ------------------------

dups <- raw |>
  add_count(streamid, Year, name = "n_dup") |>
  filter(n_dup > 1) |>
  arrange(streamid, Year)

# How many duplicate groups have more than one real estimate?
dups |>
  group_by(streamid, Year) |>
  summarise(n_estimates = sum(!is.na(MAX_ESTIMATE)), .groups = "drop") |>
  count(n_estimates)

# What differs between the duplicate rows?
dups |>
  select(streamid, Year, SPECIES_QUALIFIED, cuid, POP_ID, GFE_ID,
         RUN_TYPE, MAX_ESTIMATE) |>
  print(n = 20)

# The stream with more than one CU or location
raw |>
  group_by(streamid) |>
  filter(n_distinct(cuid) > 1 | n_distinct(Y_LAT, X_LONGT) > 1) |>
  ungroup() |>
  distinct(streamid, cuid, cu_name_pse, sys_nm, Y_LAT, X_LONGT,
           GFE_ID, POP_ID)

raw |>
  filter(!is.na(streamid)) |>
  count(streamid, Year) |>
  filter(n > 1) |>
  nrow()

raw |>
  filter(!is.na(streamid)) |>
  group_by(streamid) |>
  summarise(n_cu  = n_distinct(cuid),
            n_loc = n_distinct(Y_LAT, X_LONGT)) |>
  filter(n_cu > 1 | n_loc > 1) |>
  nrow()



# ---- 2. Annual counts table -----------------------------------------------
# Keep rows matched to a CU and with a spawner estimate.
# Observed zeros are kept: in this dataset they are real counts, not missing.

counts <- raw |>
  filter(!is.na(cuid), !is.na(streamid), !is.na(MAX_ESTIMATE)) |>
  transmute(
    streamid,
    year           = as.integer(Year),
    spawners       = MAX_ESTIMATE,
    survey_quality = factor(stream_survey_quality),
    estimate_class = factor(ESTIMATE_CLASSIFICATION),
    estimate_method = factor(ESTIMATE_METHOD)
  ) |>
  arrange(streamid, year)
  stopifnot(!anyDuplicated(counts[c("streamid", "year")]))

# ---- 3. Stream lookup table -----------------------------------------------
# One row per stream, with the attributes the map and filters need.

coverage <- counts |>
  group_by(streamid) |>
  summarise(
    first_year = min(year),
    last_year  = max(year),
    n_years    = n_distinct(year),
    .groups = "drop"
  )

streams <- raw |>
  filter(streamid %in% counts$streamid) |>
  group_by(streamid) |>
  summarise(
    species           = first(SPECIES),
    species_qualified = first(SPECIES_QUALIFIED),
    run_type          = first(RUN_TYPE),
    region            = first(region),
    cuid              = first(cuid),
    cu_name           = first(cu_name_pse),
    stream_name       = first(sys_nm),
    lat               = first(Y_LAT),
    lon               = first(X_LONGT),
    is_indicator      = first(IS_INDICATOR) == "Y",
    .groups = "drop"
  ) |>
  left_join(coverage, by = "streamid") |>
  mutate(across(c(species, species_qualified, run_type, region, cu_name),
                factor))

# ---- 4. Save ----------------------------------------------------------------

dir.create("data", showWarnings = FALSE)

salmon_app <- list(
  streams = streams,
  counts  = counts,
  source  = "Carturan & Peacock (2026). Cleaned spawner survey data (v4). Pacific Salmon Foundation. https://doi.org/10.5281/zenodo.19959144. CC BY 4.0. Derived from DFO NuSEDS.",
  built   = Sys.Date()
)

saveRDS(salmon_app, "data/salmon_app.rds", compress = "xz")

# Summary of what was saved (paste this too)
nrow(streams)
nrow(counts)
round(file.size("data/salmon_app.rds") / 1e6, 1)  # size in MB
