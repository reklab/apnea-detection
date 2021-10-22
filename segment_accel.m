%run load_DATA first
%only takes inputs of acceleration data
%nldat_accel1 must be sensor that was tapped
%sensor1 and sensor 2 should be string

function [locs,segment_nldat1 segment_nldat2]=segment_accel(nldat_accel1, nldat_accel2, sensor2, pkg_gap,ntrial, savepath)
% nldat_accel1=nldat_C3898_ACCEL;
% nldat_accel2=nldat_C3892_ACCEL;

datatype= 'ACCEL';
sensor= 'C3898';
sensor2='C3892';

%currently only set up to test for taps on sensor 3898 and only observes
%z_accel data


data_1 = get(nldat_accel1, "dataSet");
time_1 = get(nldat_accel1, "domainValues");

Zdata_1 = data_1(:,3);


%% Identify Peaks using Zdata from Chest sensor (C3898)
[pks,locs]=findpeaks(Zdata_1,time_1);


%%
std_pks=std(pks);
mean_pks=mean(pks);
cut_off=mean_pks+5*std_pks;
locs(pks<cut_off)=[];
pks(pks<cut_off)=[];

figure()
hold on
g=scatter(locs, pks, 'r');
h=plot(time_1, Zdata_1, 'k');
hold off
 %% Select ONLY important peaks       
for i=2:length(pks)
    for j=2:i
    if locs(i)<locs(j-1)+0.5
        locs(i)=0;
    end
    end
end

pks(locs==0)=[];
locs(locs==0)=[];

%UNCOMMENT TO VIZUALIZE STEPS-IF ERRORS OCCUR 
% figure()
% hold on
% g=scatter(locs, pks, 'r');
% h=plot(time_1, Zdata_1, 'k');
% hold off

%% Create patches from taps and plots over signal of z_accel for sensor being tapped
%UNCOMMENT TO VIZUALIZE STEPS-IF ERRORS OCCUR 
% ymax=max(ylim);
% ymin=min(ylim);
% 
% figure()
% hold on
% h=plot(time_1, Zdata_1, 'k');
% 
% for i=1:length(pks)+1
%     C1='c';
%     C2='g';
%     if rem(i,2)==0
%         C=C2;
%     elseif rem(i,2)==1
%         C=C1;
%     end
%     if i==1
%         x_min=-0.01
%         x_max=locs(i)-0.1;
%         patch([x_min x_max x_max x_min], [ymax ymax ymin ymin], C, 'LineStyle', 'none')
%     elseif i==length(pks)+1
%         x_min=locs(i-1)+0.1;
%         x_max=time_1(end)
%         patch([x_min x_max x_max x_min], [ymax ymax ymin ymin], C, 'LineStyle', 'none');
%     else
%         x_min=locs(i-1)+0.1;
%         x_max=locs(i)-0.1;
%         patch([x_min x_max x_max x_min], [ymax ymax ymin ymin], C, 'LineStyle', 'none');
%     end
% end
% 
% uistack(h, 'top')
% xlim([0 time_1(end)])
% ylim([ymin ymax])
% hold off


%% Accounting for Gaps

%%assumes that the first time stamp of all data readings are roughly the
%%same (within 100 ms)

%can change datatype and sensor if desired
sensor2="C3892";
datatype="ACCEL";
data_2= get(nldat_accel2, "dataSet");
time_2= get(nldat_accel2, "domainValues");


%%
figure()
for j=1:3
    subplot(3,1,j)    
    g(j)=plot(time_2,data_2(:,j), 'k');
    ymax=max(ylim);
    ymin=min(ylim);
    if j==1
        D='X';
    elseif j==2
        D='Y';
    else
        D='Z';
    end

for i=1:length(pks)+1
    C1='c';
    C2='g';
    if rem(i,2)==0
        C=C2;
    elseif rem(i,2)==1
        C=C1;
    end
    if i==1
        x_min=-0.01;
        x_max=locs(i)-0.1;
        patch([x_min x_max x_max x_min], [ymax ymax ymin ymin], C, 'LineStyle', 'none')
    elseif i==length(pks)+1
        x_min=locs(i-1)+0.1;
        x_max=time_2(end);
        patch([x_min x_max x_max x_min], [ymax ymax ymin ymin], C, 'LineStyle', 'none');
    else
        x_min=locs(i-1)+0.1;
        x_max=locs(i)-0.1;
        patch([x_min x_max x_max x_min], [ymax ymax ymin ymin], C, 'LineStyle', 'none');
    end
