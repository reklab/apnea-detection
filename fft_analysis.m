% want to plot displacement vs time for chest and abdomen to do direct
% comparison in x,y,z directions
% plot the psd for the acceleration and the displacement signals
% 
% right now nldat1 is the chest sensor and nldat2 is the abdomen sensor 

function fft_analysis(nldat_accel1, nldat_accel2, ntrial,seg, savepath, save_figs, fs2)
% nldat_accel1 = nldat_C3898_ACCEL;
% nldat_accel2 = nldat_C3898_ACCEL;

names = get(nldat_accel1, "chanNames");
nChans = length(names);
directions = ["X", "Y", "Z"];
for v = 1:nChans
    hold_data1 = nldat_accel1.dataSet;
    hold_data2 = nldat_accel2.dataSet;

    data_dec1 = decimate(hold_data1, 10);
    data_dec2 = decimate(hold_data2, 10);
    if v >1
        nldat_accel_dec1 = cat(2, nldat_accel_dec1, data_dec1);
        nldat_accel_dec2 = cat(2, nldat_accel_dec2, data_dec2);
    else
        nldat_accel_dec1 = nldat(data_dec1);
        nldat_accel_dec2 = nldat(data_dec2);
    end
end
set(nldat_accel_dec1, 'domainIncr', fs2, 'domainValues', NaN, 'chanNames', names, 'comment', "decimated accel data")

fft_accel1 = fft(nldat_accel1);
fft_accel2 = fft(nldat_accel2);

for v = 1:nChans
    dir = directions{v};
    phase_accel1 = phase(fft_accel1(:,v));  
    phase_accel2 = phase(fft_accel2(:,v));
    mag_accel1 = abs(fft_accel1(:,v));
    mag_accel2 = abs(fft_accel2(:,v));
    phase_incr = phase_accel1.domainIncr;
    
    phase_diff(:,v) = phase_accel1.dataSet{:,v}-phase_accel2.dataSet{:,v};
    nldat_temp = nldat(phase_diff(:,v));

    if v > 1
        nldat_phasediff=cat(2, nldat_phasediff, nldat_temp);
    else
        nldat_phasediff = nldat_temp;
    end
end

phase_names = {" X", " Y", " Z"};

set(nldat_phasediff, 'domainIncr', phase_incr, 'domainValues', NaN, 'chanNames', phase_names, 'comment', "phase difference")

%%
clc
a=figure(1);
b=figure(2);
c=figure(3);
d=figure(4);

ftsz = 16;

for v = 1:nChans
    
    dir = directions{v};

    figure(1, 'Units', 'normalized', 'outerposition', [0 0 1 1]);
    ax1 = subplot(nChans,1,v);
    plot(nldat_accel1(:,v))
    hold on 
    plot(nldat_accel2(:,v));
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Acceleration in the ' dir ' direction for both sensors'])
    hold off
    
    figure(2, 'Units', 'normalized', 'outerposition', [0 0 1 1]);
    ax2 = subplot(nChans,1,v);
    psd1.dataSet = 10*log10(psd1.dataSet);
    psd1.chanNames = "Power (dB)";
    plot(psd1, 'xmode', 'db');
    hold on 
    psd2.dataSet = 10*log10(psd2.dataSet);
    psd2.chanNames = "Power (dB)";
    plot(psd2, 'xmode', 'db');
    title(['Power spectral density of acceleration in ' dir ' direction for both sensors'])
    hold off

    figure(3, 'Units', 'normalized', 'outerposition', [0 0 1 1])
    ax3 = subplot(nChans,1,v);
    plot(phase_accel1)
    hold on 
    plot(phase_accel2)
    title(['Phase for both sensors in the ' dir ' direction'])
    ax3.FontSize = 16;

    ax1.FontSize = ftsz;    ax2.FontSize = ftsz;
    ax3.FontSize = ftsz;    

end

figure(4, 'Units', 'normalized', 'outerposition', [0 0 1 1])
plot(nldat_phasediff)

%% magnitude of acceleration in time domain

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
legend(["Chest Sensor", "Abdomen Sensor"])
    
%%
set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(c, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(d, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(e, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(6), 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(7), 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(1), 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(2), 'Units', 'normalized', 'outerposition', [0 0 1 1])
savefig(figure(1), [savepath, 'phase_' ntrial '_' seg])
savefig(figure(2), [savepath, 'phase_diff' ntrial '_' seg])

if save_figs

        savefig(a, [savepath, 'disp_' ntrial '_' seg])
        savefig(b, [savepath, 'accel_' ntrial '_' seg])
        savefig(c, [savepath, 'scatter_' ntrial '_' seg])
        savefig(d, [savepath, 'psd_accel_' ntrial '_' seg])
        savefig(e, [savepath, 'psd_disp_' ntrial '_' seg])
        savefig(figure(6), [savepath, 'accel_magn_' ntrial '_' seg])
        savefig(figure(7), [savepath, 'accel_angle_' ntrial '_' seg])
    close all

end
%end