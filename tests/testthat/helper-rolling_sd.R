# February 10, 2023

# testdata was generated such that we KNOW what flag should be assigned to each
# observation (data-raw/test_data.R)

# Simulated data for the gross range test
# was constructed so there are 4 observations per month
# Day 1: Gross Range Flag 4 (low)
# Day 5: Gross Range Flag 3 (low)*
# Day 10: Gross Range Flag 1
# Day 15: Gross Range Flag 4 (high)
# Day 28: Gross Range Flag 3 (high)

# * for the aquameasure and vr2ar sensors, the user_min is less than the sensor_min,
# which means a flag of 3 (low) will not be assigned

# Here, qc_test_grossrange() is applied to the test data. The qc'd data is then
# separated by day.
# The tests check that each day include the expected flag value, and
# only the expected flag value.


# dummy_thresholds --------------------------------------------------------
# library(ggplot2)
# library(plotly)
# library(dplyr)
# library(sensorstrings)
# library(zoo)

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_rolling_sd.RDS"))

# ss_ggplot_variables(dat) +
#   geom_point(size = 2) +
#   geom_line(aes(group = sensor_type))

# make sure the interval argument works as expected
qc_roll_int <- dat %>%
  qc_test_rolling_sd(keep_sd_cols = TRUE, min_interval_hours = 0.25) %>%
  qc_pivot_longer(qc_tests = "rolling_sd")

# general test
qc_roll_sd <- dat %>%
  qc_test_rolling_sd(keep_sd_cols = TRUE) %>%
  qc_pivot_longer(qc_tests = "rolling_sd")

# p <- qc_plot_flags(
#   qc_roll_sd,
#   qc_tests = "rolling_sd",
#   vars = "dissolved_oxygen_percent_saturation"
# )
#
# ggplotly(p$dissolved_oxygen_percent_saturation$rolling_sd)

qc_roll_sd_1 <- qc_roll_sd %>%
  filter(
    timestamp_utc >= as_datetime("2023-01-01 23:30:00"),
    timestamp_utc <= as_datetime("2023-01-07 06:30:00")
  )

qc_roll_sd_2 <- qc_roll_sd %>%
  filter(
    (timestamp_utc >= as_datetime("2023-01-01 12:00:00") &
       timestamp_utc <= as_datetime("2023-01-01 23:00:00")) |
      (timestamp_utc >= as_datetime("2023-01-22 00:30:00") &
         timestamp_utc <= as_datetime("2023-02-15 12:00:00"))
  )


qc_roll_sd_3 <- qc_roll_sd %>%
  filter(
    timestamp_utc > as_datetime("2023-01-07 07:00:00"),
    timestamp_utc <= as_datetime("2023-01-22 00:00:00")
  )












# # ggplotly(p)
# # could just assign number of samples to pull the sd out of
# # because when sample interval changes to 15, then it
# # does the sd of 48 obs, even though they are sampled every 30 mins
#
#
# # range (value - lag(value)) doesn't work because the ranges overlap
# # use sd
#
# sd_hours <- 24 # time interval of interest
# sd_thresh <- 5
#
#
# dat_qc <- dat %>%
#   select(-sensor_serial_number, sensor_type) %>%
#   ss_pivot_longer() %>%
#   filter(variable == "dissolved_oxygen_percent_saturation") %>%
#   mutate(
#     # sample interval
#     int_sample = difftime(timestamp_utc, lag(timestamp_utc), units = "mins"),
#     int_sample = round(as.numeric(int_sample)),
#
#     # number of samples in sd_hours period
#     n_sample = (60 / int_sample) * sd_hours,
#     n_sample = if_else(is.na(n_sample), 1, n_sample), # first obs
#
#     # backwards rolling sd
#     sd_roll = zoo::rollapply(value, width = n_sample, FUN = sd, fill = NA, align = "left"),
#     range_roll = value - lag(value, n = sd_hours),
#
#     flag_sd = if_else(sd_roll > sd_thresh, 3, 1)
#   )
#
# # ggplot(dat_qc, aes(timestamp_utc, range_roll)) +
# #   geom_point()
# #
# # # use this to choose thresholds for sd
# # ggplot(dat_qc, aes(timestamp_utc, sd_roll)) +
# #   geom_point()
# #
# ggplot(dat_qc, aes(timestamp_utc, value, col = factor(flag_sd))) +
#   geom_point()

