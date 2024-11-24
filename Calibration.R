# Clean environment
remove(list = ls())

# Install (if necessary) and load packages
library(install.load)
install_load('janitor', 'tidyverse')

# Import data
data <- read_csv('Data/calibration.csv', skip = 6)

# Clean column names
colnames(data) <- make_clean_names(colnames(data))

# Compute days and weeks
data <- data %>%
  mutate(day = (step + 1) / 4) %>%
  mutate(week = ceiling(day / 5))

# Compute weekly incidence
incidence <- data %>%
  group_by(run_number, week) %>%
  summarize(incidence = sum(count_turtles_with_infected_true) / 200) %>%
  ungroup()

maximum <- incidence %>%
  group_by(run_number) %>%
  summarise(maximum = max(incidence))
max(maximum$maximum); mean(maximum$maximum) # Good

# Extract average number of colds
colds <- data %>%
  filter(day == max(day)) %>%
  select(run_number, mean_infections_of_turtles)
mean(colds$mean_infections_of_turtles) # Good
