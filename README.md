# ASSA2
Atom surface scattering analysis scripts version 2, used to analyse the Cambridge helium-3 spin echo data after Feb 2024

In the ASSA2 folder, load the dy file you would like to analyse, which should give you a `meas` variable. Then use the following cammands to view the spectrum:

```matlab
Bl = meas.Bl; Preal = meas.mean.Preal; Pimag = meas.mean.Pimag;
E0 = meas.beam.E0; tilt = meas.tilt;
[energy,corrected_spectrum] = reconstruct_spectra(Bl,Preal,Pimag,E0,tilt);
figure
plot(energy-E0,corrected_spectrum,'-')
xlabel('$\Delta E/\mathrm{meV}$','Interpreter','latex')
ylabel('Intensity/arb. units','Interpreter','latex')
xlim([-5 20])
```

If the data has outliers in it, use the following commands to remove them

```matlab
meas = remove_spikes(meas,1);
```
