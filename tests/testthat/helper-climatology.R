# November 9, 2022

#' testdata was generated such that we KNOW what flag should be assigned to each
#' observation (data-raw/test_data_climatology.R)
#'
#' Here, qc_test_climatology() is applied to the test data. The qc'd data is
#' then separated into a data frame for each variable and flag value, based on
#' the timestamps used to generate the data in data-raw/test_data.R.
#'
#' The tests check that each data frame include the expected flag value, and
#' only the expected flag value.


#' @importFrom dplyr %>% anti_join
#' @importFrom lubridate days

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_climatology.RDS"))

# ss_ggplot_variables(dat)

qc_cl <- dat %>%
  qc_test_climatology()

# qc_plot_flags(
#   qc_cl,
#   qc_tests = "climatology",
#   vars = "all"
# )

# timestamps for flagged observations ------------------------------------------------

summer_low1 <- as_datetime("2021-08-07")
summer_low2 <- summer_low1 + lubridate::days(3)

summer_high1 <- as_datetime("2021-08-15")
summer_high2 <- summer_high1 + lubridate::days(3)

fall_low1 <- as_datetime("2021-11-07")
fall_low2 <- fall_low1 + lubridate::days(3)

fall_high1 <- as_datetime("2021-11-15")
fall_high2 <- fall_high1 + lubridate::days(3)

winter_low1 <- as_datetime("2022-02-07")
winter_low2 <- winter_low1 + lubridate::days(3)

winter_high1 <- as_datetime("2022-02-15")
winter_high2 <- winter_high1 + lubridate::days(3)

spring_low1 <- as_datetime("2022-05-07")
spring_low2 <- spring_low1 + lubridate::days(3)

spring_high1 <- as_datetime("2022-05-15")
spring_high2 <- spring_high1 + lubridate::days(3)


# suspect observations ----------------------------------------------------

qc_cl_23 <- qc_cl %>%
  qc_pivot_longer(qc_tests = "climatology") %>%
  filter(
    (timestamp_utc > summer_low1 & timestamp_utc < summer_low2)  |
      (timestamp_utc > summer_high1 & timestamp_utc < summer_high2) |

      (timestamp_utc > fall_low1 & timestamp_utc < fall_low2) |
      (timestamp_utc > fall_high1 & timestamp_utc < fall_high2) |

      (timestamp_utc > winter_low1 & timestamp_utc < winter_low2) |

      (timestamp_utc > winter_high1 & timestamp_utc < winter_high2) |

      (timestamp_utc > spring_low1 & timestamp_utc < spring_low2) |

      (timestamp_utc > spring_high1 & timestamp_utc < spring_high2)
  )

qc_cl_2 <- qc_cl_23 %>%
  filter(variable == "sensor_depth_measured_m")

qc_cl_3 <- qc_cl_23 %>%
  filter(variable != "sensor_depth_measured_m")

qc_cl_1 <- qc_cl %>%
  qc_pivot_longer(qc_tests = "climatology") %>%
  dplyr::anti_join(
    qc_cl_23,
    by = c("latitude", "longitude", "sensor_type", "sensor_serial_number",
           "timestamp_utc", "sensor_depth_at_low_tide_m", "variable", "value",
           "climatology_flag_value")
  ) %>%
  filter(variable != "sensor_depth_measured_m")


