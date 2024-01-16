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
#' @importFrom lubridate as_datetime day month
#' @importFrom tidyr pivot_longer

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_spike.RDS"))

# sensorstrings::ss_ggplot_variables(dat) + geom_point(size = 2)

qc_sp <- dat %>%
  qc_test_spike(county = "Halifax") %>%
  mutate(day = day(timestamp_utc)) %>%
  qc_pivot_longer(qc_tests = "spike")

# qc_plot_flags(
#   qc_sp,
#   qc_tests = "spike",
#   vars = "temperature_degree_c"
# )

# qc_plot_flags(
#   qc_sp,
#   qc_tests = "spike",
#   vars = "dissolved_oxygen_percent_saturation"
# )


# first and last observations should be assigned flag value of 2
qc_sp_2 <- qc_sp %>%
  mutate(month = month(timestamp_utc)) %>%
  filter((month == 1 & day == 1) | (month == 2 & day == 28))

# flag 3's from the 4 spikes AND 3 spikes
qc_sp_3 <- qc_sp %>%
  filter(day %in% c(3, 9, 11, 17))

# flag 4
qc_sp_4 <- qc_sp %>%
  filter(day == 10)

# flag 1
qc_sp_1 <- qc_sp %>%
  filter(!(day %in% c(1 , 3, 9, 10, 11, 17, 28)))
