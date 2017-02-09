# -*- coding: utf-8 -*-
"""
Written by Matt Cook
Created October 11 2016
mattheworion.cook@gmail.com

"""
import TREES
from constants import cp_air, vkk, gr_acc, ti
from math import log, sqrt, log1p, pi, sin, cos
from fixed_params import h_fixed_para, longi

#TODO:TEMPORARY SOLUTION TO NEEDING GSV0
gsv_0 = TREES.main()

# Temps in K to be calculated below, this makes the variables global (?)
trK = None
tcK = None

def long_corr(longi):
    longi = abs(longi)

    #Calculate central meridian
    cen_meridian = int((longi + 7.5)/15)
    cen_meridian = cen_meridian * 15    
    correction = (cen_meridian - longi) / 15.0

    return correction
       

def deg2rad(deg):
    """Converts degrees into radians."""
    return (pi * (deg / 180))


def zenith_angle(lati, longi, jday, thyme):
    #Longitude correction
    corr = long_corr(longi)
    
    #For calculations of corrections due to eq of time
    temp = 279.575 + (0.9856 * jday)
    temp = deg2rad(temp)
    
    #Add the equator in hours - eq. 11.4 in C&N
    tmp_corr = -104.7 * sin(temp)
    tmp_corr += 596.2 * sin(2 * temp) 
    tmp_corr += 4.3 * sin(3 * temp)
    tmp_corr += -12.7 * sin(4 * temp)
    tmp_corr += -429.3 * cos(temp)
    tmp_corr += -2.0 * cos(2 * temp)
    tmp_corr += 19.3 * cos(3 * temp)
    corr += tmp_corr / 3600.0
    

#TODO: Move to utils script
#Convert degrees Celsius to Kelvin
def C2K(deg_C):
	return deg_C + 273.15

 
#molar density of air @ pressure pressure (kPa), temp tcelsius (C)
def calc_mol_den(pressure, tcelsius):
    temp_conv = C2K(tcelsius)
    return 44.6 * pressure * 273.15 / (101.3 * temp_conv)


# calculating psi_h and psi_m at a known zeta (stability)
# eq. 7.26 & 7.27 -  Campbell & Norman
def calc_psim(zeta):
    """zeta (double): stability coefficient"""
    if (zeta < 0):
        psi_m =  -1.2*log((1.0 + sqrt(1.0 - 16.0*zeta))/2.0)
    else:
        #psi_m = 6.0*log(1 + zeta); This is slower, I presume
        psi_m = 6.0*log1p(zeta)
    return psi_m;
 
 
def calc_psih(zeta):
    """zeta (double): stability coefficient"""
    if (zeta < 0):
        return (calc_psim(zeta))/0.6
    else:
        return calc_psim(zeta)


#TODO: Refactor this to work with Python. Copied from Simulator.cpp
#trying to find by successive subst
#refer 7.21, 7.24, 7.26 & 7.27, C&N
def stability_sucs(tr,      #temp @ ref ht, C
                   tc,      #temp in canopy, C
                   z_ref,   #ref ht, m
                   #parameters
                   zm_factor,
                   zh_factor,
                   d_factor,
                   #observations
                   ur,       #wind speed @ ref ht, ms-1
                   h_canopy, #canopy ht, m
                   pressure): #atmospheric pressure, kPa

    #true constants used are vkk and cp_air & gr_acc
    #the fixed terms
    dee = d_factor*h_canopy
    zee_m = zm_factor*h_canopy
    zee_h = zh_factor*zee_m
    rho = calc_mol_den(pressure, tr) #molm-3
    lnm = log((z_ref - dee)/zee_m)
    lnh = log((z_ref - dee)/zee_h)
    trK = C2K(tr)
    tcK = C2K(tc)
 
    #the vars (initialized to None type as a placeholder and clarity)
    #TODO: Initialize to appropriate variables
    u_star, h_flux, zeta, psi_m, psi_h, delta = None
    u_star_last, u_star_diff = None        #u* is what we need, so check this

    #********** check effects F *************
    u_star_accuracy = 0.001 #accuracy of ur is <= 0.01 m/s 042004 - a change @ 4th pl dec
    i, sign_chk = None
    n_times = 50  #give up after this
    min_n = 10 #do at least 10 iterations 042004 - a change @ 4th pl dec
 
    #estimates using naive values
    #TODO: Figure out h_flux
    zeta = psi_m = psi_h = 0.0
    u_star = u_star_last = ur*vkk/(lnm + psi_m)
    h_flux = (tcK - trK)*vkk*rho*cp_air*u_star/(lnh + psi_h) #left as is 042004 mistake before?
    
    # For debugging
    # print( "stability : ", zeta, "psi : ", psi_m, " ", psi_h,
    #         " U*: ", u_star," H: ", h_flux)
    
    # iterate
    u_star_diff = 1 # force loop
    i = 0
    while((u_star_diff > u_star_accuracy or i <= min_n) and i < n_times):
        zeta = -(vkk) * gr_acc * z_ref * h_flux 
        zeta /= (rho * cp_air * trK * u_star * u_star * u_star) #7.21 
        #left as is 042004 mistake before?

        #obtains same values
        psi_m = calc_psim(zeta) #7.26 or 7.27
        psi_h = calc_psih(zeta) #7.26 or 7.27
        u_star = ur*vkk/(lnm + psi_m) #7.24
        h_flux = (tcK - trK)* vkk *rho*cp_air*u_star/(lnh + psi_h) #unnumbered in C&N
        #left as is 042004 mistake before?

        u_star_diff = u_star_last - u_star
        u_star_diff = abs(u_star_diff)
        u_star_last = u_star
        
        #check
        """
        FOR DEBUGGING
        print(" ", i, "\nstability : ", zeta, "psi : ", psi_m, " ", psi_h,
                  " U*: ", u_star, " H: ", h_flux)
        """
        i += 1
        #end for
    """
    FOR DEBUGGING
    if(i >= n_times):
        print("WARNING! ", n_times, " iterations exceeded.\n")
    """
    return zeta
    
