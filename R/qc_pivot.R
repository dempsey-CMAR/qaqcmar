#' Title
#'
#' @param dat_wide placeholder
#'
#' @param qc_tests qc tests in dat_wide. If dat_wide only includes the max flag,
#'   use \code{qc_tests = "qc"}.
#'
#' @return placeholder
#'
#' @importFrom dplyr %>% filter select
#' @importFrom tidyr pivot_longer
#'
#' @export

# # turn this into example
# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))
#
# dat_long <- dat %>%
#   qc_test_all() %>%
#   qc_pivot_longer()
#
# dat_long <- dat %>%
#   qc_test_all() %>%
#   qc_assign_max_flag() %>%
#   qc_pivot_longer(qc_tests = "qc")


qc_pivot_longer <- function(dat_wide,
                            qc_tests = c("climatology", "grossrange")) {

  qc_tests <- tolower(qc_tests)

  dat <- dat_wide %>%
    pivot_longer(
      cols = contains("value"),
      names_to = "variable", names_prefix = "value_",
      values_to = "value",
      values_drop_na = TRUE
    )

  #browser()

  if("qc" %in% qc_tests) {
    # if(length(qc_tests) > 1) {
    #   stop()
    # }
    #
    dat <- pivot_flags_longer(dat, qc_test = "qc")
  }

  if("climatology" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "climatology")
  }

  if("grossrange" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "grossrange")
  }

  dat

}


#' Title
#'
#' @param dat_wide placeholder...
#' @param qc_test placeholder
#'
#' @return placeholder
#'
#' @importFrom dplyr %>% contains filter select
#' @importFrom rlang sym
#' @importFrom tidyr pivot_longer


pivot_flags_longer <- function(dat_wide, qc_test) {

  col_name <- paste0(qc_test, "_flag_variable")

  dat_wide %>%
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
