# derivations_exposure.R
# Derive exposure metrics (Cmax, AUC)
# Author: Senior Clinical PK/PD R Developer

library(tidyverse)
library(data.table)

pc <- fread("data_adam/pc_clean.csv")

# Derive Cmax and AUC per subject
exposure <- pc %>%
  group_by(USUBJID) %>%
  summarise(
    Cmax = max(CONC, na.rm = TRUE),
    AUC = sum(diff(TIME) * (head(CONC, -1) + tail(CONC, -1))/2)
  )

fwrite(exposure, "data_adam/exposure.csv")

# End of script
