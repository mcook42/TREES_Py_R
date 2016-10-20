# David Millar 
# dave.millar@uwyo.edu
# October 20, 2016

# THIS MODULE DOES CALCULATIONS FOR SUN AND SHADE ELEMENTS WITHIN THE CANOPY

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Leaf-specific stomatal conductance to CO2 prior to photosynthetic limitation (Gc0) module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# function for estimating Gc0 for sun leaves
#-----------------------------------------------------------------------------------------------
calc_Gc0_sun <- function(Gsv0,Gva,L_sun){
  
  Gc0_sun <- 1/((1/Gsv0*L_sun)+(1/Gva)) * 1/L_sun * 1/1.6
  
  return(Gc0_sun)
  
}

# function for estimating Gc0 for shade leaves
#-----------------------------------------------------------------------------------------------
calc_Gc0_shade <- function(Gsv0,Gva,L_shade){
  
  Gc0_shade <- 1/((1/Gsv0*L_shade)+(1/Gva)) * 1/L_shade * 1/1.6
  
  return(Gc0_shade)
  
}