# Clinical PK/PD Exposure-Response Analysis Demo

## Overview
This project demonstrates a sponsor-grade clinical PK/PD analysis workflow, including simulation, SDTM/ADaM dataset generation, exposure-response modeling, regulatory-style TLFs, automated QC, and an interactive Shiny dashboard.

## Objectives
- Simulate clinical trial PK concentration-time data
- Generate SDTM-like datasets (DM, EX, PC, LB)
- Create ADaM-like derived dataset for exposure metrics
- Perform exposure-response analysis (logistic regression + Cox model)
- Generate regulatory-style Tables, Listings, and Figures (TLFs)
- Include automated QC validation checks
- Build an interactive Shiny dashboard for visualization

## Project Structure
```
/data_raw         # Raw or source data (if any)
/data_sdtm        # SDTM-like datasets (DM, EX, PC, LB)
/data_adam        # ADaM-like derived datasets (exposure, cleaned)
/R                # Modular R scripts for each workflow step
/app              # Shiny dashboard
/report           # Quarto analysis report and outputs
README.md         # Project documentation
```

## Key Scripts
- R/data_simulation.R: Simulate trial data and generate SDTM datasets
- R/data_cleaning.R: Clean and QC data
- R/derivations_exposure.R: Derive exposure metrics (Cmax, AUC)
- R/modeling_exposure_response.R: Exposure-response modeling
- R/tlf_generation.R: Generate TLFs
- R/qc_validation.R: Automated QC checks
- app/app.R: Shiny dashboard
- report/analysis_report.qmd: Quarto report

## How to Run
1. Clone the repository
2. Open in RStudio or VS Code
3. Run scripts in R/ sequentially, or knit report/analysis_report.qmd
4. Launch Shiny app with `shiny::runApp("app")`

## Reproducibility
- All simulations use `set.seed(2026)`
- Modular scripts and clear documentation

## Dependencies
- tidyverse
- data.table
- ggplot2
- survival
- broom
- gt or flextable
- shiny
- quarto or rmarkdown

## License
MIT
