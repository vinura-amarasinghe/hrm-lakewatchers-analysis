# 02_clean_data.R
# Clean and filter HRM LakeWatchers raw data
# Run after 01_fetch_data.R

library(dplyr)
library(readr)
library(lubridate)

# ---- Load raw data ----
raw <- read_csv("data/raw/hrm_lakewatchers_raw.csv", show_col_types = FALSE)
message("Loaded ", nrow(raw), " rows")

# ---- Parameters of interest ----
params_keep <- c(
  "Temperature, water",
  "Dissolved oxygen (DO)",
  "Total Phosphorus, mixed forms",
  "Chlorophyll a, corrected for pheophytin",
  "pH",
  "Depth, Secchi disk depth",
  "Escherichia coli"
)

# ---- Clean ----
clean <- raw %>%
  # Keep only parameters of interest
  filter(CharacteristicName %in% params_keep) %>%
  # Parse dates
  mutate(
    Date       = as.Date(ActivityStartDate),
    Year       = year(Date),
    Month      = month(Date),
    Season     = case_when(
      Month %in% 3:5  ~ "Spring",
      Month %in% 6:8  ~ "Summer",
      Month %in% 9:11 ~ "Fall",
      TRUE            ~ "Winter"
    ),
    # Short parameter labels for plotting
    Parameter = recode(CharacteristicName,
      "Temperature, water"                          = "Temp_C",
      "Dissolved oxygen (DO)"                       = "DO_mgL",
      "Total Phosphorus, mixed forms"               = "TP_mgL",
      "Chlorophyll a, corrected for pheophytin"     = "Chla_mgL",
      "pH"                                          = "pH",
      "Depth, Secchi disk depth"                    = "Secchi_m",
      "Escherichia coli"                            = "Ecoli_cfu"
    ),
    ResultValue = as.numeric(ResultValue)
  ) %>%
  # Remove NAs in value or date
  filter(!is.na(ResultValue), !is.na(Date)) %>%
  # Select columns we need
  select(
    LocationId, Date, Year, Month, Season,
    CharacteristicName, Parameter, ResultValue, ResultUnit,
    ActivityType, ResultDetectionCondition
  )

message("After filtering: ", nrow(clean), " rows")
message("Parameters: ", paste(unique(clean$Parameter), collapse = ", "))
message("Locations: ", length(unique(clean$LocationId)))
message("Date range: ", min(clean$Date), " to ", max(clean$Date))

# ---- Keep only locations with enough data ----
# At least 5 observations per parameter per location
location_counts <- clean %>%
  group_by(LocationId, Parameter) %>%
  summarise(n = n(), .groups = "drop") %>%
  filter(n >= 5) %>%
  group_by(LocationId) %>%
  summarise(n_params = n_distinct(Parameter)) %>%
  filter(n_params >= 3)  # at least 3 parameters measured

clean_filtered <- clean %>%
  filter(LocationId %in% location_counts$LocationId)

message("After location filter: ", 
        length(unique(clean_filtered$LocationId)), " locations, ",
        nrow(clean_filtered), " rows")

# ---- Save ----
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
write_csv(clean_filtered, "data/processed/lakewatchers_clean.csv")
message("Saved to data/processed/lakewatchers_clean.csv")