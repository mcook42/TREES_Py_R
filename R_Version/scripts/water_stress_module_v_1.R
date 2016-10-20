# David Millar 
# dave.millar@uwyo.edu
# October 19, 2016

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# TREES water stress function parameter estimation module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# function for estimating water stress function parameters
#-----------------------------------------------------------------------------------------------

para_est_water_stress <- function(psi_obs,plc_obs){
  
  # fit water stress model paras to 'plc_data' data using a sigmoid function 
  # (numerator is set to 1, in order to get 0-100%).
  
  plc.fit <- nls(plc_obs ~ 100/(1+a*exp(b*psi_obs)), start = list(a = 11, b = -1))
  plc.paras <- coef(plc.fit)
  a <- plc.paras[1]
  b <- plc.paras[2]
  
  return(a)
  return(b)
}

