#' Run specified quality control tests
#'
#' @param dat Data in a wide format. Add more here
#'
#' @param qc_tests QC tests to run.
#'
#' @inheritParams qc_test_grossrange
#' @inheritParams qc_test_climatology
#'
#' @return Tibble of \code{dat} with quality control flag columns.
#'
#' @importFrom dplyr %>% left_join
#' @importFrom purrr reduce
#'
#' @export


# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))
#
#
# dat_qc <- qc_test_all(dat)

 qc_test_all <- function(dat,
                    qc_tests = c("climatology", "grossrange"),
                    climatology_table = NULL,
                    seasons_table = NULL,
                    grossrange_table = NULL) {

  qc_tests <- tolower(qc_tests)

  dat_out <- list(NULL)

  if("climatology" %in% qc_tests) {
    dat_out[[1]] <- qc_test_climatology(
      dat,
      climatology_table = climatology_table,
      seasons_table = seasons_table
    )
  }

  if("grossrange" %in% qc_tests) {
    dat_out[[2]] <- qc_test_grossrange(
      dat,
      grossrange_table = grossrange_table
    )
  }

  # remove empty list elements
  dat_out <- Filter(Negate(is.null), dat_out)

  # join by all common columns
  dat_out %>%
    purrr::reduce(dplyr::left_join)

 }




#' Assign a single QC flag value for each observation
#'
#' @param dat wide data frame with all flag columns
#'
#' @return dat with only 1 flag column
#'
#' @importFrom dplyr %>% c_across contains mutate rename rowwise select ungroup
#' @importFrom tidyr pivot_wider
#'
#' @export

 qc_assign_max_flag <- function(dat) {

   dat %>%
     qc_pivot_longer() %>%
     rowwise() %>%
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









