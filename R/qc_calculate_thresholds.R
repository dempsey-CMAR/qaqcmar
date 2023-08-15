#' Calculate gross range test user thresholds
#'
#' The gross range user thresholds are calculated from historical data as the
#' mean +/- 3 standard deviations:
#'
#' \deqn{user_{min} = avg_{var} - 3 * stdev_{var}} \deqn{user_{max} = avg_{var} +
#' 3 * stdev_{var}}
#'
#' where \eqn{avg_{var}} is average of the variable of interest, and
#' \eqn{stdev_{var}} is the standard deviation of the variable of interest.
#'
#' This function does not automatically group by any variables. To calculate the
#' user thresholds by group (e.g., county) use
#' \code{dplyr::group_by(group_variable)}, and send the results to
#' \code{qc_calculate_user_thresholds()}.
#'
#' @param dat Data frame with at least one column.
#'
#' @param var Unquoted character string indicating which column in \code{dat} to
#'   calculate the thresholds for, e.g., \code{var = temperature_degree_c}.
#'
#' @param n_sd Number of standard deviations to add / subtract from mean to
#'   calculate the user thresholds. Default is \code{n_sd = 3}.
#'
#' @param keep_stats Logical argument indicating whether to keep the calculated
#'   mean and standard deviation columns.
#'
#' @return Returns a tibble with county, variable, user_min, user_max (and
#'   optionally mean_var and sd_var).
#'
#' @importFrom dplyr everything mutate select summarise
#' @importFrom ggplot2 ensym
#' @importFrom stringr str_remove
#' @importFrom tidyr pivot_longer
#'
#' @export

qc_calculate_user_thresholds <- function(
    dat, var, n_sd = 3, keep_stats = FALSE) {
  dat <- dat %>%
    rename(variable = {{ var }}) %>%
    summarise(
      mean_var = mean(variable),
      sd_var = sd(variable)
    ) %>%
    mutate(
      qc_test = "grossrange",
      variable = as.character(ensym(var)),
      variable = str_remove(variable, "value_"),
      user_min = mean_var - n_sd * sd_var,
      user_max = mean_var + n_sd * sd_var
    ) %>%
    select(qc_test, variable, everything())

  if (isFALSE(keep_stats)) dat <- dat %>% select(-c(mean_var, sd_var))

  dat %>%
    pivot_longer(
      cols = c(contains("user"), contains("_var")),
      values_to = "threshold_value", names_to = "threshold"
    )
}


#' Calculate climatology test (monthly) thresholds
#'
#' The climatology thresholds are calculated from historical data for each month
#' as the mean +/- 3 standard deviations:
#'
#' \deqn{season_{min} = avg_{season} - 3 * stdev_{season}} \deqn{season_{max} =
#' avg_{season} + 3 * stdev_{season}}
#'
#' \eqn{avg_{season}} is calculated as the average of all observations for a
#' given month, and \code{stdev_{season}} is the associated standard deviation.
#'
#' This function does only automatically groups by any **month**. To calculate
#' the climatology thresholds by group (e.g., county) use
#' \code{dplyr::group_by(group_variable)}, and send the results to
#' \code{qc_calculate_climatology_thresholds()}
#'
#' @inheritParams qc_calculate_user_thresholds
#'
#' @param dat Data frame with at least two columns: \code{timestamp_utc} or
#'   \code{month} and the variable for which to calculate the thresholds. If
#'   there is no column named \code{month}, the month will be extracted from
#'   \code{timestamp_utc}.
#'
#' @param ... additional grouping variable
#'
#' @return tibble with
#'
#' @importFrom dplyr group_by mutate
#' @importFrom lubridate month
#'
#' @export

qc_calculate_climatology_thresholds <- function(
    dat, var, ..., n_sd = 3, keep_stats = FALSE) {
  if(!("month" %in% colnames(dat))) {
    dat <-  dat %>%
      mutate(month = lubridate::month(timestamp_utc))
  }

  dat %>%
    group_by(..., month) %>%
    qc_calculate_user_thresholds(
      var = {{ var }}, n_sd = n_sd, keep_stats = keep_stats
    ) %>%
    mutate(
      qc_test = "climatology",
      threshold = case_when(
        threshold == "user_min" ~ "season_min",
        threshold == "user_max" ~ "season_max",
        TRUE ~ NA_character_
      )
    )
}


#' Calculate rolling standard deviation thresholds
#'
#' The rolling standard deviation thresholds are calculated from historical data
#' as the upper quartile of historical observations.
#'
#' This function does not automatically group by any variables. To calculate the
#' thresholds by group (e.g., county) use
#' \code{dplyr::group_by(group_variable)}, and send the results to
#' \code{qc_calculate_rolling_sd_thresholds()}.
#'
#' @param dat data.frame. Must include column sd_roll.
#' @param var variable to calculate thresholds for.
#' @param prob sent to quantile function
#'
#' @return tibble with
#'
#' @importFrom stats quantile
#'
#' @export

qc_calculate_rolling_sd_thresholds <- function(dat, var, prob = 0.95) {
  # turn this into proper error message
  # assert_that(length(prob) == 2)

  dat %>%
    summarise(
      q = quantile(sd_roll, probs = prob, na.rm = TRUE)
    ) %>%
    rename(rolling_sd_max = q) %>%
    mutate(
      qc_test = "rolling_sd",
      variable = as.character(ensym(var)),
      variable = str_remove(variable, "value_")
    ) %>%
    select(qc_test, variable, everything()) %>%
    pivot_longer(
      cols = rolling_sd_max,
      values_to = "threshold_value", names_to = "threshold"
    )
}
