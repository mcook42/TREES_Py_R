# David Millar 
# dave.millar@uwyo.edu
# February 9, 2017

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Canopy-absorbed radiation module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#-------------------------------------------------------------------------------------------
# These variables eventual should be read from a 'fixed parameters/constants' input file:
#
# LAI_total <- 3.2     *LAI = leaf area index*  
# Pcc <- 1.0           *Pcc = 'percent' canopy coverage (value must be 0-1)*
# omega <- 1.0         *omega = canopy clumping factor (value must be 0-1)*
# x_ratio <- 1.0       *x_ratio = ratio of average projected areas of canopy 
#                                 elements on horizontal and vertical surfaces 
#                                 (0 to infinity)*
# sig <- 5.67E-8       *Stefan-Boltzmann constant (W m-2 K-4)
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Calculate sunlit leaf area index

LAI_sun_calc <- function(LAI_total,Pcc,Kbe){
  
  LAI_sun <- exp(-Kbe*(LAI_total/Pcc))
  LAI_sun <- 1 - LAI_sun
  LAI_sun <- LAI_sun / Kbe

  return(LAI_sun)
  
}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# Calculate shaded leaf area index

LAI_shade_calc <- function(LAI_total,LAI_sun){
  
  LAI_shd <- LAI_total - LAI_sun
  
  return(LAI_shd)
  
}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate elipsoid beam light extinction coefficient
# note: z_angle is calculated in radiation module.
Kbe_calc <- function(omega,x_ratio,z_angle){
  
  Kbe <- omega * (x_ratio^2)+tan(z_angle)
  Kbe <- Kbe * tan(z_angle)^0.5
  Kbe <- Kbe / (x_ratio+1.774*(x_ratio+1.182)^-0.733)
  
  return(Kbe)
  
}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate net absorbed radiation for the sunlit canopy (R_sun)
# 
# NOTE: ground heat flux (G) would be subtracted from R_sun equation (assume it's zero here)
# Args:
#   sig: Stefan-Boltzmann constant (W m-2 K-4)
#   Q_sun: incoming photosynthetically active radiation to sunlit canopy (W m-2)
#   tau_can: canopy transmissivity 
#   tau_atm: atmospheric transmissivity (calculated in radiation module)
#   T_air: air temperature at reference height (Celcius)

R_sun_calc <- function(Q_sun,tau_can,tau_atm,sig,T_air){
  
  R_sun <- Q_sun 
  R_sun <- R_sun - (tau_can*sig*T_air^4)
  R_sun <- R_sun - (tau_air*sig*T_air^4)
  
  return(R_sun) 
  
}
#-------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------
# calculate net absorbed radiation for the shaded canopy (R_shd)
# 
# NOTE: ground heat flux (G) would be subtracted from R_shd equation (assume it's zero here)
# Args:
#   sig: Stefan-Boltzmann constant (W m-2 K-4)
#   Q_shd: incoming photosynthetically active radiation to shaded canopy (W m-2)
#   tau_can: canopy transmissivity 
#   tau_atm: atmospheric transmissivity (calculated in radiation module)
#   T_air: air temperature at reference height (Celcius)

R_shd_calc <- function(Q_shd,tau_can,tau_atm,sig,T_air){
  
  R_shd <- Q_shd 
  R_shd <- R_shd - (tau_can*sig*T_air^4)
  R_shd <- R_shd - (tau_air*sig*T_air^4)
  
  return(R_shd) 
  
}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate incoming radiation to the sunlit canopy (Q_sun)
# Args:
#   Kbe: elipsoid beam light extinction coefficient
#   alpha_PAR: leaf absorptivity in PAR
#   Iob: PAR in beam form (W m-2)
#   Id: PAR in diffuse form (W m-2)
#   Isc: PAR in scattered form (W m-2)
#   alpha_NIR: leaf absorptivity in NIR (near infrared)
#   Qob_NIR:  NIR in beam form (W m-2)
#   Qd_NIR: NIR in diffuse form (W m-2)
#   Qsc_NIR: NIR in scattered form (W m-2)

Q_sun_calc <- function(alpha_PAR,Kbe,Iob,Id,Isc,
                       alpha_NIR,Qob_NIR,Qd_NIR,Qsc_NIR) {
  
Q_sun <- alpha_PAR * (Kbe*Iob+Id+Isc) 
Q_sun <- Q_sun + alpha_NIR*(Kbe*Qob_NIR+Qd_NIR+Qsc_NIR)

return(Q_sun)

}


#-------------------------------------------------------------------------------------------
# calculate incoming radiation to the shaded canopy (Q_shd)
# Args:
#   alpha_PAR: leaf absorptivity in PAR
#   Id: PAR in diffuse form (W m-2)
#   Isc: PAR in scattered form (W m-2)
#   alpha_NIR: leaf absorptivity in NIR (near infrared)
#   Qd_NIR: NIR in diffuse form (W m-2)
#   Qsc_NIR: NIR in scattered form (W m-2)

