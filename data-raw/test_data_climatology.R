library(readr)
library(dplyr)
library(lubridate)
library(here)
library(sensorstrings) # V. 0.1.0
library(qaqcmar)       # V. 0.0.1

# Raw data ----------------------------------------------------------------

depl1 <- ss_compile_deployment_data(here("data-raw/Wedgeport_2021-07-08")) %>%
  mutate(dissolved_oxygen_uncorrected_mg_per_l = NA) %>%
  relocate(
    dissolved_oxygen_uncorrected_mg_per_l,
    .after = dissolved_oxygen_percent_saturation
  )

# ss_ggplot_variables(depl1)

# HOBO DO data from another deployment.
depl2 <- ss_compile_deployment_data(
   here("data-raw/Birchy Head_2021-11-26")
 ) %>%
   mutate(
     salinity_psu = NA,
     temperature_degree_c = NA,
     dissolved_oxygen_percent_saturation = NA,
     sensor_depth_measured_m = NA
   )

do1 <- depl2 %>%
  mutate(timestamp_utc = timestamp_utc - days(120))  # Align Birchy Head with Wedgeport

do2 <- depl2 %>%
  mutate(timestamp_utc = timestamp_utc + days(49))  # Align Birchy Head with Wedgeport


# ss_ggplot_variables(depl2)

dat_raw <- rbind(depl1, do1, do2) %>%
  ss_convert_depth_to_ordered_factor()

# ss_ggplot_variables(dat_raw)


# extract 1 month from each season for test data -------------------------------------------

# use only every sixth observation and remove extraneous columns to reduce size
dat <- dat_raw %>%
  mutate(numeric_month = month(timestamp_utc)) %>%
  filter(
    numeric_month %in% c(8, 11, 2, 5),
    row_number() %% 30 == 0
  ) %>%
  select(-c(county, waterbody, station, lease, deployment_range, mooring_type)) %>%
  ss_pivot_longer() %>%
  filter(
    !(variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        value < 13 & numeric_month == 11),
    !(variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        value < 13 & numeric_month == 5),
    !(variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        value > 15 & numeric_month == 11),
    !(variable == "temperature_degree_c" &
        value < -0.7 & numeric_month == 11)
  ) %>%
  ss_pivot_wider()

# ss_ggplot_variables(dat)


# timestamps for flagged observations ------------------------------------------------

summer_low1 <- as_datetime("2021-08-07")
summer_low2 <- summer_low1 + days(3)

summer_high1 <- as_datetime("2021-08-15")
summer_high2 <- summer_high1 + days(3)

fall_low1 <- as_datetime("2021-11-07")
fall_low2 <- fall_low1 + days(3)

fall_high1 <- as_datetime("2021-11-15")
fall_high2 <- fall_high1 + days(3)

winter_low1 <- as_datetime("2022-02-07")
winter_low2 <- winter_low1 + days(3)

winter_high1 <- as_datetime("2022-02-15")
winter_high2 <- winter_high1 + days(3)

spring_low1 <- as_datetime("2022-05-07")
spring_low2 <- spring_low1 + days(3)

spring_high1 <- as_datetime("2022-05-15")
spring_high2 <- spring_high1 + days(3)


# values to flag ----------------------------------------------------------

# base on thresholds so test will work even if thresholds are adjusted

climatology_table <- threshold_tables %>%
  filter(qc_test == "climatology") %>%
  select(-c(qc_test, sensor_type)) %>%
  mutate(
    threshold = str_replace(threshold, "winter|spring|summer|fall", "season")
    ) %>%
  pivot_wider(names_from = "threshold", values_from = "threshold_value") %>%
  mutate(
    obs_low = case_when(
      variable == "temperature_degree_c" | variable == "salinity_psu"  ~
        season_min - 5,
      TRUE ~  season_min  - 10
    ),
    obs_high = case_when(
      variable == "temperature_degree_c" | variable == "salinity_psu" ~
        season_max + 5,
      TRUE ~  season_max + 10
    )
  )

#seasons_table <- threshold_tables$seasons_table

# add observations to flag ------------------------------------------------

