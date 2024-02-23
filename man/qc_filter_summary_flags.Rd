% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/qc_filter_flags.R
\name{qc_filter_summary_flags}
\alias{qc_filter_summary_flags}
\title{Filter data to keep observations of acceptable quality}
\usage{
qc_filter_summary_flags(
  dat,
  keep_dissolved_oxygen_percent_saturation = c(1, 2, NA),
  keep_dissolved_oxygen_uncorrected_mg_per_l = c(1, 2, NA),
  keep_sensor_depth_measured_m = c(1, 2, 3, NA),
  keep_salinity_psu = c(1, 2, NA),
  keep_temperature_degree_c = c(1, 2, 3, NA)
)
}
\arguments{
\item{dat}{Data frame with summary quality control flag columns in the form
\code{qc_flag_variable_units}.}

\item{keep_dissolved_oxygen_percent_saturation}{Vector of acceptable flags
for variable dissolved_oxygen_percent_saturation. Default is c(1, 2, NA).
"Suspect/Of Interest" observations are considered biofouling and excluded
from analysis.}

\item{keep_dissolved_oxygen_uncorrected_mg_per_l}{Vector of acceptable flags
for variable dissolved_oxygen_uncorrected_mg_per_l. Default is c(1, 2, NA).
"Suspect/Of Interest" observations are considered biofouling and excluded
from analysis.}

\item{keep_sensor_depth_measured_m}{Vector of acceptable flags
for variable sensor_depth_measured_m. Default is c(1, 2, 3, NA).}

\item{keep_salinity_psu}{Vector of acceptable flags
for variable salinity_psu. Default is c(1, 2, 3, NA).}

\item{keep_temperature_degree_c}{Vector of acceptable flags
for variable temperature_degree_c. Default is c(1, 2, 3, NA).}
}
\description{
Filter data to keep observations of acceptable quality
}