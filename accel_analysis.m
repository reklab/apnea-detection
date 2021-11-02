% want to plot displacement vs time for chest and abdomen to do direct
% comparison in x,y,z directions
% plot the psd for the acceleration and the displacement signals
% 
% right now nldat1 is the chest sensor and nldat2 is the abdomen sensor 

%function accel_analysis(nldat_accel1, nldat_accel2, ntrial,seg, savepath, save_figs)
%%
nldat_accel1 = nldat_C3898_ACCEL;
nldat_accel2 = nldat_C3898_ACCEL;

% time1 = nldat_accel1.domainValues;
% ts = time1(2) - time1(1);
% sampleLength = time1(end);
% 
% time = time1(1):ts:sampleLength;
ts=0.0024;
time = 0:ts:180;
time=time';

%%
%nldat_accel1 = interp1(nldat_accel1, time, 'linear');   nldat_accel1 = detrend(nldat_accel1, 'linear');
set(nldat_accel1, 'domainValues', NaN, 'domainIncr', ts);
%nldat_accel2 = interp1(nldat_accel2, time, 'linear');   nldat_accel2 = detrend(nldat_accel2, 'linear');
set(nldat_accel2, 'domainValues', NaN, 'domainIncr', ts);

names = get(nldat_accel1, "chanNames");
nChans = length(names);

%%
directions = ["X", "Y", "Z"];

nldat_velocity1 = nldat;    nldat_velocity2 = nldat;
nldat_disp1 = nldat;    nldat_disp2 = nldat;

nldat_velocity1.dataSet = cumtrapz(time, nldat_accel1.dataSet);
nldat_velocity1 = detrend(nldat_velocity1, 'linear'); 

nldat_velocity2.dataSet = cumtrapz(time, nldat_accel2.dataSet);
nldat_velocity2 = detrend(nldat_velocity2, 'linear'); 

nldat_disp1.dataSet = cumtrapz(time, nldat_velocity1.dataSet);
nldat_disp1 = detrend(nldat_disp1, 'linear'); 

nldat_disp2.dataSet = cumtrapz(time, nldat_velocity2.dataSet);
nldat_disp2 = detrend(nldat_disp2, 'linear'); 

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
ftsz = 16;

for v = 1:nChans
    
    dir = directions{v};
    
    figure(1); 
    ax1 = subplot(nChans,1,v);
    plot(nldat_disp1(:,v))
    hold on 
    plot(nldat_disp2(:,v));
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Displacement in the ' dir ' direction for both sensors'])

    hold off
    
    figure(2);
    ax2 = subplot(nChans,1,v);
    plot(nldat_accel1(:,v))
    hold on 
    plot(nldat_accel2(:,v));
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Acceleration in the ' dir ' direction for both sensors'])
    hold off
    
    figure(3);
    ax3 = subplot(nChans,1,v);
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
    ax4 = subplot(nChans,1,v);
    psd1 = spect(nldat_accel1(:,v));
    psd1.dataSet = 10*log10(psd1.dataSet);
    psd1.chanNames = "Power (dB)";
    plot(psd1, 'xmode', 'db');
    hold on 
    psd2 = spect(nldat_accel2(:,v));
    psd2.dataSet = 10*log10(psd2.dataSet);
    psd2.chanNames = "Power (dB)";
    plot(psd2, 'xmode', 'db');
    title(['Power spectral density of acceleration in ' dir ' direction for both sensors'])
    hold off
    
    figure(5);
    ax5 = subplot(nChans,1,v);
    psd1 = spect(nldat_disp1(:,v));
    psd1.dataSet = 10*log10(psd1.dataSet);
    psd1.chanNames = "Power (dB)";
    plot(psd1, 'xmode', 'db');
    hold on 
    psd2 = spect(nldat_disp2(:,v));
    psd2.dataSet = 10*log10(psd2.dataSet);
    psd2.chanNames = "Power (dB)";
    plot(psd2, 'xmode', 'db')
    legend(["Chest Sensor", "Abdomen Sensor"])
    title(['Power spectral density of displacement in ' dir ' direction for both sensors'])
    hold off
    
    ax1.FontSize = ftsz;    ax4.FontSize = ftsz;
    ax2.FontSize = ftsz;    ax5.FontSize = ftsz;
    ax3.FontSize = ftsz;

