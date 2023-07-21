#' Add flag columns for the flat line test
#'
#' Only checks if values are *equal* (no tolerance).
#'
#' Flag of 2 assigned until can evaluate if it fails.
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param flat_line_table text
#'
#' @param keep_lag_cols text
#'
#' @return Format depends on keep_lag_cols
#'
#' @family tests
#'
#' @importFrom dplyr %>% all_of arrange case_when contains group_by if_else lag
#'   lead left_join mutate n_distinct select
#' @importFrom lubridate day
#' @importFrom sensorstrings ss_pivot_longer
#' @importFrom stringr str_detect
#' @importFrom tidyr pivot_wider separate
#'
#' @export

qc_test_flat_line <- function(
    dat,
    flat_line_table = NULL,
    keep_lag_cols = FALSE) {

  # import default thresholds from internal data file
  if (is.null(flat_line_table)) {

    flat_line_table <- data.frame(
      count_suspect = 3,
      count_fail = 5
    )
    # flat_line_table <- threshold_tables %>%
    #   filter(qc_test == "flat_line") %>%
    #   select(-c(qc_test, month, sensor_type))
  }

  cols_suspect <- c(
    "value",
    # Subtract 1 because "value" column counts as lag0
    paste("value_lag", 1:(flat_line_table$count_suspect-1), sep = "")
  )

  cols_fail <- c(
    "value",
    paste("value_lag", 1:(flat_line_table$count_fail-1), sep = "")
  )

  dat <- dat %>%
    ss_pivot_longer() %>%
    mutate(sensor = paste(sensor_type, sensor_serial_number, sep = "-")) %>%
    group_by(sensor, variable) %>%
    dplyr::arrange(timestamp_utc, .by_group = TRUE) %>%
    add_n_lag_columns(value, 1:flat_line_table$count_fail) %>%
    # pivot_wider(
    #   names_from = variable,
    #   values_from = c(contains("lag"), value),
    #   names_sort = TRUE
    # )
    rowwise() %>%
    mutate(
      # TRUE if value, value_lag1... value_lag_suspect are the same value
      suspect = n_distinct(c_across(all_of(cols_suspect))) == 1,
      # TRUE if value, value_lag1... value_lag_fail are the same value
      fail = n_distinct(c_across(all_of(cols_fail))) == 1,

      # # TRUE if value, value_lag1... value_lag_suspect are the same value
      # suspect = var(c_across(all_of(cols_suspect))) < 0.0001,
      # # # TRUE if value, value_lag1... value_lag_fail are the same value
      # fail = var(c_across(all_of(cols_fail))) < 0.0001,

      flat_line_flag = case_when(
        isTRUE(fail) ~ 4,
        # if this is below ~3, then there could be suspect obs between Not Evaluated
        is.na(sum(c_across(contains("lag")))) ~ 2,
        isTRUE(suspect) ~ 3,
        TRUE ~ 1
      ),
      flat_line_flag = ordered(flat_line_flag, levels = 1:4)
    ) %>%
    ungroup()

  if(isFALSE(keep_lag_cols)) {
    dat <- dat %>%
      select(-contains("_lag"), -suspect, -fail) %>%
      pivot_wider(
        names_from = variable,
        values_from = c(value, flat_line_flag),
        names_sort = TRUE
      )
  }

  dat

  #qc_plot_flags(dat4, qc_tests = "flat_line")
}



