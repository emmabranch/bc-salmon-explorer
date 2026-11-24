rsconnect::deployApp(
  appName  = "bc-salmon-explorer",
  appFiles = c("app.R", "renv.lock",
               list.files("R", full.names = TRUE),
               "data/salmon_app.rds", "data/cu_trends.rds",
               list.files("www", full.names = TRUE))  # motif and browser tab icon
)