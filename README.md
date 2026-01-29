# YRBSS Analysis: Social Media & Adolescent Risk Behavior

### Does increased or inappropriate use of Social Media influence the behavior of teens?

This project analyzes data from the **2023 Youth Risk Behavior Surveillance System (YRBSS)** to investigate correlations between social media frequency and various high-risk behaviors among adolescents, including substance abuse, mental health struggles, and sexual risk behaviors.

**Authors:** Michael Perez, Harold Gonzalez, Brian Bellamy, Seth Gallucci

## Executive Summary
Using weighted survey data from over **1,400 adolescents**, we performed a series of logistic and linear regressions. Our analysis reveals statistically significant associations between high-frequency social media use and several risk factors, independent of other variables.

**Key Findings:**
* **Substance Use:** Strong positive correlation found with Marijuana use ($\beta=0.157$) and Vaping ($\beta=0.137$).
* **Mental Health:** Students reporting "Not Good" mental health showed a distinct correlation with higher social media usage ($\beta=0.121$).
* **Sexual Risk:** Social media use acts as a catalyst for sexual risk behaviors, particularly in older teens (15+), where the risk curve steepens significantly compared to younger cohorts.
* **Escapism:** A correlation was found between the frequency of adult insults in the household and social media use, suggesting a cycle of escapism.

## 🛠 Methodology & Tech Stack

**Tools:** `R`, `survey`, `haven`, `ggplot2`

### Complex Survey Design
The YRBSS data uses a complex sampling method requiring specific statistical handling to be representative. We utilized **Stratified Sampling** techniques to account for race/ethnicity concentration and urbanicity.

To ensure accurate population estimates, we used the `survey` package in R to apply weighting:

```r
# Loading the data and setting the survey design
library(survey)
library(haven)

yrbs_data <- read_sav("path/to/data.sav")

# Defining the survey design to handle PSU, Strata, and Weights
yrbsdes <- svydesign(
    id = ~PSU, 
    weight = ~WEIGHT, 
    strata = ~STRATUM, 
    data = yrbs_data, 
    nest = TRUE
)
