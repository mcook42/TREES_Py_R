# -*- coding: utf-8 -*-
"""
Written by Matt Cook
Created July 5, 2016
mattheworion.cook@gmail.com
"""

# Update July 25, 2016
# Improved documentation.

# Module to simulate percent decline in stomatal conductance (water stress)
# due to declining soil water potential.

from os import chdir

from numpy import loadtxt, asarray, exp, column_stack, ones_like
from scipy.optimize import curve_fit
from statsmodels.api import OLS
import matplotlib.pyplot as plt


def sigmoid(x, a, b):
    """
    Sigmoid function used in water stress curve fitting. 'x' is the vector,
    'a' and 'b' are the coefficient guesses for the model.
    """
    return 100 / (1 + a * exp(b * x))


def water_stress_module( work_dir, csv_ws):
    """
    Takes observed water potential and percent loss conductance (PLC) data
    from laboratory xylem analysis (Heather Speckman) and returns the simulated
    water stress model.  Uses the sigmoid function for curve fitting.

    Args:
        work_dir(string):
            Path of directory in which to look for/store files

        csv_ws(string):
            Filename of .csv file with observed water potential (MPa) (psi)
            and observed percent loss conductance within the plant
            xylem (%) (plc)

            Data should be stored as:
                column 1: observed water potential (MPa)
                column 2: observed percent loss conductance within
                          the plant

    NOTE:
        When reading from csv, the script skips the first line (headers)
        so if you do not have headers and do not wish to lose the first row
        of data points, add an extra row at the top of your CSV file.
    """

    # Change the directory to your working directory
    chdir(work_dir)

    try:
        # read in the water potential and percent loss conductance (PLC) data from
        # laboratory xylem analysis (Heather Speckman)
        # psi = water potential (MPa)
        # plc = percent loss conductance within the plant xylem (%)
        psi_obs, plc_obs = loadtxt(csv_ws,
                                   delimiter=",",
                                   skiprows=1,
                                   dtype={'names': ('psi_obs', 'plc_obs'),
                                          'formats': ('float64', 'float64')},
                                   unpack=True)
    except Exception as e:
        print("Something went wrong.  Check that " + csv_ws +
              " is in the correct format.")
        print("Here is the actual error: ", e)

    # fit water stress model paras to 'plc_data' data using a sigmoid
    # function (numerator is set to 1, in order to get 0-100%).
    plc_paras = asarray([11, -1], dtype='float64')
    plc_paras, plc_covar = curve_fit(sigmoid,
                                     psi_obs,
                                     plc_obs,
                                     p0=plc_paras)

    coeff['a'] = a = plc_paras[0]
    coeff['b'] = b = plc_paras[1]

    # simulate the percent decline in sap flux as a function of decreasing
    # soil water potential
    sim = 1 - ((100 / (1 + a * exp(b * psi_obs))) / 100)
    obs = obs = 1 - (plc_obs / 100)
    # Add column of zeros to simulate y-intercept?
    obs_stacked = column_stack((obs, ones_like(obs)))

    # calculate R^2
    # summary = OLS(sim, obs_stacked).fit()
    # r_sqr = summary.rsquared

    return a, b

