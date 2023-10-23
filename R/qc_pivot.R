#' Pivot flagged sensor string data
#'
#' @param dat_wide Data frame of flagged sensor string data in wide format.
#'
#' @param qc_tests Quality control tests included in \code{dat_wide}. If
#'   \code{dat_wide} only includes the max flag, use \code{qc_tests = "qc"}.
#'
#' @return Returns \code{dat_wide}, with variables and flags pivoted to a long
#'   format.
#'
#' @importFrom dplyr %>% filter relocate select
#' @importFrom tidyr pivot_longer
#'
#' @export

# # turn this into example
# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))

# dat_long <- dat %>%
#   qc_test_all() %>%
#   qc_pivot_longer()
#
# dat_long <- dat %>%
#   qc_test_all() %>%
#   qc_assign_max_flag() %>%
#   qc_pivot_longer(qc_tests = "qc")


qc_pivot_longer <- function(dat_wide, qc_tests = NULL) {
  if (is.null(qc_tests)) {
    qc_test <- c(
      "climatology",
      "depth_crosscheck",
      "grossrange",
      "rolling_sd",
      "spike"
    )
  }

  qc_tests <- tolower(qc_tests)

  tests_foo <- c(
    "climatology",
    "depth_crosscheck",
    "grossrange",
    "rolling_sd",
    "spike",
    "qc"
  )

  if (!(all(qc_tests %in% tests_foo))) {
    err <- qc_tests[which(!(qc_tests %in% tests_foo))]

    stop(
      paste("<< ", err, " >> is not an accepted value for qc_tests.\nHINT: check spelling\n"),
      collapse = "\n"
    )
  }


  # pivot the variables
  dat <- dat_wide %>%
    # # need this for the case where depth_cross check is the only qc_test
    # rename(
    #   value_sensor_depth_at_low_tide_m = sensor_depth_at_low_tide_m
    # ) %>%
    pivot_longer(
      cols = contains("value"),
      names_to = "variable", names_prefix = "value_",
      values_to = "value",
      values_drop_na = TRUE
    )

  # pivot the flags indicated
  if ("qc" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "qc")
  }

  if ("climatology" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "climatology")
  }

  # if ("depth_crosscheck" %in% qc_tests) {
  #    dat <- dat %>% #pivot_flags_longer(dat, qc_test = "depth_crosscheck") %>%
  #      pivot_wider(values_from = "value", names_from = "variable") %>%
  #      relocate(sensor_depth_at_low_tide_m, .before = sensor_type)
  # }

  if ("flat_line" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "flat_line")
  }


  if ("grossrange" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "grossrange")
  }

  if ("rolling_sd" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "rolling_sd")
  }

  if ("spike" %in% qc_tests) {
    dat <- pivot_flags_longer(dat, qc_test = "spike")
  }

  dat
}


#' Complete pivot of flagged sensor string data
#'
#' @param dat_wide Data frame of flagged sensor string data with the variables
#'   in a long format and flags in wide format.
#'
#' @param qc_test Flag columns to pivot.
#'
#' @return Returns \code{dat_wide} with the qc_test flag columns pivoted to a
#'   long format.
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
