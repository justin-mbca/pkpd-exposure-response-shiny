
# derivations_exposure.R
# Derive exposure metrics (Cmax, AUC)
# Author: Senior Clinical PK/PD R Developer
#
# Documentation:
# - pc_clean.csv: This is the cleaned pharmacokinetics (PK) data file, generated from the raw SDTM pc.csv file.
#   It should contain at least subject ID (USUBJID), time (TIME), and concentration (CONC) columns.
#   In this workflow, pc_clean.csv is currently a direct copy of pc.csv, but in production it should be cleaned for missing/negative concentrations, duplicates, and standardized units.
#
# - Cmax calculation: For each subject, Cmax is the maximum observed concentration.
#     Cmax = max(CONC, na.rm = TRUE)
#
# - AUC calculation: For each subject, AUC (area under the concentration-time curve) is calculated using the linear trapezoidal rule:
#     AUC = sum(diff(TIME) * (head(CONC, -1) + tail(CONC, -1))/2)
#   This computes the sum of the areas of trapezoids formed by consecutive time and concentration points.
#
# - Output: exposure.csv contains Cmax and AUC for each subject, derived from pc_clean.csv.

library(tidyverse)
library(data.table)

pc <- fread("app/data_adam/pc_clean.csv")

# Derive Cmax and AUC per subject
exposure <- pc %>%
  group_by(USUBJID) %>%
  summarise(
    Cmax = max(CONC, na.rm = TRUE),
    AUC = sum(diff(TIME) * (head(CONC, -1) + tail(CONC, -1))/2)
  )

fwrite(exposure, "app/data_adam/exposure.csv")

# End of script
