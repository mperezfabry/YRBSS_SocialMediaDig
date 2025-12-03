############################################################
# Load packages
############################################################

library(survey)
library(haven)
library(here)
library(ggplot2)

options(digits = 9)

############################################################
# Load data
############################################################

yrbs_data <- read_sav(here("2023 Data/yrbs2023.sav"))

############################################################
# Recode Social Media (Q80 / QN80) into 5-level numeric
############################################################
yrbs_data$q80_num <- case_when(
  yrbs_data$Q80 == 1             ~ 1,   # No social media
  yrbs_data$Q80 %in% 2:3         ~ 2,   # Light use (few times/month or once/week)
  yrbs_data$Q80 == 4             ~ 3,   # Moderate use (few times/week)
  yrbs_data$Q80 == 5             ~ 4,   # Daily use (once/day)
  yrbs_data$Q80 %in% 6:8         ~ 5    # Heavy use (several/day to >once/hour)
)


############################################################
# Recode Alcohol (Q42 / QN42) to binary (0/1)
############################################################

yrbs_data$Q42_any <- ifelse(yrbs_data$QN42 == 1, 0, 1)

############################################################
# Build survey design
############################################################

yrbsdes <- svydesign(
  id     = ~psu,
  strata = ~stratum,
  weights= ~weight,
  data   = yrbs_data,
  nest   = TRUE
)

############################################################
# SIMPLE LINEAR REGRESSION (Linear Probability Model)
############################################################

model_lpm <- svyglm(
  Q42_any ~ q80_num,
  design = yrbsdes,
  family = gaussian()     # classic linear regression
)

summary(model_lpm)

# Calculate prevalence
prev_5 <- svyby(
  ~Q42_any,
  ~Q80,
  yrbsdes,
  svymean,
  na.rm = TRUE
)

prev_5 <- as.data.frame(prev_5)
  
  ggplot(yrbs_data, aes(x = as.factor(Q80), y = as.factor(Q42_any))) +
    geom_bin2d() +
    scale_fill_viridis_c(
      name = "Count",
      trans = "log",        # <-- log transform
      breaks = c(1, 10, 100, 1000),  # <-- optional: nicer breaks
      labels = c("1", "10", "100", "1000")
    ) +
    labs(
      title = "Heatmap of Q80 vs Q42_any (Log Color Scale)",
      x = "Q80 Social Media (1–8)",
      y = "Q42 Any Alcohol Use"
    ) +
    theme_minimal(base_size = 14)

  library(ggplot2)
  library(dplyr)
  
  table(yrbs_data$Q80, useNA = "ifany")
  table(yrbs_data$Q42, useNA = "ifany")
  
  
  prop_by_q80_raw <- yrbs_data %>%
    group_by(Q80) %>%
    summarize(prop = mean(Q42_any, na.rm = TRUE))
  
  ggplot(prop_by_q80_raw, aes(x = as.factor(Q80), y = prop, fill = prop)) +
    geom_col() +
    scale_fill_viridis_c(name = "Proportion") +
    labs(
      title = "Proportion of Alcohol Use by Raw Q80 Category (1–8)",
      x = "Raw Q80 (Social Media 1–8)",
      y = "Proportion Drinking"
    ) +
    theme_minimal(base_size = 14)
  
  #Bucketing by age
  # Create age bucket variable

View(yrbs_data)  

yrbs_data$age_bucket <- dplyr::case_when(
  yrbs_data$Q1 == 1 ~ "≤12",
  yrbs_data$Q1 == 2 ~ "13",
  yrbs_data$Q1 == 3 ~ "14",
  yrbs_data$Q1 == 4 ~ "15",
  yrbs_data$Q1 == 5 ~ "16",
  yrbs_data$Q1 == 6 ~ "17",
  yrbs_data$Q1 == 7 ~ "≥18",
  TRUE   ~ NA_character_
)

table(yrbs_data$age_bucket, useNA = "ifany")
table(yrbs_data$Q42_any, useNA = "ifany")

ggplot(yrbs_data, aes(x = as.factor(Q80), fill = age_bucket)) +
  geom_bar(position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "Age Distribution Within Each Social Media Category (Q80)",
    x = "Q80 Social Media Frequency (1–8)",
    y = "Percentage of Students",
    fill = "Age"
  ) +
  theme_minimal(base_size = 14)

prop_age_q80 <- yrbs_data %>%
  group_by(age_bucket, Q80) %>%
  summarize(prop = mean(Q42_any, na.rm = TRUE))

ggplot(prop_age_q80, aes(x = as.factor(Q80), y = prop, 
                         color = age_bucket, group = age_bucket)) +
  geom_line(size = 1.2) +
  geom_point(size = 3) +
  labs(
    title = "Alcohol Use by Social Media Category, Stratified by Age",
    x = "Q80 Social Media (1–8)",
    y = "Proportion Drinking",
    color = "Age Group"
  ) +
  theme_minimal(base_size = 14)



