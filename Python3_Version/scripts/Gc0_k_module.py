"""
Written by Matt Cook
mattheworion.cook@gmail.com
Created November 8, 2016
"""


def calc_Gc0_k(Gsv0, Gva, L_k):
    """Calculates gc0 for sun leaves"""
    Gc0_k = 1 / (Gsv0 * L_k)
    Gc0_k += 1 / Gva
    Gc0_k = 1 / Gc0_k
    Gc0_k *= 1 / L_k
    Gc0_k *= 1 / 1.6
    return Gc0_k
