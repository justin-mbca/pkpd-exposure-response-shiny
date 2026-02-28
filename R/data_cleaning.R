# data_cleaning.R
# Clean and QC raw/simulated data
# Author: Senior Clinical PK/PD R Developer

library(tidyverse)
library(data.table)

# Load SDTM datasets
dm <- fread("data_sdtm/dm.csv")
ex <- fread("data_sdtm/ex.csv")
pc <- fread("data_sdtm/pc.csv")
lb <- fread("data_sdtm/lb.csv")

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
fwrite(dm, "data_adam/dm_clean.csv")
fwrite(ex, "data_adam/ex_clean.csv")
fwrite(pc, "data_adam/pc_clean.csv")
fwrite(lb, "data_adam/lb_clean.csv")

# End of script
