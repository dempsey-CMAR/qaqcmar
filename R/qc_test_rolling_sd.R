#' Apply the rolling standard deviation test
#'
#' For large data gaps n_int will be really large so n_sample will -> 0 and
#' sd_roll will be NA.
#'
#' When n_interval = period_hours, sd_roll = NA
#'
#' Going to explicitly set n_sample to 0 when sample_int > n_period (when there
#' is potentially 1 or less samples in the time frame of interest).
#'
#' \code{sd_roll} is rounded to 2 decimal places.
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param rolling_sd_table Data frame with two columns: \code{variable}: must
#'   match the names of the variables being tested in \code{dat}.
#'   \code{stdev_max}: minimum accepted value for the rolling standard
#'   deviation. Default values are used if \code{rolling_sd_table = NULL}.
#'
#' @param period_hours Length of a full cycle in hours. Default assumes a daily
#'   cycle of \code{period_hours = 24}.
#'
#' @param min_interval_hours Minimum accepted interval between two observations.
#'   If the interval between two observations is greater than this value, the
#'   rolling standard deviation will be set to \code{NA}. This is important
#'   because for large intervals, the number of observations in
#'   \code{period_hours} will be small. For example, if samples are collected
#'   every 6 hours, only 4 observations would be used to calculate
#'   \code{roll_sd}.
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
#' @return Returns \code{dat} in a wide format, with rolling standard deviation
#'   flag columns for each variable in the form "rolling_sd_flag_variable".
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

qc_test_rolling_sd <- function(
    dat,
    rolling_sd_table = NULL,
    period_hours = 24,
    min_interval_hours = 2,
    align_window = "center",
    keep_sd_cols = FALSE) {

  # import default thresholds from internal data file -----------------------
  if (is.null(rolling_sd_table)) {

    # rolling_sd_table <- threshold_tables %>%
    #   filter(qc_test == "rolling_sd") %>%
    #   select(-c(qc_test, county, month)) %>%
    #   pivot_wider(names_from = "threshold", values_from = "threshold_value")
    rolling_sd_table <- data.frame(
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
    left_join(rolling_sd_table, by = "variable") %>%
    group_by(county, station, deployment_range, variable, sensor_serial_number) %>%
    dplyr::arrange(timestamp_utc, .by_group = TRUE) %>%
    mutate(
      # sample interval
      int_sample = difftime(timestamp_utc, lag(timestamp_utc), units = "mins"),
      int_sample = round(as.numeric(int_sample)),

      # number of samples in  period_hours
      # 60 mins / hour * 1 sample / int_sample mins * 24 hours / period
      n_sample = round((60 / int_sample) * period_hours),
      # n_sample = if_else(is.na(n_sample), 1, n_sample), # first obs
      effective_sample = case_when(
        # first observation of each group is NA, which will give error in rollapply
        is.na(n_sample) ~ 0,
        # if the sample interval is greater than acceptable limit, set n_sample to 0
        # so that roll_sd will be 0
        int_sample > min_interval_hours * 60 ~ 0,
        TRUE ~ n_sample
      ),

      # rolling sd
      sd_roll = rollapply(
        value, width = effective_sample,
        align = align_window, FUN = sd, fill = NA
      ),

      sd_roll = round(sd_roll, digits = 2)
    )


  # assign flags
  dat <- dat %>%
    mutate(
      rolling_sd_flag = case_when(
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
      values_from = c(value, rolling_sd_flag),
      names_sort = TRUE
    )

  if(isFALSE(keep_sd_cols)) {
    dat <- dat %>% select(-c(int_sample, n_sample, effective_sample, sd_roll))
  }

  dat
}
