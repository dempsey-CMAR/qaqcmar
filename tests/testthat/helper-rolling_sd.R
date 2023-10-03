# August 3, 2023

# testdata was generated such that we KNOW what flag should be assigned to each
# observation (data-raw/test_data.R)

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
  qc_test_rolling_sd(keep_sd_cols = TRUE, max_interval_hours = 0.25) %>%
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

# ggplotly(p$dissolved_oxygen_percent_saturation$rolling_sd)

qc_roll_sd_1 <- qc_roll_sd %>%
  filter(
    timestamp_utc >= as_datetime("2023-01-01 23:30:00"),
    timestamp_utc <= as_datetime("2023-01-07 13:30:00")
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
    timestamp_utc > as_datetime("2023-01-07 14:00:00"),
    timestamp_utc <= as_datetime("2023-01-22 00:00:00")
  )
