function [nldat1]=data_preprocess2(nldat1, fs1, fs2, time, saveFigs)
%preprocesses data without the jumping window
%to be used after segmentation
% nldat1=seg_nldat_C3892.seg1;
saveFigs=1;
%fs2=500;
% nldat1 = interp1(nldat1, time, 'linear');

%%
nChans=3;
L=length(nldat1.dataSet);
D=nldat1.dataSet;
T=nldat1.domainValues;
for j=1:3
    data_hold=D(:,j);
    data_hold=detrend(data_hold,3);
    D(:,j)=data_hold;
end
nldat1.dataSet=D;
%%
%nldat=nldat(1:T1,:);
data_1=nldat1.dataSet;
time_1= get(nldat1, "domainValues");

if saveFigs
figure()
for j=1:3
    subplot(3,1,j)
    plot(time_1,data_1(:,j));
    ymax=max(ylim);
   
    ymin=min(ylim);
end
end

end