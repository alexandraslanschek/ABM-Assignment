# Clean environment
remove(list = ls())

# Install (if necessary) and load packages
library(install.load)
install_load('janitor', 'tidyverse')

# Import data
data <- read_csv('Data/experiment.csv', skip = 6)

# Clean column names
colnames(data) <- make_clean_names(colnames(data))

# Assign data types
glimpse(data)

data <- mutate(data, run_number = as.factor(run_number))
data <- mutate(data, across(c(max_sick_leave_days, number_of_workers, number_of_teams, recovery_days, immunity_days, step, count_turtles_with_sick_false_and_work_true, count_turtles_with_sick_true_and_work_false, count_turtles_with_sick_true_and_work_true, count_absentees_with_sick_false_and_work_true, count_absentees_with_sick_true_and_work_false, count_absentees_with_sick_true_and_work_true, count_presentees_with_sick_false_and_work_true, count_presentees_with_sick_true_and_work_false, count_presentees_with_sick_true_and_work_true), as.integer))

# Check values of independent variables
for(i in c('max_sick_leave_days', 'number_of_workers', 'number_of_teams', 'movement_across_teams', 'share_of_presentees')) {
  print(unique(data[, i]))
} # Good

remove(i)

# Compute days
data <- mutate(data, day = (step + 1) / 4)

# Visualize mean productivity by agent type, dependent on maximum number of sick leave days
plot <- data %>%
  filter(number_of_workers == 200 & number_of_teams == 5 & movement_across_teams == 0.3 & share_of_presentees == 0.51) %>% # Calibrated values
  filter(run_number %in% seq(from = 1, to = 48600, by = 20)) %>% # Do not average out waves
  select(day, max_sick_leave_days, mean_productivity_turtles, mean_productivity_absentees, mean_productivity_presentees) %>%
  gather(mean_productivity_turtles, mean_productivity_absentees, mean_productivity_presentees, key = 'group', value = 'Mean Productivity') %>%
  mutate(group = if_else(str_detect(group, 'turtles'), 'Workers', if_else(str_detect(group, 'absentees'), 'Absentees', 'Presentees'))) %>%
  mutate(`Maximum Number of Sick Leave Days` = as.factor(max_sick_leave_days)) %>%
  filter(max_sick_leave_days %in% c(0, 1, 5, 10, 20, 50)) # For readability

ggplot(data = plot, mapping = aes(x = day, y = `Mean Productivity`, color = `Maximum Number of Sick Leave Days`)) +
  facet_grid(rows = vars(group)) +
  geom_line() +
  scale_color_brewer(palette = 'Greens') +
  xlab('Day') +
  theme_minimal()

ggplot(data = filter(plot, day <= 65 & group == 'Absentees'), mapping = aes(x = day, y = `Mean Productivity`, color = `Maximum Number of Sick Leave Days`)) +
  geom_line() +
  scale_color_brewer(palette = 'Greens') +
  xlab('Day') +
  theme_minimal() # Model appears to behave as expected

remove(plot)

# Visualize number of sick workers at home and at work by agent type, dependent on maximum number of sick leave days
plot <- data %>%
  filter(number_of_workers == 200 & number_of_teams == 5 & movement_across_teams == 0.3 & share_of_presentees == 0.51) %>% # Calibrated values
  filter(run_number %in% seq(from = 1, to = 48600, by = 20)) %>% # Do not average out waves
  select(day, max_sick_leave_days, count_turtles_with_sick_true_and_work_false, count_turtles_with_sick_true_and_work_true, count_absentees_with_sick_true_and_work_false, count_absentees_with_sick_true_and_work_true, count_presentees_with_sick_true_and_work_false, count_presentees_with_sick_true_and_work_true) %>%
  gather(count_turtles_with_sick_true_and_work_false, count_turtles_with_sick_true_and_work_true, count_absentees_with_sick_true_and_work_false, count_absentees_with_sick_true_and_work_true, count_presentees_with_sick_true_and_work_false, count_presentees_with_sick_true_and_work_true, key = 'group', value = 'N') %>%
  mutate(Behavior = if_else(str_detect(group, 'false'), 'Sick at Home', 'Sick at Work'),
         group = if_else(str_detect(group, 'turtles'), 'Workers', if_else(str_detect(group, 'absentees'), 'Absentees', 'Presentees'))) %>%
  mutate(`Maximum Number of Sick Leave Days` = as.factor(max_sick_leave_days)) %>%
  filter(max_sick_leave_days %in% c(0, 1, 5, 10, 20, 50)) # For readability

