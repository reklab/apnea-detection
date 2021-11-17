%%
%function [segment_nldat1]= segmentation(pks, locs, nldat_accel1, time)
 function [segment_nldat1]= segmentation(pks, locs, nldat_1)
 
%% Segment data and create nldats

names = get(nldat_1, "chanNames");
data_1 = nldat_1.dataSet;
time = nldat_1.domainValues;


% pks=segm_pks;
% locs=segm_locs;

for i=1:length(pks)+1
     segment=append('seg', num2str(i));
     if i==1
        [~,L2]=min(abs(time - (locs(i)-0.5)));
        segmented_data1.(segment)=data_1(1:L2,:);
        segmented_time1.(segment)=time(1:L2,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;

    elseif i==length(pks)+1
        [~,L1]=min(abs(time - (locs(i-1)+1)));
        segmented_data1.(segment)=data_1((L1):end,:);
        segmented_time1.(segment)=time((L1):end,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;

     else
        [~,L1]=min(abs(time - (locs(i-1)+1)));
        [~,L2]=min(abs(time - (locs(i)-0.5)));
        segmented_data1.(segment)=data_1(L1:L2,:);
        segmented_time1.(segment)=time(L1:L2,1);
        hold_nldat = nldat(segmented_data1.(segment));
        set(hold_nldat, 'domainValues', segmented_time1.(segment),'domainName', "Time (s)", 'chanNames', names, 'comment', ['Tapped Sensor_ACCEL']);
        segment_nldat1.(segment)=hold_nldat;
    end
end

end