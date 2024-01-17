#' Pivot flagged sensor string data from long to wide format by variable
#'
#' @param dat_long Data frame of flagged sensor string data in long format.
#'
#' @param vars Variables included in \code{dat_long}.
#'
#' @param var_position Character string. Name of the column in \code{dat_long}
#'   that the the variable column will be located after. By default, each
#'   variable column will be located after the column
#'   \code{sensor_depth_at_low_tide_m}.
#'
#' @return Returns \code{dat_long}, with variables and flags pivoted to a wide
#'   format (a separate column for each variable and variable-qc_test
#'   combination).
#'
#' @importFrom dplyr %>% all_of any_of arrange filter left_join rename
#' @importFrom purrr reduce
#' @importFrom tidyr pivot_longer
#'
#' @export

qc_pivot_wider <- function(dat_long, vars = NULL, var_position = NULL) {

  if (is.null(vars)) {
    vars <- sort(unique(dat_long$variable))
  }

  first_cols <- c(
    "county", "waterbody", "station", "lease", "latitude", "longitude",
    "deployment_range", "string_configuration",
    "sensor_type", "sensor_serial_number",
    "timestamp_utc", "sensor_depth_at_low_tide_m"
  )

  dat_out <- list(NULL)

  if("depth_crosscheck_flag_value" %in% colnames(dat_long)) {
   # dat_long <- rename(dat_long, depth_crosscheck = depth_crosscheck_flag_value)

    depth_crosscheck <- dat_long# %>%
      select(any_of(first_cols), depth_crosscheck_flag_value)

      x <- pivot_flags_wider(dat_long, var = "depth_crosscheck")

    dat_long <- dat_long %>% select(-depth_crosscheck_flag_value)
  }

  if("dissolved_oxygen_percent_saturation" %in% vars) {
    dat_out[[1]] <- pivot_flags_wider(
      dat_long,
      var = "dissolved_oxygen_percent_saturation"
    )
  }

  if("dissolved_oxygen_uncorrected_mg_per_l" %in% vars) {
    dat_out[[2]] <- pivot_flags_wider(
      dat_long,
      var = "dissolved_oxygen_uncorrected_mg_per_l"
    )
  }

  if("salinity_psu" %in% vars) {
    dat_out[[3]] <- pivot_flags_wider(dat_long, var = "salinity_psu")
  }

  if("sensor_depth_measured_m" %in% vars) {
    dat_out[[4]] <- pivot_flags_wider(dat_long, var = "sensor_depth_measured_m")
  }

  if("temperature_degree_c" %in% vars) {
    dat_out[[5]] <- pivot_flags_wider(dat_long, var = "temperature_degree_c")
  }

  # remove empty list elements
  dat_out2 <- Filter(Negate(is.null), dat_out)

  join_cols <- first_cols[first_cols %in% colnames(dat_long)]

  # join by all common columns
  dat_out3 <- dat_out2 %>%
    purrr::reduce(dplyr::left_join, by = join_cols)# %>%
    left_join(depth_crosscheck)
    select(
      any_of(first_cols),
      all_of(paste0("value_", vars)),
      contains("depth_crosscheck"),
      contains("climatology"),
      contains("grossrange"),
      contains("rolling_sd"),
      contains("spike")
      #everything()
    )

  if("depth_crosscheck" %in% colnames(dat_out)) {
    dat_out <- rename(
      dat_out,
      depth_crosscheck_flag_sensor_depth_measured_m = depth_crosscheck
    )
  }

  dat_out
}


#' Complete pivot_wider of flagged sensor string data
#'
#' @inheritParams qc_pivot_wider
#'
#' @param dat_long Data frame of flagged sensor string data with the variables
#'   in a long format and flags in wide format.
#'
#' @param var Variable to pivot.
#'
#' @return Returns \code{dat_long} with the variable and qc_test flag columns
#'   pivoted to a wide format.
#'
#' @importFrom dplyr %>% all_of contains filter relocate rename_with
#' @importFrom stringr str_remove_all
#' @importFrom tidyr pivot_wider
#'
#' @export


pivot_flags_wider <- function(dat_long, var, var_position = NULL) {

  if(is.null(var_position)) var_position <- "sensor_depth_at_low_tide_m"

  dat_wide <- dat_long %>%
    filter(variable == var) %>%
    pivot_wider(
      names_from = variable,
      names_prefix = "value_",
      values_from = value
      ) %>%
    dplyr::rename_with(
      ~ paste0(.x, "_", var),
      .cols = contains("flag")
    ) #%>%
   # relocate(all_of(var), .after = all_of(var_position))

  colnames(dat_wide) <- str_remove_all(colnames(dat_wide), pattern = "_value")

  dat_wide

}
