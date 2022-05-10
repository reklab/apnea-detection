%% fft_analysis
% function called in save_FFTfeatures
% inputs:
%   chest_accel - nldat of the chest acceleration
%   abd_accel - nldat of the abdomen acceleration
%   ntrial - trial number
%   seg - segment number
%   savepath - location to save the results
%   savefigs - 1 to save the generate figrues, 0 to not save
% outputs:
%   freq_chest/abd - peak frequency in the chest/abd spectrum (Hz)
%   phasediff_chest/abd - phase difference between the chest and abdomen at
%       the peak frequency 
%   pk_chest/abd - amplitude of the spectrum at the peak frequency 
%
% function also generates six figures if generate_figs = 1
%   - the spectrum of the chest and abdomen
%   - the phase of the chest and abdomen 
%   - the absolute magnitude of the acceleration of the chest and abdomen 


function [freq_chest, freq_abd, phasediff_chest, phasediff_abd, pk_chest, pk_abd] = fft_analysis(chest_accel, abd_accel, ntrial,seg, savepath, save_figs)


%% generate FT and its magnitude

ts = get(chest_accel, "domainIncr");
names = get(chest_accel, "chanNames");
nChans = length(names);
directions = ["X", "Y", "Z"];

fft_accel_chest = fft(chest_accel);
fft_accel_abd = fft(abd_accel);
L = length(fft_accel_chest.dataSet);

fft_accel_chest.dataSet = fft_accel_chest.dataSet/L;
fft_accel_abd.dataSet = fft_accel_abd.dataSet/L;

incr = fft_accel_chest.domainIncr;

fft_mag_accel_chest = abs(fft_accel_chest);
fft_mag_accel_abd = abs(fft_accel_abd);

mag_names = {"Amplitude X", "Amplitude Y", "Amplitude Z"};
set(fft_mag_accel_chest, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', mag_names, 'comment', "magnitude accel data")
set(fft_mag_accel_abd, 'domainIncr', incr, 'domainName', "Frequency (Hz)",'chanNames', mag_names, 'comment', "magnitude accel data")

%% generate phase difference

phase_diff = zeros(length(fft_accel_chest.dataSet), nChans);
for v = 1:nChans
    phase_accel_chest_temp = angle(fft_accel_chest(:,v));
    phase_accel_abd_temp = angle(fft_accel_abd(:,v));

    phase_diff(:,v) = phase_accel_chest_temp.dataSet{:,v}-phase_accel_abd_temp.dataSet{:,v};
    nldat_temp = nldat(phase_diff(:,v));

    if v > 1
        nldat_phasediff=cat(2, nldat_phasediff, nldat_temp);
        phase_accel_chest = cat(2, phase_accel_chest, phase_accel_chest_temp);
        phase_accel_abd = cat(2, phase_accel_abd, phase_accel_abd_temp);
    else
        nldat_phasediff = nldat_temp;
        phase_accel_chest = phase_accel_chest_temp;
        phase_accel_abd = phase_accel_abd_temp;
    end
end

phase_names = {"Phase X (rad)", "Phase Y (rad)", "Phase Z (rad)"};

set(nldat_phasediff, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase difference")
set(phase_accel_chest, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase accel data")
set(phase_accel_abd, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase accel data")

%% determine phase difference at peak magnitude

hold_data_chest = fft_mag_accel_chest.dataSet;
hold_data_abd = fft_mag_accel_abd.dataSet;
domaint = 0:incr:length(hold_data_chest);
for v = 1:nChans
    dir = directions{v};

    [pk_chest.(dir), index_chest.(dir)] = findpeaks(hold_data_chest(:,v), 'SortStr', 'descend');
    [pk_abd.(dir), index_abd.(dir)] = findpeaks(hold_data_abd(:,v), 'SortStr', 'descend');

    freq_chest(v) = domaint(index_chest.(dir)(1));
    freq_abd(v) = domaint(index_abd.(dir)(1));

    phasediff_chest(v) = phase_diff(index_chest.(dir)(1));
    phasediff_abd(v) = phase_diff(index_abd.(dir)(1));

    pk_chest(v) = pk_chest.(dir)(1);
    pk_abd(v) = pk_abd.(dir)(1);

end
%% generate magnitude of acceleration

k = chest_accel.dataSet{end,1};
j = length(k);
time = 0:ts:j*ts-ts;

magnitude1 = zeros(length(time),1);
magnitude2 = zeros(length(time),1);
data1 = chest_accel.dataSet;
data2 = abd_accel.dataSet;

for i = 1:length(time)
    x1 = data1(i,1);     x2 = data2(i,1);
    y1 = data1(i,2);     y2 = data2(i,2);
    z1 = data1(i,3);     z2 = data2(i,3);

    magnitude1(i) = sqrt(x1.^2+y1.^2+z1.^2);
    magnitude2(i) = sqrt(x2.^2+y2.^2+z2.^2);

end


nldat_mag_chest = nldat(magnitude1);
set(nldat_mag_chest, 'domainValues', NaN, 'domainIncr', ts, 'comment', "Magnitude of chest sensor");

nldat_mag_abd = nldat(magnitude2);
set(nldat_mag_abd, 'domainValues', NaN, 'domainIncr', ts, 'comment', "Magnitude of abdomen sensor");

%% generate plots

generate_figs = 0;

if generate_figs

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

end