#' Add flag column for the climatology test
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param climatology_table Data frame with 4 columns: \code{variable}: should
#'   match the names of the variables being tested in \code{dat}. \code{season}:
#'   there should be an entry of "winter", "spring", "summer", and "fall" for
#'   each variable. \code{season_min}: minimum reasonable value for the
#'   corresponding variable during the corresponding season. \code{season_max}:
#'   maximum reasonable value for the corresponding variable during the
#'   corresponding season.
#'
#'   Default values are used if \code{climatology_table = NULL}. To see the
#'   default \code{climatology_table}, type
#'   \code{threshold_tables$climatology_table} in the console.
#'
#' @param seasons_table Data frame with 2 columns: \code{month}: numeric value
#'   of the month and \code{season}, the corresponding season (entries of
#'   "winter", "spring", "summer", and "fall"). Default table is used if
#'   \code{seasons = NULL}. To see the default values, type
#'   \code{threshold_tables$seasons} in the console.
#'
#' @return placeholder for now
#'
#' @family tests
#'
#' @importFrom dplyr %>% case_when left_join mutate rename tibble
#' @importFrom lubridate month parse_date_time
#' @importFrom stringr str_detect
#'
#' @export

# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))
#
# dat2 <-  qc_test_climatology(dat)


qc_test_climatology <- function(
  dat,
  climatology_table = NULL,
  seasons_table = NULL
) {

  # import default thresholds from internal data file
  if(is.null(climatology_table)) {
    climatology_table <- threshold_tables$climatology_table
  }

  if(is.null(seasons_table)) {
    seasons_table <- threshold_tables$seasons_table
  }

  colname_ts <- colnames(dat)[which(str_detect(colnames(dat), "timestamp"))]

  dat <- dat %>%
    ss_pivot_longer() %>%
    rename(tstamp = contains("timestamp")) %>%
    mutate(numeric_month = lubridate::month(tstamp)) %>%
    left_join(seasons_table, by = "numeric_month") %>%
    left_join(climatology_table, by = c("season", "variable")) %>%
    mutate(
      climatology_flag = case_when(
        value > season_max | value < season_min ~ 3,
        value <= season_max & value >= season_min ~ 1,
        TRUE ~ 2
      ),
      climatology_flag = ordered(climatology_flag, levels = c(1:4))
    ) %>%
    #remove extra columns
    select(-c(season_min, season_max, numeric_month, season)) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, climatology_flag)
    )

  colnames(dat)[which(colnames(dat) == "tstamp")] <- colname_ts

  dat

}
