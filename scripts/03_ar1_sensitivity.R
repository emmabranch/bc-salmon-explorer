# scripts/03_ar1_sensitivity.R
# Sensitivity check: how much does ignoring year-to-year autocorrelation matter?
#
# The main trend models (scripts/02_trends.R) assume independent errors. Salmon
# counts in neighbouring years are correlated, so their confidence intervals are
# probably too narrow. Here we refit each mixed-model CU (3+ streams) with an
# AR(1) error structure within each stream, using glmmTMB, and compare.
#
# Input:  data/salmon_app.rds, data/cu_trends.rds
# Output: data/ar1_sensitivity.rds
#
# Run from the project root. Takes a few minutes.

library(dplyr)
library(glmmTMB)

salmon     <- readRDS("data/salmon_app.rds")
trend_file <- readRDS("data/cu_trends.rds")
main       <- trend_file$trends
settings   <- trend_file$settings

# ---- Same model data as the main analysis ---------------------------------

model_data <- salmon$counts |>
  filter(between(year, settings$trend_start, settings$trend_end)) |>
  inner_join(select(salmon$streams, streamid, cuid), by = "streamid") |>
  group_by(streamid) |>
  filter(n_distinct(year) >= settings$min_years) |>
  ungroup() |>
  mutate(
    log_spawners = log1p(spawners),
    year_c       = year - settings$centre_year,
    # AR(1) needs time as a factor with every year as a level, so gaps are spaced correctly
    year_f       = factor(year, levels = settings$trend_start:settings$trend_end),
    streamid     = factor(streamid)
  )

# Only CUs that used a mixed model in the main analysis (3+ streams)
mixed_cus <- main |>
  filter(grepl("Mixed model", method)) |>
  pull(cuid)

# ---- Fit the AR(1) model for one CU ---------------------------------------
#   log(spawners + 1) ~ year + (1 | stream) + AR(1) errors over years within stream
#   phi is the estimated correlation between consecutive years.

fit_ar1 <- function(d) {
  fit <- tryCatch(
    suppressWarnings(glmmTMB(
      log_spawners ~ year_c + (1 | streamid) + ar1(year_f + 0 | streamid),
      data = d
    )),
    error = function(e) NULL
  )

  if (is.null(fit)) {
    return(tibble(slope_ar1 = NA_real_, se_ar1 = NA_real_,
                  phi = NA_real_, converged = FALSE))
  }

  est <- summary(fit)$coefficients$cond["year_c", c("Estimate", "Std. Error")]

  # The AR(1) term is the second random-effect term for streamid
  phi <- tryCatch(
    attr(VarCorr(fit)$cond[[2]], "correlation")[1, 2],
    error = function(e) NA_real_
  )

  tibble(
    slope_ar1 = unname(est[1]),
    se_ar1    = unname(est[2]),
    phi       = phi,
    # FALSE means the fit is unreliable (no valid standard error)
    converged = isTRUE(fit$sdr$pdHess) && is.finite(unname(est[2]))
  )
}

# ---- Fit every mixed-model CU ---------------------------------------------

ar1 <- model_data |>
  filter(cuid %in% mixed_cus) |>
  group_by(cuid) |>
  group_modify(~ fit_ar1(.x)) |>
  ungroup()

# ---- Compare with the main models -----------------------------------------

comparison <- main |>
  select(cuid, cu_name, species, region, n_streams, n_years,
         slope_main = slope, se_main = se, trend_main = trend_class) |>
  inner_join(ar1, by = "cuid") |>
  mutate(
    se_ratio     = se_ar1 / se_main,   # > 1 means AR(1) gives wider intervals
    pct_main     = 100 * (exp(slope_main) - 1),
    pct_ar1      = 100 * (exp(slope_ar1) - 1),
    pct_low_ar1  = 100 * (exp(slope_ar1 - 1.96 * se_ar1) - 1),
    pct_high_ar1 = 100 * (exp(slope_ar1 + 1.96 * se_ar1) - 1),
    trend_ar1 = case_when(
      !converged       ~ NA_character_,
      pct_high_ar1 < 0 ~ "Declining",
      pct_low_ar1  > 0 ~ "Increasing",
      TRUE             ~ "No clear trend"
    ),
    trend_ar1 = factor(trend_ar1, levels = levels(trend_main))
  )

ok <- filter(comparison, converged)

# ---- Results (paste this output) ------------------------------------------

# How many CUs were refitted, and how many converged
comparison |> count(converged)

# Typical year-to-year correlation (phi)
summary(ok$phi)

# How much wider are the AR(1) confidence intervals? (median ratio of SEs)
summary(ok$se_ratio)

# Do the slopes themselves change much? (correlation and median absolute difference, in % per year)
cor(ok$pct_main, ok$pct_ar1)
median(abs(ok$pct_ar1 - ok$pct_main))

# Do trend labels change? Rows: main model. Columns: AR(1) model.
table(main = ok$trend_main, ar1 = ok$trend_ar1)

# ---- Save -------------------------------------------------------------------

saveRDS(comparison, "data/ar1_sensitivity.rds")
