# scripts/03_ar1_sensitivity.R
# Sensitivity check: how much does ignoring year-to-year autocorrelation matter?
#
# The main trend models (scripts/02_trends.R) assume independent errors. Salmon
# counts in neighbouring years are correlated, so their confidence intervals are
# probably too narrow. Here we refit each mixed-model CU (3+ streams) in glmmTMB
# with and without an AR(1) error structure within each stream, and compare.
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

# ---- Fit the two comparison models for one CU -----------------------------
# To isolate the effect of autocorrelation, fit the same glmmTMB model twice:
#   base: log(spawners + 1) ~ year + (1 | stream)                  independent errors
#   ar1:  log(spawners + 1) ~ year + (1 | stream) + AR(1) errors   correlated errors
# The only difference is the AR(1) term. phi is the estimated correlation
# between consecutive years within a stream.

fit_one <- function(formula, d) {
  tryCatch(suppressWarnings(glmmTMB(formula, data = d)), error = function(e) NULL)
}

slope_se <- function(fit) {
  if (is.null(fit)) return(c(NA_real_, NA_real_))
  unname(summary(fit)$coefficients$cond["year_c", c("Estimate", "Std. Error")])
}

# TRUE only if the fit worked and gave a valid standard error
fit_ok <- function(fit, se) {
  !is.null(fit) && isTRUE(fit$sdr$pdHess) && is.finite(se)
}

fit_models <- function(d) {
  base <- fit_one(log_spawners ~ year_c + (1 | streamid), d)
  ar1  <- fit_one(log_spawners ~ year_c + (1 | streamid) + ar1(year_f + 0 | streamid), d)

  b <- slope_se(base)
  a <- slope_se(ar1)

  # The AR(1) term is the second random-effect term for streamid
  phi <- if (is.null(ar1)) NA_real_ else tryCatch(
    attr(VarCorr(ar1)$cond[[2]], "correlation")[1, 2],
    error = function(e) NA_real_
  )

  tibble(
    slope_base = b[1], se_base = b[2],
    slope_ar1  = a[1], se_ar1  = a[2],
    phi        = phi,
    converged  = fit_ok(base, b[2]) && fit_ok(ar1, a[2])
  )
}

# ---- Fit every mixed-model CU ---------------------------------------------

fits <- model_data |>
  filter(cuid %in% mixed_cus) |>
  group_by(cuid) |>
  group_modify(~ fit_models(.x)) |>
  ungroup()

# ---- Compare ----------------------------------------------------------------

classify <- function(slope, se) {
  low  <- 100 * (exp(slope - 1.96 * se) - 1)
  high <- 100 * (exp(slope + 1.96 * se) - 1)
  factor(case_when(high < 0 ~ "Declining",
                   low  > 0 ~ "Increasing",
                   TRUE     ~ "No clear trend"),
         levels = c("Declining", "No clear trend", "Increasing"))
}

comparison <- main |>
  select(cuid, cu_name, species, region, n_streams, n_years,
         slope_main = slope, se_main = se, trend_main = trend_class) |>
  inner_join(fits, by = "cuid") |>
  mutate(
    pct_main   = 100 * (exp(slope_main) - 1),
    pct_base   = 100 * (exp(slope_base) - 1),
    pct_ar1    = 100 * (exp(slope_ar1)  - 1),
    trend_base = classify(slope_base, se_base),
    trend_ar1  = classify(slope_ar1,  se_ar1),
    se_ratio_ar1_vs_base = se_ar1 / se_base,   # the isolated effect of AR(1)
    se_ratio_ar1_vs_main = se_ar1 / se_main    # AR(1) versus the app's models
  )

ok <- filter(comparison, converged)

# ---- Results ------------------------------------------

# How many CUs were refitted, and how many converged (both models)
comparison |> count(converged)

# Typical year-to-year correlation (phi)
summary(ok$phi)

# ISOLATED EFFECT OF AR(1): same model with and without the AR(1) term
# SE ratio > 1 means accounting for autocorrelation widens the interval
summary(ok$se_ratio_ar1_vs_base)
cor(ok$pct_base, ok$pct_ar1)
median(abs(ok$pct_ar1 - ok$pct_base))
table(no_ar1 = ok$trend_base, ar1 = ok$trend_ar1)

# AR(1) VERSUS THE APP'S MAIN MODELS (random slopes, independent errors)
summary(ok$se_ratio_ar1_vs_main)
cor(ok$pct_main, ok$pct_ar1)
median(abs(ok$pct_ar1 - ok$pct_main))
table(main = ok$trend_main, ar1 = ok$trend_ar1)

# ---- Save -------------------------------------------------------------------

saveRDS(comparison, "data/ar1_sensitivity.rds")
