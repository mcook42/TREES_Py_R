# David Millar 
# dave.millar@uwyo.edu
# May 2, 2017

# *******NOTE********
#
# MAKE SURE TO CHECK THE UNITS ON EVERYTHING! 
# Gc0 in particular may need unit conversion.
# 05/02/17 - D. Millar

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Farquhar photosynthesis module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

# Calculate CO2 assimilation rate for canopy element (sun or shade)
#-------------------------------------------------------------------------------------------

  # Av_k = RuBisCO-limited photosynthetic 
  #        assimilation rate (umol m^-2 s^-1)
  # Aj_k = canopy element RuBP regeneration-limited 
  #        photosynthetic assimilation rate (umol m^-2 s^-1)
  # Rd = "dark" respiration that occurs in the light (umol m^-2 s^-1)

An_k_calc <- function(Av_k,Aj_k,Rd){
  
  An_k <- min(Av_k,Aj_k)
  An_k <- An_k - Rd
  
  return(An_k)
  
}
#-------------------------------------------------------------------------------------------

#Calculate quadratic solution for Av (RuBisCO-limited Ps) for canopy element
#-------------------------------------------------------------------------------------------

  # Gc0 = canopy element conductance to CO2 
  #       prior to photosynthetic limitation (mol m^-2 s^-1)
  # Ca = atmospheric CO2 concentration (ppmv)
  # Vcmax = maximum carboxylation rate (umol m^-2 s^-1)
  # Rd = "dark" respiration that occurs in the light (umol m^-2 s^-1)  
  # Kc = Michaelis-Menten constant for carboxylation (Pa)
  # Ko = Michaelis-Menten constant for oxygenation (Pa)
  # O2 = Oxygen concentration (Pa)
  # gammaStar = CO2 compensation point in the abscence 
  #             of mitochondrial respiration (Pa)

quad_Av_calc <- function(gc0,Ca,Vcmax,Rd,Kc,Ko,O2,gammaStar){
  aa = -1.0/gc0
  bb = Ca + (Vcmax - Rd)/g + Kc*(1.0 + O2/Ko)
  cc = Vcmax*(gammaStar - Ca) + Rd*(Ca + Kc*(1.0 + O2/Ko))
  det = bb^2 - 4.0*aa*cc
  
  if (det < 0.0) {
    Av = 0.0
  }
  else {
    Av = (-bb + sqrt(det)) / (2.0*aa)
  }
  
  return(Av)
}
#-------------------------------------------------------------------------------------------

#Calculate quadratic solution for Aj (RuBP regen.-limited Ps) for canopy element
#-------------------------------------------------------------------------------------------

  # Gc0 = canopy element conductance to CO2 
  #       prior to photosynthetic limitation (mol m^-2 s^-1)
  # Ca = atmospheric CO2 concentration (ppmv)
  # gammaStar = CO2 compensation point in the abscence 
  #             of mitochondrial respiration (Pa)
  # J = electron transport rate (umol m^-2 s^-1)
  # Rd = "dark" respiration that occurs in the light (umol m^-2 s^-1)  

quad_Aj_calc <- function(gc0,Ca,gammaStar,J,Rd){
  
  aa = -4.0/gc0   
  bb = 4.0*Ca + 8.0*gammaStar + J/gc0 - 4.0*Rd/gc0
  cc = J*(gammaStar - Ca) + Rd*(4.0*Ca + 8.0*gammaStar)
  det = bb^2 - 4.0*aa*cc
  
  if (det < 0.0) {
    Aj = 0.0
  }
  else	{
    Aj = (-bb + sqrt(det)) / (2.0*aa)
  }
  
  return(Aj)
}
#-------------------------------------------------------------------------------------------

# Calculate Rd - "dark" respration that continues in the light (umol m^-2 s^-1)
#-------------------------------------------------------------------------------------------

  # Rd_mult = factor parameter that relates Rd to Vcmax 
  # Vcmax = maximum carboxilation rate (umol m^-2 s^-1)

Rd_calc <- function(Rd_mult,Vcmax) {
 
  Rd = Rd_mult
  Rd = Rd * Vcmax
  
  return(Rd)

}
#-------------------------------------------------------------------------------------------

# Calculate Vcmax - maximum carboxilation rate (umol m^-2 s^-1)
#-------------------------------------------------------------------------------------------

  # Kr = Michaelis-Menten constant of Rubisco activation (umol kg^-2 s^-1)
  # NRf = proportion of leaf nitrogen in Rubisco (unitless) 
  # Nl = leaf nitrogen concentration (kg N m^-2 leaf)

Vcmax_calc <- function(Kr,NRf,Nl){
  
  Vcmax = 7.16
  Vcmax = Vcmax * Kr
  Vcmax = Vcmax * NRf
  Vcmax = Vcmax * Nl
  
  return(Vcmax)
  
}
#-------------------------------------------------------------------------------------------