ggplot(data = plot, mapping = aes(x = day, y = N, color = `Maximum Number of Sick Leave Days`, linetype = Behavior)) +
  facet_grid(rows = vars(group)) +
  geom_line() +
  scale_color_brewer(palette = 'Greens') +
  xlab('Day') +
  theme_minimal()

ggplot(data = filter(plot, day <= 65 & group == 'Absentees'), mapping = aes(x = day, y = N, color = `Maximum Number of Sick Leave Days`, linetype = Behavior)) +
  geom_line() +
  scale_color_brewer(palette = 'Greens') +
  xlab('Day') +
  theme_minimal() # Again, model appears to behave as expected

remove(plot)

# Compute mean productivity by agent type for whole year
mean_productivity <- data %>%
  group_by(run_number) %>%
  summarize(workers = mean(mean_productivity_turtles), absentees = mean(mean_productivity_absentees), presentees = mean(mean_productivity_presentees)) %>%
  left_join(data %>%
              select(run_number, max_sick_leave_days, number_of_workers, number_of_teams, movement_across_teams, share_of_presentees) %>%
              distinct())

# Plot mean productivity by agent type for whole year, dependent on maximum number of sick leave days
plot <- mean_productivity %>%
  rename(Workers = workers, Absentees = absentees, Presentees = presentees) %>%
  gather(Workers, Absentees, Presentees, key = 'group', value = 'Mean Productivity')

mean_productivity_plot_together <- ggplot(data = filter(plot, group == 'Workers'), mapping = aes(x = max_sick_leave_days, y = `Mean Productivity`)) +
  geom_point(alpha = 1 / 100, position = position_jitter(), size = 1 / 10000) +
  ylim(min(plot[, 'Mean Productivity']) - 1 / 100, max(plot[, 'Mean Productivity']) + 1 / 100) +
  labs(title = str_wrap('Figure 1: Maximum Number of Sick Leave Days and Productivity, All Workers'), x = 'Maximum Number of Sick Leave Days') +
  theme_minimal(base_size = 3) +
  theme(plot.background = element_rect(color = 'black'))
mean_productivity_plot_together

mean_productivity_plot_separate <- ggplot(data = filter(plot, group %in% c('Absentees', 'Presentees')), mapping = aes(x = max_sick_leave_days, y = `Mean Productivity`, color = group)) +
  geom_point(alpha = 1 / 100, position = position_jitter(), size = 1 / 10000) +
  scale_color_manual(values = c('Absentees' = 'grey', 'Presentees' = 'red')) +
  ylim(min(plot[, 'Mean Productivity']) - 1 / 100, max(plot[, 'Mean Productivity']) + 1 / 100) +
  labs(title = str_wrap('Figure 2: Maximum Number of Sick Leave Days and Productivity, Absentees (Grey) and Presentees (Red)'), x = 'Maximum Number of Sick Leave Days') +
  guides(color = 'none') +
  theme_minimal(base_size = 3) +
  theme(plot.background = element_rect(color = 'black'))
mean_productivity_plot_separate

remove(plot)

# Extract average number of infections by agent type for whole year
mean_infections <- data %>%
  filter(day == 260) %>%
  select(run_number, mean_infections_of_turtles, mean_infections_of_absentees, mean_infections_of_presentees, max_sick_leave_days, number_of_workers, number_of_teams, movement_across_teams, share_of_presentees) %>%
  rename(workers = mean_infections_of_turtles, absentees = mean_infections_of_absentees, presentees = mean_infections_of_presentees)

# Plot average number of infections by agent type for whole year, dependent on maximum number of sick leave days
plot <- mean_infections %>%
  rename(Workers = workers, Absentees = absentees, Presentees = presentees) %>%
  gather(Workers, Absentees, Presentees, key = 'group', value = 'Average Number of Infections')

mean_infections_plot_together <- ggplot(data = filter(plot, group == 'Workers'), mapping = aes(x = max_sick_leave_days, y = `Average Number of Infections`)) +
  geom_point(alpha = 1 / 100, position = position_jitter(), size = 1 / 10000) +
  ylim(min(plot[, 'Average Number of Infections']) - 1 / 100, max(plot[, 'Average Number of Infections']) + 1 / 100) +
  labs(title = str_wrap('Figure 3: Maximum Number of Sick Leave Days and Average Number of Infections, All Workers'), x = 'Maximum Number of Sick Leave Days') +
  theme_minimal(base_size = 3) +
  theme(plot.background = element_rect(color = 'black'))
mean_infections_plot_together

