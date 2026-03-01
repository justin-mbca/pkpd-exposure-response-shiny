# data_simulation.R
# Simulate clinical trial PK concentration-time data
# Author: Senior Clinical PK/PD R Developer
#
# Generates subject-level DM, EX, PC, LB datasets

library(tidyverse)
library(data.table)
set.seed(2026)

# Parameters
n_subj <- 200
dose_levels <- c(50, 100, 200)
time_points <- c(0, 0.5, 1, 2, 4, 8, 12, 24)

# Simulate Demographics (DM)
dm <- tibble(
  USUBJID = sprintf("SUBJ%03d", 1:n_subj),
  AGE = sample(18:80, n_subj, TRUE),
  SEX = sample(c("M", "F"), n_subj, TRUE),
  RACE = sample(c("White", "Black", "Asian", "Other"), n_subj, TRUE),
  DOSE = sample(dose_levels, n_subj, TRUE)
)

# Simulate Exposure (EX)
ex <- dm %>% select(USUBJID, DOSE) %>% mutate(EXSTDTC = "2026-01-01")

# Simulate PK Concentrations (PC)
pc <- dm %>%
  rowwise() %>%
  do({
    tibble(
      USUBJID = .$USUBJID,
      DOSE = .$DOSE,
      TIME = time_points,
      CONC = .$DOSE * exp(-0.2 * time_points) * rlnorm(length(time_points), 0, 0.1)
    )
  }) %>%
  ungroup()

# Simulate Lab (LB)
lb <- dm %>% select(USUBJID) %>% mutate(LAB = rnorm(n_subj, 100, 15))

# Simulate Adverse Events (AE)
ae_types <- c("Headache", "Nausea", "Fatigue", "Rash", "None")
ae <- dm %>% select(USUBJID, DOSE) %>%
  mutate(
    AE = sample(ae_types, n_subj, TRUE, prob = c(0.15, 0.1, 0.1, 0.05, 0.6)),
    AE_SEV = sample(c("Mild", "Moderate", "Severe", NA), n_subj, TRUE, prob = c(0.5, 0.3, 0.15, 0.05)),
    AE_YN = ifelse(AE == "None", 0, 1)
  )

# Save datasets
fwrite(dm, "data_sdtm/dm.csv")
fwrite(ex, "data_sdtm/ex.csv")
fwrite(pc, "data_sdtm/pc.csv")
fwrite(lb, "data_sdtm/lb.csv")
fwrite(ae, "data_sdtm/ae.csv")

# End of script
