% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qc_pivot_longer.R
\name{pivot_flags_longer}
\alias{pivot_flags_longer}
\title{Complete pivot_longer of flagged sensor string data}
\usage{
pivot_flags_longer(dat_wide, qc_test)
}
\arguments{
\item{dat_wide}{Data frame of flagged sensor string data with the variables
in a long format and flags in wide format.}

\item{qc_test}{Flag columns to pivot.}
}
\value{
Returns \code{dat_wide} with the qc_test flag columns pivoted to a
long format.
}
\description{
Complete pivot_longer of flagged sensor string data
}
