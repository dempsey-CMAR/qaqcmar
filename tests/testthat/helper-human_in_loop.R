# October 23, 2024

# testdata was generated such that we KNOW what flag should be assigned to each
# observation (data-raw/test_data.R)

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_rolling_sd.RDS"))

# ss_ggplot_variables(dat) +
#   geom_point(size = 2)

# general test
hil_table <- data.frame(
  station = "lighthouse",
  depl_range = "2023-Jan-01 to 2023-Jan-15",
  variable = "dissolved_oxygen_percent_saturation",
  sensor_serial_number = 123,
  timestamp_prompt = "between",
  timestamp_utc_min = as_datetime("2023-01-15 12:30:00"),
  timestamp_utc_max = NA,
  qc_test_column = "rolling_sd_flag_value",
  qc_flag_value = 3,
  human_in_loop_flag_value = 4,
  human_in_loop_comment = "dissolved_oxygen_percent_saturation: test comment"
)

qc_hil <- dat %>%
  qc_test_rolling_sd() %>%
  qc_test_human_in_loop(
    qc_tests = "rolling_sd", human_in_loop_table = hil_table
  )

# p <- qc_plot_flags(qc_hil, qc_tests = "human_in_loop")
#
# p

#ggplotly(p$dissolved_oxygen_percent_saturation$human_in_loop)

# qc_hil_max <- qc_hil %>%
#   qc_assign_max_flag(qc_tests = c("rolling_sd", "human_in_loop"))
#
# qc_plot_flags(qc_hil_max, qc_tests = "qc")


qc_hil_4 <- qc_hil %>%
  filter(
    timestamp_utc >= as_datetime("2023-01-15 12:30:00") &
    timestamp_utc <= as_datetime("2023-01-22 00:00:00")
  )

qc_hil_1 <- qc_hil %>%
  dplyr::anti_join(
    qc_hil_4,
    join_by(county, waterbody, station, deployment_range,
            sensor_type,
            sensor_serial_number, timestamp_utc, sensor_depth_at_low_tide_m,
            dissolved_oxygen_percent_saturation, sensor_depth_measured_m,
            rolling_sd_flag_dissolved_oxygen_percent_saturation,
            rolling_sd_flag_sensor_depth_measured_m,
            human_in_loop_flag_dissolved_oxygen_percent_saturation,
            human_in_loop_flag_sensor_depth_measured_m, hil_comment)
  )


