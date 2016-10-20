###############################
# Written by Matthew Cook     #
# Created August 2, 2016      #
# mattheworion.cook@gmail.com #
###############################

#Remove the following line when using in Main.R
rm(list=ls())

calcSn <- function(S, n)
{
  Sn <- numeric(length(S))
  
  for(i in 2:length(S))
  {
    Sn[i] <- (S[i] ^ n)
  }
  return(Sn)
}

calcSm <- function(S, m)
{
  Sm <- numeric(length(S))
  
  for(i in 2:length(S))
  {
    tmp <- S[i] ^ (1/m)
    tmp <- 1 - tmp
    tmp <- tmp ^ m
    tmp <- 1 - tmp
    tmp <- tmp ^ 2.0
    Sm[i] <- tmp
  }
  return(Sm)
}

#Calculate water potential, MPa
#Assumes bubbling pressure in cm
soil_water_potential <- function(porosity, bubbling_pressure, pore_size_index, residual, theta=1)
{
    #################################
    #Calculate soil water potential.#
    #################################
    
    S <- (theta - residual) / (porosity - residual)
    
    if (S < 0.001)
    {
        S <- 0.001
    }   
    else if (S > 1.0)
    {
        S <- 1.0
    }
    
    n <- pore_size_index + 1
    m <- pore_size_index / n

    #Use van Ganuchten model of soil water potential
    psi_soil <- -0.0001019977334*bubbling_pressure 
    
    sPow <- ((S ^ (-1/m)) - 1)    
    psi_soil <- psi_soil * (sPow ^ (1/n))
    
    if (psi_soil < -10)
    {
        psi_soil <- -10
    }
        
    return(psi_soil)
}

# Define user-inputted variables (hard-code for now)
por <- 0.5 #porosity
pClay <- 0.25 #percent clay
pSand <- 0.25 #percent sand

#Calculate their squares
por2 <- por*por
pClay2 <- pClay*pClay
pSand2 <- pSand*pSand

# Calculate ks
ks <- 19.52348*por 
ks <- ks -  8.96847 - 0.028212*pClay 
ks <- ks +  0.00018107*pSand2 
ks <- ks -  0.0094125*pClay2 
ks <- ks -  8.395215*por2 
ks <- ks +  0.077718*pSand*por 
ks <- ks -  0.00298*pSand2*por2 
ks <- ks -  0.019492*pClay2*por2 
ks <- ks +  0.0000173*pSand2*pClay 
ks <- ks +  0.02733*pClay2*por 
ks <- ks +  0.001434*pSand2*por 
ks <- ks -  0.0000035*pClay2*pSand

# calculate e^ks
ks <- exp(ks)

# Calculate bubbling pressure
bubbling_pressure <- 5.33967 + 0.1845 * pClay 
bubbling_pressure <- bubbling_pressure -  2.483945*por 
bubbling_pressure <- bubbling_pressure -  0.00213853*pClay2 
bubbling_pressure <- bubbling_pressure -  0.04356*pSand*por 
bubbling_pressure <- bubbling_pressure -  0.61745*pClay*por 
bubbling_pressure <- bubbling_pressure +  0.00143598*pSand2*por2 
bubbling_pressure <- bubbling_pressure -  0.00855375*pClay2*por2 
bubbling_pressure <- bubbling_pressure -  0.00001282*pSand2*pClay 
bubbling_pressure <- bubbling_pressure +  0.00895359*pClay2*por 
bubbling_pressure <- bubbling_pressure -  0.00072472*pSand2*por 
bubbling_pressure <- bubbling_pressure +  0.0000054*pClay2*pSand 
bubbling_pressure <- bubbling_pressure +  0.50028*por2*pClay

# Calculate e^bubbling_pressure
bubbling_pressure <- exp(bubbling_pressure)

# Calculate pore_size_index
pore_size_index <- -0.7842831 + 0.0177544*pSand 
pore_size_index <- pore_size_index -  1.062498*por 
pore_size_index <- pore_size_index -  0.00005304*pSand2 
pore_size_index <- pore_size_index -  0.00273493*pClay2 
pore_size_index <- pore_size_index +  1.111349*por2 
pore_size_index <- pore_size_index -  0.03088295*pSand*por 
pore_size_index <- pore_size_index +  0.00026587*pSand2*por2 
pore_size_index <- pore_size_index -  0.00610522*pClay2*por2 
pore_size_index <- pore_size_index -  0.00000235*pSand2*pClay 
pore_size_index <- pore_size_index +  0.00798746*pClay2*por 
pore_size_index <- pore_size_index -  0.00674491*por2*pClay

# calculate e^pore_size_index
pore_size_index <- exp(pore_size_index)

# Calculate the residual
residual <- -0.0182482 + 0.00087269*pSand 
residual <- residual +  0.00513488*pClay 
residual <- residual +  0.02939286*por 
residual <- residual -  0.00015395*pClay2 
residual <- residual -  0.0010827*pSand*por 
residual <- residual -  0.00018233*pClay2*por2 
residual <- residual +  0.00030703*pClay2*por 
residual <- residual -  0.0023584*por2*pClay


# Notes:
#
# So below, theta will need its own module(s) to be calculated,
# but we can get to that later on.


# Theta will be calculated elsewhere, but for now we are hardcoding it in
theta <- c(0.4,0.1,0.3,0.1,0.2,0.1,0.1,0.1,0.1,0.1)

#create object for S
S <- numeric(length(theta))

for(i in 2:length(S))
{
  toAppend <- (theta[i] - residual) / (por - residual)
  S[i] <- toAppend
}

n <- pore_size_index + 1

m <- pore_size_index / n

# Create functions to calculate Sn and Sm at each index         
Sn <- calcSn(S, n)
Sm <- calcSm(S, m)

ku <- numeric(length(Sn))
#calculate each index of ku
#NOTE: assumes Sn and Sm are same length

for(i in 1:length(ku))
{
  ku[i] <- (ks * Sn[i] * Sm[i])
}

psi_soil <- soil_water_potential(por, bubbling_pressure, pore_size_index, residual)

print(psi_soil)               
