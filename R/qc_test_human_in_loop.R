#' Apply human in the loop flags and comments
#'
#' @param dat Data frame of flagged sensor string data in wide format.
#'
#' @param human_in_loop_table Table with information required to assign the
#'   human in the loop flags. Must include the following columns: station,
#'   depl_range, variable, sensor_serial number (if \code{NA}, all sensors that
#'   recorded variable will be flagged), timestamp_prompt (indicates whether
#'   flags should be applied "between" the timestamp_utc_min
#'   and	timestamp_utc_max or "outside" these timestamps),
#'   timestamp_utc_min,	timestamp_utc_max, qc_test_column (qc flag column that
#'   is being upgraded), qc_flag_value (existing flag value for qc_test_column),
#'   human_in_loop_flag_value, and human_in_loop_comment (will be included in
#'   the dataset).
#'
#' @param qc_tests Character vector of quality control tests that have been
#'   applied to \code{dat}. Passed to \code{qc_pivot_longer()}. Defaults to all
#'   available tests: \code{qc_tests = c("climatology", "depth_crosscheck",
#'   "grossrange", "rolling_sd", "spike")}.
#'
#' @return Returns \code{dat} with a \code{human_in_loop_flag} column for each
#'   variable and a \code{human_in_loop_comment} column.
#'
#' @importFrom dplyr distinct filter last_col relocate rename select
#'
#' @export


qc_test_human_in_loop <- function(
    dat,
    human_in_loop_table = NULL,
    #path_human_in_loop,
    qc_tests = c("climatology", "grossrange", "rolling_sd", "spike")
) {

  message("applying human in the loop flags")

  # check for multiple deployments

#
#   if(is.null(human_in_loop_table)) {
#     human_in_loop <- read_excel(
#       here("human_in_loop/human_in_loop.xlsx"), na = "NA"
#     ) %>%
#       filter(station == !!station, depl_range == !!depl_range)
#   }

  hil_station <- human_in_loop_table$station
  hil_depl <- human_in_loop_table$depl_range
  hil_var <- human_in_loop_table$variable
  hil_sn <- human_in_loop_table$sensor_serial_number
  hil_timestamp_prompt <- human_in_loop_table$timestamp_prompt
  hil_timestamp_min <- human_in_loop_table$timestamp_utc_min
  hil_timestamp_max <- human_in_loop_table$timestamp_utc_max
  hil_qc_test_ref_column <- human_in_loop_table$qc_test_column
  hil_ref_flag_value <- human_in_loop_table$qc_flag_value
  hil_flag_value	<- human_in_loop_table$human_in_loop_flag_value
  hil_comment <-	human_in_loop_table$human_in_loop_comment

  if(is.na(hil_var) && is.na(hil_sn)) {
    var_sn <- dat %>%
      dplyr::select(-contains("flag")) %>%
      ss_pivot_longer() #%>%
      #dplyr::distinct(variable, sensor_serial_number)
    hil_var <- unique(var_sn$variable)
    hil_sn <- unique(var_sn$sensor_serial_number)
  } else if(is.na(hil_var) && !is.na(hil_sn)) {
    hil_var <- dat %>%
      dplyr::select(-contains("flag")) %>%
      ss_pivot_longer() %>%
      dplyr::filter(sensor_serial_number == hil_sn) %>%
      dplyr::distinct(variable)
    hil_var <- hil_var$variable
  } else if (!is.na(hil_var) && is.na(hil_sn)) {
    hil_sn <- dat %>%
      dplyr::select(-contains("flag")) %>%
      ss_pivot_longer() %>%
      dplyr::filter(variable == hil_var) %>%
      dplyr::distinct(sensor_serial_number)
    hil_sn <- hil_sn$sensor_serial_number
  }

  if(is.na(hil_timestamp_min)) hil_timestamp_min <- min(dat$timestamp_utc)
  if(is.na(hil_timestamp_max)) hil_timestamp_max <- max(dat$timestamp_utc)

  if (hil_timestamp_prompt == "between") {
    filter_text <- "between(timestamp_utc, hil_timestamp_min, hil_timestamp_max)"
  } else if (hil_timestamp_prompt == "outside") {
    filter_text <- "(timestamp_utc <= hil_timestamp_min |
    timestamp_utc >= hil_timestamp_max)"
  } else {
    stop(paste0("hil_timestamp_prompt must be << 'between' >> or << 'outside' >>,\nnot << ", hil_timestamp_prompt, " >>"))
  }

  if(is.na(hil_ref_flag_value)) hil_ref_flag_value <- c(1, 2, 3, 4)


#browser()

  dat %>%
    qc_pivot_longer(qc_tests = qc_tests) %>%
    rename(
      human_in_loop_reference_flag_col = all_of(hil_qc_test_ref_column)
    ) %>%
    mutate(
      human_in_loop_flag_value = if_else(
        (variable %in% hil_var &
           sensor_serial_number %in% hil_sn &
           eval(parse(text = filter_text)) &
           human_in_loop_reference_flag_col %in% hil_ref_flag_value),
        hil_flag_value, 1),
      human_in_loop_flag_value = ordered(human_in_loop_flag_value, levels = 1:4),

      human_in_loop_comment= if_else(
        (variable %in% hil_var &
           sensor_serial_number %in% hil_sn &
           eval(parse(text = filter_text)) &
           human_in_loop_reference_flag_col %in% hil_ref_flag_value),
        hil_comment, ""
      )
    ) %>%
    select(-human_in_loop_reference_flag_col) %>%
    qc_pivot_wider() %>%
    relocate(human_in_loop_comment, .after = last_col())
}
