# library(readr)
# library(dplyr)
# library(lubridate)
# library(here)
# library(sensorstrings) # V. 0.1.0
# library(qaqcmar)       # V. 0.0.0.9000


#' @importfrom dplyr %>% filter mutate relocate select
#' @importFrom here here
#' @importFrom lubridate as_datetime days
#' @importFrom sensorstrings  ss_convert_depth_to_ordered_factor ss_ggplot_variables



# Raw data ----------------------------------------------------------------

dat <- ss_compile_deployment_data(here("data-raw/Wedgeport_2021-07-08")) %>%
  mutate(dissolved_oxygen_uncorrected_mg_per_l = NA) %>%
  relocate(
    dissolved_oxygen_uncorrected_mg_per_l,
    .after = dissolved_oxygen_percent_saturation
  )

 #ss_ggplot_variables(dat)

# HOBO DO data from another deployment.
 hobo_do <- ss_compile_deployment_data(
   here("data-raw/Birchy Head_2021-11-26")
 ) %>%
  mutate(
    salinity_psu = NA,
    dissolved_oxygen_percent_saturation = NA,
    sensor_depth_measured_m = NA) %>%
  # Align Birchy Head January with Wedgeport October
  mutate(timestamp_utc = timestamp_utc - days(60))

# ss_ggplot_variables(hobo_do)

dat <- rbind(dat, hobo_do) %>%
  ss_convert_depth_to_ordered_factor()

#ss_ggplot_variables(dat)


# extract 1 month for test data -------------------------------------------

# use only every sixth observation and remove extraneous columns to reduce size
oct_dat <-  dat %>%
  filter(
  (timestamp_utc > as_datetime("2021-10-01 00:00:00") &
    timestamp_utc < as_datetime("2021-11-01 00:00:00")),
  row_number() %% 6 == 0
  ) %>%
  select(-county, -waterbody, -station, -lease, -deployment_range, -mooring_type)

#ss_ggplot_variables(oct_dat)


# add observations to flag ------------------------------------------------

# For each temperature and the aM DO series, the sets of anomalous points will be in this order:
# 1. Gross Range Flag 4 (low)
# 2. Gross Range Flag 4 (high)
# 3. Gross Range Flag 3 (low)
# 4. Gross Range Flag 3 (high)
# 5. Climatology Flag 3 (fall, low)
# 6. Climatology Flag 3 (fall, high)

# For the Hobo DO series, the order is:
# 1. Gross Range Flag 4 (low)
# 2. Gross Range Flag 4 (high)
# 3. Gross Range Flag 3 (high)
# 5. Climatology Flag 3 (fall/winter, low)
# 6. Climatology Flag 3 (fall/winter, high)

# For the salinity series, the order is:
# 1. Gross Range Flag 4 (low)
# 2. Gross Range Flag 4 (high)
# 3. Gross Range Flag 3 (high)

