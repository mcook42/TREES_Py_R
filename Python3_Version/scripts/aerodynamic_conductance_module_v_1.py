# David Millar
# dave.millar@uwyo.edu
# October 19, 2016

# Modified for Python3 by Matt Cook
# mattheworion.cook@gmail.com
# November 1, 2016

from math import log
from fixed_params import h_fixed_para

def calc_Gva(z, h, u_air, P_air, T_air):
  """Function for calculating aerdynamic conductance"""
  ###Calculate Subfunctions###
  
  #calculate the molar density of air
  rho_air = 273.15 + T_air
  rho_air *= 101.3
  rho_air = 273.15 / rho_air
  rho_air *= P_air
  rho_air *= 44.6
  
  #calculate zero-plane displacement for canopy height (Campbell and Norman 1998, Eq:5.2)
  d = 0.65 * h_fixed_para
  
  #calculate roughness length (Campbell and Norman 1998, Eq:5.3)
  zm = 0.1 * h_fixed_para
  
  #calculate roughness length for heat (Campbell and Norman 1998, Eq:7.19)
  zh = 0.2 * zm
  
  ### Constants ###
  # von Karman's constant
  k = 0.4
  
  # psi_m (diabatic correction factor for momentum) and 
  # psi_h (diabatic correction factor for heat) are set to zero for now,
  # which assumes atmospheric stability.
  psi_m = 0
  psi_h = 0
  
  #Calculate main function
  #TODO: Changed u to u_air.  Is that correct??
  log_zd = log(z - d)
  
  Gva = (log_zd / zh) 
  Gva += psi_h
  Gva *= (log_zd / zm) + psi_m
  Gva = (k**2 * rho_air * u_air) / Gva

  return Gva

