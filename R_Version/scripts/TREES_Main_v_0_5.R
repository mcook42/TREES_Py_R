# David Millar
# dave.millar@uwyo.edu
# October, 19, 2016

rm(list=ls())


#Set directory to R version of TREES
setwd("C:\\Users\\Dave\\Documents\\TREES_Py_R\\TREES_Py_R\\R_Version")

# 3 subdirectories within 'R_Version'
#     1) data - contains input data to run the model
#     2) scripts - contains the R scripts for each module
#     3) docs - documents with info regarding the TREES model 


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
# PARAMETER ESTIMATION MODULES #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

#Get reference stomatal conductance parameter estimation module source code
Gs_ref_para_est_module <- file.path('scripts\\Gs_ref_module_v_1.R')
source(Gs_ref_para_est_module)

#Get water stress function parameter estimation module source code
water_stress_para_est_module <- file.path('scripts\\water_stress_module_v_1.R')
source(water_stress_para_est_module)

#~~~~~~~~~~~~~~~~~~~~~~~#
# MODEL PROCESS MODULES #
#~~~~~~~~~~~~~~~~~~~~~~~#

#Get water stress module source code!!!!!!!!!!



#Get aerodynamic resistance module source code
Gva_module <- file.path('scripts\\aerodynamic_conductance_module_v_1.R')
source(Gva_module)

#Get Gsv0 module source code
Gsv0_module <- file.path('scripts\\Gsv0_module_v_1.R')
source(Gsv0_module)

#Get Gc0_k module source code
Gc0_k_module <- file.path('scripts\\Gc0_k_module_v_1.R')
source(Gc0_k_module)





