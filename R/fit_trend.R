# R/fit_trend.R
# Fit a spawner abundance trend for one Conservation Unit (CU).
#
# Model: log(spawners + 1) ~ year, with stream-level random effects
#   - 3+ streams: lmer with random intercept and slope by stream,
#                 falling back to random intercept only if the fit is singular
#   - 1 to 2 streams: ordinary regression (lm), with a fixed effect per stream
#
# The fixed year slope is the CU-level trend on the log scale.
# 100 * (exp(slope) - 1) is the average percent change per year.
#
# Shiny loads files in R/ automatically, and scripts/02_trends.R sources this
# file, so the app and the pre-computed results use the same function.

fit_trend <- function(d) {
  n_streams <- dplyr::n_distinct(d$streamid)
  fit <- NULL
  method <- NA_character_

  if (n_streams >= 3) {
    fit <- tryCatch(
      suppressMessages(lme4::lmer(log_spawners ~ year_c + (1 + year_c | streamid), data = d)),
      error = function(e) NULL
    )
    method <- "Mixed model: random intercept and slope by stream"

    if (is.null(fit) || lme4::isSingular(fit)) {
      fit <- tryCatch(
        suppressMessages(lme4::lmer(log_spawners ~ year_c + (1 | streamid), data = d)),
        error = function(e) NULL
      )
      method <- "Mixed model: random intercept by stream"
    }
  }

  if (is.null(fit)) {
    fit <- if (n_streams == 1) {
      stats::lm(log_spawners ~ year_c, data = d)
    } else {
      stats::lm(log_spawners ~ year_c + factor(streamid), data = d)
    }
    method <- "Linear regression (fewer than 3 streams)"
  }

  est <- stats::coef(summary(fit))["year_c", 1:2]

  tibble::tibble(
    slope       = unname(est[1]),
    se          = unname(est[2]),
    pct_change  = 100 * (exp(slope) - 1),
    pct_low     = 100 * (exp(slope - 1.96 * se) - 1),
    pct_high    = 100 * (exp(slope + 1.96 * se) - 1),
    n_streams   = n_streams,
    n_obs       = nrow(d),
    mean_log    = mean(d$log_spawners),   # used to draw the trend line
    mean_year_c = mean(d$year_c),
    method      = method
  )
}
