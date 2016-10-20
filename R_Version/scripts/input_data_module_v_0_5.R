# David Millar - July 2, 2016
# dave.millar@uwyo.edu

# NOTES: - ggplot code at the end is just used for evaluation and plotting, and can be omitted 
#          or commented out when integrating this module into TREES_Py_R
#        - Non-linear least squares regression are currently used to determine empirical model
#          parameter estimates.  

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::#
#                                                                                  #                                #
# Module to simulate percent decline in stomatal conductance (water stress)        #   
# due to declining soil water potential.                                           #
#                                                                                  #                                #
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::#


# clear everything out of memory
#rm(list=ls())

# call to ggplot package
#library(ggplot2)

#-----------------------------------------------------------------------------------------------------
# set the current working directory - make sure to change this as needed
#setwd("C:\\Users\\Matthew\\Documents\\GitHub\\TREES_Py_R\\R_Version_Project\\water_stress_module")


# read in the water potential and percent loss conductance (PLC) data from laboratory xylem analysis (Heather Speckman)
# psi = water potential (MPa)
# plc = percent loss conductance within the plant xylem (%)
plc_data <- read.csv("PICO_ws_obs_data.csv")
names(plc_data)=c("psi_obs", "plc_obs")

psi_obs <-plc_data$"psi_obs"
plc_obs <- plc_data$"plc_obs"