qaqc_dat <- oct_dat %>%
  mutate(
    # aM DO
    dissolved_oxygen_percent_saturation = case_when(
      timestamp_utc > as_datetime("2021-10-03 00:00:00") &
        timestamp_utc < as_datetime("2021-10-03 06:00:00") ~
        dissolved_oxygen_percent_saturation * -1,
      timestamp_utc > as_datetime("2021-10-07 00:00:00") &
        timestamp_utc < as_datetime("2021-10-07 06:00:00") ~
        dissolved_oxygen_percent_saturation + 55,
      timestamp_utc > as_datetime("2021-10-13 00:00:00") &
        timestamp_utc < as_datetime("2021-10-13 06:00:00") ~
        dissolved_oxygen_percent_saturation - 70,
      timestamp_utc > as_datetime("2021-10-17 00:00:00") &
        timestamp_utc < as_datetime("2021-10-17 06:00:00") ~
        dissolved_oxygen_percent_saturation + 35,
      timestamp_utc > as_datetime("2021-10-22 00:00:00") &
        timestamp_utc < as_datetime("2021-10-22 06:00:00") ~
        dissolved_oxygen_percent_saturation - 35,
      timestamp_utc > as_datetime("2021-10-28 00:00:00") &
        timestamp_utc < as_datetime("2021-10-28 06:00:00") ~
        dissolved_oxygen_percent_saturation + 25,
      TRUE ~ dissolved_oxygen_percent_saturation
    ),
    # Hobo DO
    dissolved_oxygen_uncorrected_mg_per_l = case_when(
      timestamp_utc > as_datetime("2021-10-03 12:00:00") &
        timestamp_utc < as_datetime("2021-10-03 18:00:00") ~
        dissolved_oxygen_uncorrected_mg_per_l * -1,
      timestamp_utc > as_datetime("2021-10-10 12:00:00") &
        timestamp_utc < as_datetime("2021-10-10 18:00:00") ~
        dissolved_oxygen_uncorrected_mg_per_l + 30,
      timestamp_utc > as_datetime("2021-10-17 12:00:00") &
        timestamp_utc < as_datetime("2021-10-17 18:00:00") ~
        dissolved_oxygen_uncorrected_mg_per_l + 15,
      timestamp_utc > as_datetime("2021-10-24 12:00:00") &
        timestamp_utc < as_datetime("2021-10-24 18:00:00") ~
        dissolved_oxygen_uncorrected_mg_per_l - 11,
      timestamp_utc > as_datetime("2021-10-30 12:00:00") &
        timestamp_utc < as_datetime("2021-10-30 18:00:00") ~
        dissolved_oxygen_uncorrected_mg_per_l + 5,
      TRUE ~ dissolved_oxygen_uncorrected_mg_per_l
    ),
    # aM Sal
    salinity_psu = case_when(
      timestamp_utc > as_datetime("2021-10-06 00:00:00") &
        timestamp_utc < as_datetime("2021-10-06 06:00:00") ~
        salinity_psu * -1,
      timestamp_utc > as_datetime("2021-10-16 00:00:00") &
        timestamp_utc < as_datetime("2021-10-16 06:00:00") ~
        salinity_psu + 20,
      timestamp_utc > as_datetime("2021-10-26 00:00:00") &
        timestamp_utc < as_datetime("2021-10-26 06:00:00") ~
        salinity_psu + 10,
      TRUE ~ salinity_psu
    ),
    # aM Temp
    temperature_degree_c = case_when(
      sensor_serial_number == 670354 &
        timestamp_utc > as_datetime("2021-10-02 00:00:00") &
        timestamp_utc < as_datetime("2021-10-02 06:00:00") ~
        temperature_degree_c * -1,
      sensor_serial_number == 670354 &
        timestamp_utc > as_datetime("2021-10-08 00:00:00") &
        timestamp_utc < as_datetime("2021-10-08 06:00:00") ~
        temperature_degree_c + 25,
      sensor_serial_number == 670354 &
        timestamp_utc > as_datetime("2021-10-12 00:00:00") &
        timestamp_utc < as_datetime("2021-10-12 06:00:00") ~
        temperature_degree_c - 19,
      sensor_serial_number == 670354 &
        timestamp_utc > as_datetime("2021-10-18 00:00:00") &
        timestamp_utc < as_datetime("2021-10-18 06:00:00") ~
        temperature_degree_c + 15,
      sensor_serial_number == 670354 &
        timestamp_utc > as_datetime("2021-10-21 00:00:00") &
        timestamp_utc < as_datetime("2021-10-21 06:00:00") ~
        temperature_degree_c - 15,
      sensor_serial_number == 670354 &
        timestamp_utc > as_datetime("2021-10-27 00:00:00") &
        timestamp_utc < as_datetime("2021-10-27 06:00:00") ~
        temperature_degree_c + 7,
      # Hobo Temp
      sensor_serial_number == 20495248 &
        timestamp_utc > as_datetime("2021-10-04 00:00:00") &
        timestamp_utc < as_datetime("2021-10-04 06:00:00") ~
        temperature_degree_c - 60,
      sensor_serial_number == 20495248 &
        timestamp_utc > as_datetime("2021-10-09 00:00:00") &
        timestamp_utc < as_datetime("2021-10-09 06:00:00") ~
        temperature_degree_c + 60,
      sensor_serial_number == 20495248 &
        timestamp_utc > as_datetime("2021-10-14 00:00:00") &
        timestamp_utc < as_datetime("2021-10-14 06:00:00") ~
        temperature_degree_c - 19,
      sensor_serial_number == 20495248 &
        timestamp_utc > as_datetime("2021-10-19 00:00:00") &
        timestamp_utc < as_datetime("2021-10-19 06:00:00") ~
        temperature_degree_c + 10,
      sensor_serial_number == 20495248 &
        timestamp_utc > as_datetime("2021-10-23 00:00:00") &
        timestamp_utc < as_datetime("2021-10-23 06:00:00") ~
        temperature_degree_c - 15,
      sensor_serial_number == 20495248 &
        timestamp_utc > as_datetime("2021-10-29 00:00:00") &
        timestamp_utc < as_datetime("2021-10-29 06:00:00") ~
        temperature_degree_c + 10,
      # Vemco Temp
      sensor_serial_number == 549340 &
        timestamp_utc > as_datetime("2021-10-05 00:00:00") &
        timestamp_utc < as_datetime("2021-10-05 12:00:00") ~
        temperature_degree_c * -1,
      sensor_serial_number == 549340 &
        timestamp_utc > as_datetime("2021-10-10 00:00:00") &
        timestamp_utc < as_datetime("2021-10-10 12:00:00") ~
        temperature_degree_c + 25,
      sensor_serial_number == 549340 &
        timestamp_utc > as_datetime("2021-10-15 00:00:00") &
        timestamp_utc < as_datetime("2021-10-15 12:00:00") ~
        temperature_degree_c - 20,
      sensor_serial_number == 549340 &
        timestamp_utc > as_datetime("2021-10-20 00:00:00") &
        timestamp_utc < as_datetime("2021-10-20 12:00:00") ~
        temperature_degree_c + 15,
      sensor_serial_number == 549340 &
        timestamp_utc > as_datetime("2021-10-25 00:00:00") &
        timestamp_utc < as_datetime("2021-10-25 12:00:00") ~
        temperature_degree_c - 15,
      sensor_serial_number == 549340 &
        timestamp_utc > as_datetime("2021-10-30 00:00:00") &
        timestamp_utc < as_datetime("2021-10-30 12:00:00") ~
        temperature_degree_c + 10,
      TRUE ~ temperature_degree_c
    )

  )

#ss_ggplot_variables(qaqc_dat)


# Export rds file
saveRDS(qaqc_dat, file = here("inst/testdata/test_data_grossrange.RDS"))

# # some quick checks
# gr_dat <- qc_test_grossrange(qaqc_dat) #%>%
# qc_pivot_longer(qc_tests = "grossrange")
# qc_plot_flag_vars(gr_dat, qc_tests = "grossrange")
#
# cl_dat <- qc_test_climatology(qaqc_dat) %>%
#   qc_pivot_longer(qc_tests = "climatology")
# qc_plot_flag_vars(cl_dat, qc_tests = "climatology")