end


%% Trial with nFFT 
    nldat_test1=nldat_accel1;
    nldat_test2=nldat_accel2;
   

for v = 1:3
    figure(4);
    ax4 = subplot(nChans,1,v);
    psd1 = spect(nldat_accel1(:,v));
    psd1.dataSet = 10*log10(psd1.dataSet);
    psd1.chanNames = "Power (dB)";
    plot(psd1, 'xmode', 'db');
    hold on 
    psd2 = spect(nldat_accel2(:,v));
    psd2.dataSet = 10*log10(psd2.dataSet);
    psd2.chanNames = "Power (dB)";
    plot(psd2, 'xmode', 'db');
    %title(['Power spectral density of acceleration in ' dir ' direction for both sensors'])
    xlim ([0 10])
    hold off
    
    figure(5);

    ax5 = subplot(nChans,1,v);

    psd1 = spect(nldat_accel1(:,v), 'nFFT', 4000);
    psd1.dataSet = 10*log10(psd1.dataSet);
    psd1.chanNames = "Power (dB)";
    plot(psd1, 'xmode', 'db');
    hold on 
    psd2 = spect(nldat_accel2(:,v), 'nFFT', 4000);
    psd2.dataSet = 10*log10(psd2.dataSet);
    psd2.chanNames = "Power (dB)";
    plot(psd2, 'xmode', 'db');
    %title(['Power spectral density of acceleration in ' dir ' direction for both sensors'])
    xlim ([0 10])
    hold off
    
    figure(6);
    ax6 = subplot(nChans,1,v);
    psd1 = spect(nldat_accel1(:,v), 'nFFT', 8000);
    psd1.dataSet = 10*log10(psd1.dataSet);
    psd1.chanNames = "Power (dB)";
    plot(psd1, 'xmode', 'db');
    hold on 
    psd2 = spect(nldat_accel2(:,v), 'nFFT', 8000);
    psd2.dataSet = 10*log10(psd2.dataSet);
    psd2.chanNames = "Power (dB)";
    plot(psd2, 'xmode', 'db');
    %title(['Power spectral density of acceleration in ' dir ' direction for both sensors'])
    xlim ([0, 10])
    hold off
end


%% TRIALS with lowpass filter
lowpass(nldat_test1(:,3).dataSet, 10, 1/ts);

%% to add to analysis
% measure magnitude and phase of displacement and plot
% generate 3D plot of displacement 
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
    
% angle between points
cos_angle1 = zeros(length(time)-1, 1);
cos_angle2 = zeros(length(time)-1, 1);

for i = 1:length(time)-1
    
    x1a = data1(i,1);    x1d = data1(i+1,1);    % x2 = data2(i,1);
    y1b = data1(i,2);    y1e = data1(i+1,2);    % y2 = data2(i,2);
    z1c = data1(i,3);    z1f = data1(i+1,3);    % z2 = data2(i,3);
    
    x2a = data2(i,1);    x2d = data2(i+1,1);    % x2 = data2(i,1);
    y2b = data2(i,2);    y2e = data2(i+1,2);    % y2 = data2(i,2);
    z2c = data2(i,3);    z2f = data2(i+1,3);    % z2 = data2(i,3);
    
    cos_angle1(i) = (x1a*x1d + y1b*y1e + z1c*z1f)/(magnitude1(i)*magnitude1(i+1));
    cos_angle2(i) = (x2a*x2d + y2b*y2e + z2c*z2f)/(magnitude2(i)*magnitude2(i+1));

end

cos1 = acos(cos_angle1);
cos2 = acos(cos_angle2);
time_temp = time(1:end-1);

figure(7)
plot(time_temp, cos1)
hold on 
plot(time_temp, cos2)
title('Acceleration: direction change', 'FontSize', ftsz)
legend(["Chest Sensor", "Abdomen Sensor"])
xlabel('Time(s)', 'FontSize', ftsz)
ylabel('Angle (rad)', 'FontSize', ftsz)
%%
set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(c, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(d, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(e, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(6), 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(7), 'Units', 'normalized', 'outerposition', [0 0 1 1])

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