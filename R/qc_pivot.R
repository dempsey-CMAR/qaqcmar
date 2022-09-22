#' Title
#'
#' @param dat_wide placeholder
#'
#' @inheritParams qc_test_all
#'
#' @return placeholder
#'
#' @importFrom dplyr %>% filter select
#' @importFrom tidyr pivot_longer
#'
#' @export


qc_pivot_longer <- function(dat_wide,
                            qc_tests = c("climatology", "grossrange")) {

  dat <- dat_wide %>%
    pivot_longer(
      cols = contains("value"),
      names_to = "variable", names_prefix = "value_",
      values_to = "value",
      values_drop_na = TRUE
    )

  if("climatology" %in% qc_tests) {
    dat <- pivot_test_longer(dat, qc_test = "climatology")
  }

  if("grossrange" %in% qc_tests) {
    dat <- pivot_test_longer(dat, qc_test = "grossrange")
  }

  dat

}



#' Title
#'
#' @param dat placeholder
#' @param qc_test placeholder
#'
#' @return placeholder
#'
#' @importFrom dplyr %>% contains filter select
#' @importFrom rlang sym
#' @importFrom tidyr pivot_longer


pivot_test_longer <- function(dat, qc_test) {

  col_name <- paste0(qc_test, "_flag_variable")

  dat %>%
    pivot_longer(
      cols = contains(qc_test),
      names_to = paste0(qc_test, "_flag_variable"),
      names_prefix = paste0(qc_test, "_flag_"),
      values_to = paste0(qc_test, "_flag_value"),
      values_drop_na = TRUE
    ) %>%
    # for sensors that measure two variables, the above adds a row for each var
    # e.g., temperature value + temperature flag AND temperature value + DO flag
    filter(!!sym(col_name) == variable) %>%
    select(-!!sym(col_name))
}