mean_infections_plot_separate <- ggplot(data = filter(plot, group %in% c('Absentees', 'Presentees')), mapping = aes(x = max_sick_leave_days, y = `Average Number of Infections`, color = group)) +
  geom_point(alpha = 1 / 100, position = position_jitter(), size = 1 / 10000) +
  scale_color_manual(values = c('Absentees' = 'grey', 'Presentees' = 'red')) +
  ylim(min(plot[, 'Average Number of Infections']) - 1 / 100, max(plot[, 'Average Number of Infections']) + 1 / 100) +
  labs(title = str_wrap('Figure 4: Maximum Number of Sick Leave Days and Average Number of Infections, Absentees (Grey) and Presentees (Red)'), x = 'Maximum Number of Sick Leave Days') +
  guides(color = 'none') +
  theme_minimal(base_size = 3) +
  theme(plot.background = element_rect(color = 'black'))
mean_infections_plot_separate

remove(plot)

# Compute number of sick days in percent by agent type for whole year
sick_days <- data %>%
  group_by(run_number) %>%
  summarize(workers = (sum(count_turtles_with_sick_true_and_work_false) + sum(count_turtles_with_sick_true_and_work_true)) / (sum(count_turtles_with_sick_false_and_work_true) + sum(count_turtles_with_sick_true_and_work_false) + sum(count_turtles_with_sick_true_and_work_true)) * 100, absentees = (sum(count_absentees_with_sick_true_and_work_false) + sum(count_absentees_with_sick_true_and_work_true)) / (sum(count_absentees_with_sick_false_and_work_true) + sum(count_absentees_with_sick_true_and_work_false) + sum(count_absentees_with_sick_true_and_work_true)) * 100, presentees = (sum(count_presentees_with_sick_true_and_work_false) + sum(count_presentees_with_sick_true_and_work_true)) / (sum(count_presentees_with_sick_false_and_work_true) + sum(count_presentees_with_sick_true_and_work_false) + sum(count_presentees_with_sick_true_and_work_true)) * 100) %>%
  left_join(data %>%
              select(run_number, max_sick_leave_days, number_of_workers, number_of_teams, movement_across_teams, share_of_presentees) %>%
              distinct())

# Plot number of sick days in percent by agent type for whole year, dependent on maximum number of sick leave days
plot <- sick_days %>%
  rename(Workers = workers, Absentees = absentees, Presentees = presentees) %>%
  gather(Workers, Absentees, Presentees, key = 'group', value = 'Number of Sick Days (in %)')

sick_days_plot_together <- ggplot(data = filter(plot, group == 'Workers'), mapping = aes(x = max_sick_leave_days, y = `Number of Sick Days (in %)`)) +
  geom_point(alpha = 1 / 100, position = position_jitter(), size = 1 / 10000) +
  ylim(min(plot[, 'Number of Sick Days (in %)']) - 1 / 100, max(plot[, 'Number of Sick Days (in %)']) + 1 / 100) +
  labs(title = str_wrap('Figure 5: Maximum Number of Sick Leave Days and Number of Sick Days (in %), All Workers'), x = 'Maximum Number of Sick Leave Days') +
  theme_minimal(base_size = 3) +
  theme(plot.background = element_rect(color = 'black'))
sick_days_plot_together

sick_days_plot_separate <- ggplot(data = filter(plot, group %in% c('Absentees', 'Presentees')), mapping = aes(x = max_sick_leave_days, y = `Number of Sick Days (in %)`, color = group)) +
  geom_point(alpha = 1 / 100, position = position_jitter(), size = 1 / 10000) +
  scale_color_manual(values = c('Absentees' = 'grey', 'Presentees' = 'red')) +
  ylim(min(plot[, 'Number of Sick Days (in %)']) - 1 / 100, max(plot[, 'Number of Sick Days (in %)']) + 1 / 100) +
  labs(title = str_wrap('Figure 6: Maximum Number of Sick Leave Days and Number of Sick Days (in %), Absentees (Grey) and Presentees (Red)'), x = 'Maximum Number of Sick Leave Days') +
  guides(color = 'none') +
  theme_minimal(base_size = 3) +
  theme(plot.background = element_rect(color = 'black'))
sick_days_plot_separate

remove(plot)

# Simple linear regression model for mean productivity by agent type for whole year
mean_productivity_lm <- mean_productivity %>%
  gather(workers, absentees, presentees, key = 'group', value = mean_productivity) %>%
  mutate(group = as.factor(group)) %>%
  mutate(group = relevel(group, 'workers')) %>%
  filter(max_sick_leave_days <= 20) # Constant for MAX-SICK-LEAVE-DAYS > 20

