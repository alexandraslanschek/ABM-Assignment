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
data <- mutate(data, day = (step + 1) / 4)

# Extract average number of colds
colds <- data %>%
  filter(day == max(day)) %>%
  select(run_number, mean_infections_of_turtles)
min(colds$mean_infections_of_turtles); mean(colds$mean_infections_of_turtles); max(colds$mean_infections_of_turtles) # Good
