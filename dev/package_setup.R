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

# add packages
use_package("dplyr")



####

dat_flag <- qc_flag_range(dat, threshold = 1)






