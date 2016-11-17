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



CorrectionLongitude <- function(longi){
  # Function for longitude correction
  # Args:
  #   longi: longitude
  # Return:
  #   The corrected longitude
  
  longi <- abs(longi)
  
  # calculate the central meridian
  cen.meridian <- 15 * as.integer((longi + 7.5) / 15) # (to round off)
  correction <- (cen.meridian - longi) / 15.0
  
  return (correction)
}


Deg2Rad <- function(deg){
  # Function to convert degrees to radians
  # Args:
  #   deg: Angle in degrees
  # Return:
  #   The angle in radians
  
  return (pi * deg / 180.0)
}


CalcZenithAngle <- function(lati,longi,jday,thyme){
  # Function to calculate zenith angle 
  # Args:
  #   lati: The latitude
  #   longi: The longitude
  #   jday: The julian day
  #   thyme: The time of day
  # Returns:
  #   The zenith angle
  
  #longitude correction
  corr <- CorrectionLongitude(longi)
  
  #for calculations of corrections due to eq of time
  temp <- Deg2Rad(279.575 + (0.9856 * jday))
  
  #calculate equation of time (Campbell and Norman 1998, Eq:11.4)
  corr <- corr + (-104.7 * sin(temp) + 596.2 * sin(2 * temp) + 4.3 * sin(3 * temp) -12.7 * sin(4 * temp)
                  -429.3 * cos(temp) -2.0 * cos(2 * temp) + 19.3 * cos(3 * temp)) / 3600.0
  
  #calculate solar noon (Campbell and Norman 1998, Eq:11.3)
  solnoon <- 12 - corr
  
  #convert to radian
  lati <- Deg2Rad(lati) 
  
  #calculate solar declination (Campbell and Norman 1998, Eq:11.2)
  temp <- Deg2Rad(278.97 + 0.9856 * jday
                  + 1.9165 * sin(Deg2Rad(356.6 + 0.9856 * jday)))
  
  declin <- asin(0.39785 * sin(temp))
  
  #calculate zenith angle [in radians] (Campbell and Norman 1998, Eq:11.1)
  z.angle <- sin(lati) * sin(declin)
  + cos(lati) * cos(declin) * 
    cos(Deg2Rad(15 * thyme - solnoon))
  
  z.angle <- acos(z.angle)
  
  #return zenith angle in radians
  return (z.angle) 
  
}


CalcSolarElevation <- function(z.angle){
  # Function to calculate solar elevation
  # Args:
  #   z.angle = The zenith angle
  # Returns:
  #   The solar elevation
  
  Se <- 0.5 * pi() - z.angle
  return (Se)
}


CalcQe <- function(Se, jday){
  # Function to calculate extra-terrestrial radiation (Qe)
  # Args:
  #   Se: The solar elevation
  #   jday: The Julian day
  # Returns:
  #   The extra-terrestrial radiation
  
  Sc <- 1370  # Solar constant (W m^-2)
  Qe <- Sc * sin(Se) * ((1 + 0.033 * cos((360 * jday) / 365)))
  return (Qe)
}


CalcQo <- function(PAR){
  # Function to convert photosynthetically active radiation from input 
  # to total incoming above-canopy radiation (Qo)
  # Args:
  #   PAR: Photosynthetically active radiation (umol m^-2 s^-1)
  # Returns:
  #   Total incoming above-canopy radiation (W m^-2)
  
  # factor used to convert PAR to total incoming solar radiation
  con.fac <- 2.12766
  
  # factor to convert units from umol m^-2 s^-1 to W m^-2
  con.units <- 0.235
  
  Qo <- PAR * con.fac * con.units
  
  return (Qo)
}


CalcTauAtm <- function(Qo, Qe){
  # Function to calculate atmospheric transmissivity
  # Args:
  #   Qo: Incoming above-canopy radiation (W m^-2)
  #   Qe: The extra-terrestrial radiation
  # Returns:
  #   Atmospheric transmissivity

  return (Qo / Qe)
}


CalcFd <- function (tau.atm, Se) {
  # Function to calculate fraction of total above canopy radiation in diffuse form
  # Args:
  #   tau.atm: Atmospheric transmissivity
  #   Se: Solar elevation
  # Return:
  #   Fraction of total above canopy radiation in diffuse form
  
  R <- 0.847 - 1.61 * sin(Se) + 1.04 * sin(Se) * sin(Se)

  K <- (1.47 - R) / 1.66
  
  f_d <- 0
  
  if (tau.atm <= 0.22) {
    f_d <- 1
  } else if (tau.atm > 0.22 & tau.atm <= 0.35) {
    f_d <- 1 - 6.4 * (tau.atm - 0.22) ^ 2
  } else if (tau.atm > 0.35 & tau.atm <= K) {
    f_d <- 1.47 - 1.66 * tau.atm
  } else{
    tau.atm <- R
  }

  #TODO (Dave): What does this return?
}


CalcQod <- function(fd, Qo){
  # Function to calculate total above canopy diffuse radiation 
  # Args:
  #   fd: Above canopy radiation in diffuse form 
  #   Qo: Incoming above-canopy radiation (W m^-2)
  # Returns:
  #   Total above canopy diffuse radiation (W m^-2)
  return (fd * Qo)
}


CalcQob <- function(Qod, Qo){
  # Function to calculate total above canopy beam radiation (Qob) (W m^-2)
  # Args:
  #   Qod: Total above canopy diffuse radiation (W m^-2)
  #   Qo: Incoming above-canopy radiation (W m^-2)
  # Returns:
  #   Total above canopy beam radiation (W m^-2)
  return (Qo - Qod)
}


CalcIob <- function(Qob){
  # Function to calculate PAR in beam form (Iob) (W m^-2)
  # Args:
  #   Qob: Total above canopy beam radiation (W m^-2)
  # Return:
  #   Photosynthetically active radiation in beam form (W m^-2)
  
  fPARbeam <- 0.5  # Fraction of PAR in beam form
  Iob <- fPARbeam * Qob
  return (Iob)
}


CalcIod <- function(Qod){
  # Function to calculate PAR in diffuse form (Iod) (W m^-2)
  # Args:
  #   Qod: Total above canopy diffuse radiation (W m^-2)
  # Return:
  #   Photosynthetically active radiation in diffuse form (W m^-2)
  
  fPARdiff <- 0.5  # Fraction of PAR in diffuse form
  Iod <- fPARdiff * Qod
  return (Iod)
}


CalcQobNIR <- function(Qob, Iob){
  # Function to calculate near infrared radiation (NIR) in beam form (QobNIR) (W m^-2)
  # Args: 
  #   Qob: Total above canopy beam radiation (W m^-2)
  #   Iob: Photosynthetically active radiation in beam form (W m^-2)
  # Return:
  #   Near infrared radiation (NIR) in beam form (W m^-2)
  
  QobNIR <- Qob - Iob
  return (QobNIR)
}


CalcQodNIR <- function(Qod,Iod){
  # Function to calculate near infrared radiation (NIR) in diffuse form (QodNIR) (W m^-2)  
  # Args:
  #   Qod: Total above canopy diffuse radiation (W m^-2)
  #   Iod: Photosynthetically active radiation in diffuse form (W m^-2)
  
  QodNIR <- Qod - Iod
  return (QodNIR)
}