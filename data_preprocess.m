function [nldat]=data_preprocess(nldat, nChans, fs1, fs2, time, saveFigs);

%fs2=500;
nldat = interp1(nldat, time, 'linear');

nChans=3;
L=length(nldat.dataSet);
WindowJump=5*fs2;
N=ceil(L/WindowJump);
data=zeros(L,nChans,N);

T1=1;
T2=fs2*20;

for n=1:N-4
    data(T1:T2,:,n)=detrend(nldat(T1:T2,:),3);
    T1=T1+WindowJump;
    T2=T2+WindowJump;
end

detrended=zeros(L,NumChan);
for j=1:NumChan
for i=1:L
    detrended(i,j)=mean(nonzeros(data(i,j,:)));
end
end

nldat.dataSet=detrended;
%nldat=nldat(1:T1,:);
data_1= get(nldat, "dataSet");
time_1= get(nldat, "domainValues");

if saveFigs
figure()
for j=1:3
    subplot(3,1,j)
    plot(time_1,data_1(:,j), 'k');
    ymax=max(ylim);
    ymin=min(ylim);
end
end

end