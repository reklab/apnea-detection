
%% function to detrend the data on a 5 second jumping window
% this is called within the data_preprocessing.m function
% detrends the acceleration data using a 3rd order polynomial
% inputs:
%   nldat1 - nldat object to be detrended (acceleration in x,y,z-directions)
%   fs - sampling frequency of the nldat
% outputs:
%   nldat1 - detrended nldat

function [nldat1]=data_detrend(nldat1, fs)

nChans=3;
L=length(nldat1.dataSet);
WindowJump=5*fs;
N=ceil(L/WindowJump);
data=zeros(L,nChans,N);

T1=1;
T2=fs*20;

% go from n=1 to n=N-4 because the window length is 4*WindowJump so data
% beyond N-4 does not exist

for n=1:N-4
    data(T1:T2,:,n)=detrend(nldat1(T1:T2,:),3);
    T1=T1+WindowJump;
    T2=T2+WindowJump;
end
T_stop=T2-WindowJump;

detrended=zeros(L,nChans);
for j=1:nChans
    for i=1:L
        detrended(i,j)=mean(nonzeros(data(i,j,:)));
    end
end

detrended=detrended(1:T_stop,:);

T=nldat1.domainValues;
nldat1.domainValues=T(1:T_stop,1);
nldat1.dataSet=detrended;

end