rm(list=ls())


# These variables eventual should be read from a 'fixed parameters' file.
lati <- 41.08
longi <- -106.318
jday <- 160
thyme <- 5

#----------------------------------------------
# function to correct longitude   

#  ***  In the original TREES C++ code (in util.cpp) this function 
#       also takes latitude as an input, but I have not idea why, so 
#       it is not included in this version. -DJM 09/28/16 ***

long_corr <- function(longi){
  
  longi <- abs(longi)
  
  #calculate the central meridian
  cen_meridian <- 15*as.integer(((longi + 7.5)/15)) # (to round off)
  correction <- (cen_meridian - longi)/15.0
  
  return(correction)
  
}
#----------------------------------------------

#===========================================================================================

#----------------------------------------------
# function to convert degrees to radians  

deg2rad <- function(deg){
  pi*deg/180.0
}
#----------------------------------------------

#===========================================================================================

#----------------------------------------------
# function to calculate zenith angle 
# (which ultimately is used to calculate solar elevation)

zenith_angle <- function(lati,longi,jday,thyme){

#longitude correction
corr <- long_corr(longi)

#for calculations of corrections due to eq of time
temp <- deg2rad(279.575 + (0.9856*jday))

#add the eqt in hours - eq. 11.4 in C&N
corr <- corr + (-104.7*sin(temp) +596.2*sin(2*temp) +4.3*sin(3*temp) -12.7*sin(4*temp)
         -429.3*cos(temp) -2.0*cos(2*temp) +19.3*cos(3*temp))/3600.0

solnoon <- 12 - corr #eq 11.3 C&N

lati <- deg2rad(lati) #convert to radian

#eq 11.2 - C&N
temp <- deg2rad(278.97 + 0.9856*jday
               + 1.9165*sin(deg2rad(356.6+0.9856*jday)))

declin <- asin(0.39785*sin(temp))

#eq 11.1 - C&N
ztemp <- sin(lati)*sin(declin)
+ cos(lati)*cos(declin)*
  cos(deg2rad(15*thyme - solnoon))

ztemp <- acos(ztemp)

return(ztemp) #the zenith angle

}

#----------------------------------------------

zenith_angle(lati,longi,jday,thyme)

