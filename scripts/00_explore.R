# Explore the raw PSF cleaned spawner survey data (v4)

library(readr)
library(dplyr)

df <- read_csv("data-raw/2_nuseds_cuid_streamid_2026-02-20.csv",
               guess_max = 100000)

dim(df)
names(df)
head(df)
glimpse(df)
sort(colMeans(is.na(df)), decreasing = TRUE)

df %>% count(streamid) %>% arrange(desc(n)) %>% head(20)
