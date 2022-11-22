#' Add flag columns for the spike test
#'
#' Might want to make this dependent on sample rate (sensor type)
#'
#' @param dat Data frame of sensor string data in wide format.
#'
#' @param spike_table Data frame with 3 columns: \code{variable}: should match
#'   the names of the variables being tested in \code{dat}.
#'
#'   Default is \code{spike_table = NULL}, which uses default values. To see the
#'   default \code{spike_table}, type \code{threshold_tables$spike_table}.
#'
#' @return placeholder for now
#'
#' @family tests
#'
#' @importFrom dplyr %>% arrange case_when contains if_else lag lead left_join
#'   mutate select
#' @importFrom sensorstrings ss_pivot_longer
#' @importFrom stringr str_detect
#' @importFrom tidyr pivot_wider separate
#'
#' @export

qc_test_spike <- function(dat, spike_table = NULL) {

  # import default thresholds from internal data file
  if (is.null(spike_table)) {
    spike_table <- threshold_tables$spike_table
  }

  x <- dat %>%
    ss_pivot_longer() %>%
    left_join(spike_table, by = "variable") %>%
    mutate(sensor = paste(sensor_type, sensor_serial_number, sep = "-")) %>%
    group_by(sensor, variable) %>%
    dplyr::arrange(timestamp_utc, .by_group = TRUE) %>%
    mutate(
      lag_value = lag(value),
      lead_value = lead(value),
      spike_ref = (lag_value + lead_value)/2,
      spike_value = abs(value - spike_ref),
      spike_flag = case_when(
        spike_value > threshold_high ~ 4,
        (spike_value <= threshold_high & spike_value > threshold_low) ~ 3,
        spike_value <= threshold_low ~ 1,
        TRUE ~ 2
      ),
      spike_flag = ordered(spike_flag, levels = 1:4)
    ) %>%
    ungroup() %>%
    #remove extra columns
    select(
      -c(
        lag_value, lead_value, spike_ref, spike_value, sensor,
         threshold_high, threshold_low)
    ) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, spike_flag),
      names_sort = TRUE
    )

# https://www.visualisingdata.com/2019/08/five-ways-to-design-for-red-green-colour-blindness/
# flag_colours <- c("chartreuse4", "#E6E1BC", "#EDA247", "#DB4325", "grey24")
# #"#006164",
# x %>%
#   mutate(
#     sensor = paste(sensor_type, sensor_serial_number, sep = "-"),
#     depth = ordered(
#       sensor_depth_at_low_tide_m,
#       levels = sort(unique(dat$sensor_depth_at_low_tide_m))
#     ),
#     depth = paste0(depth, " m")
#   ) %>%
#   filter(
#     sensor != "aquameasure-680360",
#     timestamp_utc > as_datetime("2021-10-07"),
#          timestamp_utc < as_datetime("2021-10-11")
#   ) %>%
# ggplot(aes(timestamp_utc, value_temperature_degree_C, colour = spike_flag_temperature_degree_C)) +
#   geom_point() +
#   #scale_y_continuous(var) +
#   scale_x_datetime("Date") +
#   scale_colour_manual("Flag Value", values = flag_colours, drop = FALSE) +
#   facet_wrap(~ depth + sensor_type, ncol = 2) +
#   theme_light() +
#   theme(
#     strip.text = element_text(colour = "black", size = 10),
#     strip.background = element_rect(fill = "white", colour = "darkgrey")
#   ) +
#   guides(color = guide_legend(override.aes = list(size = 4)))
#

}




#
# qc_test_spike <- function(dat, spike_table = NULL) {
#
#   # import default thresholds from internal data file
#   if (is.null(spike_table)) {
#     spike_table <- threshold_tables$spike_table
#   }
#
#   x <- dat %>%
#     ss_pivot_longer() %>%
#     left_join(spike_table, by = "variable") %>%
#     mutate(sensor = paste(sensor_type, sensor_serial_number, sep = "-")) %>%
#     group_by(sensor, variable) %>%
#     dplyr::arrange(timestamp_utc, .by_group = TRUE) %>%
#     mutate(
#       spike_ref = abs(value - lag(value)),
#       spike_flag = case_when(
#         spike_ref > threshold_high ~ 4,
#         (spike_ref <= threshold_high & spike_ref > threshold_low) ~ 3,
#         spike_ref <= threshold_low ~ 1,
#         TRUE ~ 2
#       ),
#       spike_flag = ordered(spike_flag, levels = 1:4)
#     ) %>%
#     ungroup() %>%
#     #remove extra columns
#     select(-c(spike_ref,  sensor, threshold_high, threshold_low)) %>%
#     pivot_wider(
#       names_from = variable,
#       values_from = c(value, spike_flag),
#       names_sort = TRUE
#     )
#
#
#
#     x %>%
#       mutate(
#         sensor = paste(sensor_type, sensor_serial_number, sep = "-"),
#         depth = ordered(
#           sensor_depth_at_low_tide_m,
#           levels = sort(unique(dat$sensor_depth_at_low_tide_m))
#         ),
#         depth = paste0(depth, " m")
#       ) %>%
#       filter(
#         sensor != "aquameasure-680360",
#         timestamp_utc > as_datetime("2021-10-07"),
#              timestamp_utc < as_datetime("2021-10-11")
#       ) %>%
#
#     ggplot(aes(timestamp_utc, value_temperature_degree_C, colour = spike_flag_temperature_degree_C)) +
#       geom_point() +
#       #scale_y_continuous(var) +
#       scale_x_datetime("Date") +
#       scale_colour_manual("Flag Value", values = flag_colours, drop = FALSE) +
#       facet_wrap(~ depth + sensor_type, ncol = 2) +
#       theme_light() +
#       theme(
#         strip.text = element_text(colour = "black", size = 10),
#         strip.background = element_rect(fill = "white", colour = "darkgrey")
#       ) +
#       guides(color = guide_legend(override.aes = list(size = 4)))
#
#
# }
