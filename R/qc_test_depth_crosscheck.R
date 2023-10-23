

#' Test the recorded sensor depth matches measured sensor depth.
#'
#' @param dat  Dat
#' @param depth_table TBD
#' @param county TBD
#' @param keep_depth_cols TBD
#'
#' @return TBD
#'
#' @importFrom dplyr filter group_by left_join mutate rename select summarise ungroup
#' @importFrom tidyr pivot_longer pivot_wider
#'
#' @export

qc_test_depth_crosscheck <- function(
    dat,
    depth_table = NULL,
    county = NULL,
    keep_depth_cols = FALSE
    ) {

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
  #dat <- ss_pivot_longer(dat)

  # if(is.null(join_column)) {
  #   dat <- left_join(dat, depth_table, by = "variable")
  # } else {
  #   dat <- left_join(dat, depth_table, by = c("variable", join_column))
  # }


  dat_depth <- dat %>%
    ss_pivot_wider() %>%
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
             "sensor_serial_number", "sensor_depth_at_low_tide_m")) %>%
    mutate(
      depth_diff_max = depth_table$depth_diff_max,
      depth_crosscheck_flag = case_when(
        abs_diff  > depth_diff_max ~ 3,
        abs_diff  <= depth_diff_max ~ 1,
        is.na(abs_diff ) ~ 2
      )
    ) %>%
    ungroup() %>%
    # remove extra columns
    select(-depth_diff_max) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, depth_crosscheck_flag),
      names_sort = TRUE
    ) %>%
    rename(
      sensor_depth_measured_m = value_sensor_depth_measured_m,
     depth_crosscheck_flag_value =  depth_crosscheck_flag_sensor_depth_measured_m
      # # might need to use this long name to match other tests
      # depth_crosscheck_flag_sensor_depth_at_low_tide_m =
      #    depth_crosscheck_flag_sensor_depth_measured_m
    )

  if(isFALSE(keep_depth_cols)) {
    dat <- dat %>% select(-c(min_measured, abs_diff))
  }

  dat

}