end


for i=1:length(pkg_gap.(sensor2).(datatype))
    x_min=pkg_gap.(sensor2).(datatype)(i).gap_start;
    x_max=pkg_gap.(sensor2).(datatype)(i).gap_end;
    patch([x_min x_max x_max x_min], [ymax ymax ymin ymin], 'm', 'LineStyle', 'none');
end

uistack(g(j), 'top')
xlim([0 time_2(end)])
ylim([ymin ymax])
hold off
end   

savefig([savepath, 'segmented_acceldata'])


%% Segment data and create nldats
chan=get(nldat_accel1, "chanNames");
for i=1:length(pks)+1
     segment=append('seg', num2str(i));
     if i==1
        %tapped sensor
        [~,L2]=min(abs(time_1 - (locs(i)-0.5)));
        segmented_data1.(segment)=data_1(1:L2,:);
        segmented_time1.(segment)=time_1(1:L2,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', chan, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;
        %untapped sensor
        [~,L2]=min(abs(time_2 - (locs(i)-0.5)));
        segmented_data2.(segment)=data_2(1:(L2),:);
        segmented_time2.(segment)=time_2(1:(L2),1);
        hold_nldat = nldat(segmented_data2.(segment));
        set(hold_nldat, 'domainValues', segmented_time2.(segment),'domainName', "Time (s)", 'chanNames', chan, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat2.(segment)=hold_nldat;
    elseif i==length(pks)+1
        %tapped sensor
        [~,L1]=min(abs(time_1 - (locs(i-1)+1)));
        segmented_data1.(segment)=data_1((L1):end,:);
        segmented_time1.(segment)=time_1((L1):end,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', chan, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;
        %untapped sensor
        [~,L1]=min(abs(time_2 - (locs(i-1)+1)));
        segmented_data2.(segment)=data_2((L1):end,:);
        segmented_time2.(segment)=time_2((L1):end,1);
        hold_nldat = nldat(segmented_data2.(segment));
        set(hold_nldat, 'domainValues', segmented_time2.(segment),'domainName', "Time (s)", 'chanNames', chan, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat2.(segment)=hold_nldat;
     else
        %tapped sensor
        [~,L1]=min(abs(time_1 - (locs(i-1)+0.5)));
        [~,L2]=min(abs(time_1 - (locs(i)-0.5)));
        segmented_data1.(segment)=data_1(L1:L2,:);
        segmented_time1.(segment)=time_1(L1:L2,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', chan, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;
        %untapped sensor 
        [~,L1]=min(abs(time_2 - (locs(i-1)+0.5)));
        [~,L2]=min(abs(time_2 - (locs(i)-0.5)));
        segmented_data2.(segment)=data_2(L1:L2,:);
        segmented_time2.(segment)=time_2(L1:L2,1);
        hold_nldat = nldat(segmented_data2.(segment));
        set(hold_nldat, 'domainValues', segmented_time2.(segment),'domainName', "Time (s)", 'chanNames', chan, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat2.(segment)=hold_nldat;
    end
end

%% Current Trouble shooting

%keep in mind: time_1 and time_2 are not equal, especially when gaps occur

%right now, needing to adjust cutoff to get the right segments- should be
%able to have uniform or make loop to see if we are at right # of sections

%% Calling ACCEL_analysis
%option1 make nldat for each time seg? but would never know final number
%option2 make structure with X nldats for each time seg
    %is this do-able
    %would need to change accel_analysis
%option3 passsegmented_data and segmented_time
    %would need to change accel_analysis

% for i=1:length(pks)+1
% %for i=1:1
%     segment=append('seg', num2str(i));
%     hold_nldat1=segment_nldat1.(segment);
%     hold_nldat2=segment_nldat2.(segment);
%     %need to change save path
%     savepath2=[savepath ntrial '/segment_' num2str(i) '/'];
%     if ~exist(savepath2, 'file')
%         mkdir(savepath2)
%     end
%     savefigs=1;
%     accel_analysis(hold_nldat1,hold_nldat2,ntrial,savepath2,savefigs)
% end
end