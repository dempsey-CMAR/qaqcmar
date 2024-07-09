# compare to AREA INFO (or DB version)
# two checks:
## one to compare deployment and retrieval locations
## one to compare depl/retr location to the Master Area sheet
### (ie does it need a new station name)
# I don't think these will be flags in the dataset, but should print WARNINGS
# for the person compiling the data
# would possibly be better in sensorstrings since it's at the compiling level
## but ALL tests should be applied at the compile level
# also check if coordinates are different for different sensors
## (already done in ss_read_log())

# shouldn't need to check for negative longitude any more; this should
# be taken care of with the buffer check

# or mabe put it in the read_log functioN?
# can you have two packages that are dependent on each other? --> no they cannot


# if station passes the location checks - carry on
# if the station does NOT pass the location checks --> stop
## if outside the buffer zone, rename and run the deployment_updates code
# if deployment and retriveal locations are far from each, then

qc_test_station_location <- function() {



}
