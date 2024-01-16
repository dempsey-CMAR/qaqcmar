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
#' @param county Character string indicating the county from which \code{dat}
#'   was collected. Used to filter the default \code{grossrange_table}. Not
#'   required if there is a \code{county} column in \code{dat} or if
#'   \code{grossrange_table} is provided.
#'
#' @param join_column Optional character string of a column name that is in both
#'   \code{dat} and \code{grossrange_table}. The specified column will be used
#'   to join the two tables. Default is \code{join_column = NULL}, and the
#'   tables are joined only on the \code{sensor_type} and \code{variable}
#'   columns.
#'
#' @param keep_spike_cols  Logical value. If \code{TRUE}, the columns used to
#'   produce the spike value are returned in \code{dat}. Default is
#'   \code{FALSE}.
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
#' @importFrom tidyselect where
#'
#' @export

qc_test_spike <- function(
    dat,
    county = NULL,
    join_column = NULL,
    spike_table = NULL,

    keep_spike_cols = FALSE
) {

  message("applying spike test")

  # check that not providing more than one county
  county <- assert_county(dat, county, "qc_test_spike()")

  # import default thresholds from internal data file
  if (is.null(spike_table)) {
    spike_table <- thresholds %>%
      filter(qc_test == "spike") %>%
      select(-c(qc_test, month)) %>%
      pivot_wider(values_from = "threshold_value", names_from = threshold) %>%
      select(where(~ !any(is.na(.))))

 #   spike_table <- spike_table[, !names(spike_table) %in% join_columns]
  }

  # spike_table <- spike_table %>%
  #   select(variable, threshold, threshold_value)
  # add thresholds to dat and assign flags ---------------------------------------------------
  dat <- ss_pivot_longer(dat)

  if(is.null(join_column)) {
    dat <- left_join(dat, spike_table, by = "variable")
  } else {
    dat <- left_join(dat, spike_table, by = c("variable", join_column))
  }

  dat <- dat %>%
    group_by(
      county, station, deployment_range, sensor_serial_number, variable
    ) %>%
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
    ungroup()

  if(isFALSE(keep_spike_cols)) {
    dat <- dat %>%
      select(-c(lag_value, lead_value,
                spike_ref, spike_value,
                spike_high, spike_low))
  }

  dat %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, spike_flag),
      names_sort = TRUE
    )
}
