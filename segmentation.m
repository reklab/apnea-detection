%%
function [segment_nldat1, segment_nldat2]= segmentation(pks, locs,nldat_accel1, nldat_accel2, time)
    
%% Segment data and create nldats

names = get(nldat_accel1, "chanNames");
data_1 = nldat_accel1.dataSet;
data_2 = nldat_accel2.dataSet;

% pks=segm_pks;
% locs=segm_locs;

for i=1:length(pks)+1
     segment=append('seg', num2str(i));
     if i==1
        %tapped sensor
        [~,L2]=min(abs(time - (locs(i)-0.5)));
        segmented_data1.(segment)=data_1(1:L2,:);
        segmented_time1.(segment)=time(1:L2,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;
        %untapped sensor
        [~,L2]=min(abs(time - (locs(i)-0.5)));
        segmented_data2.(segment)=data_2(1:L2,:);
        segmented_time2.(segment)=time(1:L2,1);
        hold_nldat = nldat(segmented_data2.(segment));
        set(hold_nldat, 'domainValues', segmented_time2.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat2.(segment)=hold_nldat;
    elseif i==length(pks)+1
        %tapped sensor
        [~,L1]=min(abs(time - (locs(i-1)+1)));
        segmented_data1.(segment)=data_1((L1):end,:);
        segmented_time1.(segment)=time((L1):end,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;
        %untapped sensor
        [~,L1]=min(abs(time - (locs(i-1)+1)));
        segmented_data2.(segment)=data_2((L1):end,:);
        segmented_time2.(segment)=time((L1):end,1);
        hold_nldat = nldat(segmented_data2.(segment));
        set(hold_nldat, 'domainValues', segmented_time2.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat2.(segment)=hold_nldat;
     else
        %tapped sensor
        [~,L1]=min(abs(time - (locs(i-1)+0.5)));
        [~,L2]=min(abs(time - (locs(i)-0.5)));
        segmented_data1.(segment)=data_1(L1:L2,:);
        segmented_time1.(segment)=time(L1:L2,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;
        %untapped sensor 
        [~,L1]=min(abs(time - (locs(i-1)+0.5)));
        [~,L2]=min(abs(time - (locs(i)-0.5)));
        segmented_data2.(segment)=data_2(L1:L2,:);
        segmented_time2.(segment)=time(L1:L2,1);
        hold_nldat = nldat(segmented_data2.(segment));
        set(hold_nldat, 'domainValues', segmented_time2.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat2.(segment)=hold_nldat;
    end
end

end