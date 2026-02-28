# modeling_exposure_response.R
# Exposure-response modeling (logistic regression, Cox model)
# Author: Senior Clinical PK/PD R Developer

library(tidyverse)
library(data.table)
library(survival)
library(broom)

exposure <- fread("data_adam/exposure.csv")
dm <- fread("data_adam/dm_clean.csv")

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

fwrite(logit_summary, "data_adam/logit_summary.csv")
fwrite(cox_summary, "data_adam/cox_summary.csv")

# Save exposure with response and survival info for TLFs
fwrite(exposure, "data_adam/exposure_full.csv")

# End of script
