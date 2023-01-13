# November 8, 2022

#' testdata was generated such that we KNOW what flag should be assigned to each
#' observation (data-raw/test_data.R)
#'
#' Here, qc_test_spike() is applied to the test data. The qc'd data is then
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
  filter(timestamp_utc > as_datetime("2021-10-24")) %>%
  qc_test_spike()

# p <- qc_plot_flags(
#   qc_sp,
#   qc_tests = "spike",
#   vars = "temperature_degree_c"
# )#


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
    timestamp_utc %in% as_datetime(
      c(
        "2021-10-28 23:30:00",
        "2021-10-14 01:00:00",
        "2021-10-14 05:30:00",
        "2021-10-14 07:0:00"
      )
    )
  )%>%
  rbind(
    qc_sp %>%
      filter(
        sensor_serial_number == 549340,
        timestamp_utc %in% as_datetime(
          c(
            "2021-10-24 20:00:00",
            "2021-10-25 02:00:00",
            "2021-10-25 08:0:00",
            "2021-10-25 14:0:00",
            "2012-10-29 20:00:00",
            "2012-10-30 02:00:00",
            "2012-10-30 08:00:00",
            "2012-10-30 14:00:00"
          )
        )
      )
  )

# this might change with thresholds
temp_sp_3 <- qc_sp %>%
  filter(
    sensor_serial_number == 670354,
    timestamp_utc == as_datetime("2021-10-26 23:13:00") |
      timestamp_utc == as_datetime("2021-10-27 00:13:00") |
      timestamp_utc == as_datetime("2021-10-27 05:13:00") |
      timestamp_utc == as_datetime("2021-10-27 06:13:00")
  )

# remove first and last observations (because flag should be 2)
temp_sp_1 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360 | sensor_serial_number == 20827226,
    timestamp_utc > as_datetime("2021-10-25") &
      timestamp_utc < as_datetime("2021-10-31")
  )


# dissolved oxygen - concentration ----------------------------------------

do_conc_sp_4 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    timestamp_utc == as_datetime("2021-10-24 10:52:44") |
      timestamp_utc == as_datetime("2021-10-24 12:22:44") |
      timestamp_utc == as_datetime("2021-10-24 16:52:44") |
      timestamp_utc == as_datetime("2021-10-24 18:22:44")
  )

do_conc_sp_3 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    timestamp_utc == as_datetime("2021-10-30 10:52:44") |
      timestamp_utc == as_datetime("2021-10-30 12:22:44") |
      timestamp_utc == as_datetime("2021-10-30 16:52:44") |
      timestamp_utc == as_datetime("2021-10-30 18:22:44")
  )

do_conc_sp_1 <- qc_sp %>%
  filter(
    # hobo data
    sensor_serial_number == 20827226,
    timestamp_utc > as_datetime("2021-10-25") &
      timestamp_utc < as_datetime("2021-10-30")
  )


# dissolved oxygen - percent saturation ----------------------------------------

do_sat_sp_4 <- qc_sp %>%
  filter(
    sensor_serial_number == 670354,
    timestamp_utc == as_datetime("2021-10-27 23:13:00") |
      timestamp_utc == as_datetime("2021-10-28 00:13:00") |
      timestamp_utc == as_datetime("2021-10-28 05:12:00") |
      timestamp_utc == as_datetime("2021-10-28 06:12:00")
  )

do_sat_sp_1 <- qc_sp %>%
  filter(
    sensor_serial_number == 670354,
    timestamp_utc > as_datetime("2021-10-25") &
      timestamp_utc < as_datetime("2021-10-27")
  )


# salinity ----------------------------------------------------------------

sal_sp_4 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360,
    timestamp_utc == as_datetime("2021-10-25 23:25:00") |
      timestamp_utc == as_datetime("2021-10-26 05:25:00")
  )

sal_sp_3 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360,
    timestamp_utc == as_datetime("2021-10-26 00:25:00") |
      timestamp_utc == as_datetime("2021-10-26 06:25:00")
  )

sal_sp_1 <- qc_sp %>%
  filter(
    sensor_serial_number == 680360,
    timestamp_utc > as_datetime("2021-10-27") &
      timestamp_utc < as_datetime("2021-10-31")
  )







