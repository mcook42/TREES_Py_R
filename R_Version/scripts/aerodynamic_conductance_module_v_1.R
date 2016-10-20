# David Millar
# dave.millar@uwyo.edu
# October 19, 2016

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# TREES aerodynamic conductance (gva) module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


# function for calculating aerdynamic conductance
#-----------------------------------------------------------------------------------------------
calc_Gva <- function(z,h,u_air,P_air,T_air){
  
  #------------------------#
  # Calculate subfunctions #
  #------------------------#
  
  #calculate the molar density of air
  rho_air <- 44.6*P_air*273.15/(101.3*(273.15+T_air))
  
  #calculate zero-plane displacement for canopy height (Campbell and Norman 1998, Eq:5.2)
  d <- 0.65*h_fixed_para
  
  #calculate roughness length (Campbell and Norman 1998, Eq:5.3)
  zm <- 0.1*h_fixed_para
  
  #calculate roughness length for heat (Campbell and Norman 1998, Eq:7.19)
  zh <- 0.2*zm
  
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
  # Calculate main function #
  #-------------------------#
  
  
  Gva <- (k^2*rho_air*u)/((log((z-d)/zm)+psi_m)*(log((z-d)/zh)+psi_h))
  
  return(Gva)

  
}
