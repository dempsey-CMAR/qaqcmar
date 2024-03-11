#' Filter data to keep observations of acceptable quality
#'
#' @param dat Data frame with summary quality control flags in long format
#'   (e.g., output of `qc_pivot_longer()`).
#'
#' @param keep_dissolved_oxygen_percent_saturation Vector of acceptable flags
#'   for variable dissolved_oxygen_percent_saturation. Default is c(1, 2, NA).
#'   "Suspect/Of Interest" observations are considered biofouling and excluded
#'   from analysis.
#'
#' @param keep_dissolved_oxygen_uncorrected_mg_per_l Vector of acceptable flags
#'   for variable dissolved_oxygen_uncorrected_mg_per_l. Default is c(1, 2, NA).
#'   "Suspect/Of Interest" observations are considered biofouling and excluded
#'   from analysis.
#'
#' @param keep_sensor_depth_measured_m  Vector of acceptable flags for variable
#'   sensor_depth_measured_m. Default is c(1, 2, 3, NA).
#'
#' @param keep_salinity_psu Vector of acceptable flags for variable
#'   salinity_psu. Default is c(1, 2, 3, NA).
#'
#' @param keep_temperature_degree_c Vector of acceptable flags for variable
#'   temperature_degree_c. Default is c(1, 2, 3, NA).
#'
#' @param keep_sus_do_stations Character vector of stations for which dissolved
#'   oxygen (percent saturation) should be considered "Of Interest" (not
#'   "Suspect").
#'
#' @param keep_sus_do Vector of acceptable flags for variable
#'   dissolved_oxygen_percent_saturation for stations listed in
#'   \code{keep_sus_do_stations}. Default is c(1, 2, 3, NA).
#'
#'
#' @importFrom dplyr %>% filter
#'
#' @export


qc_filter_summary_flags <- function(
    dat,

    keep_dissolved_oxygen_percent_saturation = c(1, 2, NA),
    keep_dissolved_oxygen_uncorrected_mg_per_l = c(1, 2, NA),
    keep_salinity_psu = c(1, 2, NA),
    keep_sensor_depth_measured_m = c(1, 2, 3, NA),
    keep_temperature_degree_c = c(1, 2, 3, NA),

    keep_sus_do_stations = NULL,
    keep_sus_do = c(1, 2, 3, NA)

    ) {

  if(is.null(keep_sus_do_stations)) {
    keep_sus_do_stations <- c(
      "0814x East",
      "0814x West",
      "Aberdeen",
      "Deep Basin",
      "Hourglass Lake",
      "Piper Lake",
      "Sissiboo"
    )
  }

  dat %>%
    filter(
      (variable == "dissolved_oxygen_percent_saturation" &
         station %in% keep_sus_do_stations &
         qc_flag_value %in% keep_sus_do) |

      (variable == "dissolved_oxygen_percent_saturation" &
        qc_flag_value %in% keep_dissolved_oxygen_percent_saturation) |

      (variable == "dissolved_oxygen_uncorrected_mg_per_l" &
        qc_flag_value %in% keep_dissolved_oxygen_uncorrected_mg_per_l) |

      (variable == "sensor_depth_measured_m" &
        qc_flag_value %in% keep_sensor_depth_measured_m) |

      (variable == "salinity_psu" & qc_flag_value %in%  keep_salinity_psu) |

      (variable == "temperature_degree_c" &
         qc_flag_value %in% keep_temperature_degree_c)
    )


  # # after additional review
  # if(exists(county)) {
  #
  #   if(county == "Antigonish") {
  #
  #     dat <- dat %>%
  #       filter(
  #         !(station %in% c("Antigonish 1", "Antigonish 2", "Antigonish 3") &
  #             qc_flag_temperature_degree_c == 3)
  #       )
  #   }
  # }
  #
  # dat

}




# Filters out selected observations that were flagged Not Evaluated
#
# Additional filters based on human-in-the-loop analysis
#
# param dat Data frame with summary quality control flags in long format
#   (e.g., output of `qc_pivot_longer()`).
#
# param filter_table Table indicating which observations to filter. Must
#   include the following columns: county, station, deployment_range, variable,
#   qc_flag_value, filter_out_flag, filter_from_start.
#
#   filter_out_flag should be \code{TRUE} tp indicate the observation should be
#   filtered out. filter_from_start should be \code{TRUE} if the observations
#   to filter are at the beginning of the deployment and \code{FALSE} if the
#   observations to filter are at the end.
#
# importFrom dplyr %>% filter if_else left_join
# importFrom expss thru
# importFrom lubridate days
# importFrom purrr list_rbind
#
# export

# filter_table <- read_csv(
#   "C:/Users/Danielle Dempsey/Desktop/RProjects/water_quality_reports/filter_not_evaluated_flags.csv",
#   col_types = "ccccnll",
#   show_col_types = FALSE) %>%
#   separate(
#     deployment_range,
#     into = c("start_date", "end_date"), sep = " to ",
#     remove = FALSE) %>%
#   mutate(
#     qc_flag_value = ordered(qc_flag_value, levels = 1:4),
#     start_date = as_datetime(start_date),
#     end_date = as_datetime(end_date)
#   ) %>%
#   filter(county == county)


# qc_filter_out_not_evaluated <- function(dat, filter_table) {
#
#   # dat <- suppressMessages(ss_import_data(county = "annapolis")) %>%
#   #   qc_pivot_longer()
#
#   depls <- distinct(dat, county, station, deployment_range)
#
#   dat_out <- NULL
#
#   for(i in 1:nrow(depls)) {
#
#     station_i <- depls[i, ]$station
#     depl_i <- depls[i, ]$deployment_range
#
#     filter_table_i <- filter_table %>%
#       filter(station == station_i, deployment_range == depl_i)
#
#     if(nrow(filter_table_i) == 0) {
#       dat_out[[i]] <- dat %>%
#         filter(station == station_i, deployment_range == depl_i)
#     } else{
#
#       # make a function that will look at the beginning OR end of the deployment
#       # depending on the values of filter_from_start
#       if(isTRUE(filter_table_i$filter_from_start)) {
#         filter_datetime <- thru(
#           filter_table_i$start_date, filter_table_i$start_date + days(2)
#         )
#       } else {
#         filter_datetime <- thru(
#           filter_table_i$end_date - days(2), filter_table_i$end_date
#         )
#       }
#
#       dat_out[[i]] <- dat %>%
#         filter(station == station_i, deployment_range == depl_i) %>%
#         left_join(
#           filter_table %>% select(-filter_from_start),
#           join_by(county, station, variable, qc_flag_value)
#         ) %>%
#         mutate(
#           filter_out_flag = if_else(is.na(filter_out_flag), FALSE, filter_out_flag),
#           filter_out_timestamp = filter_datetime(timestamp_utc)
#         ) %>%
#         filter(filter_out_flag != TRUE & filter_out_timestamp != TRUE) %>%
#         select(-c(filter_out_flag, filter_out_timestamp, start_date, end_date))
#     }
#   }
#
#   dat_out %>%
#     list_rbind()
# }
