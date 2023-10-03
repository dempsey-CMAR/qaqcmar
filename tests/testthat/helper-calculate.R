# September 26, 2023

# qc_calculate_user_thresholds --------------------------------------------
temp_mean <- 10
temp_sd <- 5

set.seed(954)
user_dat <- data.frame(
  temperature = round(rnorm(10000, temp_mean, temp_sd), digits = 4),
  dissolved_oxygen = round(rnorm(10000, 100, 5), digits = 4)
)

user_temp <- qc_calculate_user_thresholds(
  user_dat, var = "temperature", n_sd = 3, keep_stats = TRUE
) %>%
  pivot_wider(values_from = "threshold_value", names_from = "threshold") %>%
  mutate(
    check_user_min = mean_var - 3 * sd_var,
    check_user_max = mean_var + 3 * sd_var
  )


# qc_calculate_climatology_thresholds -------------------------------------

set.seed(2385)
clim_dat <- expand.grid(
  month = c(1:12), temperature = round(rnorm(100, 10, 5), digits = 2)
) %>%
  mutate(temperature = sample(temperature))

clim_temp <- qc_calculate_climatology_thresholds(
  clim_dat, var = "temperature", n_sd = 3, keep_stats = TRUE
) %>%
  pivot_wider(values_from = "threshold_value", names_from = "threshold") %>%
  mutate(
    check_season_min = mean_var - 3 * sd_var,
    check_season_max = mean_var + 3 * sd_var
  )


# qc_calculate_rolling_sd_threshold ---------------------------------------

set.seed(4554)
rolling_sd_dat <- data.frame(sd_roll = rlnorm(100))

q_95 <- quantile(rolling_sd_dat$sd_roll, probs = 0.95)
mean_sd <- round(
  mean(rolling_sd_dat$sd_roll) + 3 * sd(rolling_sd_dat$sd_roll), digits = 2)

rolling_sd_quantile <- qc_calculate_rolling_sd_thresholds(
  rolling_sd_dat, var = "temperature", stat = "quartile", prob = 0.95
)

rolling_sd_mean_sd <- qc_calculate_rolling_sd_thresholds(
  rolling_sd_dat, var = "temperature", stat = "mean_sd", n_sd = 3
)






