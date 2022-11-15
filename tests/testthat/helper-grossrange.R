# November 8, 2022

#' testdata was generated such that we KNOW what flag should be assigned to each
#' observation (data-raw/test_data.R)
#'
#' Here, qc_test_grossrange() is applied to the test data. The qc'd data is then
#' separated into a data frame for each variable and flag value, based on the
#' timestamps used to generate the data in data-raw/test_data.R.
#'
#' The tests check that each data frame include the expected flag value, and
#' only the expected flag value.
#'

#' @importFrom dplyr %>% anti_join

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_grossrange.RDS"))

# sensorstrings::ss_ggplot_variables(dat)

qc_gr <- dat %>%
  qc_test_grossrange()

# qc_plot_all_tests(
#   qc_gr,
#   qc_tests = "grossrange",
#   vars = "salinity_psu"
# )
#

join_cols <- c(
  "latitude", "longitude", "sensor_type", "sensor_serial_number",
  "timestamp_utc", "sensor_depth_at_low_tide_m", "value_temperature_degree_C",
  "value_salinity_psu", "value_dissolved_oxygen_percent_saturation",
  "value_dissolved_oxygen_uncorrected_mg_per_L",
  "value_sensor_depth_measured_m", "grossrange_flag_temperature_degree_C",
  "grossrange_flag_salinity_psu",
  "grossrange_flag_dissolved_oxygen_percent_saturation",
  "grossrange_flag_dissolved_oxygen_uncorrected_mg_per_L",
  "grossrange_flag_sensor_depth_measured_m"
)

  # temperature - fail --------------------------------------------------------------------

temp_gr_4 <- qc_gr %>%
  filter(
    # hobo data
    sensor_serial_number == 20495248,
    (timestamp_utc > as_datetime("2021-10-04 00:00:00") &
       timestamp_utc < as_datetime("2021-10-04 06:00:00")) |
      (timestamp_utc > as_datetime("2021-10-09 00:00:00") &
         timestamp_utc < as_datetime("2021-10-09 06:00:00"))
  ) %>%
  rbind(
    qc_gr %>%
      filter(
        # aquameasure data
        sensor_serial_number == 670354,
        (timestamp_utc > as_datetime("2021-10-02 00:00:00") &
           timestamp_utc < as_datetime("2021-10-02 06:00:00")) |
          (timestamp_utc > as_datetime("2021-10-08 00:00:00") &
             timestamp_utc < as_datetime("2021-10-08 06:00:00"))
      )
  ) %>%
  rbind(
    # vemco data
    qc_gr %>%
      filter(
        sensor_serial_number == 549340,
        (timestamp_utc > as_datetime("2021-10-05 00:00:00") &
           timestamp_utc < as_datetime("2021-10-05 12:00:00")) |
          (timestamp_utc > as_datetime("2021-10-10 00:00:00") &
             timestamp_utc < as_datetime("2021-10-10 12:00:00"))
      )
  )

# temperature - suspect -----------------------------------------------------

temp_gr_3 <- qc_gr %>%
  filter(
    # hobo data
    sensor_serial_number == 20495248,
    (timestamp_utc > as_datetime("2021-10-14 00:00:00") &
       timestamp_utc < as_datetime("2021-10-14 06:00:00")) |
      (timestamp_utc > as_datetime("2021-10-19 00:00:00") &
         timestamp_utc < as_datetime("2021-10-19 06:00:00"))
  ) %>%
  rbind(
    x <- qc_gr %>%
      filter(
        # aquameasure data
        sensor_serial_number == 670354,
        (timestamp_utc > as_datetime("2021-10-12 00:00:00")) &
          (timestamp_utc < as_datetime("2021-10-12 06:00:00")) |
          (timestamp_utc > as_datetime("2021-10-18 00:00:00")) &
          (timestamp_utc < as_datetime("2021-10-18 06:00:00"))
      )
  ) %>%
  rbind(
    qc_gr %>%
      filter(
        sensor_serial_number == 549340,
        (timestamp_utc > as_datetime("2021-10-15 00:00:00") &
           timestamp_utc < as_datetime("2021-10-15 12:00:00")) |
          (timestamp_utc > as_datetime("2021-10-20 00:00:00") &
             timestamp_utc < as_datetime("2021-10-20 12:00:00"))
      )
  )

