# David Millar
# dave.millar@uwyo.edu
# October 19, 2016


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# TREES reference stomatal conductance (Gs.ref) estimation module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#



#-----------------------------------------------------------------------------------------------

GsRefParaEst <- function(D_obs, Gs_obs){
  # Function for estimating reference stomatal conductance parameter
  # Args:
  #   D.obs: (MISSING)
  #   Gs.obs: (MISSING)
  # Return:
  #   Reference stomatal conductance parameter
  
  # Fit Gs.ref parameter to observed Gs and D data
  Gs.ref.fit <- nls(Gs_obs ~ Gs.ref - (0.6 * Gs.ref) * log(D_obs), start = list(Gs.ref = 0.1))
  Gs.ref.paras <- coef(Gs.ref.fit)
  Gs.ref <- Gs.ref.paras[1]
  
  return(Gs.ref)
}
