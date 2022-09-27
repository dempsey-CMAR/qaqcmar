#' Add flag columns for the grossrange test
#'
#' @param dat placeholder... wide data
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


# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))

qc_test_grossrange <- function(dat, grossrange_table = NULL) {

  # import default thresholds from internal data file
  if (is.null(grossrange_table)) {
    grossrange_table <- threshold_tables$grossrange_table
  }

  # check the vars in table are in the colname and vice versa
  dat_vars <- dat %>%
    select(
      contains("dissolved_oxygen"),
      contains("salinity"),
      contains("temperature")
    ) %>%
    colnames()

  # is this even helpful?
  if (!all(unique(grossrange_table$variable) %in% dat_vars)) {

    missing_var <- grossrange_table[
      which(!(grossrange_table$variable %in% colnames(dat))),
    ]

    message("Variable <<", missing_var, " >> was found in grossrange_table,
            but does not exist in dat")
  }

  if (!all(dat_vars %in% unique(grossrange_table$variable))) {

    missing_var <- dat_vars[which(!(dat_vars %in% grossrange_table$variable))]

    message("Variable <<", missing_var, " >> was found in dat,
            but not in grossrange_table")
  }

  dat %>%
    ss_pivot_longer() %>%
    separate(sensor, into = c("sensor_make", NA), remove = FALSE, sep = "-") %>%
    mutate(
      sensor_make = case_when(
        str_detect(sensor, "HOBO") ~ "hobo",
        str_detect(sensor, "aquaMeasure") ~ "aquameasure",
        str_detect(sensor, "VR2AR") ~ "vemco"
      )
    ) %>%
    left_join(grossrange_table, by = c("sensor_make", "variable")) %>%
    mutate(
      grossrange_flag = case_when(
        value > sensor_max | value < sensor_min  ~ 4,
        value > user_max | value < user_min ~ 3,
        value <= sensor_max | value >= sensor_min ~ 1,
        TRUE ~ 2
      ),
      grossrange_flag = ordered(grossrange_flag, levels = c(1:4))
    ) %>%
    #remove extra columns
    subset(select = -c(sensor_max, sensor_min, user_max, user_min, sensor_make)) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, grossrange_flag)
    )
}
