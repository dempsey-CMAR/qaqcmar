#' Title
#'
#' @param dat placeholder
#'
#' @param vars Variables to plot
#'
#' @inheritParams qc_test_all
#'
#'
#' @return ggplot
#'
#' @importFrom ggplot2  aes element_rect element_text facet_wrap geom_point
#'   ggplot ggtitle guides guide_legend  scale_colour_manual scale_x_datetime
#'   scale_y_continuous theme_light theme
#'
#' @importFrom lubridate as_datetime
#'
#' @export
#'

# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))
#
# dat <-  qc_test_climatology(dat)

qc_plot_flag_vars <- function(dat,
                              qc_tests,
                              vars = NULL) {

  var <- "dissolved_oxygen_percent_saturation"

  var <- "temperature_degree_C"
  # https://www.visualisingdata.com/2019/08/five-ways-to-design-for-red-green-colour-blindness/
  flag_colours <- c("#006164", "#E6E1BC", "#EDA247", "#DB4325")

  dat <- dat_long %>%
    rename(tstamp = contains("timestamp")) %>%
    mutate(tstamp = as_datetime(tstamp)) %>%
    filter(variable == var)


  flag_column <- paste0(qc_tests, "_flag_value")

  ggplot(dat, aes(tstamp, value, colour = !!sym(flag_column))) +
    geom_point() +
    scale_y_continuous(var) +
    scale_x_datetime("Date") +
    scale_colour_manual("Flag Value", values = flag_colours, drop = FALSE) +
    # more helpful to have sensor or depth? - could do both
    # and order factor based on depth
    facet_wrap(~ sensor) +
    theme_light() +
    theme(strip.text = element_text(colour = "black", size = 12),
          strip.background = element_rect(fill = "white", colour = "darkgrey")) +
    guides(color = guide_legend(override.aes = list(size = 4))) +
    ggtitle(paste0(qc_test, " test: ", var))

}
