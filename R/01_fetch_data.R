# 01_fetch_data.R
# Pull HRM LakeWatchers data from DataStream API
# Requires: DATASTREAM_API_KEY in .Renviron
# Run usethis::edit_r_environ() to set it

library(datastreamr)
library(readr)

# Set API key from environment (never hardcode it)
setAPIKey(Sys.getenv("DATASTREAM_API_KEY"))

# ---- Query ----
# DOI for HRM LakeWatchers v2.0.0
qs <- list(
  `$filter` = "DOI eq '10.25976/85pw-zj92'"
)

message("Fetching data from DataStream API...")
raw <- observations(qs)
message("Pulled ", nrow(raw), " observations across ", 
        length(unique(raw$LocationId)), " locations")

# ---- Cache locally ----
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
write_csv(raw, "data/raw/hrm_lakewatchers_raw.csv")
message("Saved to data/raw/hrm_lakewatchers_raw.csv")