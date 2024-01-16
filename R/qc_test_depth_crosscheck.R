#' Apply the depth crosscheck test
#'
#' Sensor depth at low tide is estimated from tide charts and the position of
#' each sensor on the string. The estimated depth is recorded in in the
#' deployment log and included in the compiled data in the column
#' \code{sensor_depth_at_low_tide_m}.
#'
#' Some sensors are capable of recording depth (pressure). When this is the
#' case, the minimum sensor depth recorded (i.e., low tide) is compared to the
#' estimated sensor depth at low tide. In the case of large discrepancies, the
#' depth_crosscheck_flag will indicate that the observation is "Suspect / Of
#' Interest". In many cases, the measured sensor depth should be considered more
#' accurate than the estimated depth; however, the measured depth should be
#' carefully evaluated.
#'
#' Note that if there are multiple sensors on the string, *only* the sensor(s)
#' with measured depth values will be evaluated with the depth crosscheck test.
#' If the depth crosscheck test identifies the estimated depth as "Suspect", the
#' other estimated sensor depths should also be considered suspect. For example,
#' if the string was moored in an area 10 m deeper than anticipated, all sensors
#' will likely be 10 m deeper than recorded in the
#' \code{sensor_depth_at_low_tide_m} column.
#'
#' @param dat Data frame of sensor string data in a wide format.
#'
#' @param depth_table Data frame with 1 column: \code{depth_diff_max}.
#'
#'   Default values are used if \code{depth_table = NULL}. To see the
#'   default \code{depth__table}, type \code{subset(thresholds,
#'   qc_test == "depth_crosscheck")} in the console.
#'
#' @param county Character string indicating the county from which \code{dat}
#'   was collected. Used to filter the default \code{depth_crosscheck_table}.
#'   Not required if there is a \code{county} column in \code{dat} or if
#'   \code{depth_table} is provided.
#'
#' @param keep_depth_cols Logical value. If \code{TRUE}, the columns used to
#'   evaluate the difference between measured depth and estimated depth
#'   (\code{min_measured} and \code{abs_diff}) are returned in \code{dat}.
#'   Default is \code{FALSE}.
#'
#' @return Returns \code{dat} in a wide format, with depth crosscheck flag
#'   column named "depth_crosscheck_flag_value".
#'
#' @importFrom dplyr filter group_by left_join mutate rename select summarise
#'   ungroup
#' @importFrom tidyr pivot_longer pivot_wider
#'
#' @export

qc_test_depth_crosscheck <- function(
    dat,
    depth_table = NULL,
    county = NULL,
    keep_depth_cols = FALSE
) {

  message("applying depth_crosscheck test")

  # check that not providing more than one county
  county <- assert_county(dat, county, "qc_test_depth_crosscheck()")

  # import default thresholds from internal data file -----------------------
  if (is.null(depth_table)) {

    depth_table <- thresholds %>%
      filter(qc_test == "depth_crosscheck", county == !!county | is.na(county)) %>%
      select(-c(qc_test, county, month, sensor_type)) %>%
      pivot_wider(values_from = "threshold_value", names_from = threshold)
  }

  # add thresholds to dat and assign flags ---------------------------------------------------
  dat_depth <- dat %>%
    group_by(
      county, station, deployment_range,
      sensor_serial_number, sensor_depth_at_low_tide_m) %>%
    summarise(min_measured = min(sensor_depth_measured_m)) %>%
    ungroup() %>%
    mutate(abs_diff = abs(sensor_depth_at_low_tide_m - min_measured))


  dat <- dat %>%
    left_join(
      dat_depth,
      by = c("county", "station", "deployment_range",
             "sensor_serial_number", "sensor_depth_at_low_tide_m")
    ) %>%
    mutate(
      depth_diff_max = depth_table$depth_diff_max,
      depth_crosscheck_flag = case_when(
        abs_diff > depth_diff_max ~ 3,
        abs_diff <= depth_diff_max ~ 1,
        is.na(abs_diff ) ~ 2
      ),
      depth_crosscheck_flag = ordered(depth_crosscheck_flag, levels = 1:4)
    ) %>%
    pivot_longer(
      cols = c(
        contains("temperature"),
        contains("dissolved_oxygen"),
        contains("salinity"),
        contains("depth_measured")
      ),
      names_to = "variable",
      values_to = "value",
      names_prefix = "value_",
      values_drop_na = FALSE # keep rows without measured depth
    ) %>%
    ungroup()

  # clean up columns --------------------------------------------------------

  if(isFALSE(keep_depth_cols)) {
    dat <- dat %>% select(-c(min_measured, abs_diff, depth_diff_max))
  }

  dat %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, depth_crosscheck_flag),
      names_sort = TRUE
    ) %>%
   select(-c(
     contains("depth_crosscheck_flag_dissolved_oxygen"),
     contains("depth_crosscheck_flag_temperature"),
     contains("depth_crosscheck_flag_salinity")
   ))

}
