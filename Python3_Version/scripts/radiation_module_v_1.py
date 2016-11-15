"""
Written by Matt Cook
Modified from Dave Millar's R script of same name
Created October 27, 2016
mattheworion.cook@gmail.com
"""

from math import cos, sin, pi, asin, acos
from fixed_params import lati, longi, jday, time


#  ***  In the original TREES C++ code (in util.cpp) this function
#       also takes latitude as an input, but I have not idea why, so
#       it is not included in this version. -DJM 09/28/16 ***

# TODO: Find where to put all of the stuff below here.
def long_corr(longi):
    """Calculates the corrected Longitude"""
    longi = abs(longi)

    # TODO: Ask Dave what kind of rounding is necessary?
    # calculate the central meridian
    cen_meridian = 15 * round((longi + 7.5) / 15)  # (to round off)
    correction = (cen_meridian - longi) / 15.0

    return correction


# function to convert degrees to radians
def deg2rad(deg):
    return (pi * deg / 180.0)


# NOTE: I tested this (calc_zenith_angle) against the unvectorized and it is
#       correct. It is noteworthy to mention that there may be a order of
#       operations error in the original equation. I had to mess with PEMDAS
#       to get the original answer.


def calc_zenith_angle(lati, longi, jday, time):
    """Calculates zenith angle in radians. """

    # longitude correction
    corr = correction_longitude(longi)

    # for calculations of corrections due to eq of time
    temp = deg2rad(279.575 + (0.9856 * jday))

    # calculate equation of time (Campbell and Norman 1998, Eq:11.4)

    corr_tmp = -104.7 * sin(temp)
    corr_tmp = corr_tmp + 596.2 * sin(2 * temp)
    corr_tmp = corr_tmp + 4.3 * sin(3 * temp)
    corr_tmp = corr_tmp - 12.7 * sin(4 * temp)
    corr_tmp = corr_tmp - 429.3 * cos(temp)
    corr_tmp = corr_tmp - 2.0 * cos(2 * temp)
    corr_tmp = corr_tmp + 19.3 * cos(3 * temp)
    corr_tmp = corr_tmp / 3600.0

    corr = corr + corr_tmp

    # calculate solar noon (Campbell and Norman 1998, Eq:11.3)
    solnoon = 12 - corr

    # convert to radian
    lati = deg2rad(lati)

    # calculate solar declination (Campbell and Norman 1998, Eq:11.2)
    temp = 356.6 + 0.9856 * jday
    temp = deg2rad(temp)
    temp = sin(temp)
    temp = 1.9165 * temp
    temp = temp + 0.9856 * jday
    temp = temp + 278.97
    temp = deg2rad(temp)

    declin = asin(0.39785 * sin(temp))

    # calculate zenith angle [in radians] (Campbell and Norman 1998, Eq:11.1)
    rad_conv = deg2rad(15 * time - solnoon)

    z_angle = cos(rad_conv)
    z_angle = z_angle * cos(declin)
    z_angle = z_angle * cos(lati)
    z_angle = z_angle + sin(declin) * sin(lati)

    z_angle = acos(z_angle)

    # return zenith angle in radians
    return(z_angle)


def calc_solar_elevation(z_angle):
    """Calculate solar elevation"""
    Se = 0.5 * pi - z_angle
    return(Se)


def calc_Qe(Se, jday):
    """Calculate extra-terrestrial radiation (Qe)"""

    # Sc = solar constant (W m^-2)
    Sc = 1370

    Qe = cos((360 * jday) / 365)
    Qe = Qe * 0.033
    Qe = 1 + Qe
    Qe = Qe * sin(Se)
    Qe = Qe * Sc
    return(Qe)


def calc_Qo(PAR):
    """
    Convert photosynthetically active radiation (PAR) (umol m^-2 s^-1) from
    input to total incoming above-canopy radiatoin (Qo) (W m^-2)
    """
    # factor used to convert PAR to total incoming solar radiation
    con_fac = 2.12766
    # factor to convert units from umol m^-2 s^-1 to W m^-2
    con_units = 0.235

    return(PAR * con_fac * con_units)


def calc_tau_atm(Qo, Qe):
    """Calculate atmospheric transmissivity"""
    return(Qo / Qe)


# TODO: Figure out what needs to be returned here
def calc_fd(tau_atm, Se):
    """Calculate fraction of total above canopy radiation in diffuse form"""

    R = sin(Se)
    R *= 1.04 * sin(Se)
    R += sin(Se)
    R *= 0.847 - 1.61

    K = (1.47 - R) / 1.66

    f_d = 0

    if (tau_atm <= 0.22):
        f_d = 1

    elif (tau_atm > 0.22 & tau_atm <= 0.35):
        f_d = 1 - 6.4 * (tau_atm - 0.22) ^ 2

    elif (tau_atm > 0.35 & tau_atm <= K):
        f_d = 1.47 - 1.66 * tau_atm

    else tau_atm = R


def calc_Qod(fd, Qo):
    """Calculate total above canopy diffuse radiation (Qod) (W m^-2)"""
    return(fd * Qo)


def calc_Qob(Qod, Qo):
    """Calculate total above canopy beam radiation (Qob) (W m^-2)"""
    return(Qo - Qod)


def calc_Iob(Qob):
    """ Calculate PAR in beam form (Iob) (W m^-2)"""
    # fraction of PAR in beam form
    fPARbeam = 0.5

    return(fPARbeam * Qob)


def calc_Iod(Qod):
    """Calculate PAR in diffuse form (Iod) (W m^-2)"""

    # fraction of PAR in diffuse form
    fPARdiff = 0.5
    return(fPARdiff * Qod)


def calc_QobNIR(Qob, Iob):
    """
    Calculate near infrared radiation (NIR) in beam form (QobNIR) (W m^-2)
    """
    QobNIR = Qob - Iob
    return(QobNIR)


def calc_QodNIR(Qod, Iod):
    """
    Calculate near infrared radiation (NIR) in diffuse form (QodNIR) (W m^-2)
    """
    return (Qod - Iod)
