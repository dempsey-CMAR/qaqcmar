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

sample_interval <- 30
n_sample <- (60 / sample_interval) * 24 # number of sample intervals in 24 hours

amp1 <- 5
amp3 <- 10
amp4 <- 20
trans_do <- 100
trans_temp <- 10

ts1 <- data.frame(
  timestamp_utc = seq(
    as_datetime("2023-01-01 12:00:00"), as_datetime("2023-01-15 12:00:00"),
    by = paste0(sample_interval, " mins")
  )
)  %>%
  mutate(
    index = 1:n() - 1,
    value = amp1 * sin(2 * pi / n_sample * index) + trans_do,
    sensor_depth_at_low_tide_m = 5,
    sensor_type = "aquameasure",
    sensor_serial_number = 1,
    status = "No biofouling"
  )

ts3 <-   data.frame(
  timestamp_utc = seq(
    as_datetime("2023-01-15 12:30:00"), as_datetime("2023-01-31 12:00:00"),
    by = paste0(sample_interval, " mins")
  )
) %>%
  mutate(
    index = 1:n() - 1,
    value = amp3 * sin(2 * pi / n_sample * index) + trans_do,
    sensor_depth_at_low_tide_m = 5,
    sensor_type = "aquameasure",
    sensor_serial_number = 1,
    #status = "Moderate biofouling"
    status = "Biofouling"
  )


ts4 <-   data.frame(
  timestamp_utc = seq(
    as_datetime("2023-01-31 12:30:00"), as_datetime("2023-02-15 12:00:00"),
    by = paste0(sample_interval, " mins")
  )
) %>%
  mutate(
    index = 1:n() - 1,
    value = amp4 * sin(2 * pi / n_sample * index) + trans_do,
    sensor_depth_at_low_tide_m = 5,
    sensor_type = "aquameasure",
    sensor_serial_number = 1,
   # status = "Intense biofouling"
   status = "Biofouling"
  )

dat <- bind_rows(ts1, ts3, ts4) %>%
  mutate(
    county = "Halifax",
    waterbody = "mcnabs",
    station = "lighthouse",
    deployment_range = paste(
      format(min(as_date(ts1$timestamp_utc)), "%Y-%b-%d"),
      "to",
      format(max(as_date(ts4$timestamp_utc)), "%Y-%b-%d")
      ),
    sensor_type = "abc",
    sensor_serial_number = "123",
    sensor_depth_at_low_tide_m = 5
  ) %>%
  rename(dissolved_oxygen_percent_saturation = value) %>%
  select(
    county, waterbody, station, deployment_range,
    sensor_type, sensor_serial_number,
    timestamp_utc, sensor_depth_at_low_tide_m,
    dissolved_oxygen_percent_saturation,
    status
  )

 ss_ggplot_variables(dat) +
#   geom_point(size = 2)


# Export rds file
saveRDS(dat, file = here("inst/testdata/test_data_rate_of_change.RDS"))










