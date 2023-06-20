#' Add flag columns for the flat line test
#'
#' Only checks if values are *equal* (no tolerance)
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @return placeholder for now
#'
#' @family tests
#'
#' @importFrom dplyr %>% arrange case_when contains group_by if_else lag lead
#'   left_join mutate select
#' @importFrom lubridate day
#' @importFrom sensorstrings ss_pivot_longer
#' @importFrom stringr str_detect
#' @importFrom tidyr pivot_wider separate
#'
#' @export

qc_test_spike <- function(dat, flat_line_table = NULL, keep_lag_cols = FALSE) {

  # import default thresholds from internal data file
  if (is.null(flat__table)) {
    flat_line_table <- threshold_tables %>%
      filter(qc_test == "flat_line") %>%
      select(-c(qc_test, month, sensor_type))
  }
#
#   spike_table <- spike_table %>%
#     select(variable, threshold, threshold_value)

  flat_line_table <- data.frame(
    count_suspect = 3,
    count_fail = 5
  )

  cols_suspect <- c(
    "value",
    paste("value_lag", 1:(flat_line_table$count_suspect-1), sep = "")
  )

  cols_fail <- c(
    "value",
    paste("value_lag", 1:(flat_line_table$count_fail-1), sep = "")
  )


  x <- dat %>%
    ss_pivot_longer() %>%
    mutate(sensor = paste(sensor_type, sensor_serial_number, sep = "-")) %>%
    group_by(sensor, variable) %>%
    dplyr::arrange(timestamp_utc, .by_group = TRUE) %>%
    add_n_lag_columns(value, 1:flat_line_table$count_fail) %>%
    rowwise() %>%
    mutate(
      # TRUE if value, value_lag1... value_lag_suspect are the same value
      suspect = n_distinct(c_across(all_of(cols_suspect))) == 1,
      # TRUE if value, value_lag1... value_lag_fail are the same value
      fail = n_distinct(c_across(all_of(cols_fail))) == 1,

      flat_line_flag = case_when(
        isTRUE(fail) ~ 4,
        isTRUE(suspect) ~ 3,

        #  is.na(suspect) & is.na(fail) ~ 2,

        TRUE ~ 1
      ),
      flat_line_flag = ordered(flat_line_flag, levels = 1:4)
    ) %>%
    ungroup() %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, flat_line_flag),
      names_sort = TRUE
    )



   qc_plot_flags(x, qc_tests = "flat_line")
#
# # NAs for when lag vals are NA
#   # suspect for when 4 in a row
#     ungroup() %>%
#     #remove extra columns
#     select(
#       -c(lag_value, lead_value, spike_ref, spike_value, sensor,
#          spike_high, spike_low)
#     ) %>%
#     pivot_wider(
#       names_from = variable,
#       values_from = c(value, spike_flag),
#       names_sort = TRUE
#     )

}



