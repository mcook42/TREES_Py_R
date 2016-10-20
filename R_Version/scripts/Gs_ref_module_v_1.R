# David Millar
# dave.millar@uwyo.edu
#October 19, 2016


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# TREES reference stomatal conductance (Gs_ref) estimation module #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


# function for estimating reference stomatal conductance parameter
#-----------------------------------------------------------------------------------------------

para_est_Gs_ref <- function(D_obs,Gs_obs){
  
  # fit Gs_ref parameter to observed Gs and D data
  
  Gs_ref.fit <- nls(Gs_obs ~ Gs_ref - (0.6*Gs_ref)*log(D_obs), start = list(Gs_ref = 0.1))
  Gs_ref.paras <- coef(Gs_ref.fit)
  Gs_ref <- Gs_ref.paras[1]
  
  return(Gs_ref)
  
}
