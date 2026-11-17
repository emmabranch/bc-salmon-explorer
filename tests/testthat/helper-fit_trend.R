# tests/testthat/helper-fit_trend.R
# testthat runs files starting with "helper" before the tests.
# This one loads fit_trend() and defines a function that simulates one CU.

source(file.path("..", "..", "R", "fit_trend.R"))

# Simulate log(spawners + 1) for one CU with a known trend.
#   n_streams: number of streams in the CU
#   n_years:   number of years of data per stream
#   slope:     true CU-level trend on the log scale (per year)
#   sd_slope:  how much each stream's slope varies around the CU slope
sim_cu <- function(n_streams, n_years = 20, slope = -0.05, sd_slope = 0.02,
                   sd_noise = 0.2, seed = 1) {
  set.seed(seed)
  years <- seq(2000, length.out = n_years)
  d <- expand.grid(streamid = seq_len(n_streams), year = years)
  stream_int   <- rnorm(n_streams, mean = 7, sd = 1)
  stream_slope <- rnorm(n_streams, mean = slope, sd = sd_slope)
  d$year_c       <- d$year - 2010
  d$log_spawners <- stream_int[d$streamid] +
    stream_slope[d$streamid] * d$year_c +
    rnorm(nrow(d), sd = sd_noise)
  d
}
