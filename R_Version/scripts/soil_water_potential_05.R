###############################
# Written by Matthew Cook     #
# Created August 2, 2016      #
# mattheworion.cook@gmail.com #
###############################

#Remove the following line when using in Main.R
#rm(list=ls())

#TODO (Dave/Matt): Fill in missing items
CalcSn <- function(S, n){
  # Function to calculate (MISSING)
  # Args:
  #   S:
  #   n:
  # Returns:
  #   (MISSING)
  
  Sn <- numeric(length(S))
  
  for(i in 2:length(S)){
    Sn[i] <- (S[i] ^ n)
  }
  return(Sn)
}

calcSm <- function(S, m){
  # Function to calculate (MISSING)
  # Args:
  #   S:
  #   m:
  # Returns:
  #   (MISSING)
  
  Sm <- numeric(length(S))
  
  for(i in 2:length(S)) {
    tmp <- S[i] ^ (1 / m)
    tmp <- 1 - tmp
    tmp <- tmp ^ m
    tmp <- 1 - tmp
    tmp <- tmp ^ 2.0
    Sm[i] <- tmp
  }
  return(Sm)
}


soil_water_potential <- function(porosity, bubbling.pressure, pore.size.index, residual, theta=1){
  # Calculate soil water potential, MPa. Assumes bubbling pressure in cm.
  # Args:
  #   porosity: (MISSING)
  #   bubbling.pressure: (MISSING)
  #   pore.size.index: (MISSING)
  #   residual: (MISSING)
  #   theta: (MISSING)
  # Returns:
  #   Soil water potential (Mpa)
  
  #################################
  #Calculate soil water potential.#
  #################################
  
  S <- (theta - residual) / (porosity - residual)
  
  if (S < 0.001){
      S <- 0.001
  } else if (S > 1.0){
      S <- 1.0
  }
  
  n <- pore.size.index + 1
  m <- pore.size.index / n

  #Use van Ganuchten model of soil water potential
  psi.soil <- -0.0001019977334 * bubbling.pressure 
  
  sPow <- ((S ^ (-1 / m)) - 1)    
  psi.soil <- psi.soil * (sPow ^ (1 / n))
  
  if (psi.soil < -10)
  {
      psi.soil <- -10
  }
      
  return(psi.soil)
}

# Define user-inputted variables (hard-code for now)
por <- 0.5 #porosity
p.clay <- 0.25 #percent clay
p.sand <- 0.25 #percent sand

#Calculate their squares
por2 <- por * por
p.clay2 <- p.clay * p.clay
p.sand2 <- p.sand * p.sand

# Calculate ks
ks <- 19.52348 * por 
ks <- ks -  8.96847 - 0.028212 * p.clay 
ks <- ks +  0.00018107 * p.sand2 
ks <- ks -  0.0094125 * p.clay2 
ks <- ks -  8.395215 * por2 
ks <- ks +  0.077718 * p.sand * por 
ks <- ks -  0.00298 * p.sand2 * por2 
ks <- ks -  0.019492 * p.clay2 * por2 
ks <- ks +  0.0000173 * p.sand2 * p.clay 
ks <- ks +  0.02733 * p.clay2 * por 
ks <- ks +  0.001434 * p.sand2 * por 
ks <- ks -  0.0000035 * p.clay2 * p.sand

# calculate e^ks
ks <- exp(ks)

# Calculate bubbling pressure
bubbling.pressure <- 5.33967 + 0.1845 * p.clay 
bubbling.pressure <- bubbling.pressure -  2.483945 * por 
bubbling.pressure <- bubbling.pressure -  0.00213853 * p.clay2 
bubbling.pressure <- bubbling.pressure -  0.04356 * p.sand * por 
bubbling.pressure <- bubbling.pressure -  0.61745 * p.clay * por 
bubbling.pressure <- bubbling.pressure +  0.00143598 * p.sand2 * por2 
bubbling.pressure <- bubbling.pressure -  0.00855375 * p.clay2 * por2 
bubbling.pressure <- bubbling.pressure -  0.00001282 * p.sand2 * p.clay 
bubbling.pressure <- bubbling.pressure +  0.00895359 * p.clay2 * por 
bubbling.pressure <- bubbling.pressure -  0.00072472 * p.sand2 * por 
bubbling.pressure <- bubbling.pressure +  0.0000054 * p.clay2 * p.sand 
bubbling.pressure <- bubbling.pressure +  0.50028 * por2 * p.clay

# Calculate e^bubbling.pressure
bubbling.pressure <- exp(bubbling.pressure)

# Calculate pore.size.index
pore.size.index <- -0.7842831 + 0.0177544 * p.sand 
pore.size.index <- pore.size.index -  1.062498 * por 
pore.size.index <- pore.size.index -  0.00005304 * p.sand2 
pore.size.index <- pore.size.index -  0.00273493 * p.clay2 
pore.size.index <- pore.size.index +  1.111349 * por2 
pore.size.index <- pore.size.index -  0.03088295 * p.sand * por 
pore.size.index <- pore.size.index +  0.00026587 * p.sand2 * por2 
pore.size.index <- pore.size.index -  0.00610522 * p.clay2 * por2 
pore.size.index <- pore.size.index -  0.00000235 * p.sand2 * p.clay 
pore.size.index <- pore.size.index +  0.00798746 * p.clay2 * por 
pore.size.index <- pore.size.index -  0.00674491 * por2 * p.clay

# calculate e^pore.size.index
pore.size.index <- exp(pore.size.index)

# Calculate the residual
residual <- -0.0182482 + 0.00087269 * p.sand 
residual <- residual +  0.00513488 * p.clay 
residual <- residual +  0.02939286 * por 
residual <- residual -  0.00015395 * p.clay2 
residual <- residual -  0.0010827 * p.sand * por 
residual <- residual -  0.00018233 * p.clay2 * por2 
residual <- residual +  0.00030703 * p.clay2 * por 
residual <- residual -  0.0023584 * por2 * p.clay


# Notes:
#
# So below, theta will need its own module(s) to be calculated,
# but we can get to that later on.


# Theta will be calculated elsewhere, but for now we are hardcoding it in
theta <- c(0.4, 0.1, 0.3, 0.1, 0.2, 0.1, 0.1, 0.1, 0.1, 0.1)

#create object for S
S <- numeric(length(theta))

for(i in 2:length(S))
{
  toAppend <- (theta[i] - residual) / (por - residual)
  S[i] <- toAppend
}

n <- pore.size.index + 1

m <- pore.size.index / n

# Create functions to calculate Sn and Sm at each index         
Sn <- CalcSn(S, n)
Sm <- calcSm(S, m)

ku <- numeric(length(Sn))
#calculate each index of ku
#NOTE: assumes Sn and Sm are same length

for(i in 1:length(ku))
{
  ku[i] <- (ks * Sn[i] * Sm[i])
}

psi.soil <- soil_water_potential(por, bubbling.pressure, pore.size.index, residual)

#FOR DEBUGGING
#print(psi.soil)               
