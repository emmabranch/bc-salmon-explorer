# tests/testthat/test-fit_trend.R
# Unit tests for fit_trend() in R/fit_trend.R
# Run them all with: testthat::test_dir("tests/testthat")

test_that("returns one row with the expected columns", {
  res <- fit_trend(sim_cu(n_streams = 5))
  expect_equal(nrow(res), 1)
  expect_named(res, c("slope", "se", "pct_change", "pct_low", "pct_high",
                      "n_streams", "n_years", "n_obs", "mean_log",
                      "mean_year_c", "method"))
})

test_that("recovers a known declining trend", {
  # True slope of -0.05 on the log scale is about -4.9% per year
  true_slope <- -0.05
  res <- fit_trend(sim_cu(n_streams = 8, slope = true_slope))
  expect_lt(abs(res$slope - true_slope), 0.01)                        # within 0.01
  expect_lt(abs(res$pct_change - 100 * (exp(true_slope) - 1)), 1)     # within 1 percentage point
})

test_that("recovers a known increasing trend", {
  true_slope <- 0.03
  res <- fit_trend(sim_cu(n_streams = 8, slope = true_slope))
  expect_lt(abs(res$slope - true_slope), 0.01)
  expect_gt(res$pct_low, 0)   # confidently increasing
})

test_that("confidence interval surrounds the estimate", {
  res <- fit_trend(sim_cu(n_streams = 5))
  expect_lt(res$pct_low, res$pct_change)
  expect_gt(res$pct_high, res$pct_change)
  expect_gt(res$se, 0)
})

test_that("uses linear regression for 1 or 2 streams", {
  expect_match(fit_trend(sim_cu(n_streams = 1))$method, "Linear regression")
  expect_match(fit_trend(sim_cu(n_streams = 2))$method, "Linear regression")
})

test_that("uses the random-slope mixed model when streams' slopes differ", {
  res <- fit_trend(sim_cu(n_streams = 10, sd_slope = 0.05))
  expect_match(res$method, "random intercept and slope")
})

test_that("falls back to random intercept when streams share one slope", {
  # No between-stream slope variation makes the random-slope model singular
  res <- fit_trend(sim_cu(n_streams = 5, sd_slope = 0))
  expect_match(res$method, "random intercept by stream")
})

test_that("counts streams, years, and observations correctly", {
  d <- sim_cu(n_streams = 4, n_years = 12)
  d <- d[-(1:3), ]   # drop 3 rows so the data are unbalanced
  res <- fit_trend(d)
  expect_equal(res$n_streams, 4)
  expect_equal(res$n_years, 12)
  expect_equal(res$n_obs, 4 * 12 - 3)
})
