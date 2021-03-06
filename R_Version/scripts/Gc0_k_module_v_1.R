# David Millar 
# dave.millar@uwyo.edu
# October 20, 2016

# THIS MODULE DOES CALCULATIONS FOR SUN AND SHADE ELEMENTS WITHIN THE CANOPY

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Leaf-specific stomatal conductance to CO2 prior to photosynthetic limitation (Gc0) module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


#TODO (Matt/Dave): Fill in empty argument descriptions
CalcGc0k <- function(Gsv0, Gva, L.k){
  # Function for estimating Gc0 for sun and shade leaves
  # Args:
  #   Gsv0: 
  #   Gva:
  #   L.k:
  # Return:
  #   Gc0k for (k = sun OR shade) leaves
  
  # TODO (Dave): Double check this equation
  Gc0.k <- (1 / 1.6)
  Gc0.k <- Gc0.k * (1 / L.k)
  Gc0.k <- Gc0.k * (1 / Gsv0 * L.k) + (1 / Gva)
  Gc0.k <- 1 / Gc0.k
  
  return (Gc0.k)
}
