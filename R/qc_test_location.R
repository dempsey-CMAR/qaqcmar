#' Add flag column for the location test
#'
#' @param dat Data.frame with at least one column \code{timestamp}.
#' @param latmax maximum latitude
#' @param latmin minimum latitude
#' @param longmax maximum longitude
#' @param longmin minimum longitude
#'
#' @return placeholder for now
#'
#' @importFrom dplyr %>% case_when mutate
#'
#' @export


qc_test_location <- function(dat, latmax = 47.146147,latmin = 43.336527,longmax = -59.496715,longmin = -66.457067) {

  dat %>%
    mutate(
      flag = case_when(
        LATITUDE > latmax |
        LATITUDE < latmin |
        abs(LONGITUDE) < abs(longmax) |
        abs(LONGITUDE) > abs(longmin) ~ 4,
        LATITUDE <= latmax |
        LATITUDE >= latmin |
        abs(LONGITUDE) >= abs(longmax) |
        abs(LONGITUDE) <= abs(longmin) ~ 1,
        TRUE ~ 2
      )
    )
}


#testlocation <- qc_test_location(dat)


# #test function
# dat<-read.csv("Y:/Coastal Monitoring Program/Open Data/Submissions/2021-12-22/Station_Locations_2021-12-21.csv")
# switch sign back for longitude
# fewer decimal places for lat/long
#
# latmax <- 47.146147
# latmin <- 43.336527
# longmax <- -59.496715
# longmin <- -66.457067
#
#
# dat2 <- dat %>%
#   mutate(
#     flag = case_when(
#       LATITUDE > latmax |
#       LATITUDE < latmin |
#       LONGITUDE < longmax |
#       LONGITUDE > longmin ~ 4,
#       LATITUDE <= latmax |
#       LATITUDE >= latmin |
#       LONGITUDE >= longmax |
#       LONGITUDE <= longmin ~ 1
#     )
#   )


