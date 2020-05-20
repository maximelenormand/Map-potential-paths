# Load packages
library(raster)

# Working directory
wd="/home/maxime/mmmycloud/Research/Articles/InProgress/MPP/Git"
setwd(wd)

# Load function
source("Model/mpp.R")

# Define parameters
season="wet"
delta_w=0.8
delta_r=0.1

mpp(season,delta_w,delta_r,wd)






