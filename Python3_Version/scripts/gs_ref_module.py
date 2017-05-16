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


def fit_func(x, ref):
    """Function for curve fit optimization"""
    return ref - (0.6 * ref) * log(x)


def gsRef(work_dir, csv_atm):
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

    # set the current working directory -make sure to change this as needed
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
                                     dtype={'names': ('num',
                                                      'd_obs',
                                                      'gs_obs'),
                                            'formats': ('O',
                                                        'float64',
                                                        'float64')},
                                     unpack=True)

        d_obs = d_obs
        gs_obs = gs_obs

    except Exception as e:
        print("Something went wrong.  Check that " + csv_atm +
              " is in the correct format.")
        print("Here is the actual error: ", e)

    # specify initial guess
    start = [0.1]

    # fit Gs_ref parameter to observed Gs and D data
    gs_paras, gs_covar = curve_fit(fit_func,
                                   d_obs,
                                   gs_obs,
                                   p0=start)

    # extract gs_ref from the list
    gs_ref = gs_paras[0]

    # simulate Gx in the absence of water supply and/or photosynthetic
    # limitation
    gs_sim = fit_func(d_obs, gs_ref)

    # Add column of zeros to simulate y-intercept?
    obs_stacked = column_stack((gs_obs, ones_like(gs_obs)))

    # Calculate R^2
    # summary = OLS(gs_sim, obs_stacked).fit()
    # r_sqr = summary.rsquared

    return gs_ref