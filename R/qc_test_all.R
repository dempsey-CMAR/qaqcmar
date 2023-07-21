#' Apply multiple quality control tests
#'
#' @param dat Data frame of sensor string data in a wide format.
#'
#' @param qc_tests Character vector of quality control tests to apply to
#'   \code{dat}. Defaults to all available tests: \code{qc_tests =
#'   c("climatology", "grossrange", "spike")}
#'
#' @inheritParams qc_test_climatology
#' @inheritParams qc_test_flat_line
#' @inheritParams qc_test_grossrange
#' @inheritParams qc_test_rolling_sd
#' @inheritParams qc_test_spike

#'
#' @return Returns \code{dat} with additional quality control flag columns.
#'
#' @importFrom dplyr %>% left_join
#' @importFrom purrr reduce
#'
#' @export

#@inheritParams qc_test_spike

# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))
#
#
# dat_qc <- qc_test_all(dat)

qc_test_all <- function(
  dat,
  qc_tests = NULL,
  climatology_table = NULL,
  flat_line_table = NULL,
  grossrange_table = NULL,
  rolling_sd_table = NULL,
  spike_table = NULL,
  county,
  message = TRUE
) {

  if (is.null(qc_tests)) {
    qc_test <- c("climatology", "flat_line", "grossrange", "rolling_sd", "spike")
  }

  qc_tests <- tolower(qc_tests)

  dat_out <- list(NULL)

  if("climatology" %in% qc_tests) {
    dat_out[[1]] <- qc_test_climatology(
      dat,
      climatology_table = climatology_table,
      county = county
    )
  }

  if("grossrange" %in% qc_tests) {
    dat_out[[2]] <- qc_test_grossrange(
      dat,
      grossrange_table = grossrange_table,
      county = county,
      message = message
    )
  }

  if("rolling_sd" %in% qc_tests) {
    dat_out[[3]] <- qc_test_rolling_sd(
      dat,
      rolling_sd_table = rolling_sd_table
    )
  }

  # if("spike" %in% qc_tests) {
  #   dat_out[[3]] <- qc_test_spike(
  #     dat,
  #     spike_table = spike_table
  #   )
  # }

  # remove empty list elements
  dat_out <- Filter(Negate(is.null), dat_out)

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
   qc_tests =  c("climatology", "grossrange", "spike")
 ) {

   if(!("variable" %in% colnames(dat))) {
     dat <- qc_pivot_longer(dat, qc_tests = qc_tests)
   }

   dat %>%
     rowwise() %>%
     #mutate(qc_col = max(c_across(contains("flag"))), na.rm = TRUE) %>%
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









