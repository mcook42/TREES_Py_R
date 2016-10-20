# David Millar - June 15, 2016
# dave.millar@uwyo.edu

# NOTES: - ggplot code at the end is just used for evaluation and plotting, and can be omitted 
#          or commented out when integrating this module into TREES_Py_R
#        - Non-linear least squares regression are currently used to determine empirical model
#          parameter estimates.  

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::#
#                                                                                                     #
# Module to downscale xylem conductance (transpiration) as a function of blue stain fungal infection. #
#                                                                                                     #
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::#

#clear everything out
#rm(list=ls())

#call to ggplot package
#library(ggplot2)

#-----------------------------------------------------------------------------------------------------

#setwd("C:\\Users\\Matthew\\Documents\\GitHub\\TREES_Py_R\\R_Version_Project\\blue_stain_xylem_scaling_module")


# read in the temperature and growth rate of blue stain fungi from Moore and Six 2015
    # temp = temperature (degrees C)
    # gr = blue stain fungal growth rate (mm^2 d^-1)
temp_gr <- read.csv("blue_stain_temp_and_growth_rate.csv")
names(temp_gr)=c("temp_obs", "gr_obs")

temp_obs <- temp_gr$"temp_obs"
gr_obs <- temp_gr$"gr_obs"


# read in observed mean daily percent sap flux decline with mean daily air temperatures
# *** as of 6/15/16, this data set is from Chimney Park 2009 ***
    # date = mm/dd/yyyy
    # at = mean daily air temperature (degrees C)
    # sfd = relative sap flux decline 
    #       (mean sapflux of attacked trees/mean sap flux of unimpacted trees)
sf_decline <- read.csv("CP_daily_AT_and_perc_sap_flux_decline.csv")
names(sf_decline)=c("date","at","sfd")

dates <- sf_decline$"date"
at_obs <- sf_decline$"at"
xs_obs <- sf_decline$"sfd"   # 'xs' represents 'xylem scalar'

#-----------------------------------------------------------------------------------------------------

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::#
#   full bark beetle-impact xylem scalar model function   #
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::#

xylem_scalar <- function(temp_obs,gr_obs,at_obs,xs_obs){
  
  # fit blue stain growth model paras to 'temp_gr' data using a Guassian function
  bs_gr.fit <- nls(gr_obs ~ a * exp(-0.5*((temp_obs-b)/c)^2), data = temp_gr,
                   start = list(a = 450, b = 25, c = 5))
  bs_gr.paras <- coef(bs_gr.fit)
  a <- bs_gr.paras[1]
  b <- bs_gr.paras[2]
  c <- bs_gr.paras[3]

  # simulate cumulative daily blue stain fungal biomass 
  # as function of temperature-dependent growth rate
  sim_bs_bm <- numeric(length(at_obs))
  for (i in 2:length(sim_bs_bm)){
    sim_bs_bm[i] <- sim_bs_bm[i-1] + (a * exp(-0.5*((at_obs[i]-b)/c)^2))
  }
  
  # fit model of simulated blue stain fungal growth to percent sapflux decline 
  # using a sigmoid function (numerator is set to 1, in order to get 0-100%)
  xs.fit <- nls(xs_obs ~ 1/(1+a2*exp(b2*sim_bs_bm)), start = list(a2 = 0.04, b2 = 0.0006))
  xs.paras <- coef(xs.fit)
  a2 <- xs.paras[1]
  b2 <- xs.paras[2]

  # simulate the decline in sap flux as a function of simulated blue stain fungal biomass
  xs_sim <- 1/(1+a2*exp(b2*sim_bs_bm))

return(xs_sim)

}

#-----------------------------------------------------------------------------------------------------

#::::::::::::::::::::::::::::::::::::::::::::::::#
#   create timeseries plot of obs and sim sfd    #
#::::::::::::::::::::::::::::::::::::::::::::::::#
# 
# CP_xs_sim <- xylem_scalar(temp_obs,gr_obs,at_obs,xs_obs)
# CP_xs_obs <- xs_obs
# CP_date <- as.POSIXct(dates,format="%m/%d/%Y")
# 
# # print(CP_xs_sim)
# # print(CP_xs_obs)
# # print(CP_date)
# 
# ggdata <- cbind.data.frame(CP_date,CP_xs_sim,CP_xs_obs)
# # 
# # CP_test_plot <- ggplot(ggdata) + 
# #                 geom_point(aes(x=CP_date, y=CP_xs_obs, shape ='observed', linetype = 'observed', color ='observed',size ='observed')) + 
# #                 geom_line(aes(x=CP_date, y=CP_xs_sim, shape ='simulated', linetype = 'simulated', color ='simulated',size ='simulated')) +
# #                 scale_shape_manual(values=c(19, NA)) + 
# #                 scale_linetype_manual(values=c(0, 1)) +
# #                 scale_size_manual(values=c(4,1.5)) +
# #                 scale_color_manual(values=c("blue","springgreen3")) +
# #                 xlab(NULL) + 
# #                 ylab("fraction of functional xylem") +
# #                 ggtitle("CP sapflux decline 2009") +
# #                 theme(axis.text=element_text(size=18),
# #                       strip.text=element_text(size=18),
# #                       title=element_text(size=18),
# #                       text=element_text(size=18),
# #                       legend.text=element_text(size=18),
# #                       legend.title=element_blank(),
# #                       legend.key = element_blank())
# # 
# # CP_test_plot
# 
# #-----------#
# # save plot #
# #-----------#
# 
# #ggsave("CP_sf_decline_obs_and_sim_timeseries.png",width=10,height=4,units='in',dpi=500)
# #dev.off()
# 
# 
# 