dat_qc <- dat %>%
  ss_pivot_longer() %>%
  left_join(months_seasons, by = "numeric_month") %>%
  left_join(climatology_table, by = c("season", "variable")) %>%
  mutate(
    # DO % saturation
    value = case_when(
      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > summer_low1 & timestamp_utc < summer_low2 ~ obs_low,
      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > summer_high1 & timestamp_utc < summer_high2 ~ obs_high,

      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > fall_low1 & timestamp_utc < fall_low2 ~ obs_low,
      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > fall_high1 & timestamp_utc < fall_high2 ~ obs_high,

      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > winter_low1 & timestamp_utc < winter_low2 ~ obs_low,
      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > winter_high1 & timestamp_utc < winter_high2 ~ obs_high,

      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > spring_low1 & timestamp_utc < spring_low2 ~ obs_low,
      variable == "dissolved_oxygen_percent_saturation" &
      timestamp_utc > spring_high1 & timestamp_utc < spring_high2 ~ obs_high,

      # DO concentration
      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > summer_low1 & timestamp_utc < summer_low2 ~ obs_low,
      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > summer_high1 & timestamp_utc < summer_high2 ~ obs_high,

      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > fall_low1 & timestamp_utc < fall_low2 ~ obs_low,
      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > fall_high1 & timestamp_utc < fall_high2 ~ obs_high,

      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > winter_low1 & timestamp_utc < winter_low2 ~ obs_low,
      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > winter_high1 & timestamp_utc < winter_high2 ~ obs_high,

      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > spring_low1 & timestamp_utc < spring_low2 ~ obs_low,
      variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        timestamp_utc > spring_high1 & timestamp_utc < spring_high2 ~ obs_high,

      # temperature
      variable == "temperature_degree_c" &
        timestamp_utc > summer_low1 & timestamp_utc < summer_low2 ~ obs_low,
      variable == "temperature_degree_c" &
        timestamp_utc > summer_high1 & timestamp_utc < summer_high2 ~ obs_high,

      variable == "temperature_degree_c" &
        timestamp_utc > fall_low1 & timestamp_utc < fall_low2 ~ obs_low,
      variable == "temperature_degree_c" &
        timestamp_utc > fall_high1 & timestamp_utc < fall_high2 ~ obs_high,

      variable == "temperature_degree_c" &
        timestamp_utc > winter_low1 & timestamp_utc < winter_low2 ~ obs_low,
      variable == "temperature_degree_c" &
        timestamp_utc > winter_high1 & timestamp_utc < winter_high2 ~ obs_high,

      variable == "temperature_degree_c" &
        timestamp_utc > spring_low1 & timestamp_utc < spring_low2 ~ obs_low,
      variable == "temperature_degree_c" &
        timestamp_utc > spring_high1 & timestamp_utc < spring_high2 ~ obs_high,

      # salinity
      variable == "salinity_psu" &
        timestamp_utc > summer_low1 & timestamp_utc < summer_low2 ~ obs_low,
      variable == "salinity_psu" &
        timestamp_utc > summer_high1 & timestamp_utc < summer_high2 ~ obs_high,

      variable == "salinity_psu" &
        timestamp_utc > fall_low1 & timestamp_utc < fall_low2 ~ obs_low,
      variable == "salinity_psu" &
        timestamp_utc > fall_high1 & timestamp_utc < fall_high2 ~ obs_high,

      variable == "salinity_psu" &
        timestamp_utc > winter_low1 & timestamp_utc < winter_low2 ~ obs_low,
      variable == "salinity_psu" &
        timestamp_utc > winter_high1 & timestamp_utc < winter_high2 ~ obs_high,

      variable == "salinity_psu" &
        timestamp_utc > spring_low1 & timestamp_utc < spring_low2 ~ obs_low,
      variable == "salinity_psu" &
        timestamp_utc > spring_high1 & timestamp_utc < spring_high2 ~ obs_high,

      TRUE ~ value
    )
  ) %>%
  select(-c(season, season_min, season_max, obs_low, obs_high, numeric_month)) %>%
  ss_pivot_wider()

ss_ggplot_variables(dat_qc)


# Export rds file
saveRDS(dat_qc, file = here("inst/testdata/test_data_climatology.RDS"))

