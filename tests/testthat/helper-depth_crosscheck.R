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

# dat %>%
#   ss_pivot_wider() %>%
#   ss_ggplot_variables() +
#   geom_point(size = 2)

# general test
qc_depth <- dat %>%
  qc_test_depth_crosscheck()

# p <- qc_plot_flags(
#   qc_depth,
#   qc_tests = "depth_crosscheck"
# )

qc_depth_1 <- qc_depth %>%
  filter(sensor_depth_at_low_tide_m %in% c(2, 5))

qc_depth_2 <- qc_depth %>%
  filter(sensor_depth_at_low_tide_m == 10)

qc_depth_3 <- qc_depth %>%
  filter(sensor_depth_at_low_tide_m == 15)


# could  just show the min value
# qc_depth %>%
#   qc_assign_flag_labels() %>%
#   ggplot(
#     aes(sensor_depth_measured_m, sensor_depth_at_low_tide_m,
#         col = depth_crosscheck_flag_value)
#   ) +
#   geom_point(size = 2, alpha = 0.75) +
#   geom_abline(intercept = 0, slope = 1) +
#   scale_colour_manual("Flag Value",
#     values = c("chartreuse4", "#E6E1BC", "#EDA247", "#DB4325", "grey24"))






