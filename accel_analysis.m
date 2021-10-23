% want to plot displacement vs time for chest and abdomen to do direct
% comparison in x,y,z directions
% plot the psd for the acceleration and the displacement signals
% 
% right now nldat1 is the chest sensor and nldat2 is the abdomen sensor 

function accel_analysis(nldat_accel1, nldat_accel2, ntrial,seg, savepath, save_figs)
%%

%nldat_accel1 = segment_nldat1.seg2;
%nldat_accel2 = segment_nldat2.seg2;
time = nldat_accel1.domainValues;
ts=0.0024;
% time2 = nldat_accel2.domainValues;
% ts = time1(2)-time1(1);
% fs = 1/ts;
% sampleLength = time1(end);
% time = time1(1):ts:sampleLength;

figure()
plot(nldat_accel1)
figure()
plot(nldat_accel2)

%%
%nldat_accel1 = interp1(nldat_accel1, time, 'linear');   nldat_accel1 = detrend(nldat_accel1, 'linear');
%nldat_accel1.dataSet = zscore(nldat_accel1.dataSet);
set(nldat_accel1, 'domainValues', NaN, 'domainIncr', ts);
%nldat_accel2 = interp1(nldat_accel2, time, 'linear');   nldat_accel2 = detrend(nldat_accel2, 'linear');
%nldat_accel2.dataSet = zscore(nldat_accel2.dataSet);
set(nldat_accel2, 'domainValues', NaN, 'domainIncr', ts);

names = get(nldat_accel1, "chanNames");
nChans = length(names);

%%
directions = ["X", "Y", "Z"];

nldat_velocity1 = nldat;    nldat_velocity2 = nldat;
nldat_disp1 = nldat;    nldat_disp2 = nldat;

nldat_velocity1.dataSet = cumtrapz(time, nldat_accel1.dataSet);
nldat_velocity1 = detrend(nldat_velocity1, 'linear'); 
%nldat_velocity1.dataSet = zscore(nldat_velocity1.dataSet);

nldat_velocity2.dataSet = cumtrapz(time, nldat_accel2.dataSet);
nldat_velocity2 = detrend(nldat_velocity2, 'linear'); 
%nldat_velocity2.dataSet = zscore(nldat_velocity2.dataSet);

nldat_disp1.dataSet = cumtrapz(time, nldat_velocity1.dataSet);
nldat_disp1 = detrend(nldat_disp1, 'linear'); 
%nldat_disp1.dataSet = zscore(nldat_disp1.dataSet);

nldat_disp2.dataSet = cumtrapz(time, nldat_velocity2.dataSet);
nldat_disp2 = detrend(nldat_disp2, 'linear'); 
%nldat_disp2.dataSet = zscore(nldat_disp2.dataSet);

velocity_names = {"VELOCITY X", "VELCOTIY Y", "VELOCITY Z"};
disp_names = {"DISP X", "DISP Y", "DISP Z"};

set(nldat_velocity1, 'chanNames', velocity_names, 'domainValues', NaN, 'domainIncr', ts, 'comment' ,"Velocity from chest sensor")
set(nldat_velocity2, 'chanNames', velocity_names, 'domainValues', NaN,'domainIncr', ts, 'comment', "Velocity from abdomen sensor")
set(nldat_disp1, 'chanNames', disp_names, 'domainValues', NaN,'domainIncr', ts,'comment' ,"Displacement from chest sensor")
set(nldat_disp2, 'chanNames', disp_names, 'domainValues', NaN,'domainIncr', ts,'comment', "Displacement from abdomen sensor")

%% create nldat that holds x-x/y-y/z-z displacement for each sensor

for v = 1:nChans
    dir = directions{v};
%     
    nldat_temp1 = nldat_disp1(:,v);
    set(nldat_temp1, 'chanNames', "Chest Sensor", 'domainValues', time)
    
    nldat_temp2 = nldat_disp2(:,v);
    set(nldat_temp2, 'chanNames', "Abdomen Sesnsor", 'domainValues', time)
    
    eval(['nldat_disp_' dir '= cat(2, nldat_temp1, nldat_temp2);']);
end

nldat_disp_X.comment = 'displacement from both sensors in the X direction';
nldat_disp_Y.comment = 'displacement from both sensors in the Y direction';
nldat_disp_Z.comment = 'displacement from both sensors in the Z direction';
%%
clc
a=figure(1);
b=figure(2);
c=figure(3);
d=figure(4);
e=figure(5);

for v = 1:nChans
    
    dir = directions{v};
    
    figure(1); 
    subplot(nChans,1,v)
    plot(nldat_disp1(:,v))
    
    line(nldat_disp2(:,v))
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Displacement in the ' dir ' direction for both sensors'])

    
    figure(2);
    subplot(nChans,1,v)
    plot(nldat_accel1(:,v))
    hold on
    plot(nldat_accel2(:,v))
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Acceleration in the ' dir ' direction for both sensors'])
    hold off
    
    figure(3);
    subplot(nChans,1,v)
    eval(['plot(nldat_disp_' dir ', "plotmode", "xy" )'])
    title(['Scatter of displacement of both sensors in ' dir '-' dir ' direction'])
    hold on
    eval(['nldatDouble = nldat_disp_' dir '.dataSet;'])
    start1 = nldatDouble(1,1);  start2 = nldatDouble(1,2);
    end1 = nldatDouble(end,1);  end2 = nldatDouble(end,2);
    k = scatter(start1, start2, 'g', 'filled');
    k.SizeData = 100;

    h  = scatter(end1, end2, 'r', 'filled');
    h.SizeData = 100;

%     eval(['scatter(nldat_disp_' dir '.dataSet{1,1}, nldat_disp_' dir '.dataSet{1,2}, "g")'])
%     eval(['scatter(nldat_disp_' dir '.dataSet{end,1}, nldat_disp_' dir '.dataSet{end,2}, "g")'])
        
    figure(4);
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
%     legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Power spectral density of acceleration in ' dir ' direction for both sensors - using spect objects'])
    hold off
    
    figure(5);
    subplot(nChans,1,v)
    psd1 = spect(nldat_disp1(:,v));
    plot(psd1, 'xmode', 'db');
%     [psd1,f] = pwelch(disp1(:,v), fs);
%     plot(f,pow2db(psd1))
%     xlabel('Frequency (Hz)')
%     ylabel('PSD')
    hold on 
    psd2 = spect(nldat_disp2(:,v));
    plot(psd2, 'xmode', 'db')
%     [psd2,f] = pwelch(disp2(:,v));
%     plot(f,pow2db(psd2))
%     xlabel('Frequency (Hz)')
%     ylabel('PSD')    
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Power spectral density of displacement in ' dir ' direction for both sensors - using spect objects'])
    hold off
    
end
% 
%     set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
%     set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])
%     set(c, 'Units', 'normalized', 'outerposition', [0 0 1 1])
%     set(d, 'Units', 'normalized', 'outerposition', [0 0 1 1])
%     set(e, 'Units', 'normalized', 'outerposition', [0 0 1 1])
    
if save_figs

    savefig(a, [savepath, 'disp_' ntrial '_' seg])
    savefig(b, [savepath, 'accel_' ntrial '_' seg])
    savefig(c, [savepath, 'scatter_' ntrial '_' seg])
    savefig(d, [savepath, 'psd_disp_' ntrial '_' seg '_spect'])
    savefig(e, [savepath, 'psd_accel_' ntrial '_' seg '_spect'])
    
    close all
end


%end