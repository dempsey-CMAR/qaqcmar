#' Add flag column for the grossrange test
#'
#' @param dat Data.frame with at least one column \code{timestamp}.
#'
#' @return placeholder for now
#'
#' @importFrom dplyr %>% case_when mutate stringr
#'
#' @export


qc_test_grossrange <- function(dat) {

  dat %>%
    mutate(
      sensormax = case_when(
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 150, #aquaMeasure DOT DO
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 30, #Hobo DO DO
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ 35, #aquaMeasure ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ 70, #Hobo ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ 40, #Vemco temp
        VARIABLE == "Salinity" ~ 40 #aquaMeasure SAL SAL
      )) %>%
    mutate(
      sensormin = case_when(
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 0, #aquaMeasure DOT DO
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 0, #Hobo DO DO
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ -5, #aquaMeasure ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ -40, #Hobo ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ -5, #Vemco temp
        VARIABLE == "Salinity" ~ 0 #aquaMeasure SAL SAL
      )) %>%
    mutate(
      usermax = case_when(
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 130, #aquaMeasure DOT DO
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 25, #Hobo DO DO
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ 25, #aquaMeasure ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ 25, #Hobo ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ 25, #Vemco temp
        VARIABLE == "Salinity" ~ 35 #aquaMeasure SAL SAL
      ))%>%
    mutate(
      usermin = case_when(
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "aquaMeasure") == TRUE ~ 50, #aquaMeasure DOT DO
        VARIABLE == "Dissolved Oxygen" & str_detect(dat$SENSOR, "HOBO") == TRUE ~ 0, #Hobo DO DO
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "aquaMeasure") ~ -3, #aquaMeasure ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "HOBO") ~ -3, #Hobo ALL temp
        VARIABLE == "Temperature" & str_detect(dat$SENSOR, "VR2AR") ~ -3, #Vemco temp
        VARIABLE == "Salinity" ~ 0 #aquaMeasure SAL SAL
      ))%>%
    mutate(
      flag = case_when(
        VALUE > sensormax |
        VALUE < sensormin  ~ 4,
        VALUE > usermax |
        VALUE < usermin ~ 3,
        VALUE <= sensormax |
        VALUE >= sensormin ~ 1,
        TRUE ~ 2
      )) %>%
    mutate(flag = factor(flag)) %>%
    # assign levels to the factor based on the numeric values of flag
    mutate(flag = ordered(flag,
                          levels = as.numeric(levels(flag))[order(as.numeric(levels(flag)))])) %>%
    #remove extra columns
    subset(select = -c(sensormax, sensormin, usermax, usermin))

}

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
