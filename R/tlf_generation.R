# tlf_generation.R
# Generate regulatory-style Tables, Listings, Figures (TLFs)
# Author: Senior Clinical PK/PD R Developer

library(tidyverse)
library(data.table)
library(ggplot2)
library(gt)
library(survival)

exposure <- fread("data_adam/exposure_full.csv")
dm <- fread("data_adam/dm_clean.csv")
logit_summary <- fread("data_adam/logit_summary.csv")
cox_summary <- fread("data_adam/cox_summary.csv")

# Concentration-time plot
# ...existing code...

# Boxplot of Cmax by dose
exposure_dm <- left_join(exposure, dm, by = "USUBJID")
ggplot(exposure_dm, aes(x = factor(DOSE), y = Cmax)) +
  geom_boxplot() +
  labs(title = "Cmax by Dose Group", x = "Dose", y = "Cmax")
ggsave("report/boxplot_cmax.png")

# Exposure-response scatter plot
ggplot(exposure_dm, aes(x = Cmax, y = RESPONSE)) +
  geom_jitter(width = 0.1, height = 0.05) +
  labs(title = "Exposure-Response Scatter Plot", x = "Cmax", y = "Response")
ggsave("report/exposure_response_scatter.png")

# Kaplan-Meier curve by exposure quartile
exposure_dm <- exposure_dm %>% mutate(EXP_Q = ntile(AUC, 4))
km_fit <- survfit(Surv(SURV_TIME, STATUS) ~ EXP_Q, data = exposure_dm)
# If ggsurvplot is not available, use base plot
png("report/km_curve.png")
plot(km_fit, xlab = "Time", ylab = "Survival Probability", main = "Kaplan-Meier by Exposure Quartile", col = 1:4)
legend("topright", legend = paste("Q", 1:4), col = 1:4, lty = 1)
dev.off()

# Forest plot of covariates
# ...existing code...

# Table: Logistic regression summary
gt(logit_summary) %>%
  gtsave("report/logit_table.html")

# Table: Cox model summary
gt(cox_summary) %>%
  gtsave("report/cox_table.html")

# End of script
