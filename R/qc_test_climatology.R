#' Apply the climatology test
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param climatology_table Data frame with 4 columns: \code{variable}: must
#'   match the names of the variables being tested in \code{dat}; \code{month}:
#'   numeric values from 1 to 12 for each variable; \code{season_min}: minimum
#'   reasonable value for the corresponding variable and month;
#'   \code{season_max}: maximum reasonable value for the corresponding variable
#'   and month.
#'
#'   Default values are used if \code{climatology_table = NULL}. To see the
#'   default \code{climatology_table}, type \code{subset(threshold_tables,
#'   qc_test == "climatology")} in the console.
#'
#' @param county Character string indicating the county from which \code{dat}
#'   was collected. Required if the default \code{climatology_table} is used.
#'
#' @return Returns \code{dat} in a wide format, with climatology flag columns
#'   for each variable in the form "climatology_flag_variable".
#'
#' @family tests
#'
#' @importFrom dplyr %>% as_tibble bind_rows case_when left_join mutate rename
#'   tibble
#' @importFrom lubridate month parse_date_time
#' @importFrom stringr str_detect str_replace
#' @importFrom tidyr pivot_wider
#'
#' @export

# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))
#
# dat2 <-  qc_test_climatology(dat)


qc_test_climatology <- function(
  dat,
  climatology_table = NULL,
  county = NULL
) {

  # import default thresholds from internal data file & format
  if(is.null(climatology_table)) {

    if(is.null(county)) {
      stop("Must specify << county >> in qc_test_climatology()")
    }

    climatology_table <- threshold_tables %>%
      filter(qc_test == "climatology", county == !!county) %>%
      select(-c(qc_test, county, sensor_type)) %>%
      tidyr::pivot_wider(
        names_from = "threshold", values_from = "threshold_value"
      ) %>%
      # placeholder
      bind_rows(
        data.frame(
          variable = rep("dissolved_oxygen_percent_saturation", 12),
          month = seq(1, 12),
          season_min = rep(95, 12),
          season_max = rep(105, 12)
        )
      )
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

  if (!all(dat_vars %in% unique(climatology_table$variable))) {

    missing_var <- unique(dat_vars[which(!(dat_vars %in% climatology_table$variable))])

    message(
      "Variable(s)", paste("\n <<", missing_var, collapse = " >> \n"),
      " >> \n found in dat, but not in climatology_table"
    )
  }

  colname_ts <- colnames(dat)[which(str_detect(colnames(dat), "timestamp"))]

  dat <- dat %>%
    ss_pivot_longer() %>%
    rename(tstamp = contains("timestamp")) %>%
    mutate(month = lubridate::month(tstamp)) %>%
    left_join(climatology_table, by = c("month", "variable")) %>%
    mutate(
      climatology_flag = case_when(
        value > season_max | value < season_min ~ 3,
        value <= season_max & value >= season_min ~ 1,
        TRUE ~ 2
      ),
      climatology_flag = ordered(climatology_flag, levels = 1:4)
    ) %>%
    #remove extra columns
    select(-c(season_min, season_max, month)) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, climatology_flag),
      names_sort = TRUE
    )

  colnames(dat)[which(colnames(dat) == "tstamp")] <- colname_ts

  dat

}
