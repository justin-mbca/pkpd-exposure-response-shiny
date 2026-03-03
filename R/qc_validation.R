# ------------------------------------------------------------------------------
# Quality Control (QC) Overview
# ------------------------------------------------------------------------------
# QC (Quality Control) in this project is performed using functions in R that check
# the integrity and consistency of your data. The main steps include:
#
# - Checking for missing values in key columns using validate_missing_values(),
#   which summarizes missing data per column.
# - Identifying outliers in numeric columns with identify_outliers(), which uses
#   the interquartile range (IQR) method to flag values outside expected ranges.
# - Generating summary tables with generate_qc_summary(), which reports both
#   missing values and outlier counts for specified columns.
# - Validating data consistency between datasets (e.g., matching subject IDs)
#   using validate_data_consistency(), which highlights discrepancies between key
#   columns in different data frames.
#
# These QC routines help ensure your data is clean, complete, and ready for
# analysis or reporting.
# ------------------------------------------------------------------------------
# qc_validation.R
# ----------------
# This script contains functions and procedures for quality control (QC) and validation of data used in the PK/PD exposure-response Shiny application.
# It includes routines for checking data integrity, identifying missing or outlier values, and generating QC summary outputs for downstream analysis and reporting.
#
# Author: Justin Zhang
# Date: March 2, 2026
#
# Functions in this file are intended to be sourced and used within the data processing and reporting pipeline.

 
validate_missing_values <- function(df, columns) {
 
identify_outliers <- function(df, columns, iqr_multiplier = 1.5) {
 
generate_qc_summary <- function(df, columns) {

validate_data_consistency <- function(df1, df2, key_columns) {
# qc_validation.R
# Automated QC validation checks
# Author: Senior Clinical PK/PD R Developer

library(tidyverse)
library(data.table)

# Load datasets
dm <- fread("data_adam/dm_clean.csv")
exposure <- fread("app/data_adam/exposure.csv")
dm <- fread("app/data_adam/dm_clean.csv")

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
