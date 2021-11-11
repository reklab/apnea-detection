function [nldat1]=data_preprocess2(nldat1, fs1, fs2, time, saveFigs)
%preprocesses data without the jumping window
%to be used after segmentation
% nldat1=seg_nldat_C3892.seg1;
saveFigs=1;
%fs2=500;
% nldat1 = interp1(nldat1, time, 'linear');

%%
detrend(nldat1,3);
%%
%nldat=nldat(1:T1,:);
data_1=nldat1.dataSet;
time_1= nldat1.domainValues;

if saveFigs
figure()
for j=1:nChans
    subplot(nChans,1,j)
    plot(time_1,data_1(:,j));
    ymax=max(ylim);
   
    ymin=min(ylim);
end
end

end