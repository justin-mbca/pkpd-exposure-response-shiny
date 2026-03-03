# data_cleaning.R
# Clean and QC raw/simulated data
# Author: Senior Clinical PK/PD R Developer

# In production, these datasets should be thoroughly cleaned before analysis.
# See cleaning steps below for best practices and example code.

# --- Production Cleaning Best Practices ---
# For dm (Demographics):
#   - Remove duplicate subjects:
#       dm <- dm %>% distinct(SUBJID, .keep_all = TRUE)
#   - Standardize categorical variables:
#       dm <- dm %>% mutate(SEX = recode(SEX, "Male" = "M", "Female" = "F"))
#   - Filter to analysis population, check for missing/implausible values, ensure unique IDs.
# For ex (Exposure):
#   - Remove records with missing/zero dose:
#       ex <- ex %>% filter(!is.na(DOSE) & DOSE > 0)
#   - Standardize dose units:
#       ex <- ex %>% mutate(DOSE_UNIT = toupper(DOSE_UNIT))
#   - Remove duplicates, check dosing times, align with PK if needed.
# For pc (PK):
#   - Remove missing/negative concentrations:
#       pc <- pc %>% filter(!is.na(CONC) & CONC >= 0)
#   - Standardize units, remove duplicates:
#       pc <- pc %>% distinct(SUBJID, TIME, ANALYTE, .keep_all = TRUE)
#   - Flag/remove outliers, check timepoints.
#
# The following code currently only checks for missing values and flags outliers in labs.
# Extend as needed for full production cleaning.

library(tidyverse)
library(data.table)

# Load SDTM datasets
dm <- fread("app/data_sdtm/dm.csv")
ex <- fread("app/data_sdtm/ex.csv")
pc <- fread("app/data_sdtm/pc.csv")
lb <- fread("app/data_sdtm/lb.csv")

# Check for missing values
qc_missing <- function(df) {
  df %>% summarise_all(~sum(is.na(.)))
}

missing_dm <- qc_missing(dm)
missing_ex <- qc_missing(ex)
missing_pc <- qc_missing(pc)
missing_lb <- qc_missing(lb)

# Flag outliers (example for LAB)
lb <- lb %>% mutate(OUTLIER = abs(LAB - mean(LAB)) > 3 * sd(LAB))

# Save cleaned datasets
fwrite(ex, "data_adam/ex_clean.csv")
fwrite(pc, "data_adam/pc_clean.csv")
fwrite(lb, "data_adam/lb_clean.csv")
fwrite(dm, "app/data_adam/dm_clean.csv")
fwrite(ex, "app/data_adam/ex_clean.csv")
fwrite(pc, "app/data_adam/pc_clean.csv")
fwrite(lb, "app/data_adam/lb_clean.csv")

# End of script
