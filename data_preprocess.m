function [nldat1]=data_preprocess(nldat1, fs1, fs2, time, saveFigs)

%nldat1=nldat_C3892_ACCEL;
%fs2=500;
nldat1 = interp1(nldat1, time, 'linear');
%%
nChans=3;
L=length(nldat1.dataSet);
WindowJump=5*fs2;
N=ceil(L/WindowJump);
data=zeros(L,nChans,N);

T1=1;
T2=fs2*20;
%%
for n=1:N-4
    data(T1:T2,:,n)=detrend(nldat1(T1:T2,:),3);
    T1=T1+WindowJump;
    T2=T2+WindowJump;
%     if n>30
%     disp(n)
%     disp(T2)
%     end
end
T_stop=T2-WindowJump;
%%
detrended=zeros(L,nChans);
for j=1:nChans
for i=1:L
    detrended(i,j)=mean(nonzeros(data(i,j,:)));
end
end
%%
detrended=detrended(1:T_stop,:);
%%
nldat1.dataSet=detrended;
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