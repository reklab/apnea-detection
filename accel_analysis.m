% want to plot displacement vs time for chest and abdomen to do direct
% comparison in x,y,z directions
% plot the psd for the acceleration and the displacement signals

% right now nldat1 is the chest sensor and nldat2 is the abdomen sensor 

function accel_analysis(nldat_accel1, nldat_accel2, ntrial, savepath, save_figs)


time1 = get(nldat_accel1, "domainValues");
a1 = length(find(time1<=150000)); % used to analyze first 160s of normal breathing - take this out once we do the data segmentation 
time1 = time1(1:a1);
time2 = get(nldat_accel2, "domainValues");
a2 = length(find(time2<=150000));
time2 = time2(1:a2);

names = get(nldat_accel1, "chanNames");
nChans = length(names);

accel1 = get(nldat_accel1, "dataSet");
accel1 = accel1(1:a1,:);
accel1 = detrend(accel1, 'linear'); accel1 = zscore(accel1);

accel2 = get(nldat_accel2, "dataSet");
accel2 = accel2(1:a2,:);
accel2 = detrend(accel2, 'linear'); accel2 = zscore(accel2);

directions = ["X", "Y", "Z"];

velocity1 = zeros(length(accel1), nChans);
velocity2 = zeros(length(accel2), nChans);
disp1 = zeros(length(accel1), nChans);
disp2 = zeros(length(accel2), nChans);

for v = 1:nChans
    velocity1(:,v) = cumtrapz(time1, accel1(:,v));
    velocity1(:,v) = detrend(velocity1(:,v), 'linear'); velocity1 = zscore(velocity1);
    
    velocity2(:,v) = cumtrapz(time2 ,accel2(:,v));
    velocity2(:,v) = detrend(velocity2(:,v), 'linear'); velocity2 = zscore(velocity2);
    
    disp1(:,v) = cumtrapz(time1, velocity1(:,v));
    disp1(:,v) = detrend(disp1(:,v), 'linear'); disp1 = zscore(disp1);
    
    disp2(:,v) = cumtrapz(time2, velocity2(:,v));
    disp2(:,v) = detrend(disp2(:,v), 'linear'); disp2 = zscore(disp2);
    
    
    if v == 1
        nldat_velocity1 = nldat(velocity1(:,v));
        nldat_velocity2 = nldat(velocity2(:,v));
        
        nldat_disp1 = nldat(disp1(:,v));
        nldat_disp2 = nldat(disp2(:,v));
    else
        nldat_temp = nldat(velocity1(:,v));
        nldat_velocity1 = cat(2, nldat_velocity1, nldat_temp);
        nldat_temp = nldat(velocity2(:,v));
        nldat_velocity2 = cat(2, nldat_velocity2, nldat_temp);
        nldat_temp = nldat(disp1(:,v));
        nldat_disp1 = cat(2, nldat_disp1, nldat_temp);
        nldat_temp = nldat(disp2(:,v));
        nldat_disp2 = cat(2, nldat_disp2, nldat_temp);
    end
    
end
%
velocity_names = {"VELOCITY X", "VELCOTIY Y", "VELOCITY Z"};
disp_names = {"DISP X", "DISP Y", "DISP Z"};

set(nldat_velocity1, 'chanNames', velocity_names, 'domainValues', time1, 'comment' ,"Velocity from chest sensor")
set(nldat_velocity2, 'chanNames', velocity_names, 'domainValues', time2, 'comment', "Velocity from abdomen sensor")
set(nldat_disp1, 'chanNames', disp_names, 'domainValues', time1,'comment' ,"Displacement from chest sensor")
set(nldat_disp2, 'chanNames', disp_names, 'domainValues', time2,'comment', "Displacement from abdomen sensor")

%%

j=1;
for i = 1:length (time1)
    a = find(time2 == time1(i));
    
    if a ~= 0
        velocity1_keep(j,:) = velocity1(i,:);
        velocity2_keep(j,:) = velocity2(a,:);
        disp1_keep(j,:) = disp1(i,:);
        disp2_keep(j,:) = disp2(a,:);
        time_both (j) = time1(i);
        j = j+1;
    end
