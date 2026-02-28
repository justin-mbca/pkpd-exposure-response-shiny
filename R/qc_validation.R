# qc_validation.R
# Automated QC validation checks
# Author: Senior Clinical PK/PD R Developer

library(tidyverse)
library(data.table)

# Load datasets
exposure <- fread("data_adam/exposure.csv")
dm <- fread("data_adam/dm_clean.csv")

# Check missing values
qc_missing <- function(df) {
  df %>% summarise_all(~sum(is.na(.)))
}
missing_exposure <- qc_missing(exposure)
missing_dm <- qc_missing(dm)

# Validate exposure derivations
qc_exposure <- exposure %>%
  filter(Cmax < 0 | AUC < 0)

# Compare summary stats across datasets
summary_exposure <- exposure %>% summarise(across(c(Cmax, AUC), list(mean = mean, sd = sd, min = min, max = max)))
summary_dm <- dm %>% summarise(across(c(AGE), list(mean = mean, sd = sd, min = min, max = max)))

# Flag outliers
outliers <- exposure %>% filter(Cmax > mean(Cmax) + 3 * sd(Cmax) | AUC > mean(AUC) + 3 * sd(AUC))

# Save QC results
fwrite(missing_exposure, "report/qc_missing_exposure.csv")
fwrite(missing_dm, "report/qc_missing_dm.csv")
fwrite(qc_exposure, "report/qc_exposure.csv")
fwrite(summary_exposure, "report/qc_summary_exposure.csv")
fwrite(summary_dm, "report/qc_summary_dm.csv")
fwrite(outliers, "report/qc_outliers.csv")

# End of script