#calculating gHa to get gHr = gHa + gr
def calc_gHa(uz,      #wind speed @ ref height, m/s (input varying by each timestep)
             z,     #ref height, m (fixed)
             canopy_ht,       #height of canopy, m (fixed)
             #the followings are parameters
             d_factor,        #d = d_factor*canopy_ht (fixed)
             zm_factor,       #zm = zm_factor*canopy_ht (fixed)
             zh_factor,       #zh = zh_factor*zm (fixed)
             #the followings are calculated values
             molar_dens,      #molar density of air, molm-3 
             psi_m,           #diabatic correction factors assume fixed (0) FOR NOW
             psi_h):          #assume fixed (0) FOR NOW

    lnz_d = log(z - d_factor * canopy_ht)
    gHa = (lnz_d - log(zh_factor * zm_factor * canopy_ht) + psi_h)
    gHa *= (lnz_d - log(zm_factor * canopy_ht) + psi_m)
    gHa = (vkk * vkk * molar_dens * uz) / gHa
    
    #enable for debugging
    """
    print(vkk, '\t', molar_dens, '\t', uz, '\t',
            (lnz_d - log(zm_factor*canopy_ht) + psi_m), '\t', 
            (lnz_d - log(zh_factor*zm_factor*canopy_ht) + psi_h), '\t', 
            (vkk*vkk*molar_dens*uz), '\t', gHa, '\t' 
            (log((z - d_factor*canopy_ht)/(zm_factor*canopy_ht))+psi_m), '\t', 
            (log((z - d_factor*canopy_ht)
                /(zh_factor*zm_factor*canopy_ht))+psi_h))
    """
    return g_ha


# Leaf specific conductances to CO2 for sunlit and canopy elements
def calcgc0(gsv_0, L, g_va):
    """Calculates leaf specific conductances to C02"""
    denom = gsv_0 * L
    denom = 1 / denom
    denom = denom + (1 / g_va)
    gc0 = 1 / denom
    gc0 = gc0 * (1 / L)
    gc0 = gc0 * (1 / 1.6)
    return gc0

############ Appendix C ############


#TODO: Read in the p_air
# Molar density of air (mol m^-3)
p_air = None
rho_mol = calc_mol_den(p_air, t_ref)
zenith_angle = zenith(ti, lat, longi)

# Wind speed (m s^1) at reference height
u_z = None

# Zero-plane displacement for canopy of height (m)
d = 0.65 * h_fixed_para

# Roughnss length (m)
z_m = 0.1 * h_fixed_para

# Roughness length for heat (m)
z_h = 0.2 * z_m

#Vapor and heat boundary layer conductances, respectively (mol m^-2 s^-1)
g_va = g_ha = calc_gHa()#TODO: Fill in these arguments)


# Calculate gc0 sunlit element
gc0_sun = calcgc0(gsv_0, L_sun, g_va)

# Calculate gc0 shaded element
gc0_shd = calcgc0(gsv_0, L_shade, g_va)