# 01_fetch_data.R
# Pull HRM LakeWatchers data from the DataStream API.
#
# Prerequisites:
#   - DATASTREAM_API_KEY set in ~/.Renviron (use usethis::edit_r_environ())
#   - datastreamr installed: remotes::install_github("datastreamapp/datastreamr")

library(datastreamr)
library(dplyr)
library(readr)
library(here)

# HRM LakeWatchers DOI (v2.0.0)
hrm_doi <- "10.25976/85pw-zj92"

# Query: pull all observations with location metadata via /Records
# /Records is preferred over /Observations here because it joins
# monitoring-location info to each row in a single call.
qs <- list(
  `$select` = paste(
    "DOI", "DatasetName",
    "MonitoringLocationName",
    "MonitoringLocationLatitude", "MonitoringLocationLongitude",
    "MonitoringLocationType",
    "ActivityStartDate", "ActivityStartTime",
    "ActivityDepthHeightMeasure", "ActivityDepthHeightUnit",
    "CharacteristicName",
    "ResultSampleFraction",
    "ResultValue", "ResultUnit",
    "ResultDetectionCondition",
    "ResultDetectionQuantitationLimitMeasure",
    "ResultDetectionQuantitationLimitUnit",
    sep = ","
  ),
  `$filter` = sprintf("DOI eq '%s'", hrm_doi),
  `$top` = 10000
)

message("Querying DataStream API for HRM LakeWatchers...")
raw <- records(qs)
message("Pulled ", nrow(raw), " records.")

# Cache locally (data/raw/ is gitignored)
dir.create(here("data", "raw"), recursive = TRUE, showWarnings = FALSE)
out_path <- here("data", "raw", "hrm_lakewatchers_raw.csv")
write_csv(raw, out_path)
message("Saved to ", out_path)