lm(mean_productivity ~ group * max_sick_leave_days, mean_productivity_lm) %>%
  summary()

mean_productivity_lm <- mutate(mean_productivity_lm, group = str_to_title(group))

mean_productivity_plot_together +
  geom_smooth(data = filter(mean_productivity_lm, group == 'Workers'), mapping = aes(x = max_sick_leave_days, y = mean_productivity), method = 'lm', color = 'black', linewidth = 1 / 3, se = FALSE)
ggsave('Figure 1.png', scale = 1 / 3)

mean_productivity_plot_separate +
  geom_smooth(data = filter(mean_productivity_lm, group %in% c('Absentees', 'Presentees')), mapping = aes(x = max_sick_leave_days, y = mean_productivity, color = group), method = 'lm', linewidth = 1 / 3, se = FALSE)
ggsave('Figure 2.png', scale = 1 / 3)

remove(mean_productivity, mean_productivity_plot_separate, mean_productivity_plot_together)

# Simple linear regression model for average number of infections by agent type for whole year
mean_infections_lm <- mean_infections %>%
  gather(workers, absentees, presentees, key = 'group', value = mean_infections) %>%
  mutate(group = as.factor(group)) %>%
  mutate(group = relevel(group, 'workers')) %>%
  filter(max_sick_leave_days <= 20) # Constant for MAX-SICK-LEAVE-DAYS > 20

lm(mean_infections ~ group * max_sick_leave_days, mean_infections_lm) %>%
  summary()

mean_infections_lm <- mutate(mean_infections_lm, group = str_to_title(group))

mean_infections_plot_together +
  geom_smooth(data = filter(mean_infections_lm, group == 'Workers'), mapping = aes(x = max_sick_leave_days, y = mean_infections), method = 'lm', color = 'black', linewidth = 1 / 3, se = FALSE)
ggsave('Figure 3.png', scale = 1 / 3)

mean_infections_plot_separate +
  geom_smooth(data = filter(mean_infections_lm, group %in% c('Absentees', 'Presentees')), mapping = aes(x = max_sick_leave_days, y = mean_infections, color = group), method = 'lm', linewidth = 1 / 3, se = FALSE)
ggsave('Figure 4.png', scale = 1 / 3)

remove(mean_infections, mean_infections_plot_separate, mean_infections_plot_together)

# Simple linear regression model for number of sick days in percent by agent type for whole year
sick_days_lm <- sick_days %>%
  gather(workers, absentees, presentees, key = 'group', value = sick_days) %>%
  mutate(group = as.factor(group)) %>%
  mutate(group = relevel(group, 'workers')) %>%
  filter(max_sick_leave_days <= 20) # Constant for MAX-SICK-LEAVE-DAYS > 20

lm(sick_days ~ group * max_sick_leave_days, sick_days_lm) %>%
  summary()

sick_days_lm <- mutate(sick_days_lm, group = str_to_title(group))

sick_days_plot_together +
  geom_smooth(data = filter(sick_days_lm, group == 'Workers'), mapping = aes(x = max_sick_leave_days, y = sick_days), method = 'lm', color = 'black', linewidth = 1 / 3, se = FALSE)
ggsave('Figure 5.png', scale = 1 / 3)

sick_days_plot_separate +
  geom_smooth(data = filter(sick_days_lm, group %in% c('Absentees', 'Presentees')), mapping = aes(x = max_sick_leave_days, y = sick_days, color = group), method = 'lm', linewidth = 1 / 3, se = FALSE)
ggsave('Figure 6.png', scale = 1 / 3)

remove(sick_days, sick_days_plot_separate, sick_days_plot_together)

# Multiple linear regression model for mean productivity for whole year
lm(mean_productivity ~ max_sick_leave_days * (number_of_workers + number_of_teams + movement_across_teams + share_of_presentees), filter(mean_productivity_lm, group == 'Workers')) %>%
  summary()

remove(mean_productivity_lm)

# Multiple linear regression model for average number of infections for whole year
lm(mean_infections ~ max_sick_leave_days * (number_of_workers + number_of_teams + movement_across_teams + share_of_presentees), filter(mean_infections_lm, group == 'Workers')) %>%
  summary()

remove(mean_infections_lm)

# Multiple linear regression model for number of sick days in percent by agent type for whole year
lm(sick_days ~ max_sick_leave_days * (number_of_workers + number_of_teams + movement_across_teams + share_of_presentees), filter(sick_days_lm, group == 'Workers')) %>%
  summary()

remove(sick_days_lm)
