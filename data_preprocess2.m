function [nldat1]=data_preprocess2(nldat1, fs1, fs2, time, saveFigs)
%preprocesses data without the jumping window
%to be used after segmentation
%nldat1=nldat_C3892_ACCEL;
%fs2=500;
% nldat1 = interp1(nldat1, time, 'linear');

%%
nChans=3;
L=length(nldat1.dataSet);
data=detrend(nldat1(:,3));
nldat1.dataSet=data;

%%
%nldat=nldat(1:T1,:);
data_1= get(nldat1, "dataSet");
time_1= get(nldat1, "domainValues");

if saveFigs
figure()
for j=1:nC
    subplot(3,1,j)
    plot(time_1,data_1(:,j), 'k');
    ymax=max(ylim);
    ymin=min(ylim);
end
end

end