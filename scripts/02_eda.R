# ==============================================================================
# Script: 02_eda.R
# Project: Belgian Residential Energy Consumption Analysis
# Purpose: Exploratory Data Analysis (EDA), correlations, and chi-square tests.
# ==============================================================================

library(ggplot2)

# Ensure plot output directory exists
if (!dir.exists("plots")) dir.create("plots")

# ── 1. LOAD PROCESSED DATA ───────────────────────────────────────────────────

data_clean <- readRDS("data/processed/clean_energy_data.rds")


# ── 2. DESCRIPTIVE STATISTICS ─────────────────────────────────────────────────

# Numeric Variables Summary
numeric_vars <- data_clean[, c("annual_kwh", "sq_meters", "income_euro", 
                               "occupancy_count", "dist_to_brussels")]

summary_stats <- data.frame(
  Mean   = round(sapply(numeric_vars, mean), 2),
  SD     = round(sapply(numeric_vars, sd), 2),
  Median = round(sapply(numeric_vars, median), 2),
  IQR    = round(sapply(numeric_vars, IQR), 2),
  Min    = round(sapply(numeric_vars, min), 2),
  Max    = round(sapply(numeric_vars, max), 2)
)

cat("--- Summary Statistics for Continuous Variables ---\n")
print(summary_stats)


# ── 3. CORRELATION ANALYSIS ───────────────────────────────────────────────────

# Pearson correlation matrix
cor_matrix <- round(cor(numeric_vars, use = "complete.obs"), 2)

cat("\n--- Pearson Correlation Matrix ---\n")
print(cor_matrix)

# Save scatterplot matrix with correlations
png("plots/correlation_matrix.png", width = 800, height = 800)
pairs(
  data.frame(
    log_annual_kwh  = log(data_clean$annual_kwh),
    sq_meters       = data_clean$sq_meters,
    income_euro     = data_clean$income_euro,
    occupancy_count = data_clean$occupancy_count
  ),
  main = "Scatterplot Matrix - log(annual_kwh) vs Predictors",
  pch  = 16,
  col  = adjustcolor("steelblue", alpha.f = 0.3)
)
dev.off()


# ── 4. CATEGORICAL ASSOCIATION (CHI-SQUARE TEST) ─────────────────────────────

# Contingency table: building_era vs epc_label
cont_table <- table(data_clean$building_era, data_clean$epc_label)

cat("\n--- Contingency Table (Building Era vs EPC Label) ---\n")
print(cont_table)

# Chi-square test (evaluating perfect collinearity)
chi_test <- chisq.test(cont_table)

cat("\n--- Chi-Square Test Results ---\n")
print(chi_test)


# ── 5. EXPLORATORY PLOTS ──────────────────────────────────────────────────────

# Plot 1: EPC Label Distribution
p1 <- ggplot(data_clean, aes(x = epc_label, y = annual_kwh, fill = epc_label)) +
  geom_boxplot(outlier.color = "darkred", alpha = 0.7) +
  labs(
    title = "Annual Energy Consumption by EPC Label",
    x     = "EPC Label",
    y     = "Annual kWh"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("plots/consumption_by_epc.png", plot = p1, width = 7, height = 5)

# Plot 2: Income vs Living Area (Explaining income absorption)
p2 <- ggplot(data_clean, aes(x = income_euro, y = sq_meters)) +
  geom_point(color = "steelblue", alpha = 0.3, size = 1) +
  geom_smooth(method = "lm", color = "darkred", linewidth = 0.8) +
  labs(
    title = "Living Area vs Household Income (r = 0.72)",
    x     = "Household Income (€)",
    y     = "Living Area (m²)"
  ) +
  theme_minimal()

ggsave("plots/sqmeters_vs_income.png", plot = p2, width = 7, height = 5)

cat("\n✅ EDA script completed. Plots generated in 'plots/' directory.\n")

