#' @importFrom readxl read_excel


path <- system.file("data-raw", package = "qaqcmar")


climatology_table <- readxl::read_excel(
  paste0(path, "/qc_thresholds.xlsx"), sheet = "climatology"
)

seasons_table <- readxl::read_excel(
  paste0(path, "/qc_thresholds.xlsx"), sheet = "seasons"
)

grossrange_table <- readxl::read_excel(
  paste0(path, "/qc_thresholds.xlsx"), sheet = "grossrange"
)


# export ------------------------------------------------------------------

threshold_tables <- list(
  climatology_table = climatology_table,
  seasons_table = seasons_table,
  grossrange_table = grossrange_table
)

usethis::use_data(threshold_tables, overwrite = TRUE)



# Old ---------------------------------------------------------------------

# # might be better to read these in from csv files in data-raw
# template <- data.frame(
#   variable = c(
#     "dissolved_oxygen_mg_per_L",
#     "dissolved_oxygen_percent_saturation",
#     "salinity_psu",
#     "temperature_degree_C",
#     "temperature_degree_C",
#     "temperature_degree_C"
#   ),
#   sensor_make = c(
#     "hobo",
#     "aquameasure",
#     "aquameasure",
#     "aquameasure",
#     "hobo",
#     "vemco"
#   )
# )
#
# # climatology -------------------------------------------------------------
#
# seasons <- c("winter", "spring", "summer", "fall")
#
#
# climatology_table <- expand.grid(
#   variable = unique(template$variable), season = seasons
# ) %>%
#   cbind(
#     season_min = c(2, 5, 10, 2, 70, 70, 70, 70, 0, 0, 0, 0, -0.7, 0, 7, 5),
#     season_max = c(15, 20, 20, 15, 120, 130, 130, 120, 40, 40, 40, 40, 15, 20, 25, 20)
#   )
#
# # gross range -------------------------------------------------------------
# grossrange_table <- template %>%
#   cbind(
#     sensor_min = c(0, 0, 0, -5, -40, -5),
#     sensor_max = c(30, 150, 40, 35, 70, 40),
#     user_min = c(0, 50, 0, -3, -3, -3),
#     user_max = c(25, 130, 35, 25, 25, 25)
#   )

