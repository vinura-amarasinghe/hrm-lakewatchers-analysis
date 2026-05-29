# 03_analysis.R
# Summary statistics and seasonal analysis
# Run after 02_clean_data.R

library(dplyr)
library(readr)
library(lubridate)
library(ggplot2)

# ---- Load ----
df <- read_csv("data/processed/lakewatchers_clean.csv", show_col_types = FALSE)

# ---- Seasonal summary by parameter ----
seasonal_summary <- df %>%
  group_by(Year, Season, Parameter) %>%
  summarise(
    n        = n(),
    mean_val = mean(ResultValue, na.rm = TRUE),
    median_val = median(ResultValue, na.rm = TRUE),
    sd_val   = sd(ResultValue, na.rm = TRUE),
    .groups  = "drop"
  ) %>%
  filter(Season != "Winter")  # very few winter obs

print(seasonal_summary, n = 30)

# ---- Guideline exceedances ----
# Health Canada: E. coli > 200 cfu/100mL = impaired recreation
# CCME: TP > 0.01 mg/L = eutrophication risk (sensitive lakes)
# DO < 6.5 mg/L = stress for cold-water fish

exceedances <- df %>%
  mutate(exceeds = case_when(
    Parameter == "Ecoli_cfu"  & ResultValue > 200   ~ "E.coli > 200 cfu/100mL",
    Parameter == "TP_mgL"     & ResultValue > 0.01  ~ "TP > 0.01 mg/L",
    Parameter == "DO_mgL"     & ResultValue < 6.5   ~ "DO < 6.5 mg/L",
    TRUE ~ NA_character_
  )) %>%
  filter(!is.na(exceeds)) %>%
  group_by(Parameter, exceeds, Year, Season) %>%
  summarise(n_exceed = n(), .groups = "drop")

print(exceedances)

# ---- Plot 1: Temperature by season and year ----
dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

temp_data <- df %>% filter(Parameter == "Temp_C", Season != "Winter")

p1 <- ggplot(temp_data, aes(x = factor(Year), y = ResultValue, fill = Season)) +
  geom_boxplot(outlier.size = 0.5, alpha = 0.8) +
  scale_fill_manual(values = c("Spring" = "#74c476", 
                                "Summer" = "#fd8d3c", 
                                "Fall"   = "#9ecae1")) +
  labs(
    title    = "Water Temperature by Season and Year",
    subtitle = "HRM LakeWatchers dataset, 2022–2024",
    x        = "Year",
    y        = "Temperature (°C)",
    fill     = "Season",
    caption  = "Source: HRM LakeWatchers, DataStream DOI: 10.25976/85pw-zj92"
  ) +
  theme_minimal(base_size = 13)

ggsave("outputs/figures/01_temperature_seasonal.png", p1, 
       width = 8, height = 5, dpi = 150)
message("Saved 01_temperature_seasonal.png")

# ---- Plot 2: Dissolved oxygen by season ----
do_data <- df %>% filter(Parameter == "DO_mgL", Season != "Winter")

p2 <- ggplot(do_data, aes(x = factor(Year), y = ResultValue, fill = Season)) +
  geom_boxplot(outlier.size = 0.5, alpha = 0.8) +
  geom_hline(yintercept = 6.5, linetype = "dashed", colour = "red", linewidth = 0.7) +
  annotate("text", x = 0.6, y = 6.8, label = "6.5 mg/L threshold", 
           colour = "red", size = 3.5, hjust = 0) +
  scale_fill_manual(values = c("Spring" = "#74c476", 
                                "Summer" = "#fd8d3c", 
                                "Fall"   = "#9ecae1")) +
  labs(
    title    = "Dissolved Oxygen by Season and Year",
    subtitle = "HRM LakeWatchers dataset, 2022–2024",
    x        = "Year",
    y        = "Dissolved Oxygen (mg/L)",
    fill     = "Season",
    caption  = "Source: HRM LakeWatchers, DataStream DOI: 10.25976/85pw-zj92"
  ) +
  theme_minimal(base_size = 13)

ggsave("outputs/figures/02_dissolved_oxygen_seasonal.png", p2,
       width = 8, height = 5, dpi = 150)
message("Saved 02_dissolved_oxygen_seasonal.png")

# ---- Plot 3: Total Phosphorus ----
tp_data <- df %>% filter(Parameter == "TP_mgL", Season != "Winter")

p3 <- ggplot(tp_data, aes(x = factor(Year), y = ResultValue, fill = Season)) +
  geom_boxplot(outlier.size = 0.5, alpha = 0.8) +
  geom_hline(yintercept = 0.01, linetype = "dashed", colour = "red", linewidth = 0.7) +
  annotate("text", x = 0.6, y = 0.0115, label = "0.01 mg/L (CCME sensitive lakes)",
           colour = "red", size = 3.5, hjust = 0) +
  scale_fill_manual(values = c("Spring" = "#74c476",
                                "Summer" = "#fd8d3c",
                                "Fall"   = "#9ecae1")) +
  scale_y_log10() +
  labs(
    title    = "Total Phosphorus by Season and Year (log scale)",
    subtitle = "HRM LakeWatchers dataset, 2022–2024",
    x        = "Year",
    y        = "Total Phosphorus (mg/L, log scale)",
    fill     = "Season",
    caption  = "Source: HRM LakeWatchers, DataStream DOI: 10.25976/85pw-zj92"
  ) +
  theme_minimal(base_size = 13)

ggsave("outputs/figures/03_total_phosphorus_seasonal.png", p3,
       width = 8, height = 5, dpi = 150)
message("Saved 03_total_phosphorus_seasonal.png")

message("\nAll done. Check outputs/figures/ for plots.")