Q_shd_calc <- function(alpha_PAR,Id,Isc,
                       alpha_NIR,Qd_NIR,Qsc_NIR) {
  
  Q_shd <- alpha_PAR * (Id+Isc) 
  Q_shd <- Q_shd + alpha_NIR*(Qd_NIR+Qsc_NIR)
  
  return(Q_shd)
  
}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate incident diffuse PAR (W m-2)

Qd_PAR_calc <- function(Qod_PAR,alpha_PAR,Kd,LAI_total){

Qd_PAR <- Qod_PAR
Qd_PAR <- Qd_PAR * (1-exp(-sqrt(alpha_PAR)*Kd*lai_total))
Qd_PAR <- Qd_PAR / (sqrt(alpha_PAR)*Kd*lai_total)

return(Qd_PAR)

}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate incident scattered PAR (W m-2)

Qsc_PAR_calc <- function(Qob_PAR,alpha_PAR,Kbe,LAI_total){
  
Qsc_PAR <- Qob_PAR * exp(-sqrt(alpha_PAR)*Kbe*LAI_total)
Qsc_PAR <- Qsc_PAR - Qob_PAR*exp(-Kbe*lai_total)
Qsc_PAR <- Qsc_PAR / 2

return(Qsc_PAR)

}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate incident diffuse NIR (W m-2)

Qd_NIR_calc <- function(Qod_NIR,alpha_NIR,Kd,LAI_total) {

Qd_NIR <- Qod_NIR
Qd_NIR <- Qd_NIR * (1-exp(-sqrt(alpha_NIR)*Kd*LAI_total))
Qd_NIR <- Qd_NIR / (sqrt(alpha_NIR)*Kd*LAI_total)

return(Qd_NIR)

}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate incident scattered NIR (W m-2)

Qsc_NIR_calc <- function(Qob_NIR,alpha_NIR,Kbe,LAI_total){

Qsc_NIR = Qob_NIR * exp(-sqrt(alpha_NIR)*Kbe*LAI_total)
Qsc_NIR = Qsc_NIR - Qob_NIR*exp(-Kbe*LAI_total)
Qsc_NIR = Qsc_NIR / 2

return(Qsc_NIR)

}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate diffuse light extinction coefficient 

Kd_calc <- function(tau_d,LAI_total){

Kd = -log(tau_d) / LAI_total

return(Kd)

}
#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate beam transmissivity
tau_be_calc <- function(Kbe, LAI_total){
  
  tau_be <- exp(-Kbe*LAI_total)
  
  return(tau_be)
  
}

#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate diffuse light transmissivity ?
# This function is going to need some further work. I will look into this further on
# Monday (02/27/17).

#ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
# This is how the integral in Eq. B13 of the appendix is handled in simulator.cpp 
# for the C++ version:
#
# //variables for numerical integration
# double integral; //value of sum
# int steps,i;
# double Kb, psi, dpsi, max_psi;
# //initialize
# steps = 90; //about 1 degree steps
# max_psi = M_PI_2; //pi/2
# dpsi = max_psi/steps;
# psi = 0.0;
# integral = 0.0;
# while(psi < max_psi) //left sum
# {
#  integral += exp(-cnpy_beam_ext(psi, l_angle, omega, p_crown)*lai_total)
#  *sin(psi)*cos(psi)*dpsi;
#   psi += dpsi;
# }

# tau_d = 2.0*integral;
#ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

#ATTEMPT #1: Trying to emulate the C++ version approach:

tau_d_calc <- function(tau_be,z_angle) {

  steps <- 90
  max_z_angle <- pi()/2
  dz_angle <- max_z_angle/steps
  z_angle <- 0 
  integral <- 0

  while(z_angle < max_z_angle) {
  
      integral <- integral + tau_be*sin(z_angle)*cos(z_angle)*dz_angle

}
  
tau_d = 2.0*integral

return(tau_d)

}


#ATTEMPT #2: Trying to R 'integrate' function approach:

tau_d_calc <- function (tau_be, z_angle) {
  
num_int_func <- function(z_angle, tau_be) {
    
    num_int <- tau_be
    num_int <- num_int * sin(z_angle)*cos(z_angle)
    
    return(num_int)
    
  }

num_int <- integrate(num_int_func, lower = 0, upper = (pi()/2), 
                     LAI_total = LAI_total, Kbe = Kbe) 

tau_d <- num_int * 2

return(tau_d)

}

#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate photosynthetically active radiation (PAR) used for photosynthesis (Ps) 
# in sunlit leaves

PAR_Ps_sun_calc <- function(alpha_PAR,Kbe,Iob,Id,Isc){
  
  PAR_Ps_sun <- alpha_PAR
  PAR_Ps_sun <- PAR_Ps_sun * (Kbe*Iob+Id+Isc)
  
  return(PAR_Ps_sun)
}

#-------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------
# calculate photosynthetically active radiation (PAR) used for photosynthesis (Ps) 
# in shaded leaves

PAR_Ps_shd_calc <- function(alpha_PAR,Kbe,Iob,Id,Isc){
  
  PAR_Ps_shd <- alpha_PAR
  PAR_Ps_shd <- PAR_Ps_shd * (Id+Isc)
  
  return(PAR_Ps_shd)
}
#-------------------------------------------------------------------------------------------

# END OF MODULE