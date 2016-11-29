# David Millar
# dave.millar@uwyo.edu
# October 19, 2016

# Modified for Python3 by Matt Cook
# mattheworion.cook@gmail.com
# November 1, 2016

from math import log, log1p, sqrt
from fixed_params import h_fixed_para
from constants import vkk, gr_acc, cp_air

# calculating psi_h and psi_m at a known zeta (stability)
# eq. 7.26 & 7.27 -  Campbell & Norman
def calc_psim(zeta):
    """zeta (double): stability coefficient"""
    if (zeta < 0):
        psi_m =  -1.2 * log((1.0 + sqrt(1.0 - 16.0*zeta))/2.0)
    else:
        #psi_m = 6.0*log(1 + zeta); This is slower, I presume
        psi_m = 6.0 * log1p(zeta)
    return psi_m;
 
 
def calc_psih(rho_air, u_star, trk, h_flux, zeta):
    """zeta (double): stability coefficient"""
    if (zeta < 0):
        return (calc_psim(zeta))/0.6
    else:
        return calc_psim(zeta)

        zeta = -(vkk) * gr_acc * h_fixed_para * h_flux 
        zeta /= (rho_air * cp_air * trK * u_star ** 3)
        

def calc_Gva(z, h, u_air, P_air, T_air, optimize_psi=False):
  """Function for calculating aerdynamic conductance"""
  
  # Assuming :
  # h_fixed_para is reference height
  # h is canopy height
  # u_air is windspeed
  
  # Knowing:
  # vkk: von Karman's constant
  # cp_air: specific heat of air  J mol-1 C-1
  
  # Calculate the molar density of air
  rho_air = 273.15 + T_air
  rho_air *= 101.3
  rho_air = 273.15 / rho_air
  rho_air *= P_air
  rho_air *= 44.6
  
  # Calculate zero-plane displacement for canopy height 
  # (Campbell and Norman 1998, Eq:5.2)
  d = 0.65 * h_fixed_para
  
  # Calculate roughness length (Campbell and Norman 1998, Eq:5.3)
  zm = 0.1 * h_fixed_para
  
  # Calculate roughness length for heat (Campbell and Norman 1998, Eq:7.19)
  zh = 0.2 * zm
  
  if (optimize_psi):
      #the fixed terms
      lnm = log((h - d) / zm)
      lnh = log((h - d) / zh)
      
      #TODO: Check validity of this equation without tcK and trK
      #T_air_K = C2K(T_air)
      
      #estimates using naive values
      #TODO: Figure out h_flux
      psi_m = 0.0
      psi_h = 0.0
      u_star = u_star_last = u_air * vkk / (lnm + psi_m)

      # TODO (DAVE): How do we want the equation to look if we don't have
      # tck(canopy temp in kelvin) or trk(reference temp in kelvin)
      # Or is it even necessary?

      h_flux = vkk * rho_air * cp_air * u_star / (lnh + psi_h)
      # h_flux = (tcK - trK) * vkk * rho_air * cp_air * u_star / (lnh + psi_h)
      
      # ********** check effects F *************
      # accuracy of ustar is <= 0.01 m/s 042004 - a change @ 4th pl dec
      u_star_accuracy = 0.001 
      i, sign_chk = None
      n_times = 50  # give up after this
      min_n = 10 # do at least 10 iterations 042004 - a change @ 4th pl dec
      
      # iterate
      u_star_diff = 1 # force loop
      i = 0
      while((u_star_diff > u_star_accuracy or i <= min_n) and i < n_times):
          zeta = -(vkk) * gr_acc * h * h_flux 
          
          #TODO (DAVE): Is the equation correct without trK?
          zeta /= (rho_air * cp_air * trK * u_star * u_star * u_star) #7.21 
          
          #left as is 042004 mistake before?          
          #obtains same values
          psi_m = calc_psim(zeta) #7.26 or 7.27
          psi_h = calc_psih(rho_air, u_star, trk, h_flux, zeta) #7.26 or 7.27
          u_star = u_air * vkk/(lnm + psi_m) #7.24
          
          # TODO (Dave): Same equation as before,
          h_flux = (tcK - trK)* vkk * rho_air * cp_air * u_star / (lnh + psi_h) #unnumbered in C&N

          #left as is 042004 mistake before?
          u_star_diff = u_star_last - u_star
          u_star_diff = abs(u_star_diff)
          u_star_last = u_star
        
          #check
          """
          FOR DEBUGGING
          print(" ", i, "\nstability : ", zeta, "psi : ", psi_m, " ", psi_h,
                    " U*: ", u_star, " H: ", h_flux)
          """
          i += 1

  else:
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
  Gva = (vkk ** 2 * rho_air * u_air) / Gva

  return Gva
