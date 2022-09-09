#' Add flag columns for the grossrange test
#'
#' What makes the most sense for the sensor_make column?
#'
#' How can user see grossrange table?
#'
#'
#' @param dat placeholder
#'
#' @param grossrange_table Data.frame with 6 columns: \code{variable}: should
#'   match the names of the variables being tested in \code{dat}.
#'   \code{sensor_make}: this may change \code{sensor_min}: minimum value the
#'   sensor can record. \code{sensor_max}: maximum value the sensor can record.
#'   \code{user_min}: minimum reasonable value; smaller values are "of
#'   interest". \code{user_max}: maximum reasonable value; larger values are "of
#'   interest".
#'
#'   Default is \code{grossrange_table = NULL}, which uses default values stored
#'   internally.
#'
#' @return placeholder for now
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
    grossrange_table <-get0(
      "threshold_tables", envir = asNamespace("qaqcmar")
    )$grossrange_table
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




# qc_test_grossrange <- function(dat) {
#
#   dat %>%
#     mutate(
#       sensormax = case_when(
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 150, #aquaMeasure DOT DO
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 30, #Hobo DO DO
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ 35, #aquaMeasure ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ 70, #Hobo ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ 40, #Vemco temp
#         VARIABLE == "Salinity" ~ 40 #aquaMeasure SAL SAL
#       )) %>%
#     mutate(
#       sensormin = case_when(
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 0, #aquaMeasure DOT DO
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 0, #Hobo DO DO
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ -5, #aquaMeasure ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ -40, #Hobo ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ -5, #Vemco temp
#         VARIABLE == "Salinity" ~ 0 #aquaMeasure SAL SAL
#       )) %>%
#     mutate(
#       usermax = case_when(
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 130, #aquaMeasure DOT DO
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 25, #Hobo DO DO
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ 25, #aquaMeasure ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ 25, #Hobo ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ 25, #Vemco temp
#         VARIABLE == "Salinity" ~ 35 #aquaMeasure SAL SAL
#       ))%>%
#     mutate(
#       usermin = case_when(
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 50, #aquaMeasure DOT DO
#         VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 0, #Hobo DO DO
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ -3, #aquaMeasure ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ -3, #Hobo ALL temp
#         VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ -3, #Vemco temp
#         VARIABLE == "Salinity" ~ 0 #aquaMeasure SAL SAL
#       ))%>%
#     mutate(
#       flag = case_when(
#         VALUE > sensormax |
#         VALUE < sensormin  ~ 4,
#         VALUE > usermax |
#         VALUE < usermin ~ 3,
#         VALUE <= sensormax |
#         VALUE >= sensormin ~ 1,
#         TRUE ~ 2
#       )) %>%
#     mutate(flag = factor(flag)) %>%
#     # assign levels to the factor based on the numeric values of flag
#     mutate(
#       flag = ordered(
#         flag,
#         levels = as.numeric(levels(flag))[order(as.numeric(levels(flag)))]
#       )
#     ) %>%
#     #remove extra columns
#     subset(select = -c(sensormax, sensormin, usermax, usermin))
#
# }

#Considerations:
#problem: operational range is unique to sensor AND variable... not just variable
       #use narrowest range between all sensors?
       #no unique identifier to specify anything other than manufacturer.
#will need to add additional range values as we process data for new variables (level loggers, TURB, CHL)
#what do we want to name the "flag" column?





##test the function
# dat3 <- qc_test_grossrange(dat)
#
# #read in file with outliers to test each flag
# dat<-read.csv("C:/Users/Nicole Torrie/Documents/R/test_qaqc_dataset/Colchester_2021-12-09_QAQC.csv")
#
# library(dplyr)
# library(stringr)
# library(ggplot2)
#
# dat2 <- dat %>%
#   mutate(
#     sensormax = case_when(
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 150, #aquaMeasure DOT DO
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 30, #Hobo DO DO
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ 35, #aquaMeasure ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ 70, #Hobo ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ 40, #Vemco temp
#       VARIABLE == "Salinity" ~ 40 #aquaMeasure SAL SAL
#     )) %>%
#   mutate(
#     sensormin = case_when(
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 0, #aquaMeasure DOT DO
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 0, #Hobo DO DO
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ -5, #aquaMeasure ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ -40, #Hobo ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ -5, #Vemco temp
#       VARIABLE == "Salinity" ~ 0 #aquaMeasure SAL SAL
#     )) %>%
#   mutate(
#     usermax = case_when(
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 130, #aquaMeasure DOT DO
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 25, #Hobo DO DO
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ 25, #aquaMeasure ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ 25, #Hobo ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ 25, #Vemco temp
#       VARIABLE == "Salinity" ~ 35 #aquaMeasure SAL SAL
#     ))%>%
#   mutate(
#     usermin = case_when(
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 50, #aquaMeasure DOT DO
#       VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 0, #Hobo DO DO
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ -3, #aquaMeasure ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ -3, #Hobo ALL temp
#       VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ -3, #Vemco temp
#       VARIABLE == "Salinity" ~ 0 #aquaMeasure SAL SAL
#     ))%>%
#   mutate(
#     flag = case_when(
#       VALUE > sensormax |
#       VALUE < sensormin  ~ 4,
#       VALUE > usermax |
#       VALUE < usermin ~ 3,
#       VALUE <= sensormax |
#       VALUE >= sensormin ~ 1,
#       TRUE ~ 2
#     )) %>%
#   mutate(flag = factor(flag)) %>%
#   # assign levels to the factor based on the numeric values of flag
#   mutate(flag = ordered(flag,
#                         levels = as.numeric(levels(flag))[order(as.numeric(levels(flag)))]))
#
#
#
#
#
# #test plots
# DO <- filter(dat2,VARIABLE == "Dissolved Oxygen", preserve=TRUE)
# TEMPam <- filter(dat2,VARIABLE == "Temperature" & str_detect(dat2$SENSOR, "aquaMeasure"), preserve=TRUE)
# TEMPhobo <- filter(dat2,VARIABLE == "Temperature" & str_detect(dat2$SENSOR, "HOBO"), preserve=TRUE)
# TEMPvr <- filter(dat2,VARIABLE == "Temperature" & str_detect(dat2$SENSOR, "VR2AR"), preserve=TRUE)
#
#
# ggplot(TEMPhobo, aes(TIMESTAMP, VALUE, colour = flag, label = TEST))+
#   geom_point()+geom_text(hjust=0, vjust=0)+
#   scale_color_manual(values=c("green", "orange", "red"))+
#   ggtitle(TEMPhobo$VARIABLE)
#
#
#
