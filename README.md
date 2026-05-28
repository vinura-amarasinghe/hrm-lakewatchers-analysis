# HRM LakeWatchers: Trends in Urban Lake Water Quality

> Multi-year analysis of water quality across Halifax Regional Municipality lakes
> using the open DataStream HRM LakeWatchers dataset.

**Author:** Vinura Jayowin Amarasinghe
**Status:** In progress
**Report:** *Will be published to GitHub Pages once analysis is complete.*

---

## The question

How have key water quality indicators — temperature, dissolved oxygen,
total phosphorus, and chlorophyll-a — varied across HRM lakes in recent
years, and are there detectable trends that align with known urban
pressures or climate signals?

## Why it matters

HRM has issued multiple blue-green algae advisories at supervised lake
beaches in recent summers. Urban lakes in the municipality are subject to
stormwater runoff, road-salt loading, and warming summer temperatures —
all drivers of eutrophication. Open monitoring data lets us examine the
trends behind the headlines.

## Data

- **Source:** Halifax Regional Municipality (2025). *HRM LakeWatchers*
  (dataset). 2.0.0. DataStream. https://doi.org/10.25976/85pw-zj92
- **Access:** Pulled via the [DataStream public API](https://github.com/datastreamapp/api-docs)
  using the [`datastreamr`](https://github.com/datastreamapp/datastreamr)
  R package.
- **Coverage:** Multiple HRM lakes, multi-year time series. See
  `R/01_fetch_data.R` for the exact query.

## Methods

- Data pulled from the DataStream API and cached locally (`data/raw/`).
- Cleaned and reshaped using `dplyr`, `tidyr`, and `lubridate`.
- Trend analysis using Mann-Kendall tests (non-parametric, robust to
  non-normal water-quality distributions) via the `Kendall` package.
- Visualizations with `ggplot2`; maps with `sf` and `tmap`.
- Full report rendered with Quarto.

## Reproduce the analysis

```bash
# Clone the repo
git clone https://github.com/vinura-amarasinghe/hrm-lakewatchers-analysis.git
cd hrm-lakewatchers-analysis
```

Then in R (open the `.Rproj` file in RStudio):

```r
# Restore exact package versions
renv::restore()

# Pull data (requires DATASTREAM_API_KEY in .Renviron)
source("R/01_fetch_data.R")
source("R/02_clean_data.R")
source("R/03_analysis.R")

# Render the report
quarto::quarto_render("index.qmd")
```

You'll need a free DataStream API key — request one at
https://datastream.org. Save it as `DATASTREAM_API_KEY` in your
`.Renviron` file.

## Key findings

*To be added once analysis is complete.*

## Tools

R · tidyverse · datastreamr · Kendall · sf · tmap · Quarto · renv

## License

Code: MIT (see `LICENSE`).
Data: Halifax Regional Municipality Open Data License (see DataStream DOI).