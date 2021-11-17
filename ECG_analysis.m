%nldat_ECG=nldat_C3898_ECG;
nldat_ECG=seg_ECG_C3898.seg9
data_1 = get(nldat_ECG, "dataSet");
time_1 = get(nldat_ECG, "domainValues");

[pks,locs]=findpeaks(data_1,time_1);

std_pks=std(pks);
mean_pks=mean(pks);
cut_off=mean_pks+5*std_pks;
locs(pks<cut_off)=[];
pks(pks<cut_off)=[];

% figure()
% hold on
% g=scatter(locs, pks, 'r');
% h=plot(time_1, data_1, 'k');
% xlim([time_1(1000) time_1(2000)])
% hold off

%if tapping is disturbing sensor, HR_diff is unable to detect HR
HR_diff=60./diff(locs);

figure()
plot(locs(2:end),HR_diff)

L=0;
H=0;
Low_HR=struct([]);
High_HR=struct([]);
%Determines when single heat rate is too high or low
for i=1:length(HR_diff)
    if HR_diff(i)<62
        L=L+1;
        Low_HR(L).HR=HR_diff(i);
        Low_HR(L).time=locs(i+1);
    elseif HR_diff(i)>75
        H=H+1;
        High_HR(H).HR=HR_diff(i);
        High_HR(H).time=locs(i+1);
    end
end

%do we need code for irregular heart beat that fall within the normal range

