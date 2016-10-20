# David Millar 
# dave.millar@uwyo.edu
# October 20, 2016

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Above-canopy radiation module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#














# function to calculate fraction of total above canopy radiation in diffuse form
#-----------------------------------------------------------------------------------------------

f_d <- 0
if (tau_atm <= 0.22) {
  f_d <- 1
} 
  else if (tau_atm > 0.22 & tau_atm <= 0.35) {
    f_d <- 1-6.4*(tau_atm-0.22)^2
  }
  else if (tau_atm > 0.35 & tau_atm <= K) {
    f_d <- 1.47-1.66*tau_atm
  }
  else tau_atm <- R
#-----------------------------------------------------------------------------------------------
