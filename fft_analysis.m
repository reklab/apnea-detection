% want to plot displacement vs time for chest and abdomen to do direct
% comparison in x,y,z directions
% plot the psd for the acceleration and the displacement signals
%
% right now nldat1 is the chest sensor and nldat2 is the abdomen sensor

function [freq_a, freq_b, phasediff_a, phasediff_b, pk_a, pk_b] = fft_analysis(nldat_accel1, nldat_accel2, ntrial,seg, savepath, save_figs)

% nldat_accel1 = nldat_C3898_ACCEL_clean.seg1;
% nldat_accel2 = nldat_C3892_ACCEL_clean.seg1;
%% generate FT and its magnitude 

ts = get(nldat_accel1, "domainIncr");
names = get(nldat_accel1, "chanNames");
nChans = length(names);
directions = ["X", "Y", "Z"];

fft_accel1 = fft(nldat_accel1);
fft_accel2 = fft(nldat_accel2);
L = length(fft_accel1.dataSet);

fft_accel1.dataSet = fft_accel1.dataSet/L;
fft_accel2.dataSet = fft_accel2.dataSet/L;

incr = fft_accel1.domainIncr;

fft_mag_accel1 = abs(fft_accel1);
fft_mag_accel2 = abs(fft_accel2);

mag_names = {"Amplitude X", "Amplitude Y", "Amplitude Z"};
set(fft_mag_accel1, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', mag_names, 'comment', "magnitude accel data")
set(fft_mag_accel2, 'domainIncr', incr, 'domainName', "Frequency (Hz)",'chanNames', mag_names, 'comment', "magnitude accel data")

%% generate phase difference 

phase_diff = zeros(length(fft_accel1.dataSet), nChans);
for v = 1:nChans
    phase_accel1_temp = angle(fft_accel1(:,v));
    phase_accel2_temp = angle(fft_accel2(:,v));

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

phase_names = {"Phase X (rad)", "Phase Y (rad)", "Phase Z (rad)"};

set(nldat_phasediff, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase difference")
set(phase_accel1, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase accel data")
set(phase_accel2, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase accel data")

%% determine phase difference at peak magnitude 

hold_data1 = fft_mag_accel1.dataSet;
hold_data2 = fft_mag_accel2.dataSet;
domaint = 0:incr:length(hold_data1);
for v = 1:nChans
    dir = directions{v};

    [pk_1.(dir), index_a.(dir)] = findpeaks(hold_data1(:,v), 'SortStr', 'descend');
    [pk_2.(dir), index_b.(dir)] = findpeaks(hold_data2(:,v), 'SortStr', 'descend');

    freq_a(v) = domaint(index_a.(dir)(1));
    freq_b(v) = domaint(index_b.(dir)(1));

    phasediff_a(v) = phase_diff(index_a.(dir)(1));
    phasediff_b(v) = phase_diff(index_b.(dir)(1));

    pk_a(v) = pk_1.(dir)(1);
    pk_b(v) = pk_2.(dir)(1);

end
%% generate magnitude of acceleration 

k = nldat_accel1.dataSet{end,1};
j = length(k);
time = 0:ts:j*ts-ts;

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

%% generate plots

clc
a=figure(1);
b=figure(2);
c=figure(3);
d=figure(4);
e=figure(5);
ftsz = 20;
cutoff = 5;
linew = 0.8; 

accel1 = fft_mag_accel1.dataSet;
accel2 = fft_mag_accel2.dataSet;

i = nldat_mag1.domainIncr;
x = 0:i:length(accel1)*i-i;

for v = 1:nChans

    dir = directions{v};

    figure(a);
    ax1 = subplot(nChans,1,v);
    plot(nldat_accel1(:,v))
    hold on
    plot(nldat_accel2(:,v));
    set(findall(gca, 'Type', 'Line'),'LineWidth',linew);
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Acceleration in the ' dir ' direction for both sensors'])
    hold off

    figure(b)
    ax3 = subplot(nChans,1,v);
    plot(fft_mag_accel1(:,v))
    hold on
    plot(fft_mag_accel2(:,v))
    scatter(freq_a(v),pk_a(v),  80, 'g', 'filled')
    scatter(freq_b(v),pk_b(v),  80, 'r', 'filled')
    legend(["Chest Sensor", "Abdomen Sensor"])
    set(findall(gca, 'Type', 'Line'),'LineWidth',linew);
    title(['Magnitude of the Fourier Transform in ' dir ' direction for both sensors'])
    xlim([0,cutoff])
    hold off

    log_accel1 = 10*log10(accel1(:,v));
    log_accel2 = 10*log10(accel2(:,v));

    figure(c);
    ax4 = subplot(nChans,1,v);
    plot(x,log_accel1)
    hold on
    plot(x,log_accel2);
    set(findall(gca, 'Type', 'Line'),'LineWidth',linew);
    ylabel(['Log Amplitude ' dir])
    xlabel('Frequency (Hz)')
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Log Magnitude of the Fourier Transform in ' dir ' direction for both sensors'])
    xlim([0 5])

    figure(d)
    ax5 = subplot(nChans,1,v);
    plot(phase_accel1(:,v))
    hold on
    plot(phase_accel2(:,v))
    xlim([0,cutoff])
    set(findall(gca, 'Type', 'Line'),'LineWidth',linew);
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Phase of the Fourier Transform for both sensors in the ' dir ' direction'])


    figure(e)
    ax6 = subplot(nChans,1, v);
    plot(nldat_phasediff(:,v))
    xlim([0, cutoff])
    set(findall(gca, 'Type', 'Line'),'LineWidth',linew);
    title(['Phase Difference between sensors in the ' dir ' direction'])

    ax1.FontSize = ftsz;    ax2.FontSize = ftsz;
    ax3.FontSize = ftsz;    ax4.FontSize = ftsz;
    ax5.FontSize = ftsz;    ax6.FontSize = ftsz;
    
end

figure(6)
plot(nldat_mag1)
hold on
plot(nldat_mag2)
title('Magnitude of acceleration for both sensors', 'FontSize', ftsz)
ylabel('Magnitude', 'FontSize', ftsz)
xlabel('Time (s)', 'FontSize', ftsz)
legend(["Chest Sensor", "Abdomen Sensor"])
set(findall(gca, 'Type', 'Line'),'LineWidth',linew);
set(gca, 'FontSize', ftsz)
hold off

%% finalize and save plots 
set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(c, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(d, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(e, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(6), 'Units', 'normalized', 'outerposition', [0 0 1 1])
%%
if save_figs

    savefig(a, [savepath, 'accel_' ntrial '_' seg])
    savefig(b, [savepath, 'accel_fftmagn_' ntrial '_' seg])
    savefig(c, [savepath, 'accel_logfftmagn_' ntrial '_' seg])
    savefig(d, [savepath, 'accel_fftphase_' ntrial '_' seg])
    savefig(e, [savepath, 'phase_diff' ntrial '_' seg])
    savefig(figure(6), [savepath, 'accel_magn_' ntrial '_' seg])

end

close all
end