# Calculate gammaStar - CO2 compensation point 
# in the abscence of mitochondrial respiration (Pa)
#-------------------------------------------------------------------------------------------

  # t = leaf temperature in degrees Celcius

gammaStar_calc <- function(t){
  
  gammaStar = 0.0036*(t-25)*(t-25)
  gammaStar = gammaStar + 0.188*(t-25)
  gammaStar = gammaStar + 3.69
  
  return(gammaStar)
  
}
#-------------------------------------------------------------------------------------------

# Calculate Kc - Michaelis-Menten constant for carboxylation (umol kg^-2 s^-1)
#-------------------------------------------------------------------------------------------

  # t = temperature in degrees Celcius
  # Kc_25 = Kc @ 25 degrees Celcius
  # Kc_q10 = factor by which Kc changes per 10 degree Celcius temperature increase

Kc_calc <- function(t,Kc_25,Kc_q10){
  
  Kc <- Kc_25 
  Kc <- Kc * Kc_q10^((t-25)/10)
  
  return(Kc)
}
#-------------------------------------------------------------------------------------------

# Calculate Ko - Michaelis-Menten constant for oxygenation (umol kg^-2 s^-1)
#-------------------------------------------------------------------------------------------

# t = temperature in degrees Celcius
# Ko_25 = Ko @ 25 degrees Celcius
# Ko_q10 = factor by which Ko changes per 10 degree Celcius temperature increase

Ko_calc <- function(t,Ko_25,Ko_q10){
  
  Ko <- Ko_25 
  Ko <- Ko * Ko_q10^((t-25)/10)
  
  return(Ko)
}
#-------------------------------------------------------------------------------------------

# Calculate Kr - Michaelis-Menten constant for RuBisCO activation (umol kg^-2 s^-1)
#-------------------------------------------------------------------------------------------

# t = temperature in degrees Celcius
# Kr_25 = Kr @ 25 degrees Celcius
# Kr_q10 = factor by which Kr changes per 10 degree Celcius temperature increase

Kr_calc <- function(t,Kr_25,Kr_q10){
  
  Kr <- Kr_25 
  Kr <- Kr * Kr_q10^((t-25)/10)
  
  return(Kr)
}
#-------------------------------------------------------------------------------------------

# Calculate Jmax25 - maximum electron transport rate @s5 degrees C (umol m^-2 s^-1)
#-------------------------------------------------------------------------------------------

  # Jvr is the ratio of Jmax to Vcmax
  # Vcmax25 is the maximum carboxylation rate at 25 degrees C (umol m^-2 s^-1)

Jmax_25_calc <- function(Jvr, Vcmax25){
  
  Jmax25 = Jvr * Vcmax25
  
  return(Jmax25)
  
}
#-------------------------------------------------------------------------------------------

# Calculate Jmax - maximum electron transport rate (umol m^-2 s^-1)
#-------------------------------------------------------------------------------------------

  #Jmax25 = maximum electron transport rate at 25 degrees Celcius (umol m^-2 s^-1)
  #t = leaf temperature in degrees Celcius
  #R = Gas Law constant(J mol^1 K^1) - value found in constants module

Jmax_calc <- function(Jmax25,t,R){
    
  # convert leaf temperature to degrees Kelvin
  tk = t + 273.15 
  
  Ea = 37000 # activation energy (kJ mol^-1)
  S = 710 # electrong transport temperature response parameter(J K^-1 mol^-1)
  H = 220000 # electron transport temperature curvature parameter(J mol^-1)
  
  Jmax = Jmax25
  Jmax = Jmax * exp((tk-298)*Ea/(R*tk*298))
  Jmax = Jmax * (1+exp((S*298-H)/(R*298)))
  Jmax = Jmax / (1+exp((S*tk-H)/(R*tk)))
  
  return(Jmax)
  
}
#-------------------------------------------------------------------------------------------

# Calculate J -  electron transport rate (umol m^-2 s^-1)
#-------------------------------------------------------------------------------------------

  # Ir = incoming photosynthetically active radiation (umol m^-2 s^-1)
  # Jmax = maximum electron transport rate (umol m^-2 s^-1)
  # phi_J = light adapted quantum yield (mol e- mol photons^-1)
  # theta_J = parameter that described the curvature  
  #          of the photosynthetic response to light

J_calc <- function(Ir,Jmax,phi_J,theta_J){

  Ji = Ir * phiJ
  aa = thetaJ
  bb = -Ji -Jmax
  cc = Ji*Jmax
  J = (-bb - sqrt(bb*bb - 4.0*aa*cc))/(2.0*aa)
  
  return(J)
  
}

# END OF MODULE