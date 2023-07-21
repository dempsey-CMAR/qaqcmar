#' Add lagged versions of column \code{var} to \code{dat}
#'
#' This is an internal function used in \code{qc_test_flat_line()}.
#'
#' @param dat Data frame with at least one column, \code{var}.
#'
#' @param var Column in \code{dat} that will be lagged.
#'
#' @param n_lags Vector of lagged versions of \code{var} to include. For
#'   example, if \code{n_lags} = 1, a lag-1 version named \code{var_lag1} will
#'   be added to \code{dat}. If \code{n_lags} = 2:3, the lag-2 and lag-3
#'   versions will be added and named \code{var_lag2} and \code{var_lag3},
#'   respectively.
#'
#' @return Returns \code{dat} with additional columns that are lagged versions
#'   of column \code{var}.
#'
#' @importFrom dplyr across lag mutate
#' @importFrom purrr map partial

add_n_lag_columns <- function(dat, var, n_lags){
  map_lag <- n_lags %>% map(~partial(lag, n = .x))

  dat %>%
    mutate(
      across(.cols = {{ var }}, .fns = map_lag, .names = "{.col}_lag{n_lags}")
    )
}



# add lead and lag columns to dat -----------------------------------------

# add_lead_and_lag_columns <- function(dat, var, n){
#   map_lag <- n %>% map(~partial(lag, n = .x))
#   map_lead <- n %>% map(~partial(lead, n = .x))
#
#   dat %>%
#     mutate(
#       across(.cols = {{ var }}, .fns = map_lag, .names = "{.col}_lag{n}"),
#       across(.cols = {{ var }}, .fns = map_lead, .names = "{.col}_lead{n}"),
#     )
# }

