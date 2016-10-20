# Written by Matt Cook
# Created July 21, 2016
# mattheworion.cook@gmail.com

# NOTES:  Non-linear least squares regression are currently used to determine 
#           empirical modelparameter estimates.  

# Update July 25, 2016
# Improved documentation


"""
Module for  estimating the Gs_ref parameter using stomatal conductance
and vapor pressure deficit data
"""

from os import chdir
from statsmodels.api import OLS

from scipy.optimize import curve_fit
from numpy import loadtxt, column_stack, ones_like, log

class GsRef(object):
    """
    Stores calculations for gsRef.
    
    Args:
        work_dir(string):
            Path of directory in which to look for/store files
            
        csv_atm(string):
            filename of .csv file with vapor pressure deficit (VPD) and 
            non-water-stressed non-photosynthesis-limited canopy 
            conductance (Gs) calculated from sap flux measurements.
            
            Data should be stored as:
                column 1: reading number (row number)
                column 2: VPD
                columnn 3: Gs

    NOTE:
        The first row will be ignored to remove headers.  If you do 
        not have a header for your columns please add an extra row
        at the top of your csv file
            
    Attributes:
        gs_ref(float):
            Calculated gs_ref coefficient.
            
        gs_obs(numpy array):
            The observe non-water-stressed, non-photosynthesis-limited 
            stomatal conductance for each time step(mol m^-2 s^-1)
        
        gs_sim(numpy array):
            The simulated non-water-stress, non-photosynthesis-limited
            stomatal conductance for each time step (mol m^-2 s^-1)
        
        r_sqr(float):
            The r-squared value of the simulated model.
            
        d_obs(numpy array):
            The atmospheric vapor pressure deficit (kPa)
        
    """
    
    def __init__(self, work_dir, csv_atm):      
        # Initialize variables
        self.gs_ref = None
        self.gs_obs = None
        self.gs_sim = None
        self.r_sqr = None
        self.d_obs = None
        
        # Calculate gs_ref
        self.__gsRef(work_dir, csv_atm)
    
            
    def __fitFunc(self, x, ref):
        """Function for curve fit optimization"""
        return ref - (0.6 * ref) * log(x)
    
    def __gsRef(self, work_dir, csv_atm):
        """
        A module to calculate the Gsref coefficient.
        
        Method to fit the observed data to a simulated curve and calculate the
        Gsref coefficient.  It modifies the attributes of this class directly.
        
        Args:
            work_dir(string):
                Path of directory in which to look for/store files
                
            csv_atm(string):
                filename of .csv file with vapor pressure deficit (VPD) and 
                non-water-stressed non-photosynthesis-limited canopy 
                conductance (Gs) calculated from sap flux measurements.
                
        """
        
        # set the current working directory - make sure to change this as needed
        chdir(work_dir)        
        
        try:
            # read in the vapor pressure deficit (VPD) and non-water-stressed, 
            # non-photosynthesis-limited canopy conductance (Gs) calculated 
            # from sap flux measurements.
            
            # d = atmospheric vapor pressure deficit (kPa)
            # gs = non-water-stressed, non-photosynthesis-limited stomatal 
            # conductance (mol m^-2 s^-1)
            num, d_obs, gs_obs = loadtxt(csv_atm,
                                           delimiter=",",
                                           skiprows=1,
                                           dtype={'names':('num',
                                                           'd_obs',
                                                           'gs_obs'),
                                                  'formats':('O',
                                                             'float64',
                                                             'float64')},
                                           unpack=True)
            
            self.d_obs = d_obs
            self.gs_obs = gs_obs
    
        except Exception as e:
            print("Something went wrong.  Check that " + csv_atm + 
                    " is in the correct format.")
            print("Here is the actual error: ", e)
            
        # specify initial guess
        start = [0.1]
        
        # fit Gs_ref parameter to observed Gs and D data
        gs_paras, gs_covar = curve_fit(self.__fitFunc,
                                         self.d_obs,
                                         self.gs_obs,
                                         p0=start)
        
        # extract gs_ref from the list
        self.gs_ref = gs_paras[0]  
        
        # simulate Gx in the absence of water supply and/or photosynthetic 
        # limitation
        self.gs_sim = self.__fitFunc(self.d_obs, self.gs_ref)    
        
        # Add column of zeros to simulate y-intercept?
        obs_stacked = column_stack((self.gs_obs, ones_like(self.gs_obs)))
       
        #calculate R^2
        summary = OLS(self.gs_sim, obs_stacked).fit()
        self.r_sqr = summary.rsquared
    
