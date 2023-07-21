#' Plot sensor data coloured by flag value
#'
#' @param dat Data frame of flagged sensor string data in long or wide format.
#'   Must include at least one column name with the string "_flag_variable".
#'
#' @param vars Character vector of variables to plot. Default is \code{vars =
#'   "all"}, which will make a plot for each recognized variable in \code{dat}.
#'
#' @param labels Logical argument indicating whether to convert numeric flag
#'   values to text labels for the legend.
#'
#' @param ncol Number of columns for faceted plots.
#'
#' @param flag_title Logical argument indicating whether to include a ggtitle of
#'   the qc test and variable plotted.
#'
#' @inheritParams qc_test_all
#'
#' @return Returns a list of ggplot objects; one figure for each test in
#'   \code{qc_tests} and variable in \code{vars}. Points are coloured by the
#'   flag value and panels are faceted by depth and sensor. faceted by depth and
#'   sensor.
#'
#' @importFrom lubridate as_datetime
#'
#' @export
#'

# turn this into example
# path <- system.file("testdata", package = "qaqcmar")
# dat <- read.csv(paste0(path, "/example_data.csv"))
#
# dat <-  qc_test_all(dat) #%>%
#   qc_pivot_longer()
#
# plots <- qc_plot_flag_vars(dat)

qc_plot_flags <- function(
    dat,
    qc_tests = c("climatology", "grossrange", "rolling_sd", "spike"),
    vars = "all",
    labels = TRUE, ncol = NULL, flag_title = TRUE
) {

  dat <- dat %>%
    rename(tstamp = contains("timestamp")) %>%
    mutate(tstamp = as_datetime(tstamp))

  if(!("variable" %in% colnames(dat))) {
    dat <- qc_pivot_longer(dat, qc_tests = qc_tests)
  }

  if(vars == "all") vars <- unique(dat$variable)

  if(isTRUE(labels)) dat <- dat %>% qc_assign_flag_labels()

  if(is.null(ncol)) ncol <- 1

  p <- list(NULL)
  p_out <- list(NULL)

  # plot for each variable
  for (i in seq_along(vars)) {

    var_i <- vars[i]

    dat_i <- filter(dat, variable == var_i)

    # if nrow is 0 don't make a plot
    if(nrow(dat_i) == 0) {
      stop("No data for variable << ", var_i, " >>")
    }

    # plot for each test
    for (j in seq_along(qc_tests)) {

      qc_test_j <- qc_tests[j]

      p[[qc_test_j]] <- ggplot_flags(
        dat_i, qc_test = qc_test_j, var = var_i, ncol = ncol
      )

      p <- Filter(Negate(is.null), p) # remove empty list element
    }
    p_out[[var_i]] <- p
  }
  p_out <- Filter(Negate(is.null), p_out)   # not sure why first element was null

  p_out
}


#' Create ggplot for one qc_test and variable
#'
#' @param dat Data frame of flagged sensor string data in long format. Must
#'   include a column named with the string "_flag_value".
#'
#' @param qc_test qc test to plot.
#'
#' @param var variable to plot.
#'
#' @inheritParams qc_plot_flags
#'
#' @return Returns a ggplot object; a figure for \code{qc_test} and \code{var}.
#'   Points are coloured by the flag value and panels are faceted by depth and
#'   sensor.
#'
#' @importFrom ggplot2 aes element_rect element_text facet_wrap geom_point
#'   ggplot ggtitle guides guide_legend  scale_colour_manual scale_x_datetime
#'   scale_y_continuous theme_light theme
#'
#' @importFrom gtools mixedsort


ggplot_flags <- function(dat, qc_test, var, ncol = NULL, flag_title = TRUE) {

  # https://www.visualisingdata.com/2019/08/five-ways-to-design-for-red-green-colour-blindness/
  flag_colours <- c("chartreuse4", "#E6E1BC", "#EDA247", "#DB4325", "grey24")

  flag_column <- paste0(qc_test, "_flag_value")

  p <- dat %>%
    mutate(
      sensor = paste(sensor_type, sensor_serial_number, sep = "-"),
      depth = paste0(sensor_depth_at_low_tide_m, " m", " (", sensor, ")"),
      depth = ordered(
        depth,
        levels = gtools::mixedsort(unique(depth))
      )
    ) %>%
    ggplot(aes(tstamp, value, colour = !!sym(flag_column))) +
    geom_point() +
    scale_y_continuous(var) +
    scale_x_datetime("Date") +
    scale_colour_manual("Flag Value", values = flag_colours, drop = FALSE) +
    facet_wrap(~ depth, ncol = ncol) +
    theme_light() +
    theme(
      strip.text = element_text(colour = "black", size = 10),
      strip.background = element_rect(fill = "white", colour = "darkgrey")
    ) +
    guides(color = guide_legend(override.aes = list(size = 4)))

  if(isTRUE(flag_title)) p + ggtitle(paste0(qc_test, " test: ", var))

  p

}
