# February 10, 2023

# Simulate data for the Spike test

# Day 2: Spike Flag 4 (low)
# Day 5: Spike Flag 3 (low)
# Day 15: Spike Flag 4 (high)
# Day 27: Spike Flag 3 (high)


# library(dplyr)
# library(lubridate)
# library(here)
# library(sensorstrings)
# library(qaqcmar)


#' @importfrom dplyr %>% filter mutate relocate select
#' @importFrom here here
#' @importFrom lubridate as_datetime day
#' @importFrom sensorstrings  ss_convert_depth_to_ordered_factor ss_ggplot_variables

# Raw data ----------------------------------------------------------------

# vectors used to create data frame
months <- seq(1, 2)
days <- rep(c(1:28), 2)
variables = c("temperature_degree_c", "dissolved_oxygen_percent_saturation")
sensors <- c("aquameasure", "hobo", "tidbit", "vr2ar")

dat <- expand.grid(
  month = months, day = days, variable = variables, sensor_type = sensors
) %>%
  distinct(month, day, variable, sensor_type) %>%
  # filter out impossible sensor-variable combinations
  filter(
    !((variable == "dissolved_oxygen_percent_saturation" |
         variable == "dissolved_oxygen_mg_per_l") &
        (sensor_type == "tidbit" | sensor_type == "hobo" | sensor_type == "vr2ar")),
    !(variable == "dissolved_oxygen_percent_saturation" & sensor_type == "hobo do")
  ) %>%
  # consider changing to only keep possible sensor-variable combinations
  # filter(
  #   (sensor_type == "aquameasure" &
  #      variable %in% c("temperature_degree_c",
  #                      "dissolved_oxygen_percent_saturation",
  #                      "salinity_psu",
  #                      "sensor_depth_measured_m")) |
  #     (sensor_type == "hobo" &
  #        variable %in% c("temperature_degree_c", "
  #                     dissolved_oxygen_mg_per_l_uncorrected")) |
  #     (sensor_type == "tidbit" & variable == "temperature_degree_c") |
  #     (sensor_type == "vr2ar" &
  #        variable %in% c("temperature_degree_c","sensor_depth_measured_m"))
  # )
  mutate(
    # add depths (so easier to view simulated data when plotted)
    sensor_depth_at_low_tide_m = case_when(
      sensor_type == "hobo" ~ 2,
      sensor_type == "aquameasure" ~ 5,
      sensor_type == "hobo do" ~ 10,
      sensor_type == "tidbit" ~ 15,
      sensor_type == "vr2ar" ~ 25,
       TRUE ~ NA_real_
    ),
    timestamp_utc = as_datetime(paste("2023", month, day, sep = "-")),
    # add :"good values"
    value = case_when(

      variable == "temperature_degree_c" & sensor_type == "hobo" ~ 22,
      variable == "temperature_degree_c" & sensor_type == "aquameasure" ~ 16,
      variable == "temperature_degree_c" & sensor_type == "hobo do" ~ 11,
      variable == "temperature_degree_c" & sensor_type == "tidbit" ~ 4,
      variable == "temperature_degree_c" & sensor_type == "vr2ar" ~ 1,

      variable == "dissolved_oxygen_percent_saturation" ~ 100
    ),
    # add values with known flags
    value = case_when(
      day == 3 ~ value - 10,
      day == 10 ~ value - 5,
      day == 17 ~ value + 10,
      day == 23 ~ value + 5,
      TRUE ~ value
    ),
    sensor_serial_number = ""
  ) %>%
  select(-c(month, day)) %>%
  ss_pivot_wider()

# Export rds file
saveRDS(dat, file = here("inst/testdata/test_data_spike.RDS"))



dat %>%
  ss_ggplot_variables() +
  geom_point(size = 3)

# qc_gr <- dat %>%
#   qc_test_grossrange(county = "Lunenburg") %>%
#   mutate(sensor_serial_number = "")
#
#
# qc_plot_flags(
#   qc_gr,
#   qc_tests = "grossrange",
#   vars = "temperature_degree_c"
# )
#
# qc_plot_flags(
#   qc_gr,
#   qc_tests = "grossrange",
#   vars = "dissolved_oxygen_percent_saturation"
# )


