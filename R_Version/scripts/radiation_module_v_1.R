# David Millar 
# dave.millar@uwyo.edu
# October 20, 2016

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# Above-canopy radiation module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


# These variables eventual should be read from a 'fixed parameters' input file:
#
#     lati <- 41.08
#     longi <- -106.318
#     jday <- 160
#     thyme <- 5


# function for longitude correction
#-----------------------------------------------------------------------------------------------

correction_longitude <- function(longi){
  
  longi <- abs(longi)
  
  # calculate the central meridian
  cen_meridian <- 15*as.integer(((longi + 7.5)/15)) # (to round off)
  correction <- (cen_meridian - longi)/15.0
  
  return(correction)
  
}

# function to convert degrees to radians  
#-----------------------------------------------------------------------------------------------

convert_deg2rad <- function(deg){
  pi*deg/180.0
}


# function to calculate zenith angle 
#-----------------------------------------------------------------------------------------------
#thyme = time
calc_zenith_angle <- function(lati,longi,jday,thyme){
  
  #longitude correction
  corr <- correction_longitude(longi)
  
  #for calculations of corrections due to eq of time
  temp <- deg2rad(279.575 + (0.9856*jday))
  
  #calculate equation of time (Campbell and Norman 1998, Eq:11.4)
  corr <- corr + (-104.7*sin(temp) +596.2*sin(2*temp) +4.3*sin(3*temp) -12.7*sin(4*temp)
                  -429.3*cos(temp) -2.0*cos(2*temp) +19.3*cos(3*temp))/3600.0
  
  #calculate solar noon (Campbell and Norman 1998, Eq:11.3)
  solnoon <- 12 - corr
  
  #convert to radian
  lati <- deg2rad(lati) 
  
  #calculate solar declination (Campbell and Norman 1998, Eq:11.2)
  temp <- deg2rad(278.97 + 0.9856*jday
                  + 1.9165*sin(deg2rad(356.6+0.9856*jday)))
  
  declin <- asin(0.39785*sin(temp))
  
  #calculate zenith angle [in radians] (Campbell and Norman 1998, Eq:11.1)
  z_angle <- sin(lati)*sin(declin)
  + cos(lati)*cos(declin)*
    cos(deg2rad(15*thyme - solnoon))
  
  z_angle <- acos(z_angle)
  
  #return zenith angle in radians
  return(z_angle) 
  
}


# function to calculate solar elevation
#-----------------------------------------------------------------------------------------------
calc_solar_elevation <- function(z_angle){
  
  Se <- 0.5*pi() - z_angle
  
  return(Se)

}


# function to calculate extra-terrestrial radiation (Qe)
#-----------------------------------------------------------------------------------------------
calc_Qe <- function(Se,jday){
  
  # Sc = solar constant (W m^-2)
  Sc <- 1370 
  
  Qe <- Sc * sin(Se) * ((1+0.033*cos((360*jday)/365)))
  
  return(Qe)
  
}


# function to convert photosynthetical active radiation (PAR) (umol m^-2 s^-1) from input 
# to total incoming above-canopy radiation (Qo) (W m^-2)
#-----------------------------------------------------------------------------------------------
calc_Qo <- function(PAR){
  
  # factor used to convert PAR to total incoming solar radiation
  con_fac <- 2.12766
  
  # factor to convert units from umol m^-2 s^-1 to W m^-2
  con_units <- 0.235
  
  Qo <- PAR * con_fac * con_units
  
  return(Qo)
  
}


# function to calculate atmospheric transmissivity
#-----------------------------------------------------------------------------------------------
calc_tau_atm <- function(Qo,Qe){
  
  tau_atm <- Qo/Qe
  
  return(tau_atm)
  
}


# function to calculate fraction of total above canopy radiation in diffuse form
#-----------------------------------------------------------------------------------------------
calc_fd <- function (tau_atm,Se) {
  
  R <- 0.847 - 1.61*sin(Se) + 1.04*sin(Se)*sin(Se)

  K <- (1.47-R)/1.66
  
  f_d <- 0
  
  if (tau_atm <= 0.22) {
  f_d <- 1
  } 
  else if (tau_atm > 0.22 & tau_atm <= 0.35) {
    f_d <- 1-6.4*(tau_atm-0.22)^2
  }
  else if (tau_atm > 0.35 & tau_atm <= K) {
    f_d <- 1.47-1.66*tau_atm
  }
  else tau_atm <- R

}

# function to calculate total above canopy diffuse radiation (Qod) (W m^-2)
#-----------------------------------------------------------------------------------------------
calc_Qod <- function(fd,Qo){
  
  Qod <- fd*Qo
  
  return(Qod)
  
}


# function to calculate total above canopy beam radiation (Qob) (W m^-2)
#-----------------------------------------------------------------------------------------------
calc_Qob <- function(Qod,Qo){
  
  Qob <- Qo - Qod
  
  return(Qob)
  
}

# function to calculate PAR in beam form (Iob) (W m^-2)
#-----------------------------------------------------------------------------------------------
calc_Iob <- function(Qob){
  
  # fraction of PAR in beam form
  fPARbeam <- 0.5
  
  Iob <- fPARbeam*Qob
  
  return(Iob)
  
}

# function to calculate PAR in diffuse form (Iod) (W m^-2)
#-----------------------------------------------------------------------------------------------
calc_Iod <- function(Qod){
  
  # fraction of PAR in diffuse form
  fPARdiff <- 0.5
  
  Iod <- fPARdiff*Qod
  
  return(Iod)
  
}

# function to calculate near infrared radiation (NIR) in beam form (QobNIR) (W m^-2)
#-----------------------------------------------------------------------------------------------
calc_QobNIR <- function(Qob,Iob){
  
  QobNIR <- Qob - Iob
  
  return(QobNIR)
  
}

# function to calculate near infrared radiation (NIR) in diffuse form (QodNIR) (W m^-2)
#-----------------------------------------------------------------------------------------------
calc_QodNIR <- function(Qod,Iod){
  
  QodNIR <- Qod - Iod
  
  return(QodNIR)
  
}