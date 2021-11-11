% want to plot displacement vs time for chest and abdomen to do direct
% comparison in x,y,z directions
% plot the psd for the acceleration and the displacement signals
%
% right now nldat1 is the chest sensor and nldat2 is the abdomen sensor

function fft_analysis(nldat_accel1, nldat_accel2, ntrial,seg, savepath, save_figs, fs2)
% nldat_accel1 = seg_nldat_C3898.seg2;
% nldat_accel2 = seg_nldat_C3892.seg2;


d = 10; fs = fs2/d; ts = 1/fs;
names = get(nldat_accel1, "chanNames");
nChans = length(names);
directions = ["X", "Y", "Z"];

nldat_accel1_dec = decimate(nldat_accel1,d);
nldat_accel2_dec = decimate(nldat_accel2,d);
set(nldat_accel1_dec, 'domainIncr', ts, 'domainValues', NaN, 'chanNames', names, 'comment', "decimated accel data")
set(nldat_accel2_dec, 'domainIncr', ts, 'domainValues', NaN, 'chanNames', names, 'comment', "decimated accel data")
%%
fft_accel1 = fft(nldat_accel1_dec);
fft_accel2 = fft(nldat_accel2_dec);
L = length(fft_accel1.dataSet);

fft_accel1.dataSet = fft_accel1.dataSet/L;
fft_accel2.dataSet = fft_accel2.dataSet/L;

h = fft_accel1.dataSet;
h = h(1:(L-1)/2+1,:);
fft_accel1_1S = nldat(h);

h = fft_accel2.dataSet;
h = h(1:(L-1)/2+1,:);
fft_accel2_1S = nldat(h);

incr = fft_accel1.domainIncr;

mag_accel1 = abs(fft_accel1_1S);
mag_accel2 = abs(fft_accel2_1S);

set(fft_accel1_1S, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', names, 'comment', "one sided fft of accel 1")
set(fft_accel2_1S, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', names, 'comment', "one sided fft of accel 2")
set(mag_accel1, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', names, 'comment', "magnitude accel data")
set(mag_accel2, 'domainIncr', incr, 'domainName', "Frequency (Hz)",'chanNames', names, 'comment', "magnitude accel data")

%%
phase_diff = zeros(length(fft_accel1_1S.dataSet), nChans);
for v = 1:nChans
    phase_accel1_temp = phase(fft_accel1_1S(:,v));
    phase_accel2_temp = phase(fft_accel2_1S(:,v));

    phase_diff(:,v) = phase_accel1_temp.dataSet{:,v}-phase_accel2_temp.dataSet{:,v};
    nldat_temp = nldat(phase_diff(:,v));

    if v > 1
        nldat_phasediff=cat(2, nldat_phasediff, nldat_temp);
        phase_accel1 = cat(2, phase_accel1, phase_accel1_temp);
        phase_accel2 = cat(2, phase_accel2, phase_accel2_temp);
    else
        nldat_phasediff = nldat_temp;
        phase_accel1 = phase_accel1_temp;
        phase_accel2 = phase_accel2_temp;
    end
end

phase_names = {" X", " Y", " Z"};

set(nldat_phasediff,  'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase difference")
set(phase_accel1, 'domainName', "Frequency (Hz)", 'chanNames', names, 'comment', "phase accel data")
set(phase_accel2, 'domainName', "Frequency (Hz)", 'chanNames', names, 'comment', "phase accel data")

%%
clc
a=figure(1);
b=figure(2);
c=figure(3);
d=figure(4);
e=figure(5);
ftsz = 16;

for v = 1:nChans

    dir = directions{v};

    figure(a);
    ax1 = subplot(nChans,1,v);
    plot(nldat_accel1(:,v))
    hold on
    plot(nldat_accel2(:,v));
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Acceleration in the ' dir ' direction for both sensors'])
    hold off

    figure(b);
    ax2 = subplot(nChans,1,v);
    plot(nldat_accel1_dec(:,v))
    hold on
    plot(nldat_accel2_dec(:,v));
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Decimated Acceleration in the ' dir ' direction for both sensors'])
    hold off

    figure(c)
    ax3 = subplot(nChans,1,v);
    plot(mag_accel1(:,v))
    hold on
    plot(mag_accel2(:,v))
    title(['Power spectral density of acceleration in ' dir ' direction for both sensors'])
    hold off

    figure(d)
    ax4 = subplot(nChans,1,v);
    plot(phase_accel1(:,v))
    hold on
    plot(phase_accel2(:,v))
    title(['Phase for both sensors in the ' dir ' direction'])
    ax1.FontSize = ftsz;    ax2.FontSize = ftsz;
    ax3.FontSize = ftsz;    ax4.FontSize = ftsz;

end

figure(e)
plot(nldat_phasediff);
title('Phase Difference between sensors', 'FontSize', ftsz)

%% magnitude of acceleration in time domain
k = nldat_accel1_dec.dataSet{end,1};
j = length(k);
time = 0:ts:j*ts;

magnitude1 = zeros(length(time),1);
magnitude2 = zeros(length(time),1);
data1 = nldat_accel1.dataSet;
data2 = nldat_accel2.dataSet;

for i = 1:length(time)
    x1 = data1(i,1);     x2 = data2(i,1);
    y1 = data1(i,2);     y2 = data2(i,2);
    z1 = data1(i,3);     z2 = data2(i,3);

    magnitude1(i) = sqrt(x1.^2+y1.^2+z1.^2);
    magnitude2(i) = sqrt(x2.^2+y2.^2+z2.^2);

end

nldat_mag1 = nldat(magnitude1);
set(nldat_mag1, 'domainValues', NaN, 'domainIncr', ts, 'comment', "Magnitude of chest sensor");

nldat_mag2 = nldat(magnitude2);
set(nldat_mag2, 'domainValues', NaN, 'domainIncr', ts, 'comment', "Magnitude of abdomen sensor");

figure(6)
plot(nldat_mag1)
hold on
plot(nldat_mag2)
title('Magnitude of acceleration for both sensors', 'FontSize', ftsz)
ylabel('Magnitude')
legend(["Chest Sensor", "Abdomen Sensor"])
hold off
%%
set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(c, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(d, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(e, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(6), 'Units', 'normalized', 'outerposition', [0 0 1 1])

if save_figs

    savefig(a, [savepath, 'accel_' ntrial '_' seg])
    savefig(b, [savepath, 'accel_dec_' ntrial '_' seg])
    savefig(c, [savepath, 'accel_fftmagn_' ntrial '_' seg])
    savefig(d, [savepath, 'accel_fftphase_' ntrial '_' seg])
    savefig(e, [savepath, 'phase_diff' ntrial '_' seg])
    savefig(figure(6), [savepath, 'accel_magn_' ntrial '_' seg])
    close all

end
% end