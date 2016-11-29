# David Millar
# dave.millar@uwyo.edu
# October 19, 2016

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# TREES aerodynamic conductance (gva) module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#TODO (Matt/Dave): Fill in the empty argument descriptions
CalcGva <- function(z, h, u_air, P_air, T_air){
  # Function for calculating aerdynamic conductance
  # Args:
  #   z:
  #   h:
  #   u_air:
  #   P_air:
  #   T_air:
  # Returns:
  #   The calculated value of Gva
  
  
  #------------------------#
  # Calculate subequations #
  #------------------------#
  # TODO(Dave): Double check this equation
  # Calculate the molar density of air
  rho_air <- 44.6 * P_air
  rho_air <- rho_air * 273.15
  rho_air <- rho_air / (101.3 * (273.15 + T_air))
  
  # Calculate zero-plane displacement for canopy height (Campbell and Norman 1998, Eq:5.2)
  d <- 0.65 * h_fixed_para
  
  # Calculate roughness length (Campbell and Norman 1998, Eq:5.3)
  zm <- 0.1 * h_fixed_para
  
  # Calculate roughness length for heat (Campbell and Norman 1998, Eq:7.19)
  zh <- 0.2 * zm
  
  #-----------#
  # constants #
  #-----------#
  
  # von Karman's constant
  k <- 0.4
  
  # psi_m (diabatic correction factor for momentum) and 
  # psi_h (diabatic correction factor for heat) are set to zero for now,
  # which assumes atmospheric stability.
  psi_m <- 0
  psi_h <- 0
  
  #-------------------------#
  # Calculate main equation #
  #-------------------------#
  logzd <- log(z - d) # Recurring calculation in equation below
  
  Gva <- (log / zm) + psi_m
  Gva <- Gva * ((logzd / zh) + psi_h)
  Gva <- (k ^ 2 * rho_air * u) / Gva
  
  return(Gva)
}
