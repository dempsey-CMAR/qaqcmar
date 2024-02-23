#' Filter data to keep observations of acceptable quality
#'
#' @param dat Data frame with summary quality control flag columns in the form
#'   `qc_flag_variable_units`.
#' @param keep_dissolved_oxygen_percent_saturation Vector of acceptable flags
#'   for variable dissolved_oxygen_percent_saturation. Default is c(1, 2, NA).
#'   "Suspect/Of Interest" observations are considered biofouling and excluded
#'   from analysis.
#' @param keep_dissolved_oxygen_uncorrected_mg_per_l Vector of acceptable flags
#'   for variable dissolved_oxygen_uncorrected_mg_per_l. Default is c(1, 2, NA).
#'   "Suspect/Of Interest" observations are considered biofouling and excluded
#'   from analysis.
#' @param keep_sensor_depth_measured_m  Vector of acceptable flags
#'   for variable sensor_depth_measured_m. Default is c(1, 2, 3, NA).
#' @param keep_salinity_psu Vector of acceptable flags
#'   for variable salinity_psu. Default is c(1, 2, 3, NA).
#' @param keep_temperature_degree_c Vector of acceptable flags
#'   for variable temperature_degree_c. Default is c(1, 2, 3, NA).
#'
#' @importFrom dplyr %>% filter
#' @importFrom stringr str_detect
#'
#' @export


qc_filter_summary_flags <- function(
    dat,
    keep_dissolved_oxygen_percent_saturation = c(1, 2, NA),
    keep_dissolved_oxygen_uncorrected_mg_per_l = c(1, 2, NA),
    keep_sensor_depth_measured_m = c(1, 2, 3, NA),
    keep_salinity_psu = c(1, 2, NA),
    keep_temperature_degree_c = c(1, 2, 3, NA)
    ) {

  qc_flags <- colnames(dat)[str_detect(colnames(dat), "qc_flag")]

  if ("qc_flag_dissolved_oxygen_percent_saturation" %in% qc_flags) {
    dat <- dat %>%
      filter(
        qc_flag_dissolved_oxygen_percent_saturation %in%
          keep_dissolved_oxygen_percent_saturation)
  }

  if ("qc_flag_dissolved_oxygen_uncorrected_mg_per_l" %in% qc_flags) {
    dat <- dat %>%
      filter(qc_flag_dissolved_oxygen_uncorrected_mg_per_l %in%
               keep_dissolved_oxygen_uncorrected_mg_per_l)
  }

  if ("qc_flag_sensor_depth_measured_m" %in% qc_flags) {
    dat <- dat %>%
      filter(qc_flag_sensor_depth_measured_m %in% keep_sensor_depth_measured_m)
  }

  if ("qc_flag_salinity_psu" %in% qc_flags) {
    dat <- dat %>%
      filter(qc_flag_salinity_psu %in%  keep_salinity_psu)
  }

  if ("qc_flag_temperature_degree_c" %in% qc_flags) {
    dat <- dat %>%
      filter(qc_flag_temperature_degree_c %in% keep_temperature_degree_c)
  }

  dat

}
