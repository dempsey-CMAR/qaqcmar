#' @importFrom readxl read_excel
#' @importFrom here here
#' @importFrom stringr str_remove

# path <- system.file("data-raw", package = "qaqcmar")

months_seasons <- readxl::read_excel(
  here::here("data-raw/qc_thresholds.xlsx"), sheet = "seasons"
)

climatology_table <- readxl::read_excel(
 here::here("data-raw/qc_thresholds.xlsx"), sheet = "climatology"
)

grossrange_table <- readxl::read_excel(
  here::here("data-raw/qc_thresholds.xlsx"), sheet = "grossrange"
)

spike_table <- readxl::read_excel(
  here::here("data-raw/qc_thresholds.xlsx"), sheet = "spike"
)

# merge and format --------------------------------------------------------

threshold_tables <- climatology_table %>%
  pivot_longer(cols = c("season_min", "season_max"), names_to = "threshold") %>%
  mutate(threshold = str_remove(threshold, pattern = "season_"),
         threshold = paste(season, threshold, sep = "_")) %>%
  mutate(qc_test = "climatology") %>%
 # select(-season) %>%
  bind_rows(
    grossrange_table %>%
      pivot_longer(cols = sensor_min:user_max, names_to = "threshold") %>%
      mutate(
        sensor_type = if_else(sensor_type == "vemco", "vr2ar", sensor_type),
        qc_test = "grossrange", threshold = paste0(sensor_type, "_", threshold),
        threshold = str_replace(threshold, "aquameasure", "am")
      )
  ) %>% bind_rows(
   spike_table %>%
      pivot_longer(cols = c("spike_high", "spike_low"), names_to = "threshold") %>%
      mutate(qc_test = "spike")
  ) %>%
  mutate(sensor_type = if_else(sensor_type == "vemco", "vr2ar", sensor_type)) %>%
  select(qc_test, variable, sensor_type, season, threshold, threshold_value = value)


# export ------------------------------------------------------------------

usethis::use_data(months_seasons, overwrite = TRUE)

usethis::use_data(threshold_tables, overwrite = TRUE)
