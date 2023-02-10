
<!-- README.md is generated from README.Rmd. Please edit that file -->

# qaqcmar

<img src="man/figures/hex_qaqcmar.png" width="25%" style="display: block; margin: auto;" />

<!-- badges: start -->

[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![](https://img.shields.io/badge/devel%20version-0.0.3-blue.svg)](https://github.com/dempsey-cmar/qaqcmar)
[![CodeFactor](https://www.codefactor.io/repository/github/dempsey-cmar/qaqcmar/badge)](https://www.codefactor.io/repository/github/dempsey-cmar/qaqcmar)
[![R-CMD-check](https://github.com/dempsey-CMAR/qaqcmar/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dempsey-CMAR/qaqcmar/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of qaqcmar is to apply quality control flags to Water Quality
data collected through the Centre for Marine Applied Research’s (CMAR)
Coastal Monitoring Program.

## Installation

You can install the development version of qaqcmar from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("dempsey-CMAR/qaqcmar")
```

## Background

### Coastal Monitoring Program

The Centre for Marine Applied Research ([CMAR](https://cmar.ca/))
coordinates an extensive [Coastal Monitoring
Program](https://cmar.ca/coastal-monitoring-program/) to measure
[Essential Ocean
Variables](https://www.goosocean.org/index.php?option=com_content&view=article&id=14&Itemid=114)
from around the coast of Nova Scotia, Canada. There are three main
branches of the program: *Water Quality*, *Currents*, and *Waves*.
Processed data for each branch can be viewed and downloaded from several
sources, as outlined in the [CMAR Report & Data Access Cheat
Sheet](https://github.com/Centre-for-Marine-Applied-Research/strings/blob/master/man/figures/README-access-cheatsheet.pdf)
(download for clickable links).

### Quality Assurance and Quality Control

CMAR applies Quality Assurance (QA) and Quality Control (QC) processes
to support the delivery of high quality data (Bushnell et al, 2019). QA
processes are typically completed prior to sensor deployment (e.g.,
sensor calibration and validation), and are documented in a series of
Standard Operating Procedures (link here).

Quality Control processes (e.g., automated data flags, manual review)
are completed for each deployment after the data have been collected and
compiled. CMAR has adopted the QARTOD (Quality Assurance / Quality
Control of Real-Time Oceanographic Data) flagging scheme and associated
tests. QARTOD provides a relatively simple yet informative rating scale
(Table X), and is very well documented. There are QARTOD manuals for 14
EOVs that provide codeable instructions for implementing recommended QC
tests. QARTOD has been adopted by oceanographic organizations around the
world, including the US Integrated Ocean Observing System (IOOS).

`qaqcmar` is a quality control tool that automates assigning flags to
each observation based on QARTOD recommendations.

- link to thresholds analysis document
  - Tests that we are planning to run (include table)
  - Flagging scheme (include table)

## Example

``` r
library(ggplot2)
library(qaqcmar)
library(sensorstrings)
library(dplyr)
library(kableExtra)
library(lubridate)
```

### Example Sensor String Data

Consider simulated Water Quality data from January 1 to December
2023.(Note: this data was simulated to illustrate quality control
processes and does not reflect expected profiles.)

``` r
# read in example data
path <- system.file("testdata", package = "qaqcmar")

dat <- readRDS(paste0(path, "/test_data_grossrange.RDS")) %>% 
  mutate(sensor_serial_number = "123")

kable(dat[1:5, ])
```

<table>
<thead>
<tr>
<th style="text-align:left;">
sensor_type
</th>
<th style="text-align:right;">
sensor_depth_at_low_tide_m
</th>
<th style="text-align:left;">
timestamp_utc
</th>
<th style="text-align:right;">
dissolved_oxygen_percent_saturation
</th>
<th style="text-align:right;">
temperature_degree_c
</th>
<th style="text-align:left;">
sensor_serial_number
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-01-01
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
123
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-02-01
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
123
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
123
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-04-01
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
123
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-05-01
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
123
</td>
</tr>
</tbody>
</table>

``` r
ss_ggplot_variables(dat) + geom_point(size = 1)
```

<img src="man/figures/README-fig1-1.png" width="100%" />

### Apply QC flags

`qcqcmar` includes a separate function for each QC test. For example,
`qc_test_grossrange()` applies the gross range test by adding a a
`grossrange_flag_**` column for each variable in `dat`.

#### Gross Range Test

Apply test:

``` r
dat_gr <- qc_test_grossrange(dat, county = "Lunenburg")

kable(dat_gr[1:5, ])
```

<table>
<thead>
<tr>
<th style="text-align:left;">
sensor_type
</th>
<th style="text-align:right;">
sensor_depth_at_low_tide_m
</th>
<th style="text-align:left;">
timestamp_utc
</th>
<th style="text-align:left;">
sensor_serial_number
</th>
<th style="text-align:right;">
value_dissolved_oxygen_percent_saturation
</th>
<th style="text-align:right;">
value_temperature_degree_c
</th>
<th style="text-align:left;">
grossrange_flag_dissolved_oxygen_percent_saturation
</th>
<th style="text-align:left;">
grossrange_flag_temperature_degree_c
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-01-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-02-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-04-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-05-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
</tbody>
</table>

The flagged data can be plotted with `qc_plot_flags()`, specifying
argument `qc_tests = "grossrange"`.

``` r
qc_plot_flags(dat_gr, qc_tests = "grossrange", ncol = 2)
#> $dissolved_oxygen_percent_saturation
#> $dissolved_oxygen_percent_saturation$grossrange
```

<img src="man/figures/README-fig2-1.png" width="100%" />

    #> 
    #> 
    #> $temperature_degree_c
    #> $temperature_degree_c$grossrange

<img src="man/figures/README-fig2-2.png" width="100%" />

#### All Tests

`qc_test_all()` will apply all specified QC tests to `dat`.

``` r
dat_qc <- dat %>% 
  qc_test_all(qc_tests = c("climatology", "grossrange"), county = "Lunenburg") 

kable(dat_qc[1:5, ])
```

<table>
<thead>
<tr>
<th style="text-align:left;">
sensor_type
</th>
<th style="text-align:right;">
sensor_depth_at_low_tide_m
</th>
<th style="text-align:left;">
timestamp_utc
</th>
<th style="text-align:left;">
sensor_serial_number
</th>
<th style="text-align:right;">
value_dissolved_oxygen_percent_saturation
</th>
<th style="text-align:right;">
value_temperature_degree_c
</th>
<th style="text-align:left;">
climatology_flag_dissolved_oxygen_percent_saturation
</th>
<th style="text-align:left;">
climatology_flag_temperature_degree_c
</th>
<th style="text-align:left;">
grossrange_flag_dissolved_oxygen_percent_saturation
</th>
<th style="text-align:left;">
grossrange_flag_temperature_degree_c
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-01-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-02-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-04-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-05-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
3
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
</tbody>
</table>

There are now 10 columns in `dat_qc`!

`qc_assign_max_flag()` reduces the number of columns in `dat_qc` by
keeping the *worst* flag for each variable.

``` r
dat_qc <- dat_qc %>% 
 qc_assign_max_flag(qc_tests = c("climatology", "grossrange"))

kable(dat_qc[1:5, ])
```

<table>
<thead>
<tr>
<th style="text-align:left;">
sensor_type
</th>
<th style="text-align:right;">
sensor_depth_at_low_tide_m
</th>
<th style="text-align:left;">
timestamp_utc
</th>
<th style="text-align:left;">
sensor_serial_number
</th>
<th style="text-align:right;">
value_dissolved_oxygen_percent_saturation
</th>
<th style="text-align:right;">
value_temperature_degree_c
</th>
<th style="text-align:left;">
qc_flag_dissolved_oxygen_percent_saturation
</th>
<th style="text-align:left;">
qc_flag_temperature_degree_c
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-01-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-02-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-03-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-04-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
<tr>
<td style="text-align:left;">
aquameasure
</td>
<td style="text-align:right;">
5
</td>
<td style="text-align:left;">
2023-05-01
</td>
<td style="text-align:left;">
123
</td>
<td style="text-align:right;">
-5
</td>
<td style="text-align:right;">
-10
</td>
<td style="text-align:left;">
4
</td>
<td style="text-align:left;">
4
</td>
</tr>
</tbody>
</table>

The flagged data can be plotted with `qc_plot_flags()`, specifying
argument `qc_tests = "qc"`.

``` r
qc_plot_flags(dat_qc, qc_tests = "qc")
#> $dissolved_oxygen_percent_saturation
#> $dissolved_oxygen_percent_saturation$qc
```

<img src="man/figures/README-fig3-1.png" width="100%" />

    #> 
    #> 
    #> $temperature_degree_c
    #> $temperature_degree_c$qc

<img src="man/figures/README-fig3-2.png" width="100%" />

## References

Bushnell, M. et al. (2019). Quality Assurance of Oceanographic
Observations: Standards and Guidance Adopted by an International
Partnership. Frontiers in Marine Science, 6(706).
<doi:10.3389/fmars.2019.00706>

U.S. Integrated Ocean Observing System, 2020. QARTOD - Prospects for
Real-Time Quality Control Manuals, How to Create Them, and a Vision for
Advanced Implementation. 22 pp. DOI: 10.25923/ysj8-5n28
