% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qc_assign_max_flag.R
\name{qc_assign_max_flag}
\alias{qc_assign_max_flag}
\title{Assign each observation the maximum flag from applied QC tests.}
\usage{
qc_assign_max_flag(dat, qc_tests = NULL, return_all = TRUE)
}
\arguments{
\item{dat}{Data frame in long or wide format with flag columns from multiple
quality control tests.}

\item{qc_tests}{Quality control tests included in \code{dat}. Default is
\code{qc_tests = c("climatology", "grossrange", "rolling_sd", "spike")}.}

\item{return_all}{Logical value indicating whether to return all quality
control flag columns or only the summary columns. If \code{TRUE}, all flag
columns will be returned. If \code{FALSE}, only the summary columns will be
returned. Default is \code{TRUE}.}
}
\value{
Returns \code{dat} in a wide format, with a single flag column for
each variable column.
}
\description{
\code{depth_crosscheck_flag} is not considered when evaluating the maximum
flag value.  \code{depth_crosscheck_flag} remains its own column with a
single value for the whole deployment.
}
