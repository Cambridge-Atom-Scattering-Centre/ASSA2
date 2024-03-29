% define your own parameters in the experiments
E0 = 8.05;
FWHM = 0.5;
max_dE = 12;
theta_i = 29.2;
theta_tot = 44.4;

PhononModel(1).BranchName = "elastic";
PhononModel(1).Dispersion = @(x) zeros(size(x));

PhononModel(2).BranchName = 'Cu(111) LR';
PhononModel(2).Dispersion = @(x) 9.5/0.3427*x;

PhononModel(3).BranchName = 'Cu(111) RW';
PhononModel(3).Dispersion = @(x) 5.8/0.494*x;

[lambda_i_Mat, lambda_f_Mat, wavelengthIntMat, tilt] = ...
    PhononExpTools.calcMeasurementsParams(E0, FWHM, max_dE, theta_i, theta_tot, PhononModel);

[lambda_1D, lambda_axis_shifted, wavelengthInt_proj,energy,spectrum_in_energy] = ...
    PhononExpTools.projectByTilt(lambda_i_Mat, lambda_f_Mat, wavelengthIntMat, tilt, E0);