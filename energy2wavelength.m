function lambda = energy2wavelength(energy, mass)
% function to convert energy (in meV) to wavelength (in Angstrom)

load_spinecho_parameters;

% if mass is 3 amu i.e. if particle is helium-3
% converts mass to kg
if mass==3
    m = SE_amu * 3.01603;
% if mass is 4 amu i.e. if particle is helium-4
% converts mass to kg
elseif mass==4
    m = SE_amu * 4.00260;
% helium only has two isotopes - anything else is not allowed
else
    disp('Only masses 3 and 4 allowed')
end
% calculate the energy in SI units
% change from eV to SI
E_SI = energy ./ 1000*SE_e;

% calculate wavelength in metres
% multiply by 1e10 to cancel out the angstrom-based input
lambda = SE_h ./ sqrt(2*m*E_SI) * 1e10;
end