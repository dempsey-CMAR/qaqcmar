# August 23, 2022

library(devtools)

# set up project
create_package("C:/Users/Danielle Dempsey/Desktop/RProjects/Packages/qaqcmar")

# add license
use_gpl3_license()

# set up git repo
use_git()

# set up github
use_github()

# add packages (from CRAN)
use_package("dplyr")
use_package("purrr")
use_package("ggplot2")
use_package("lubridate")
use_package("purrr")
use_package("readxl")
use_package("rlang")
use_package("stringr")
use_package("tidyr")

# add packages (not on CRAN)
use_dev_pacakge("sensorstrings", remote = "dempsey-CMAR/sensorstrings")

# readme
use_readme_rmd()

# github actions
use_github_action_check_standard()

# code factor
# https://www.codefactor.io/dashboard

# tests
use_testthat(3)

