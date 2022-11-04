#' Add flag column for the gap test
#'
#' @param dat Data.frame with at least one column \code{timestamp}.
#' @param variable Variable to apply the test to.
#' @param threshold Gap that fails test.
#'
#' @return placeholder for now
#'
#' @importFrom dplyr %>% case_when group_by lead lag mutate ungroup
#'
#' @export

qc_test_gap <- function(dat, variable, threshold) {

  dat %>%
    mutate(sensor = paste(sensor_type, sensor_serial_number, sep = "-")) %>%
    group_by(sensor) %>%
    mutate(
      diff = as.numeric(
        difftime(timestamp_utc, lag(timestamp_utc), units = "hours")
      ),

      flag = case_when(
        diff > threshold ~ 4,
        diff <= threshold ~ 1,
        timestamp_utc == max(timestamp_utc) ~ 1,
        TRUE ~ diff
      )
    ) %>%
    select(-sensor) %>%
    ungroup()

}





