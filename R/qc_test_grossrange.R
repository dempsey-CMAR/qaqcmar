#' Add flag columns for the grossrange test
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param grossrange_table Data frame with 6 columns: \code{variable}: should
#'   match the names of the variables being tested in \code{dat}.
#'   \code{sensor_make}: this may change \code{sensor_min}: minimum value the
#'   sensor can record. \code{sensor_max}: maximum value the sensor can record.
#'   \code{user_min}: minimum reasonable value; smaller values are "of
#'   interest". \code{user_max}: maximum reasonable value; larger values are "of
#'   interest".
#'
#'   Default is \code{grossrange_table = NULL}, which uses default values. To
#'   see the default \code{grossrange_table}, type
#'   \code{threshold_tables$grossrange_table}.
#'
#' @return placeholder for now
#'
#' @family tests
#'
#' @importFrom dplyr %>% case_when contains left_join mutate select
#' @importFrom sensorstrings ss_pivot_longer
#' @importFrom stringr str_detect
#' @importFrom tidyr pivot_wider separate
#'
#' @export

qc_test_grossrange <- function(dat, grossrange_table = NULL) {

  # import default thresholds from internal data file
  if (is.null(grossrange_table)) {
    grossrange_table <- threshold_tables$grossrange_table
  }

  # check the vars in table are in the colname and vice versa
  dat_vars <- dat %>%
    select(
      contains("depth_measured"),
      contains("dissolved_oxygen"),
      contains("salinity"),
      contains("temperature")
    ) %>%
    colnames()

  # is this even helpful?
  if (!all(unique(grossrange_table$variable) %in% dat_vars)) {

    missing_var <- unique(grossrange_table[
      which(!(grossrange_table$variable %in% dat_vars)), "variable"
    ])

    for (i in 1:seq_along(missing_var)) {
      message("Variable << ", unique(missing_var$variable[i]), " >>
            was found in grossrange_table, but does not exist in dat")
    }
  }

  if (!all(dat_vars %in% unique(grossrange_table$variable))) {

    missing_var <- unique(dat_vars[which(!(dat_vars %in% grossrange_table$variable))])

    for (i in seq_along(missing_var)) {
      message("Variable << ", missing_var[i], " >> was found in dat,
            but not in grossrange_table")
    }
  }

  dat %>%
    ss_pivot_longer() %>%
    left_join(grossrange_table, by = c("sensor_type", "variable")) %>%
    mutate(
      grossrange_flag = case_when(
        value > sensor_max | value < sensor_min  ~ 4,
        (value <= sensor_max & value > user_max) |
          (value >= sensor_min &  value < user_min) ~ 3,
        value <= user_max | value >= user_min ~ 1,
        TRUE ~ 2
      ),
      grossrange_flag = ordered(grossrange_flag, levels = 1:4)
    ) %>%
    #remove extra columns
    select(-c(sensor_max, sensor_min, user_max, user_min)) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, grossrange_flag),
      names_sort = TRUE
    )
}
