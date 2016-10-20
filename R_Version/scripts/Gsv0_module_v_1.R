# David Millar 
# dave.millar@uwyo.edu
# October 20, 2016

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Stomatal conductance prior to photosynthetic limitation (Gsv0) module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# function for estimating Gsv0 function parameters
#-----------------------------------------------------------------------------------------------

calc_Gsv0 <- function(Gs_ref,ws,vpd){
  
  Gsv_0 <- ws * Gs_ref - (m * log(vpd)) 
  
  return(Gsv_0)
  
}