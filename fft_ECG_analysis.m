% ECG analysis
function fft_ECG_analysis(nldat_ECG, ntrial, seg, savepath, savefigs)

% nldat_ECG = nldat_C3898_ECG;

% fs = 250;
% d = 5;
% ts2 = 1/(fs/d);
% 
% nldat_ECG_dec = decimate(nldat_ECG,d);
% set(nldat_ECG_dec, 'domainIncr', ts2, 'domainValues', NaN, 'chanNames', "ECG", 'comment', "decimated ECG data")

fft_ECG = fft(nldat_ECG);
L = length(fft_ECG.dataSet);

fft_ECG.dataSet = fft_ECG.dataSet/L;
incr = fft_ECG.domainIncr;

mag_ECG = abs(fft_ECG);

mag_names = {"Amplitude X", "Amplitude Y", "Amplitude Z"};
set(mag_ECG, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', mag_names, 'comment', "magnitude accel data")

phase_ECG = angle(fft_ECG);
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


ax1.FontSize = ftsz;
ax2.FontSize = ftsz;

set(figure(1), 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(3), 'Units', 'normalized', 'outerposition', [0 0 1 1])

if savefigs
    savefig(figure(1), [savepath, 'ECG_fftphase_magn_' ntrial '_' seg])
    savefig(figure(2), [savepath, 'ECG_' ntrial '_' seg])
    close all

end


%%
data = nldat_ECG.dataSet;
incr = nldat_ECG.domainIncr;
time_1 = 0:incr:length(data)*incr-incr;

[pks,locs]=findpeaks(data,time_1);

std_pks=std(pks);
mean_pks=mean(pks);
cut_off=mean_pks+5*std_pks;
locs(pks<cut_off)=[];
pks(pks<cut_off)=[];

% figure()
% hold on
% g=scatter(locs, pks, 'r');
% h=plot(time_1, data_1, 'k');
% xlim([time_1(1000) time_1(2000)])
% hold off

%if tapping is disturbing sensor, HR_diff is unable to detect HR
HR_diff=60./diff(locs);
%
% figure()
% plot(locs(2:end),HR_diff)

L=0;
H=0;
Low_HR=struct([]);
High_HR=struct([]);

%Determines when single heat rate is too high or low
for i=1:length(HR_diff)
    if HR_diff(i)<62
        L=L+1;
        Low_HR(L).HR=HR_diff(i);
        Low_HR(L).time=locs(i+1);
    elseif HR_diff(i)>75
        H=H+1;
        High_HR(H).HR=HR_diff(i);
        High_HR(H).time=locs(i+1);
    end
end

end