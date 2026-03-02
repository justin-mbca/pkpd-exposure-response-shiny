# tlf_generation.R
# Generate regulatory-style Tables, Listings, Figures (TLFs)
# Author: Senior Clinical PK/PD R Developer

library(tidyverse)
library(data.table)
library(ggplot2)
library(gt)
library(survival)

# Safety analysis
ae <- fread("app/data_sdtm/ae.csv")

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
# Save a larger PNG (e.g., 1200x900 pixels)
png("report/km_curve.png", width = 1200, height = 900)
par(mar = c(5.1, 6, 4.1, 2.1)) # Increase left margin for Y label
plot(km_fit,
  xlab = "Time",
  ylab = "Survival Probability",
  main = "Kaplan-Meier by Exposure Quartile",
  col = 1:4,
  cex.lab = 2.2,    # Axis label size
  cex.axis = 1.8,   # Axis tick size
  cex.main = 2.5,   # Title size
  lwd = 3           # Line width
)
legend("topright",
    legend = paste("Exposure Quartile Q", 1:4),
    col = 1:4,
    lty = 1,
    cex = 2.0       # Legend font size
)
dev.off()

# Forest plot of covariates
# ...existing code...

# Safety TLF: AE rate by dose group
ae_rate_dose <- ae %>% group_by(DOSE) %>% summarise(AE_rate = mean(AE_YN))
ggplot(ae_rate_dose, aes(x = factor(DOSE), y = AE_rate)) +
  geom_bar(stat = "identity", fill = "#e41a1c") +
  labs(title = "Adverse Event Rate by Dose Group", x = "Dose", y = "AE Rate")
ggsave("report/ae_rate_dose.png")

# Safety TLF: AE rate by exposure quartile
exposure_ae <- left_join(exposure, ae, by = "USUBJID") %>% mutate(EXP_Q = ntile(AUC, 4))
ae_rate_expq <- exposure_ae %>% group_by(EXP_Q) %>% summarise(AE_rate = mean(AE_YN))
ggplot(ae_rate_expq, aes(x = factor(EXP_Q), y = AE_rate)) +
  geom_bar(stat = "identity", fill = "#377eb8") +
  labs(title = "Adverse Event Rate by Exposure Quartile", x = "Exposure Quartile", y = "AE Rate")
ggsave("report/ae_rate_expq.png")

# Table: Logistic regression summary
gt(logit_summary) %>%
  gtsave("report/logit_table.html")

# Table: Cox model summary
gt(cox_summary) %>%
  gtsave("report/cox_table.html")

# End of script
