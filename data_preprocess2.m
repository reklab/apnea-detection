%function [nldat1]=data_preprocess2(nldat1, fs1, fs2, time, saveFigs)
%preprocesses data without the jumping window
%to be used after segmentation
nldat1=nldat_C3892_ACCEL;
saveFigs=1;
%fs2=500;
% nldat1 = interp1(nldat1, time, 'linear');

%%
nChans=3;
L=length(nldat1.dataSet);
for j=1:3
    data(:,j)=detrend(nldat1(:,j),3);
end
nldat1.dataSet=data;

%%
%nldat=nldat(1:T1,:);
data_1= get(nldat1, "dataSet");
time_1= get(nldat1, "domainValues");

if saveFigs
figure()
for j=1:3
    subplot(3,1,j)
    plot(nldat1(:,j));
    ymax=max(ylim);
    ymin=min(ylim);
end
end

%end