# temperature - pass --------------------------------------------------------

temp_gr_1 <- qc_gr %>%
  filter(sensor_serial_number %in% c(670354, 20495248, 549340)) %>%
  dplyr::anti_join(temp_gr_4, by = join_cols) %>%
  dplyr::anti_join(temp_gr_3, by = join_cols)


# do_percent_saturation - fail ----------------------------------------------

do_sat_gr_4 <- qc_gr %>%
  filter(
    # aquameasure data
    sensor_serial_number == 670354,
    (timestamp_utc > as_datetime("2021-10-03 00:00:00") &
      timestamp_utc < as_datetime("2021-10-03 06:00:00")) |
    timestamp_utc > as_datetime("2021-10-07 00:00:00") &
      timestamp_utc < as_datetime("2021-10-07 06:00:00")
  )

# do percent saturation - suspect -------------------------------------------

do_sat_gr_3 <- qc_gr %>%
  filter(
    # aquameasure data
    sensor_serial_number == 670354,
    (timestamp_utc > as_datetime("2021-10-13 00:00:00") &
      timestamp_utc < as_datetime("2021-10-13 06:00:00")) |
    (timestamp_utc > as_datetime("2021-10-17 00:00:00") &
      timestamp_utc < as_datetime("2021-10-17 06:00:00"))
  )

# do percent saturation - pass ----------------------------------------------

do_sat_gr_1 <- qc_gr %>%
  filter(sensor_serial_number == 670354) %>%
  dplyr::anti_join(do_sat_gr_4, by = join_cols) %>%
  dplyr::anti_join(do_sat_gr_3, by = join_cols)


# do concentration - fail ---------------------------------------------------

do_conc_gr_4 <- qc_gr %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    (timestamp_utc > as_datetime("2021-10-03 12:00:00") &
       timestamp_utc < as_datetime("2021-10-03 18:00:00")) |
      (timestamp_utc > as_datetime("2021-10-10 12:00:00") &
         timestamp_utc < as_datetime("2021-10-10 18:00:00"))
  )

# do concentration - suspect ------------------------------------------------

do_conc_gr_3 <- qc_gr %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    timestamp_utc > as_datetime("2021-10-17 12:00:00") &
      timestamp_utc < as_datetime("2021-10-17 18:00:00")
  )

# do percent saturation - pass ----------------------------------------------

do_conc_gr_1 <- qc_gr %>%
  filter(sensor_serial_number == 20827226) %>%
  dplyr::anti_join(do_conc_gr_4, by = join_cols) %>%
  dplyr::anti_join(do_conc_gr_3, by = join_cols)

# salinity - fail ---------------------------------------------------------

salinity_gr_4 <- qc_gr %>%
  filter(
    sensor_serial_number == 680360,
    (timestamp_utc > as_datetime("2021-10-06 00:00:00") &
      timestamp_utc < as_datetime("2021-10-06 06:00:00")) |
    (timestamp_utc > as_datetime("2021-10-16 00:00:00") &
      timestamp_utc < as_datetime("2021-10-16 06:00:00"))
  )


# salinity - suspect ------------------------------------------------------

salinity_gr_3 <- qc_gr %>%
  filter(
    sensor_serial_number == 680360,
    timestamp_utc > as_datetime("2021-10-26 00:00:00") &
      timestamp_utc < as_datetime("2021-10-26 06:00:00")
  )


# salinity - pass ---------------------------------------------------------

salinity_gr_1 <- qc_gr %>%
  filter(sensor_serial_number == 680360) %>%
  dplyr::anti_join(salinity_gr_4, by = join_cols) %>%
  dplyr::anti_join(salinity_gr_3, by = join_cols)


# labels ------------------------------------------------------------------

flag_labels <- data.frame(flag = c(1, 2, 3, 4, 9)) %>%
  qc_assign_flag_labels()

