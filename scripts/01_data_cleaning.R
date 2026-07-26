# ==============================================================================
# Script: 01_data_cleaning.R
# Project: Belgian Residential Energy Consumption Analysis
# Purpose: Preprocessing, NA handling, outlier removal, and saving clean dataset.
# ==============================================================================

# ── 1. LOAD RAW DATA ──────────────────────────────────────────────────────────

# Path to the raw dataset (Ensure the file is saved in data/raw/)
raw_data_path <- "data/raw/belgian_energy_consumption.txt"

data <- read.table(
  file      = raw_data_path,
  header    = TRUE,      # First row contains column names
  sep       = ";",       # Semicolon separator
  quote     = "\"",      # Double quotes
  row.names = 1          # First column is row index
)

cat("Initial dataset dimensions:", dim(data), "\n")


# ── 2. INITIAL CLEANING & FACTOR CONVERSION ───────────────────────────────────

# Remove group 1 specific rows (rows 1, 11, and 40)
data <- data[-c(1, 11, 40), ]

# Exclude variables rejected a priori (non-predictive/irrelevant)
data$roof_color    <- NULL
data$pet_ownership <- NULL

# Convert categorical variables to factor with explicit reference levels
data$epc_label <- factor(
  data$epc_label,
  levels = c("A", "B", "C", "D", "E", "F")  # EPC A as reference
)

data$building_era <- factor(
  data$building_era,
  levels = c("Pre-1970", "1970-2000", "Post-2000")
)


# ── 3. MISSING VALUES HANDLING ────────────────────────────────────────────────

# Check missing values count
na_count <- colSums(is.na(data))
cat("Missing values per column:\n")
print(na_count)

# Listwise deletion for incomplete rows (< 1% of total sample)
data_clean <- na.omit(data)
cat("Observations after listwise deletion:", nrow(data_clean), "\n")


# ── 4. OUTLIER REMOVAL (3.0 x IQR RULE) ──────────────────────────────────────

# Identify extreme physical errors (annual_kwh > 1,000,000 kWh)
# Five extreme rows identified as data-entry errors are removed.
# Retained high consumption homes (e.g., 16,395 and 17,197 kWh) as plausible.
data_analytical <- data_clean[data_clean$annual_kwh <= 1000000, ]

cat("Final analytical sample size (n):", nrow(data_analytical), "\n")


# ── 5. EXPORT PROCESSED DATASETS ──────────────────────────────────────────────

# Save final analytical dataset as RDS (R native, fast and preserves factors)
saveRDS(data_analytical, file = "data/processed/clean_energy_data.rds")

# Save CSV copy for transparency and non-R users
write.csv(data_analytical, file = "data/processed/clean_energy_data.csv", row.names = FALSE)

cat("✅ Data cleaning complete. Output saved to 'data/processed/'\n")