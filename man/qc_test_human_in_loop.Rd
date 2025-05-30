% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qc_test_human_in_loop.R
\name{qc_test_human_in_loop}
\alias{qc_test_human_in_loop}
\title{Apply human in the loop flags and comments}
\usage{
qc_test_human_in_loop(
  dat,
  human_in_loop_table = NULL,
  qc_tests = c("climatology", "grossrange", "rolling_sd", "spike")
)
}
\arguments{
\item{dat}{Data frame of flagged sensor string data in wide format.}

\item{human_in_loop_table}{Data table with information required to assign the
human in the loop flags. Must include the following columns: station,
depl_range, variable, sensor_serial number (if \code{NA}, all sensors that
recorded variable will be flagged), timestamp_prompt (indicates whether
flags should be applied "between" the timestamp_utc_min
and    timestamp_utc_max or "outside" these timestamps),
timestamp_utc_min,    timestamp_utc_max, qc_test_column (qc flag column that
is being upgraded), qc_flag_value (existing flag value for qc_test_column),
human_in_loop_flag_value, and human_in_loop_comment (will be included in
the dataset).}

\item{qc_tests}{Character vector of quality control tests that have been
applied to \code{dat}. Passed to \code{qc_pivot_longer()}. Default is:
\code{qc_tests = c("climatology", "grossrange", "rolling_sd", "spike")}.}
}
\value{
Returns \code{dat} with a \code{human_in_loop_flag} column for each
variable and a corresponding \code{hil_comment} column.
}
\description{
Only deployments that require additional human-in-loop QC will have non-NA
values in the human-in-loop columns. Observations in these deployments that
do not need additional QC will be assigned a \code{human_in_loop_flag_value}
of 1.
}
\details{
Flags are assigned to each observation. For example, if a sensor measures
dissolved oxygen and temperature at the same time, and only the dissolved
oxygen observation is poor quality, then only the dissolved oxygen
observation will be flagged. The column
\code{human_in_loop_flag_value_dissolved_oxygen} will have a value of 3 or 4
(as specified in human_in_loop_table), while
\code{human_in_loop_flag_value_tempearture} will be 1.

However, there is only one column for comments, \code{hil_comment}. This is
to reduce the total number of columns in the wide data set. The trade off is
that the comment will appear to apply to both variables. To avoid confusion
in this situation, comments should be pre-pended with the variable they refer
to, e.g., "dissolved oxygen: suspected biofouling not flagged by other
tests". This is not necessary for comments that apply to all variables (e.g.,
only one variable is measured).
}
