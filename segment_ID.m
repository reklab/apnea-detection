%run load_DATA first
%only takes inputs of acceleration data
%nldat_accel1 must be sensor that was tapped
%sensor1 and sensor 2 should be string

function [locs,pks]=segment_ID(nldat_accel1, nldat_accel2, pkg_gap,ntrial, savepath, savefigs)
% nldat_accel1=nldat_C3898_ACCEL;
% nldat_accel2=nldat_C3892_ACCEL;

%currently only set up to test for taps on sensor 3898 and only observes
%z_accel data

data_1 = get(nldat_accel1, "dataSet");
time_1 = get(nldat_accel1, "domainValues");
names = get(nldat_accel1, "chanNames");
nChans = length(names);

sensor2="C3892";
datatype="ACCEL";
data_2= get(nldat_accel2, "dataSet");
time_2= get(nldat_accel2, "domainValues");

Zdata_1 = data_1(:,3);

%% Identify Peaks using Zdata from Chest sensor (C3898)
[pks,locs]=findpeaks(Zdata_1,time_1);

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
    if locs(i)<locs(j-1)+1
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

%%
figure()
for j=1:nChans
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

if savefigs
    savefig(gca, [savepath, 'segmented_acceldata_' ntrial])
end

end