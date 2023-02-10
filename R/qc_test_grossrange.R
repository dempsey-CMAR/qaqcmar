#' Apply the gross range test
#'
#' The value must be greater than the threshold to trigger flag (e.g., value >
#' sensor_max is assigned a flag of 4; value == sensor_max is assigned a flag of
#' 3).
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param grossrange_table Data frame with 8 columns: \code{variable}: must
#'   match the names of the variables being tested in \code{dat}.
#'   \code{sensor_type}: type of sensor that recorded the observation;
#'   \code{sensor_min}: minimum value the sensor can record; \code{sensor_max}:
#'   maximum value the sensor can record. \code{user_min}: minimum reasonable
#'   value; \code{user_max}: maximum reasonable value.
#'
#'   Default values are used if \code{grossrange_table = NULL}. To see the
#'   default \code{grossrange_table}, type \code{subset(threshold_tables,
#'   qc_test == "grossrange")} in the console.
#'
#' @param county Character string indicating the county from which \code{dat}
#'   was collected. Required if the default \code{grossrange_table} is used.
#'
#' @param message Logical argument indicating whether to display a message if
#'   any \code{user_min} < \code{sensor_min} and/or \code{user_max} >
#'   \code{sensor_max} (i.e., flag of 3 cannot be applied).
#'
#' @return Returns \code{dat} in a wide format, with grossrange flag columns for
#'   each variable in the form "grossrange_flag_variable".
#'
#' @family tests
#'
#' @importFrom dplyr %>% case_when contains distinct inner_join left_join mutate
#'   select
#' @importFrom sensorstrings ss_pivot_longer
#' @importFrom stringr str_detect str_remove
#' @importFrom tidyr pivot_wider separate
#' @importFrom utils capture.output
#'
#' @export

qc_test_grossrange <- function(
    dat,
    grossrange_table = NULL,
    county = NULL,
    message = TRUE
) {

  # import default thresholds from internal data file -----------------------
  if (is.null(grossrange_table)) {

    if(is.null(county)) {
      stop("Must specify << county >> in qc_test_grossrange()")
    }

    grossrange_table <- threshold_tables %>%
      filter(qc_test == "grossrange", county == !!county | is.na(county)) %>%
      select(-c(qc_test, county, month)) %>%
      pivot_wider(names_from = "threshold", values_from = "threshold_value") %>%
      # placeholder
      bind_rows(
        data.frame(
          variable = rep("dissolved_oxygen_percent_saturation"),
          user_min = 80, user_max = 120
        )
      )

    user_thresh <- grossrange_table %>%
      select(variable, contains("user")) %>%
      filter(!is.na(user_min) & !is.na(user_max))

    sensor_thresh <- grossrange_table %>%
      select(sensor_type, variable, contains("sensor")) %>%
      filter(!is.na(sensor_type))

    grossrange_table <- sensor_thresh %>%
      inner_join(user_thresh, by = "variable")

  }

  # message if user thresholds are larger than sensor thresholds --------------
  grossrange_check <- grossrange_table %>%
    mutate(
      check_max = user_max > sensor_max,
      check_min = user_min < sensor_min
    )

  check_max <- grossrange_check %>%
    filter(check_max == 1) %>%
    distinct(sensor_type, variable) %>%
    as.data.frame()

  if(isTRUE(message)) {
    if(nrow(check_max) > 0) {
      message("<< user_max >> is greater than << sensor_max >> for: ")
      message(paste(utils::capture.output(check_max), collapse = "\n"))
    }

    check_min <- grossrange_check %>%
      filter(check_min == 1) %>%
      distinct(sensor_type, variable) %>%
      as.data.frame()

    if(nrow(check_min) > 0) {
      message("<< user_min >> is less than << sensor_min >> for: ")
      message(paste(utils::capture.output(check_min), collapse = "\n"))
    }
  }

  #  warning if there are variables in dat that do not have threshold --------
  dat_vars <- dat %>%
    select(
      contains("depth_measured"),
      contains("dissolved_oxygen"),
      contains("salinity"),
      contains("temperature")
    ) %>%
    colnames()

  if (!all(dat_vars %in% unique(grossrange_table$variable))) {

    missing_var <- unique(dat_vars[which(!(dat_vars %in% grossrange_table$variable))])

    warning(
      "Variable(s)", paste("\n <<", missing_var, collapse = " >> \n"),
      " >> \n found in dat, but not in grossrange_table"
    )
  }

# add thresholds to dat and assign flags ---------------------------------------------------
  dat %>%
    ss_pivot_longer() %>%
    left_join(grossrange_table, by = c("sensor_type", "variable")) %>%
    # sensor_max and sensor_min get evaluated first, so don't need to worry
    # about if user_min < sensor_min (it will get assigned a flag of 4)
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
