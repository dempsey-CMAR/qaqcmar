#' @importFrom readxl read_excel
#' @importFrom here here

# path <- system.file("data-raw", package = "qaqcmar")


climatology_table <- readxl::read_excel(
 here::here("data-raw/qc_thresholds.xlsx"), sheet = "climatology"
)

seasons_table <- readxl::read_excel(
  here::here("data-raw/qc_thresholds.xlsx"), sheet = "seasons"
)

grossrange_table <- readxl::read_excel(
  here::here("data-raw/qc_thresholds.xlsx"), sheet = "grossrange"
)


# export ------------------------------------------------------------------

threshold_tables <- list(
  climatology_table = climatology_table,
  seasons_table = seasons_table,
  grossrange_table = grossrange_table
)

usethis::use_data(threshold_tables, overwrite = TRUE)
