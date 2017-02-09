# David Millar 
# dave.millar@uwyo.edu
# October 20, 2016

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Stomatal conductance prior to photosynthetic limitation (Gsv0) module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#TODO (Dave/Matt): Fill in missing items
CalcGsv0 <- function(Gs.ref, ws, vpd){
  # Function for estimating Gsv0 function parameters
  # Args:
  #   Gs.ref: (MISSING)
  #   ws: (MISSING)
  #   vpd: (MISSING)
  # Return:
  #   (MISSING)

  Gsv0 <- ws 
  Gsv0 <- Gsv0 * Gs.ref
  Gsv0 <- Gsv0 - (m * log(vpd)) 
  return(Gsv0)
}