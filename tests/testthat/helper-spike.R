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

#' @importFrom dplyr %>% anti_join filter group_by summarise ungroup
#' @importFrom lubridate as_datetime
#' @importFrom tidyr pivot_longer

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_grossrange.RDS"))

# sensorstrings::ss_ggplot_variables(dat)

qc_sp <- dat %>%
  filter(timestamp_utc > as_datetime("2020-10-18")) %>%
  qc_test_spike()

p <- qc_plot_flags(
  qc_sp,
  qc_tests = "spike"
  #vars = "temperature_degree_C"
)#


qc_sp_long <- qc_sp %>%
  qc_pivot_longer(qc_test = "spike") %>%
  mutate(sensor = paste(sensor_type, sensor_serial_number, sep = "-"))

# first and last observations should be assigned flag value of 2
qc_sp_2 <- qc_sp_long %>%
  group_by(sensor, variable) %>%
  dplyr::summarise(
    MIN = min(timestamp_utc), MAX = max(timestamp_utc), .groups = "keep"
  ) %>%
  ungroup() %>%
  pivot_longer(cols = c("MIN", "MAX"), values_to = "timestamp_utc") %>%
  left_join(qc_sp_long, by = c("sensor", "variable", "timestamp_utc"))

# qc_sp_long %>%
#   filter(timestamp_utc > "2021-10-18") %>%
#   qc_plot_flags(qc_tests = "spike")


# temperature -------------------------------------------------------------

temp_sp_4 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20495248,
    timestamp_utc == as_datetime("2021-10-13 23:45:00") |
      timestamp_utc == as_datetime("2021-10-14 01:15:00") |
      timestamp_utc == as_datetime("2021-10-14 05:45:00") |
      timestamp_utc == as_datetime("2021-10-14 07:15:00")
  ) %>%
  rbind(
    qc_sp %>%
      filter(
        sensor_serial_number == 670354,
        timestamp_utc == as_datetime("2021-10-17 23:47:00") |
          timestamp_utc == as_datetime("2021-10-18 00:47:00") |
          timestamp_utc == as_datetime("2021-10-18 05:47:00") |
          timestamp_utc == as_datetime("2021-10-18 06:47:00")
      )
  ) %>%
  rbind(
    qc_sp %>%
      filter(
        sensor_serial_number == 549340,
        timestamp_utc == as_datetime("2021-10-20 00:00:00") |
          timestamp_utc == as_datetime("2021-10-20 06:00:00") |
          timestamp_utc == as_datetime("2021-10-20 12:0:00")
      )
  )

# this might change with thresholds
temp_sp_3 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20495248,
    timestamp_utc == as_datetime("2021-10-29 01:15:00") |
      timestamp_utc == as_datetime("2021-10-29 05:45:00") |
      timestamp_utc == as_datetime("2021-10-29 07:15:00")
  ) %>%
  rbind(
    qc_sp %>%
      filter(
        sensor_serial_number == 670354,
        timestamp_utc == as_datetime("2021-10-26 23:43:00") |
          timestamp_utc == as_datetime("2021-10-27 00:43:00") |
          timestamp_utc == as_datetime("2021-10-27 05:43:00") |
          timestamp_utc == as_datetime("2021-10-27 06:43:00")
      )
  )

temp_sp_1 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360 | sensor_serial_number == 20827226,
    timestamp_utc > as_datetime("2021-10-01 01:10:00") &
      timestamp_utc < as_datetime("2021-10-23 23:30:00")
  )


# dissolved oxygen - concentration ----------------------------------------

do_conc_sp_4 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    timestamp_utc == as_datetime("2021-10-17 11:37:44") |
      timestamp_utc == as_datetime("2021-10-17 13:07:44") |
      timestamp_utc == as_datetime("2021-10-17 17:37:44") |
      timestamp_utc == as_datetime("2021-10-17 19:07:44")
  )

do_conc_sp_3 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    timestamp_utc == as_datetime("2021-10-30 11:37:44") |
      timestamp_utc == as_datetime("2021-10-30 13:07:44") |
      timestamp_utc == as_datetime("2021-10-30 17:37:44") |
      timestamp_utc == as_datetime("2021-10-30 19:07:44")
  )

do_conc_sp_1 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    timestamp_utc > as_datetime("2021-10-04"),
      timestamp_utc < as_datetime("2021-10-09")
  )


# dissolved oxygen - percent saturation ----------------------------------------

do_sat_sp_4 <- qc_sp %>%
  filter(
    sensor_serial_number == 670354,
    timestamp_utc == as_datetime("2021-10-27 23:43:00") |
      timestamp_utc == as_datetime("2021-10-28 00:43:00") |
      timestamp_utc == as_datetime("2021-10-28 05:42:00") |
      timestamp_utc == as_datetime("2021-10-28 06:42:00")
  )

do_sat_sp_1 <- qc_sp %>%
  filter(
    sensor_serial_number == 670354,
    timestamp_utc > as_datetime("2021-10-07 07:00:00"),
    timestamp_utc < as_datetime("2021-10-12 22:50:00")
  )


# salinity ----------------------------------------------------------------

sal_sp_4 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360,
    timestamp_utc == as_datetime("2021-10-15 23:54:00") |
      timestamp_utc == as_datetime("2021-10-16 00:54:00") |
      timestamp_utc == as_datetime("2021-10-16 05:54:00") |
      timestamp_utc == as_datetime("2021-10-16 06:54:00")
  )

sal_sp_3 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360,
    timestamp_utc == as_datetime("2021-10-26 00:55:00") |
      timestamp_utc == as_datetime("2021-10-26 06:55:00")
  )

sal_sp_1 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360,
    timestamp_utc > as_datetime("2021-10-07 00:00:00"),
      timestamp_utc < as_datetime("2021-10-15 06:55:00")
  )







