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

qc_assign_max_flag1 <- function(
    dat,
    qc_tests = c("climatology", "depth_crosscheck",
                 "grossrange", "rolling_sd", "spike")) {

  if (!("variable" %in% colnames(dat))) {
    dat <- qc_pivot_longer(dat, qc_tests = qc_tests)
  }

  vars <- unique(dat$variable)

  dat %>%
    # rowwise is REALLY slow - need to change to map_ of apply
    rowwise() %>%
    # mutate(qc_col = max(c_across(contains("flag"))), na.rm = TRUE) %>%
    mutate(qc_col = max(c_across(contains("flag")))) %>%
    ungroup() %>%
    select(-contains("flag")) %>%
    rename(qc_flag = qc_col) %>%
    # pivot_wider(
    #   names_from = variable,
    #   values_from = c(value, qc_flag),
    #   names_sort = TRUE
    # )
    qc_pivot_wider(vars = vars)
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
#' @importFrom purrr pmap
#' @importFrom tidyr pivot_wider
#'
#' @export

qc_assign_max_flag2 <- function(dat, qc_tests = NULL) {

  if(is.null(qc_tests)) {
    qc_tests = c("climatology", "depth_crosscheck",
                 "grossrange", "rolling_sd", "spike")
  }

  if (!("variable" %in% colnames(dat))) {
    dat <- qc_pivot_longer(dat, qc_tests = qc_tests)
  }

  if("depth_crosscheck_flag_value" %in% colnames(dat)) {
    dat <- rename(dat, depth_crosscheck = depth_crosscheck_flag_value)
  }

  vars <- unique(dat$variable)

  dat <- dat %>%
    mutate(
      qc_col = pmap(select(dat, contains("flag")), max, na.rm = TRUE),
      qc_col = unlist(qc_col)
    ) %>%
    rename(qc_flag = qc_col) %>%
    qc_pivot_wider(vars = vars)

  if("depth_crosscheck" %in% colnames(dat)) {
    dat <- rename(dat, depth_crosscheck_flag_value = depth_crosscheck)
  }

  dat
}


# z <- x %>%
#   filter(variable == "dissolved_oxygen_percent_saturation") %>%
#   pivot_wider(names_from = variable, values_from = value) %>%
#   rename(
#     contains("flag_value"),
#     ~ paste("dissolved_oxygen_percent_saturation", .x)
#   ) %>%

