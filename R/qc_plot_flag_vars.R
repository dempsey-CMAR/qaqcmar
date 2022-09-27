#' Title
#'
#' @param dat placeholder... can be wide or long, but must include columns named
#'   _flag_variable.
#'
#' @param vars Variables to plot
#'
#' @inheritParams qc_test_all
#'
#' @return list of ggplot objects
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

qc_plot_all_tests <- function(dat,
                              qc_tests = c("climatology", "grossrange"),
                              vars = "all") {

  dat <- dat %>%
    rename(tstamp = contains("timestamp")) %>%
    mutate(tstamp = as_datetime(tstamp))

  if(!("variable" %in% colnames(dat))) {
    dat <- qc_pivot_longer(dat, qc_tests = qc_tests)
  }

  if(vars == "all") vars <- unique(dat$variable)

  p <- list(NULL)
  p_out <- list(NULL)

  for (i in seq_along(vars)) {

    var_i <- vars[i]

    dat_i <- filter(dat, variable == var_i)

    # if nrow is 0 don't make a plot
    if(nrow(dat_i) == 0) {
      message("No data for variable << ", var_i, " >>")
      break
    }

    for (j in seq_along(qc_tests)) {

      qc_test_j <- qc_tests[j]

      p[[qc_test_j]] <- ggplot_all_tests(dat_i, qc_test = qc_test_j, var = var_i)
      # might want to ggpubr these together

      p <- Filter(Negate(is.null), p)
    }
    p_out[[var_i]] <- p
  }

  # not sure why first element was null
  p_out <- Filter(Negate(is.null), p_out)

  p_out
}




#' Title
#'
#' @param dat placeholder
#' @param qc_test qc test to plot
#' @param var  variable to plot
#'
#' @return ggplot object
#'
#' @importFrom ggplot2  aes element_rect element_text facet_wrap geom_point
#'   ggplot ggtitle guides guide_legend  scale_colour_manual scale_x_datetime
#'   scale_y_continuous theme_light theme

ggplot_all_tests <- function(dat, qc_test, var) {

  # https://www.visualisingdata.com/2019/08/five-ways-to-design-for-red-green-colour-blindness/
  flag_colours <- c("#006164", "#E6E1BC", "#EDA247", "#DB4325")

  flag_column <- paste0(qc_test, "_flag_value")

  ggplot(dat, aes(tstamp, value, colour = !!sym(flag_column))) +
    geom_point() +
    scale_y_continuous(var) +
    scale_x_datetime("Date") +
    scale_colour_manual("Flag Value", values = flag_colours, drop = FALSE) +
    # more helpful to have sensor or depth? - could do both
    # and order factor based on depth
    facet_wrap(~ sensor) +
    theme_light() +
    theme(strip.text = element_text(colour = "black", size = 10),
          strip.background = element_rect(fill = "white", colour = "darkgrey")) +
    guides(color = guide_legend(override.aes = list(size = 4))) +
    ggtitle(paste0(qc_test, " test: ", var))

}
