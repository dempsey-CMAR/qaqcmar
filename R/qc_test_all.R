#' Run specified quality control tests
#'
#' @param dat Data in a wide format.
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
