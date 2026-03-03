
# modeling_exposure_response.R
# Exposure-response modeling (logistic regression, Cox model)
# Author: Senior Clinical PK/PD R Developer
#
# Documentation:
# - exposure.csv: This file contains per-subject Cmax (maximum observed concentration) and AUC (area under the concentration-time curve),
#   derived from pc_clean.csv using the linear trapezoidal rule (see derivations_exposure.R for details).
#   Columns: USUBJID, Cmax, AUC.
# - This script reads exposure.csv and dm_clean.csv, simulates response and survival data, and fits:
#     * Logistic regression: RESPONSE ~ Cmax + AGE + SEX
#     * Cox proportional hazards model: Surv(SURV_TIME, STATUS) ~ AUC + AGE + SEX
# - Model summaries are saved as logit_summary.csv and cox_summary.csv in app/data_adam/.
# - The exposure_full.csv file contains exposure metrics with simulated response and survival outcomes for further analysis and TLFs.

library(tidyverse)
library(data.table)
library(survival)
library(broom)

dm <- fread("data_adam/dm_clean.csv")
exposure <- fread("app/data_adam/exposure.csv")
dm <- fread("app/data_adam/dm_clean.csv")

# Simulate binary response and survival time
set.seed(2026)
exposure <- exposure %>%
  mutate(
    RESPONSE = rbinom(n(), 1, plogis(0.01 * Cmax - 1)),
    SURV_TIME = rexp(n(), rate = 0.01 * AUC),
    STATUS = rbinom(n(), 1, 0.8)
  )

# Logistic regression: Response ~ Cmax + covariates
logit_mod <- glm(RESPONSE ~ Cmax + AGE + SEX, data = left_join(exposure, dm, by = "USUBJID"), family = binomial)
logit_summary <- tidy(logit_mod)

# Cox model: Survival ~ AUC + covariates
cox_mod <- coxph(Surv(SURV_TIME, STATUS) ~ AUC + AGE + SEX, data = left_join(exposure, dm, by = "USUBJID"))
cox_summary <- tidy(cox_mod)

fwrite(cox_summary, "data_adam/cox_summary.csv")
fwrite(logit_summary, "app/data_adam/logit_summary.csv")
fwrite(cox_summary, "app/data_adam/cox_summary.csv")

# Save exposure with response and survival info for TLFs
fwrite(exposure, "app/data_adam/exposure_full.csv")

# End of script
