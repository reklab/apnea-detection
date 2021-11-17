% ECG analysis
function fft_ECG_analysis(nldat_ECG, savepath, savefigs)

% nldat_ECG = nldat_C3898_ECG;
a = nldat_ECG.domainValues;
sampleLength =a(end);

fs = 250;
ts = 1/fs;
d = 5;
ts2 = 1/(fs/d);
time = 0:ts:sampleLength;

nldat_ECG = interp1(nldat_ECG,  time, 'linear');


set(nldat_ECG, 'domainIncr', ts, 'domainValues', NaN, 'chanNames', "ECG", 'comment', "ECG data")

nldat_ECG_dec = decimate(nldat_ECG,d);
set(nldat_ECG_dec, 'domainIncr', ts2, 'domainValues', NaN, 'chanNames', "ECG", 'comment', "decimated ECG data")

fft_ECG = fft(nldat_ECG_dec);
L = length(fft_ECG.dataSet);

fft_ECG.dataSet = fft_ECG.dataSet/L;
incr = fft_ECG.domainIncr;

mag_ECG = abs(fft_ECG);

mag_names = {"Amplitude X", "Amplitude Y", "Amplitude Z"};
set(mag_ECG, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', mag_names, 'comment', "magnitude accel data")

phase_ECG = phase(fft_ECG);
phase_names = {"Phase X", "Phase Y", "Phase Z"};

set(phase_ECG, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase difference")

cutoff = 5;
ftsz = 20;

figure(1)
ax1 = subplot(211);
plot(mag_ECG)
title(['Magnitude of the Fourier Transform of ECG'])
xlim([0,cutoff])

ax2 = subplot(212);
plot(phase_ECG)
xlim([0,cutoff])
title(['Phase of the Fourier Transform of ECG'])

figure(2);
plot(nldat_ECG)
title(['ECG'])

figure(3);
plot(nldat_ECG_dec(:,v))
title('Decimated ECG data')

ax1.FontSize = ftsz;
ax2.FontSize = ftsz;

end