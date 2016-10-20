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

import blue_stain_xylem_scaling_module as bsmod
import water_stress_module as wsmod
import gs_ref_module as gsr
import gsv0


# define working directory
work_dir = 'C:\\Users\\Someone\\Documents\\Github\\TREES_Py_R'
work_dir += '\\Python3_Version\\data'

# xs calculates/stores a simulated xylem scalar model and its plot against the
# observed data                   
xs = bsmod.XylemScalar(work_dir,
                       'blue_stain_temp_and_growth_rate.csv',
                       'CP_daily_at_and_perc_sap_flux_decline.csv')

# ws calculates/stores a simulated xylem scalar model and its plot against the
# observed data                   
ws = wsmod.WaterStress(work_dir, 'PICO_ws_obs_data.csv')
  
# calculate and store gs_ref and the results                   
gs = gsr.GsRef(work_dir, 'PICO_atm_demand_data.csv')

# Calculate gsv_0 
gsv_0 = gsv0.Gsv_0(xs, ws, gs)                    
gsv_0.calculate()


