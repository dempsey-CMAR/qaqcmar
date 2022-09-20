#' Add flag column for the climatology test
#'
#' @param dat placeholder
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
    subset(select = -c(season_min, season_max, numeric_month, season)) %>%
    pivot_wider(
      names_from = variable,
      values_from = c(value, climatology_flag)
    )

  colnames(dat)[which(colnames(dat) == "tstamp")] <- colname_ts

  dat

}





#
# ##test the function
# #read in file with outliers to test each flag
# # dat<-read.csv("C:/Users/Nicole Torrie/Documents/R/test_qaqc_dataset/Colchester_2021-12-09_QAQC.csv")
# library(dplyr)
# library(stringr)
# library(lubridate)
#
#
#
# dat2 <- dat %>%
#   mutate(
#     SEASON = case_when(
#       month(TIMESTAMP) == 12|
#       month(TIMESTAMP) == 1|
#       month(TIMESTAMP) == 2 ~ "Winter",
#       month(TIMESTAMP) == 3|
#       month(TIMESTAMP) == 4|
#       month(TIMESTAMP) == 5 ~ "Spring",
#       month(TIMESTAMP) == 6|
#       month(TIMESTAMP) == 7|
#       month(TIMESTAMP) == 8 ~ "Summer",
#       month(TIMESTAMP) == 9|
#       month(TIMESTAMP) == 10|
#       month(TIMESTAMP) == 11 ~ "Fall"
#     )) %>%
#   mutate(
#     seasonmax = case_when(
#       #winter
#       SEASON == "Winter" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 120, #aquaMeasure DOT DO
#       SEASON == "Winter" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 15, #Hobo DO DO
#       SEASON == "Winter" & VARIABLE == "Temperature" ~ 15, #ALL temp
#       SEASON == "Winter" & VARIABLE == "Salinity" ~ 40, #aquaMeasure SAL
#       #spring
#       SEASON == "Spring" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 130, #aquaMeasure DOT DO
#       SEASON == "Spring" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 20, #Hobo DO DO
#       SEASON == "Spring" & VARIABLE == "Temperature" ~ 20, #ALL temp
#       SEASON == "Spring" & VARIABLE == "Salinity" ~ 40, #aquaMeasure SAL
#       #summer
#       SEASON == "Summer" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 130, #aquaMeasure DOT DO
#       SEASON == "Summer" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 20, #Hobo DO DO
#       SEASON == "Summer" & VARIABLE == "Temperature" ~ 25, #ALL temp
#       SEASON == "Summer" & VARIABLE == "Salinity" ~ 40, #aquaMeasure SAL
#       #fall
#       SEASON == "Fall" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 120, #aquaMeasure DOT DO
#       SEASON == "Fall" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 15, #Hobo DO DO
#       SEASON == "Fall" & VARIABLE == "Temperature" ~ 20, #ALL temp
#       SEASON == "Fall" & VARIABLE == "Salinity" ~ 40 #aquaMeasure SAL
#     )) %>%
#   mutate(
#     seasonmin = case_when(
#       #winter
#       SEASON == "Winter" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 70, #aquaMeasure DOT DO
#       SEASON == "Winter" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 2, #Hobo DO DO
#       SEASON == "Winter" & VARIABLE == "Temperature" ~ -0.75, #ALL temp
#       SEASON == "Winter" & VARIABLE == "Salinity" ~ 40, #aquaMeasure SAL
#       #spring
#       SEASON == "Spring" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 70, #aquaMeasure DOT DO
#       SEASON == "Spring" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 5, #Hobo DO DO
#       SEASON == "Spring" & VARIABLE == "Temperature" ~ 0, #ALL temp
#       SEASON == "Spring" & VARIABLE == "Salinity" ~ 40, #aquaMeasure SAL
#       #summer
#       SEASON == "Summer" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 70, #aquaMeasure DOT DO
#       SEASON == "Summer" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 10, #Hobo DO DO
#       SEASON == "Summer" & VARIABLE == "Temperature" ~ 7, #ALL temp
#       SEASON == "Summer" & VARIABLE == "Salinity" ~ 40, #aquaMeasure SAL
#       #fall
#       SEASON == "Fall" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 70, #aquaMeasure DOT DO
#       SEASON == "Fall" & VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 2, #Hobo DO DO
#       SEASON == "Fall" & VARIABLE == "Temperature" ~ 5, #ALL temp
#       SEASON == "Fall" & VARIABLE == "Salinity" ~ 40 #aquaMeasure SAL
#     ))%>%
#   mutate(
#     flag = case_when(
#       VALUE > seasonmax |
#       VALUE < seasonmin ~ 3,
#       VALUE <= seasonmax |
#       VALUE >= seasonmin ~ 1,
#       TRUE ~ 2
#     )) %>%
#   mutate(flag = factor(flag)) %>%
#   # assign levels to the factor based on the numeric values of flag
#   mutate(flag = ordered(flag,
#                         levels = as.numeric(levels(flag))[order(as.numeric(levels(flag)))])) %>%
#   mutate(TIMESTAMP = parse_date_time(TIMESTAMP,
#                                      orders= c("dmY HM", "dmY HMS",
#                                                "mdY HM", "mdY HMS",
#                                                "Ymd HM", "Ymd HMS")))
#
#
# #unique(dat2$flag)
#
#
#
# # #test plots
# DO <- filter(dat2,VARIABLE == "Dissolved Oxygen", preserve=TRUE)
# TEMPam <- filter(dat2,VARIABLE == "Temperature" & str_detect(dat2$SENSOR, "aquaMeasure"), preserve=TRUE)
# TEMPhobo <- filter(dat2,VARIABLE == "Temperature" & str_detect(dat2$SENSOR, "HOBO"), preserve=TRUE)
# TEMPvr <- filter(dat2,VARIABLE == "Temperature" & str_detect(dat2$SENSOR, "VR2AR"), preserve=TRUE)
#
#
# ggplot(TEMPhobo, aes(TIMESTAMP, VALUE, colour = flag))+
#   geom_point()+
#   scale_color_manual(values=c("green", "orange"))+
#   ggtitle(TEMPhobo$VARIABLE)


