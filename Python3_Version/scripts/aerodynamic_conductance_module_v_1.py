# David Millar
# dave.millar@uwyo.edu
# October 19, 2016

# Modified for Python3 by Matt Cook
# mattheworion.cook@gmail.com
# November 1, 2016

from math import log


def calc_Gva(z, h, u_ref, P_ref, T_ref):
    """
    Function for calculating aerdynamic conductance

    Args:
      z: height of instruments on tower (reference height) (m)
      h: canopy height (m)
      u_ref: wind speed @ reference height (m s-1)
      P_ref: atomspheric pressure @ reference height (kPa)
      T_ref: air temperature @ reference height (Celcius)
    Returns:
      The calculated value of Gva
    """

    # TODO(Dave): Double check this equation
    # Calculate the molar density of air
    rho_air = 44.6 * P_ref
    rho_air *= 273.15
    rho_air /= (101.3 * (273.15 + T_ref))

    # Calculate zero-plane displacement for canopy height (Campbell and Norman 1998, Eq:5.2)
    d = 0.65 * h

    # Calculate roughness length (Campbell and Norman 1998, Eq:5.3)
    zm = 0.1 * h

    # Calculate roughness length for heat (Campbell and Norman 1998, Eq:7.19)
    zh = 0.2 * zm

    # -----------#
    # constants #
    # -----------#

    # von Karman's constant
    k = 0.4

    # psi_m (diabatic correction factor for momentum) and
    # psi_h (diabatic correction factor for heat) are set to zero for now,
    # which assumes atmospheric stability.
    psi_m = 0
    psi_h = 0

    # -------------------------#
    # Calculate main equation #
    # -------------------------#
    logzd = log(z - d)  # Recurring calculation in equation below

    Gva = (log / zm) + psi_m
    Gva *= ((logzd / zh) + psi_h)
    Gva = (k ^ 2 * rho_air * u_ref) / Gva

    return Gva