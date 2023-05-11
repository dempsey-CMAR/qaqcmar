#' Apply the gross range test
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param rate_of_change_table Data frame with two columns: \code{variable}:
#'   must match the names of the variables being tested in \code{dat}.
#'   \code{stdev_max}: minimum accepted value for the rolling standard
#'   deviation. Default values are used if \code{rate_of_change_table = NULL}.
#'
#' @param period_hours Length of a full cycle in hours. Default assumes a daily
#'   cycle of \code{period_hours = 24}.
#'
#' @param align_window Alignment for the window used to calculate the rolling
#'   standard deviation. Passed to \code{zoo:rollapply()}. Default is
#'   \code{align_window = "center"}. Other options are \code{"right"} (backward
#'   window) and \code{"left"} (forward window).
#'
#' @param keep_sd_cols Logical value. If \code{TRUE}, the columns used to
#'   produce the rolling standard deviation (int_sample, n_sample, and sd_roll)
#'   are returned in \code{dat}. Default is \code{FALSE}.
#'
#' @return Returns \code{dat} in a wide format, with rate of change flag columns
#'   for each variable in the form "rate_of_change_flag_variable".
#'
#' @family tests
#'
#' @importFrom dplyr %>% case_when group_by if_else left_join mutate select
#'   ungroup
#' @importFrom sensorstrings ss_pivot_longer
#' @importFrom stats sd
#' @importFrom tidyr pivot_wider
#' @importFrom zoo rollapply
#'
#' @export

qc_test_rate_of_change <- function(
    dat,
    period_hours = 24,
    rate_of_change_table = NULL,
    align_window = "center",
    keep_sd_cols = FALSE
) {

  # import default thresholds from internal data file -----------------------
  if (is.null(rate_of_change_table)) {

    # rate_of_change_table <- threshold_tables %>%
    #   filter(qc_test == "rate_of_change") %>%
    #   select(-c(qc_test, county, month)) %>%
    #   pivot_wider(names_from = "threshold", values_from = "threshold_value")
    rate_of_change_table <- data.frame(
      variable = c(
        "dissolved_oxygen_percent_saturation",
        "temperature_degree_c",
        "salinity_psu"
        ),
      stdev_max = c(5, 5, 5)
    )
  }

# add warning about variables in each table?

# add thresholds to dat and assign flags ---------------------------------------------------
  dat <-  dat %>%
    ss_pivot_longer() %>%
    left_join(rate_of_change_table, by = "variable") %>%
    group_by(county, station, deployment_range, variable, sensor_serial_number) %>%

    mutate(
      # sample interval
      int_sample = difftime(timestamp_utc, lag(timestamp_utc), units = "mins"),
      int_sample = round(as.numeric(int_sample)),

      # number of samples in  period_hours
      n_sample = (60 / int_sample) * period_hours,
      n_sample = if_else(is.na(n_sample), 1, n_sample), # first obs

      # rolling sd
      sd_roll = rollapply(
        value, width = n_sample, align = align_window, FUN = sd, fill = NA
      ),
      # assign flags
      rate_of_change_flag = case_when(
        sd_roll > stdev_max ~ 3,
        sd_roll <= stdev_max ~ 1,
        is.na(sd_roll) ~ 2
      )
    ) %>%
    ungroup() %>%
    #remove extra columns
    select(-stdev_max) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, rate_of_change_flag),
      names_sort = TRUE
    )

    if(isFALSE(keep_sd_cols)) {
      dat <- dat %>% select(-c(int_sample, n_sample, sd_roll))
    }

    dat
}
