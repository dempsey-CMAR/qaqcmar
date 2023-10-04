# Ocotber 4, 2023

# testdata was generated such that we KNOW what flag should be assigned to each
# observation (data-raw/test_data.R)

# dummy_thresholds --------------------------------------------------------
# library(ggplot2)
# library(plotly)
# library(dplyr)
# library(sensorstrings)
# library(zoo)

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_estimated_depth.RDS"))

# ss_ggplot_variables(dat) +
#   geom_point(size = 2)

# general test
qc_depth <- dat %>%
  qc_test_depth_crosscheck()

# p <- qc_plot_flags(
#   qc_roll_sd,
#   qc_tests = "rolling_sd",
#   vars = "dissolved_oxygen_percent_saturation"
# )

qc_depth_1 <- qc_depth %>%
  filter(sensor_depth_at_low_tide_m %in% c(2, 5))

qc_depth_2 <- qc_depth %>%
  filter(sensor_depth_at_low_tide_m == 10)

qc_depth_3 <- qc_depth %>%
  filter(sensor_depth_at_low_tide_m == 15)
