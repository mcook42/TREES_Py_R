# Written by Matt Cook
# Created July 23, 2016
# mattheworion.cook@gmail.com

# Update July 25, 2016
# Refactored to unpack variables here instead of in main.  Also, improved
# documentation.

import sys
import traceback

from numpy import log


class Gsv_0(object):
    """
    Calculate gsv0.

    Stores variables to calculate Gsv_0.  Once all variables have been
    calculated. It will return the vector containing Gsv_0 for each time step.

    Args:
        xs(object):
            An object containing the observed and simulated data for 
            the Xylem Scalar calculations.  Data is stored in numpy arrays.

        ws(object):
            An object containing the observed and simulated data for 
            the Water Stress calculations, as well as the r-squared value
            for the calculations.  Data for the observed and simulated data 
            are stored in numpy arrays and r-squared in a float.

        gs(object):
            An object containing the observed and simulated data for 
            the gsref calculations, as well as the r-squared value
            for the calculations.  Data for the observed and simulated data 
            are stored in numpy arrays and r-squared in a float.

    Attributes:
        xs(dictionary):
            Variable to store information returned from the xylem scalar
            calculation.  Stores observed and simulated data in numpy arrays

        ws(dictionary):
            Variable to store information returned from the water stress
            calculation.  Stores observed and simulated data in numpy arrays.

        gs(dictionary):
            Variable to store information returned from the gs_ref calculation.
            Stores observed and simulated data in numpy arrays.

        d_obs(array):
            Variable to store the observed vapor pressure deficit extracted 
            from the csv file in gs_ref_module.

        r_sqrs(dictionary):
            Variable to store the r-squared values for each calculation (if
            they were calculated).

        gsv_0(array):
            Calculated gsv_0 values for each time step are stored in this
            array.

        Examples:
            To access a certain stored value in a dictionary:
                self.xs['obs']

                or

                self.r_sqrs['ws']

        TO DO:
            Include Xylem Scalar in final calculation.  Sizes do not match, so 
            maybe look into doing the same as other array?

    """

    def __init__(self,
                 xs,
                 ws,
                 gs):

        # initialize variables
        self.xs = {}
        self.ws = {}
        self.gs = {}
        self.r_sqrs = {}

        # unpack and store variables from each calculation's object
        self.xs['obs'] = xs.obs
        self.xs['sim'] = xs.sim
        self.ws['obs'] = ws.obs
        self.ws['sim'] = ws.sim
        self.r_sqrs['ws'] = ws.r_sqr
        self.gs['obs'] = gs.gs_obs
        self.gs['sim'] = gs.gs_sim
        self.gs['ref'] = gs.gs_ref
        self.d_obs = gs.d_obs
        self.r_sqrs['gs'] = gs.r_sqr

    def calculate(self):
        """Calculates gsv0.

        Calculates gsv0 using the formula:
            Gsv0 = ws * Gsref - (m * ln(d_obs)),
            where m = Gsref * 0.6

        It directly modifies the gsv0 attribute of this class.

        """
        try:
            # calculate m scalar
            m = self.gs['ref'] * 0.6

            # initialize local variables
            ws_sim = self.ws['sim']
            d_obs = self.d_obs
            xs_sim = self.xs['sim']
            gs_ref = self.gs['ref']

            # initialize the length variables and calculate time step
            # difference
            ws_sim_len = len(ws_sim)
            d_obs_len = len(d_obs)
            time_steps = int(ws_sim_len / d_obs_len)
            rem = ws_sim_len % d_obs_len
            goal_len = (ws_sim_len - rem)

            # initialize new array for storage of time step adjustment
            d_extend = []
            d_ext_len = len(d_extend)

            # initialize control variable
            i = 0

            # duplicate d_obs readings to match size of gs_ref
            while d_ext_len < goal_len:
                for j in range(time_steps):
                    d_extend.append(d_obs[i])
                i += 1
                d_ext_len = len(d_extend)

            # if the time steps don't divide evenly, tack on values at the
            # end to make it the correct size
            while rem > 0:
                d_extend.append(d_obs[i - 1])
                rem -= 1

            # calculate gsv_0
            self.gsv_0 = ws_sim * gs_ref - (m * log(d_extend))

            # Debug
            # print(self.gsv_0)

        except ValueError as v:
            print("""
                    Check that these following sizes match.  If they don't
                    match, your time steps may be the problem.
                    """)
            print("Xylem Scalar:          ", len(xs_sim))
            print("Water Stress:          ", ws_sim_len)
            print("D observed (extended): ", d_ext_len)
            print(v)

        except Exception as e:
            tb = sys.exc_info()[-1]
            pr_tb = traceback.extract_tb(tb, limit=1)[-1][1]
            print("Something went wrong on line: ", pr_tb, "in gsv0.py")
            print(e)
