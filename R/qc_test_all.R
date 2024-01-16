#' Apply multiple quality control tests
#'
#' @param dat Data frame of sensor string data in a wide format.
#'
#' @param qc_tests Character vector of quality control tests to apply to
#'   \code{dat}. Defaults to all available tests: \code{qc_tests =
#'   c("climatology", "depth_crosscheck", "grossrange", "rolling_sd", "spike")}.
#'
#' @param ping Logical argument. If \code{TRUE}, a "ping" sound will be played
#'   when the function has completed. If function is run several times in quick
#'   succession (e.g., for testing the package), this can cause R to abort the
#'   session. Caution is advised when setting this argument to \code{TRUE}.
#'   Default is \code{ping = FALSE}.
#'
#' @param join_column_spike Optional character string of a column name that is in both
#'   \code{dat} and \code{spike_table}. The specified column will be used to
#'   join the two tables. Default is \code{join_column = NULL}, and the tables
#'   are joined only on the \code{sensor_type} and \code{variable} columns.
#'
#' @inheritParams qc_test_climatology
#' @inheritParams qc_test_depth_crosscheck
#' @inheritParams qc_test_flat_line
#' @inheritParams qc_test_grossrange
#' @inheritParams qc_test_rolling_sd
#' @inheritParams qc_test_spike
#'
#' @return Returns \code{dat} with additional quality control flag columns.
#'
#' @importFrom beepr beep
#' @importFrom dplyr %>% left_join
#' @importFrom purrr reduce
#'
#' @export

qc_test_all <- function(
    dat,
    qc_tests = NULL,
    county = NULL,

    climatology_table = NULL,
    #  flat_line_table = NULL,
    depth_table = NULL,
    grossrange_table = NULL,
    rolling_sd_table = NULL,
    spike_table = NULL,
    join_column = NULL,
    join_column_spike = NULL,

    period_hours = 24,
    max_interval_hours = 2,
    align_window = "center",
    keep_sd_cols = FALSE,
    keep_spike_cols = FALSE,

    ping = FALSE
    ) {

  if (is.null(qc_tests)) {
    qc_tests <- c("climatology", "depth_crosscheck",
                 "grossrange", "rolling_sd", "spike")
  }

  qc_tests <- tolower(qc_tests)

  dat_out <- list(NULL)

  if ("climatology" %in% qc_tests) {
    dat_out[[1]] <- qc_test_climatology(
      dat,
      climatology_table = climatology_table,
      county = county,
      join_column = join_column
    )
  }

  if ("depth_crosscheck" %in% qc_tests) {
    dat_out[[2]] <- qc_test_depth_crosscheck(
      dat,
      depth_table = depth_table,
      county = county
    )
  }

  if ("grossrange" %in% qc_tests) {
    dat_out[[3]] <- qc_test_grossrange(
      dat,
      grossrange_table = grossrange_table,
      county = county,
      join_column = join_column
    )
  }

  if ("rolling_sd" %in% qc_tests) {
    dat_out[[4]] <- qc_test_rolling_sd(
      dat,
      rolling_sd_table = rolling_sd_table,
      county = county,
      join_column = join_column,

      period_hours = period_hours,
      max_interval_hours = max_interval_hours,
      align_window = align_window,
      keep_sd_cols = keep_sd_cols
    )
  }

  if("spike" %in% qc_tests) {
    dat_out[[5]] <- qc_test_spike(
      dat,
      spike_table = spike_table,
      join_column = join_column_spike,
      keep_spike_cols = keep_spike_cols
    )
  }

  # remove empty list elements
  dat_out <- Filter(Negate(is.null), dat_out)

  if(isTRUE(ping)) beep("ping")

  # join by all common columns
  dat_out %>%
    purrr::reduce(dplyr::left_join)
}


#' Assign each observation the maximum flag from applied QC tests.
#'
#' ** change the spike test values at beginning/end to NA instead of 2
#'
#' @param dat Data frame in long or wide format with flag columns from multiple
#'   quality control tests.
#'
#' @param qc_tests Quality control tests included in \code{dat}.
#'
#' @return Returns \code{dat} in a wide format, with a single flag column for
#'   each variable column.
#'
#' @importFrom dplyr %>% c_across contains mutate rename rowwise select ungroup
#' @importFrom tidyr pivot_wider
#'
#' @export

qc_assign_max_flag <- function(
    dat,
    qc_tests = c("climatology", "depth_crosscheck",
                 "grossrange", "rolling_sd", "spike")) {

  if (!("variable" %in% colnames(dat))) {
    dat <- qc_pivot_longer(dat, qc_tests = qc_tests)
  }

  # check if ALL flag values are "2". if so, max flag is 2. Otherwise ignore
  # OR just assign 2
  dat %>%
    # rowwise is REALLY slow - need to change to map_ of apply
    rowwise() %>%
    # mutate(qc_col = max(c_across(contains("flag"))), na.rm = TRUE) %>%
    mutate(qc_col = max(c_across(contains("flag")))) %>%
    ungroup() %>%
    select(-contains("flag")) %>%
    rename(qc_flag = qc_col) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, qc_flag),
      names_sort = TRUE
    )
}
