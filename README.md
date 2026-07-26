# ⚡ Determinants of Residential Energy Consumption in Belgium

[![R](https://img.shields.io/badge/Language-R-blue.svg)](https://www.r-project.org/)
[![License-MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Project-Academic%20(UHasselt)-orange.svg)]()

An empirical statistical analysis investigating the structural, socio-economic, and efficiency drivers of annual residential electricity consumption across 2,500 Belgian households.

---

## 🎯 Executive Summary & Key Questions

This study evaluates key determinants of household energy demand to answer four core research questions:
- **Q1 (Model Selection):** What is the optimal linear predictive model for residential electricity demand?
- **Q2 (EPC Efficiency Gap):** How significantly does energy consumption differ between Energy Performance Certificate (EPC) Label A and Labels B–F?
- **Q3 (Income Effect):** Does household income exert a direct effect on consumption when structural variables are controlled?
- **Q4 (Interaction Effects):** Does the efficiency impact of EPC labels vary depending on household occupancy?

---

## 📊 Key Findings

- **Optimal Model ($R^2 = 0.891$, $Adj. R^2 = 0.891$, $\text{AIC} = -3349.3$):** Log-transformed annual kWh is best predicted by living space ($m^2$), EPC label, and occupancy count.
- **Occupancy Dominance:** Each additional resident increases electricity consumption by **+16.3%** ($p < 0.001$).
- **EPC Label Impact:** EPC Label A homes consume on average **21.6% less** than the B–F average ($p_{adj} < 0.001$).
- **Income Absorption:** Income shows no direct impact ($p_{adj} = 0.534$). Its effect is absorbed indirectly through living space ($r = 0.72$).
- **No EPC × Occupancy Interaction:** Efficiency gains from higher EPC ratings remain consistent regardless of household size.

---

## 🔬 Statistical Methodology

1. **Data Preprocessing & Outlier Detection:**
   - Evaluated $n = 2,500$ cross-sectional households.
   - Applied $3.0 \times \text{IQR}$ rule to remove 5 extreme data-entry errors (>2,000,000 kWh/year). Final analytical sample: $n = 2,477$.
   - Evaluated collinearity: Excluded `building_era` due to perfect collinearity with `epc_label` ($\chi^2 p < 0.001$) and `dist_to_brussels` ($r = 0.00$).

2. **Model Diagnostics & Transformations:**
   - Detected severe heteroscedasticity and non-normality in raw kWh scale.
   - Applied **log transformation** ($\log(\text{annual\_kwh})$), resolving heteroscedasticity and yielding normal residuals (Kolmogorov-Smirnov test $p = 0.94$).
   - Checked multicollinearity via Generalized Variance Inflation Factors (GVIF < 2.4).

3. **Multiple Testing Correction:**
   - Applied the **Holm-Bonferroni stepwise procedure** to control the Familywise Error Rate (FWER) at $\alpha = 0.05$ across pre-planned hypothesis tests.

---

## 📐 Final Model Formula

```math
$$
\log(\text{annual\_kwh}) = 7.211 + 0.004 \cdot \text{sq\_meters} + \sum_{k=B}^{F} \beta_k \cdot I[\text{epc} = k] + 0.151 \cdot \text{occupancy\_count}
$$
```
---

## 🛠️ Stack & Tools

- **Language:** R
- **Key Packages:** `car` (GVIF calculation), `ggplot2` (visualization), `stats`
- **Methodologies:** Linear Regression, Log Transformations, Variable Selection (AIC/Forward), Residual Diagnostics, Multiple Hypothesis Testing (Holm-Bonferroni).

---

## 👥 Authors & Academic Context

Developed as part of the **Project Learning from Data** course at **Hasselt University (UHasselt)**.  
**Contributors:** Alejandrina Jimenez Guzman, Joffre Sanchez Ceron, Mohammed Tahri, Sulaiman Mirzai, Wanna Tafal Husna, Zunaira Zafar.
