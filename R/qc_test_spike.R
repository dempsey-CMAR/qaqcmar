#' Add flag columns for the spike test
#'
#' Might want to make this dependent on sample rate (sensor type)
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param spike_table Data frame with 3 columns: \code{variable}: should match
#'   the names of the variables being tested in \code{dat}.
#'
#'   Default is \code{spike_table = NULL}, which uses default values. To see the
#'   default \code{spike_table}, type \code{threshold_tables$spike_table}.
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

qc_test_spike <- function(dat, spike_table = NULL) {
  # import default thresholds from internal data file
  if (is.null(spike_table)) {
    spike_table <- threshold_tables %>%
      filter(qc_test == "spike") %>%
      select(-c(qc_test, month, sensor_type)) # %>%
    # pivot_wider(names_from = "threshold", values_from = "threshold_value")
  }

  spike_table <- spike_table %>%
    select(variable, threshold, threshold_value)

  dat %>%
    ss_pivot_longer() %>%
    left_join(spike_table, by = "variable") %>%
    pivot_wider(names_from = "threshold", values_from = "threshold_value") %>%
    mutate(sensor = paste(sensor_type, sensor_serial_number, sep = "-")) %>%
    group_by(sensor, variable) %>%
    dplyr::arrange(timestamp_utc, .by_group = TRUE) %>%
    mutate(
      lag_value = lag(value),
      lead_value = lead(value),
      spike_ref = (lag_value + lead_value) / 2,
      spike_value = abs(value - spike_ref),
      spike_flag = case_when(
        spike_value > spike_high ~ 4,
        (spike_value <= spike_high & spike_value > spike_low) ~ 3,
        spike_value <= spike_low ~ 1,
        TRUE ~ 2
      ),
      spike_flag = ordered(spike_flag, levels = 1:4)
    ) %>%
    ungroup() %>%
    # remove extra columns
    select(
      -c(
        lag_value, lead_value, spike_ref, spike_value, sensor,
        spike_high, spike_low
      )
    ) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, spike_flag),
      names_sort = TRUE
    )
}
