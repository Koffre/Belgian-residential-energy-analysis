# ==============================================================================
# Script: 03_modeling.R
# Project: Belgian Residential Energy Consumption Analysis
# Purpose: Forward selection, log transformation, residual diagnostics,
#          and hypothesis testing with Holm-Bonferroni correction.
# ==============================================================================

library(car)      # For Generalized Variance Inflation Factor (GVIF)
library(multcomp) # For custom linear hypothesis contrasts (glht)

# Ensure output directory for diagnostic plots exists
if (!dir.exists("plots")) dir.create("plots")

# ── 1. LOAD PROCESSED DATA ───────────────────────────────────────────────────

data_model <- readRDS("data/processed/clean_energy_data.rds")


# ── 2. FORWARD SELECTION - LOG SCALE ──────────────────────────────────────────

# Stepwise forward model building on log(annual_kwh)
m_log1 <- lm(log(annual_kwh) ~ sq_meters, data = data_model)
m_log2 <- lm(log(annual_kwh) ~ sq_meters + epc_label, data = data_model)
m_log3 <- lm(log(annual_kwh) ~ sq_meters + epc_label + occupancy_count, data = data_model)
m_log4 <- lm(log(annual_kwh) ~ sq_meters + epc_label + occupancy_count + income_euro, data = data_model)
m_log5 <- lm(log(annual_kwh) ~ sq_meters + epc_label + occupancy_count + epc_label:occupancy_count, data = data_model)

# Model Comparison Table
rmse <- function(m) round(sqrt(mean(m$residuals^2)), 4)

model_comp <- data.frame(
  Model  = c("m_log1", "m_log2", "m_log3 (Optimal)", "m_log4", "m_log5"),
  Terms  = c("sq_meters", "+ epc_label", "+ occupancy_count", "+ income_euro", "+ epc:occupancy"),
  AIC    = round(AIC(m_log1, m_log2, m_log3, m_log4, m_log5)$AIC, 2),
  R2     = round(c(summary(m_log1)$r.squared, summary(m_log2)$r.squared, summary(m_log3)$r.squared, summary(m_log4)$r.squared, summary(m_log5)$r.squared), 4),
  Adj_R2 = round(c(summary(m_log1)$adj.r.squared, summary(m_log2)$adj.r.squared, summary(m_log3)$adj.r.squared, summary(m_log4)$adj.r.squared, summary(m_log5)$adj.r.squared), 4),
  RMSE   = c(rmse(m_log1), rmse(m_log2), rmse(m_log3), rmse(m_log4), rmse(m_log5))
)

cat("--- Model Selection & Stepwise Comparison ---\n")
print(model_comp)


# ── 3. OPTIMAL MODEL SUMMARY & DIAGNOSTICS ───────────────────────────────────

cat("\n--- Optimal Model Summary (m_log3) ---\n")
print(summary(m_log3))

# Multicollinearity check (GVIF)
cat("\n--- Multicollinearity Assessment (GVIF) ---\n")
print(vif(m_log3))

# Save residual diagnostic plots
png("plots/model_diagnostics.png", width = 900, height = 450)
par(mfrow = c(1, 2))

# Normal Q-Q Plot
qqnorm(m_log3$residuals, main = "Normal Q-Q Plot (Log Model)", pch = 16, col = adjustcolor("steelblue", 0.4))
qqline(m_log3$residuals, col = "darkred", lwd = 1.5)

# Residuals vs Fitted Values
plot(m_log3$fitted.values, m_log3$residuals,
     main = "Residuals vs Fitted Values",
     xlab = "Fitted Values", ylab = "Residuals",
     pch = 16, col = adjustcolor("steelblue", 0.4))
abline(h = 0, col = "darkred", lwd = 1.5)
dev.off()


# ── 4. RESEARCH HYPOTHESIS TESTING (HOLM-BONFERRONI) ──────────────────────────

# Q2: EPC Label A vs Average of Labels B-F
# Contrast vector order: (Intercept), sq_meters, epc_labelB..F, occupancy_count
contrast_Q2 <- rbind("EPC A vs Mean(B-F)" = c(0, 0, -1/5, -1/5, -1/5, -1/5, -1/5, 0))
test_Q2 <- glht(m_log3, linfct = contrast_Q2)

# Q3: Income Direct Effect (tested in m_log4 where income is added)
contrast_Q3 <- rbind("Income Direct Effect" = c(0, 0, 0, 0, 0, 0, 0, 0, 1))
test_Q3 <- glht(m_log4, linfct = contrast_Q3)

# Extract raw p-values
p_raw <- c(
  Q2 = summary(test_Q2)$test$pvalues[1],
  Q3 = summary(test_Q3)$test$pvalues[1]
)

# Apply Holm-Bonferroni correction
p_adjusted <- p.adjust(p_raw, method = "holm")

results_holm <- data.frame(
  Hypothesis = c("Q2: EPC A vs Average(B-F)", "Q3: Income Direct Effect"),
  Raw_p_value = round(p_raw, 6),
  Holm_Adj_p_value = round(p_adjusted, 6),
  Significant_alpha_0.05 = ifelse(p_adjusted < 0.05, "Yes", "No")
)

cat("\n--- Multiple Testing Adjustments (Holm-Bonferroni) ---\n")
print(results_holm)

# Q2 Effect Back-Transformation (% difference)
est_Q2 <- confint(test_Q2)$confint[1, "Estimate"]
pct_diff_Q2 <- round((exp(est_Q2) - 1) * 100, 2)
cat("\nQ2 Percentage Difference (EPC Label A vs B-F Avg):", pct_diff_Q2, "%\n")

cat("\n✅ Modeling script executed successfully. Diagnostic plots saved in 'plots/'.\n")

