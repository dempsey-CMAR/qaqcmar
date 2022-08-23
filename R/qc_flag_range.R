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

qc_flag_range <- function(dat, variable, threshold) {

  dat %>%
    group_by(sensor) %>%
    mutate(
      diff = as.numeric(
        #difftime(lead(timestamp_utc), timestamp_utc, units = "hours")
        difftime(timestamp_utc, lag(timestamp_utc), units = "hours")
      ),

      flag = case_when(
        diff > threshold ~ 4,
        diff <= threshold ~ 1,
        timestamp_utc == max(timestamp_utc) ~ 1,
        TRUE ~ diff
      )
    ) %>%
    ungroup()

}


#test

# DD test right back!



