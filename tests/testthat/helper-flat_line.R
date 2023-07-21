# June 20, 2023
#' testdata was generated such that we KNOW what flag should be assigned to each
#' observation (data-raw/test_data_climatology.R)
#'
#' Here, qc_test_climatology() is applied to the test data. The qc'd data is
#' then separated into a data frame for each flag value, based on
#' the timestamps used to generate the data in data-raw/test_data.R.
#'
#' The tests check that each data frame include the expected flag value, and
#' only the expected flag value.


#' @importFrom dplyr %>% anti_join
#' @importFrom lubridate day

path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_flat_line.RDS"))

# ss_ggplot_variables(dat) +
#   geom_point(size = 3)

#
# qc_flat <- dat %>%
#   qc_test_flat_line()
#
# qc_plot_flags(qc_flat, "flat_line")
#
#
# x <- data.frame(lag0 = c(1, 1, 1, 1, 1, 1, 2:10))
#
# y <- x %>%
#   add_n_lag_columns(lag0, 1:4) %>%
#   rowwise() %>%
#   mutate(
#     suspect = n_distinct(c_across(contains("lag"))) == 1,
#     flat_line_flag = case_when(
#
#       is.na(sum(c_across(contains("lag")))) ~ 2,
#       isTRUE(suspect) ~ 3,
#
#       TRUE ~ 1
#     ),
#     flat_line_flag = ordered(flat_line_flag, levels = 1:4)
#   )
#
#
#
# depl_qc <- depl_trim %>%
#   qc_test_flat_line()
