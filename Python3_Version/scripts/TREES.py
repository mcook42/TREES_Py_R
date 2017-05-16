# Written by Matt Cook
# Created June 27, 2016
# mattheworion.cook@gmail.com

# Update July 15, 2016
# added water stress and converted to object-oriented structure

# Update July 21, 2016
# added gs ref and gsv0 calculations

# Update July 22, 2016
# added gsv0 calculation and memory use reduction

# Update July 25, 2016
# refactored layout of calculations.  Moved from here into gsv0.py

# Update September 22, 2016
# Added soil water potential calculation

# Update September 27, 2016
# Added recalculation of Water stress simulation using soil water potential
# psi_soil data

import os

import water_stress_module as wsmod
import gs_ref_module as gsr
import gsv0
import soil_water_potential as sw_pot


def stripAndLower(str_in):
    """Takes string in and returns lowercase version without whitespace"""
    str_out = str.strip(str_in)
    str_out = str.lower(str_out)
    return str_out

## Warning message for the users.
dir_strct = """
    BEFORE USING THIS CODE PLEASE RESTRUCTURE YOUR DIRECTORIES TO RESEMBLE THE 
                                FOLLOWING


 Python Directory:
 C:/Users/Someone/Documents/Github/TREES_Py_R/Python3_Version
 C:/Users/Someone/Documents/Github/TREES_Py_R/Python3_Version/data
 C:/Users/Someone/Documents/Github/TREES_Py_R/Python3_Version/docs
 C:/Users/Someone/Documents/Github/TREES_Py_R/Python3_Version/scripts
 
 R Directory:
 C:/Users/Someone/Documents/Github/TREES_Py_R/R_Version
 C:/Users/Someone/Documents/Github/TREES_Py_R/R_Version/data
 C:/Users/Someone/Documents/Github/TREES_Py_R/R_Version/docs
 C:/Users/Someone/Documents/Github/TREES_Py_R/R_Version/scripts

Note: Replace everything before "/TREES_Py_R" with the specifics of your 
      system. 
"""

def main():
    ###START OF THE TEXT BASED USER INTERFACE###
    # Ask if structured like ours, if not, print the correct structure
    print(dir_strct)
    
    strct_ans = input("Are your directories structured like above?\n")
    strct_ans = stripAndLower(strct_ans)
    if (not strct_ans.startswith('y')):
        print("Please restructure your directories and try again.")
        exit()
    
    w_dir_in = input("Copy and paste the path to your 'Python3_Version' directory: \n")
    w_dir_in = os.path.abspath(w_dir_in)
    ### END OF TEXT BASED USER INTERFACE ####
    
    # define working directory
    work_dir = w_dir_in + '/data'
    
    # xs calculates/stores a simulated xylem scalar model and its plot against the
    # observed data
    xs = bsmod.XylemScalar(work_dir,
                           'blue_stain_temp_and_growth_rate.csv',
                           'CP_daily_at_and_perc_sap_flux_decline.csv')
    
    #Calculate soil water potential
    swp = sw_pot.SoilWaterPotential(work_dir, "TEST_DATA_090216-Edit.csv")
    
    # ws calculates/stores a simulated xylem scalar model and its plot against the
    # observed data
    ws = wsmod.WaterStress(work_dir, 'PICO_ws_obs_data.csv')
    
    #Use Soil water potential psi values to recalculate the ws simulation
    ws.simFunc(swp.psi_soil)
    
    # calculate and store gs_ref and the results               
    gs = gsr.GsRef(work_dir, 'PICO_atm_demand_data.csv')
    
    # Calculate gsv_0 
    gsv_0 = gsv0.Gsv_0(xs, ws, gs)
    return gsv_0
