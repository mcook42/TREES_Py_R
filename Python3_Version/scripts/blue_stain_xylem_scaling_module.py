# Written by Matt Cook
# Created June 27, 2016
# mattheworion.cook@gmail.com

# Update July 25, 2016
# Improved documentation of class and methods

from os import chdir

import numpy as np
from scipy.optimize import curve_fit

class XylemScalar(object):
    """
    Module to downscale xylem conductance (transpiration) as a function of blue
    stain fungal infection.
    
    Args:
        work_dir(string):
            Stores the path of the directory in which to look for the data
            files.
            
        csv_gr(string):
            Store the filename of the .csv file containing temperature and 
            observed blue stain xylem growth.
            Data should be stored as:
                column one: temperature 
                column two: growth
                        
        csv_sfd(string):
            Store the filename of the .csv file containing dates, mean daily
            air temperature in degrees C, and observed xylem scalar. 
            Data should be stored as: 
                column one:   date as mm/dd/yyyy
                column two:   mean daily air temperature in degrees C
                column three: xylem scalar
            
        NOTE: Headers for each column are expected, otherwise the first data
              point in the .csv file will be ignored.
            
               
    Attributes:
        xs_sim(numpy array):
            Stores simulated xylem scalars.
            
        xs_obs(tuple):
            Stores observed xylem scalars (faster and immutable).
            
        graph(matplotlib plot):
            Plot of the simulated and observed xylem scalars.
        
        coeff(array):
            Stores optimized coefficients for xylem scalar calculation.
            
    """
    def __init__(self, work_dir, csv_gr, csv_sfd):
        """
        Stores information from Xylem Scalar module.
        """
        self.sim = []
        self.obs = ()
        self.graph = None
        self.coeff = {}
        self.dates = ()
        
        self.__xylem_scaling_module(work_dir, csv_gr, csv_sfd)
        
        
    def __xylem_scaling_module(self, work_dir, csv_gr, csv_sfd):
        """
        Look in the readme to see how this works, for now.
        
        NOTE: When reading from csv, the script skips the first line (headers)
            so if you do not have headers and do not wish to lose the first row
            of data points, add an extra row at the top of your CSV file.
        
        Inputs:
            work_dir = working directory for where you have your CSV files 
                       stored
        
            csv_gr = the CSV file containing your temperature and observed 
                     blue stain xylem growth
        
            csv_sfd = the CSV containing columns for:
                       date as mm/dd/yyyy
                       mean daily air temperature in degrees C
                       mean daily percent sap flux decline
        
        Attributes:
            xs_sim = the simulated xylem scalar model
            
            xs_obs = the observed xylem scalar model
         
        """
        
        # Change the directory to your working directory
        chdir(work_dir)
        
        try:
            # read in the temperature and growth rate of blue stain fungi from
            # Moore and Six 2015.
            # temp = temperature (degrees C)
            # gr = blue stain fungal growth rate (mm^2 d^-1)
            temp_gr = np.loadtxt(csv_gr, delimiter=",",
                                 skiprows=1,
                                 dtype={'names':('temp_obs', 'gr_obs'),
                                        'formats':('float32', 'float32')})
        except Exception as e:
            print("Something went wrong.  Check that " + csv_gr + 
                    " is in the correct format.")
            print("Here is the actual error: ", e)
        
        try:
            # read in observed mean daily percent sap flux decline with mean 
            # daily air temperatures
            # *** as of 6/15/16, this data set is from Chimney Park 2009 ***
            # date = mm/dd/yyyy
            # at = mean daily air temperature (degrees C)
            # 'xs' represents 'xylem scalar'
            sf_decline = np.loadtxt(csv_sfd,
                                    delimiter=",",
                                    skiprows=1,
                                    dtype={'names':('dates',
                                                    'at_obs',
                                                    'xs_obs'),
                                           'formats':('O',
                                                      'float64',
                                                      'float64')})
                                                      
        except Exception as e:
            print("Something went wrong.  Check that " + csv_sfd + 
            " is in the correct format.")
            print(e)
        
        self.sim = self.__xylem_scalar(temp_gr, sf_decline)
        self.obs = sf_decline['xs_obs']
        self.dates = sf_decline['dates']
       
    
    # Define model function for Gaussian fit
    def __gauss(self, x, a, b, c):
        """Gaussian fit function for optimizing curve """
        return a*np.exp(-0.5*((x-b)/c)**2)
    
    
    # Define model function for Sigmoid fit
    def __sigmoid(self, x, a2, b2):
        """
        Sigmoid function used to fit model of simulated blue stain fungal growth
        to percent sapflux decline. 'x' is the vector,'a2' and 'b2' are the
        coefficient guesses for the model.
        """
        return 1/(1+a2*np.exp(b2*x))
    
    
    def __xylem_scalar(self, temp_gr, sf_decline):
        """
        Takes temperature and growth rate of blue stain fungi
        from previous data (temp_gr) and observed mean daily percent sap flux
        decline with mean daily air temperatures (sf_decline).
    
        Args:
            temp_gr = 2-column array with temperature and growth rate.
            sf_decline = 2-column array with observed mean daily air 
                        temperatures and mean daily percent sap flux decline
    
        output:
        xs_sim = simulated water stress model
        """
        # fit blue stain growth model paras to 'temp_gr' data using a Guassian
        # function.  Covariance is unused.
        bs_gr_coef = np.asarray([450, 25, 5], dtype='float16')
        bs_gr_coef, bs_gr_covar = curve_fit(self.__gauss,
                                            temp_gr['temp_obs'],
                                            temp_gr['gr_obs'],
                                            p0=bs_gr_coef)
        self.coeff['a'] = a = bs_gr_coef[0]
        self.coeff['b'] = b = bs_gr_coef[1]
        self.coeff['c'] = c = bs_gr_coef[2]
        
        # simulate cumulative daily blue stain fungal biomass
        # as function of temperature-dependent growth rate
        temp = sf_decline['at_obs']
        sim_bs_bm = np.empty_like(temp)
        for i in range(1, sim_bs_bm.shape[0]):
            sim_bs_bm[i] = sim_bs_bm[i-1] + a*np.exp(-0.5*((temp[i]-b)/c)**2)
        
        # fit model of simulated blue stain fungal growth to percent sapflux decline
        # using a sigmoid function (numerator is set to 1, in order to get 0-100%)
        xs_coef = np.asarray([0.04, 0.0006], dtype='float16')
        xs_coef, xs_covar = curve_fit(self.__sigmoid,
                                      sim_bs_bm,
                                      sf_decline['xs_obs'],
                                      p0=xs_coef)
        self.coeff['a2'] = a2 = xs_coef[0]
        self.coeff['b2'] = b2 = xs_coef[1]
            
        # simulate the decline in sap flux as a function of simulated
        # blue stain fungal biomass
        sim = 1 / (1 + a2 * np.exp(b2 * sim_bs_bm))
        
        return sim

