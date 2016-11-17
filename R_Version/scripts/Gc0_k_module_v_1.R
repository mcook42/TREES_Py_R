# David Millar 
# dave.millar@uwyo.edu
# October 20, 2016

# THIS MODULE DOES CALCULATIONS FOR SUN AND SHADE ELEMENTS WITHIN THE CANOPY

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Leaf-specific stomatal conductance to CO2 prior to photosynthetic limitation (Gc0) module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#TODO (Dave): Fill in empty argument descriptions
CalcGc0k <- function(Gsv0, Gva, L.k){
  # Function for estimating Gc0 for sun and shade leaves
  # Args:
  #   Gsv0: 
  #   Gva:
  #   L.k:
  # Return:
  #   Gc0k for (k = sun OR shade) leaves
  
  Gc0.k <- 1 / ((1 / Gsv0 * L.k) + (1 / Gva)) * (1 / L.k) * (1 / 1.6)
  return (Gc0.k)
}
