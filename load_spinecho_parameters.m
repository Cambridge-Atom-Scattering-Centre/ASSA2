% This file contains a list of parameters describing the Cambridge HeSE apparatus
%
% Note: the parameters are all prefixed SE, to avoid mixing with any other variables
%
% Updated on 25 March 2024

% General parameters (SI)
SE_h = 6.62608e-34;
SE_hbar = 1.05457e-34;
SE_e = 1.60218e-19;
SE_kB = 1.380658e-23;
SE_amu = 1.66054e-27;
SE_3hemass = SE_amu * 3.01603;  % mass of 3He
SE_gamma = 2.037895e8;          % gyromagnetic ratio for 3He
SE_mu0 = 1.25663706212e-6;      % vacuum magnetic permeability in N*A^−2

% the number of turns in each winding of each solenoid
N_inner = 481+457+432;          % double layers 1, 2, and 3
N_middle = 408+381;             % double layers 4 and 5
N_outer = 356+332+307;          % double layers 6, 7, and 8

% number of turns in the phase coil
N_phase = 100;