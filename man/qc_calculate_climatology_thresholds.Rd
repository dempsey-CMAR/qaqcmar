% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qc_calculate_thresholds.R
\name{qc_calculate_climatology_thresholds}
\alias{qc_calculate_climatology_thresholds}
\title{Calculate climatology test (monthly) thresholds}
\usage{
qc_calculate_climatology_thresholds(
  dat,
  var,
  ...,
  n_sd = 3,
  keep_stats = FALSE
)
}
\arguments{
\item{dat}{Data frame with at least two columns: \code{timestamp_utc} or
\code{month} and the variable for which to calculate the thresholds. If
there is no column named \code{month}, the month will be extracted from
\code{timestamp_utc}.}

\item{var}{Unquoted character string indicating which column in \code{dat} to
calculate the thresholds for, e.g., \code{var = temperature_degree_c}.}

\item{...}{Additional grouping variable(s).}

\item{n_sd}{Number of standard deviations to add / subtract from mean to
calculate the user thresholds. Default is \code{n_sd = 3}.}

\item{keep_stats}{Logical argument indicating whether to keep the calculated
mean and standard deviation columns.}
}
\value{
Tibble with columns \code{qc_test}, \code{variable}, \code{month},
\code{threshold}, and \code{threshold_value}.
}
\description{
The climatology thresholds are calculated from historical data for each month
as the mean +/- 3 standard deviations:
}
\details{
\deqn{season_{min} = avg_{season} - 3 * stdev_{season}} \deqn{season_{max} =
avg_{season} + 3 * stdev_{season}}

\eqn{avg_{season}} is calculated as the average of all observations for a
given month, and \code{stdev_{season}} is the associated standard deviation.

This function only automatically groups by \strong{month}. To calculate
the climatology thresholds by group (e.g., county) use
\code{dplyr::group_by(group_variable)}, and send the results to
\code{qc_calculate_climatology_thresholds()}.
}