end

for v = 1:nChans
    dir = directions{v};
    
    nldat_temp1 = nldat(velocity1_keep(:,v));
    set(nldat_temp1, 'chanNames', "Chest Sesnsor", 'domainValues', time_both)
    
    nldat_temp2 = nldat(velocity2_keep(:,v));
    set(nldat_temp2, 'chanNames', "Abdomen Sesnsor", 'domainValues', time_both)
    
    eval(['nldat_velocity_' dir '= cat(2, nldat_temp1, nldat_temp2);']);
    
    nldat_temp1 = nldat(disp1_keep(:,v));
    set(nldat_temp1, 'chanNames', "Chest Sensor", 'domainValues', time_both)
    
    nldat_temp2 = nldat(disp2_keep(:,v));
    set(nldat_temp2, 'chanNames', "Abdomen Sesnsor", 'domainValues', time_both)
    
    eval(['nldat_disp_' dir '= cat(2, nldat_temp1, nldat_temp2);']);
end
%%
clc
a=figure(1);
b=figure(2);
c=figure(3);
d=figure(4);
e=figure(5);

for v = 1:nChans
    
    dir = directions{v};
    
    figure(1)
    subplot(nChans,1,v)
    plot(nldat_disp1(:,v))
    hold on
    plot(nldat_disp2(:,v))
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Displacement in the ' dir ' direction for both sensors'])
    hold off
    
    figure(2)
    subplot(nChans,1,v)
    plot(nldat_accel1(:,v))
    hold on
    plot(nldat_accel2(:,v))
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Acceleration in the ' dir ' direction for both sensors'])
    hold off
    
    figure(3)
    subplot(nChans,1,v)
    eval(['plot(nldat_disp_' dir ', "plotmode", "xy" )'])
    title(['Scatter of displacement of both sensors in ' dir '-' dir ' direction'])
    
    figure(4)
    subplot(nChans,1,v)
    psd1 = spect(nldat_accel1(:,v));
    plot(psd1);
%     [psd1,f] = pwelch(accel1(:,v));
%     plot(f,pow2db(psd1))
%     xlabel('Frequency (Hz)')
%     ylabel('PSD')    
    hold on
    psd2 = spect(nldat_accel2(:,v));
    plot(psd2)
%     [psd2,f] = pwelch(accel2(:,v));
%     plot(f,pow2db(psd2))
%     xlabel('Frequency (Hz)')
%     ylabel('PSD')    
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Power spectral density of acceleration in ' dir ' direction for both sensors - using spect objects'])
    hold off
    
    figure(5)
    subplot(nChans,1,v)
    psd1 = spect(nldat_disp1(:,v));
    plot(psd1);
%     [psd1,f] = pwelch(disp1(:,v));
%     plot(f,pow2db(psd1))
%     xlabel('Frequency (Hz)')
%     ylabel('PSD')
    hold on 
    psd2 = spect(nldat_disp2(:,v));
    plot(psd2)
%     [psd2,f] = pwelch(disp2(:,v));
%     plot(f,pow2db(psd2))
%     xlabel('Frequency (Hz)')
%     ylabel('PSD')    
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Power spectral density of displacement in ' dir ' direction for both sensors - using spect objects'])
    hold off
    
end

    set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
    set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])
    set(c, 'Units', 'normalized', 'outerposition', [0 0 1 1])
    set(d, 'Units', 'normalized', 'outerposition', [0 0 1 1])
    set(e, 'Units', 'normalized', 'outerposition', [0 0 1 1])
    
if save_figs

    savefig(a, [savepath, 'disp_' ntrial])
    savefig(b, [savepath, 'accel_' ntrial])
    savefig(c, [savepath, 'scatter_' ntrial])
    savefig(d, [savepath, 'psd_disp_' ntrial '_spect'])
    savefig(e, [savepath, 'psd_accel_' ntrial '_spect'])
end


end