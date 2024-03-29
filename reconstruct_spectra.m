function [energy,corrected_spectrum]=reconstruct_spectra(Bl,Preal,Pimag,E0,tilt)
% this function converts the singal from spin echo to an energy spectrum

Bl = Bl*1e-3; % convert from militeslametre to teslametre
load_spinecho_parameters;

Preal = Preal(:)';
Pimag = Pimag(:)';
Bl = Bl(:)';

%% Process Bl domain signal
% assuming that the measurement was taken from Bl = 0 and is evenly spaced in Bl

bs = Preal+1i*Pimag;
Bl = [fliplr(-Bl) Bl(2:end)];
bsm = [fliplr(conj(bs(2:end))) bs];
N = length(bsm);

%% Wavelength domain

bsf = abs(fftshift(fft(bsm)))*(Bl(2)-Bl(1));
wavelength_res = 1/(2*max(Bl)*SE_gamma*SE_3hemass/2/pi/SE_h); % the step in wavelength
lambda_a = linspace(-(N-1)*wavelength_res/2,(N-1)*wavelength_res/2,N);

ki = beamprops('energy',E0,3)*1e10; % wavelength of the incoming beam
lambda_i = 2*pi/ki;
lambda_f_temp = -lambda_i/tand(tilt) + lambda_a/sind(tilt);

lambda_f = lambda_f_temp(lambda_f_temp>0);
spectrum = bsf(lambda_f_temp>0);

%% Energy domain

energy = SE_h^2./(2*SE_3hemass*lambda_f.^2); % in joules
jacobian = SE_3hemass*lambda_f.^3*sind(tilt)/SE_h^2;
corrected_spectrum = spectrum.*jacobian;
energy = 6.2415e21*energy; % convert from joule to meV

end
