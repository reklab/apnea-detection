
% rough code outline to generate the impulse response
clc
ts = 0.002;
% nldat_ACCEL_output = nldat_C3898_ACCEL(:,3);
% nldat_ACCEL_output=seg_nldat_C3898.seg1 (:,3);
nldat_ACCEL_output=seg_C3898_ACCEL.seg2(:,3);
set(nldat_ACCEL_output, 'domainIncr', ts, 'domainName', "Time (s)");
L=length(nldat_ACCEL_output);
x = nldat_ACCEL_output.dataSet;
time=nldat_ACCEL_output.domainValues;

%%
nldat_ECG_input=interp1(nldat_C3898_ECG, time, 'linear');
T1=find(time==D(1));
T2=find(time==D(9141));
nldat_ECG_input=nldat_ECG_input(T1:T2);
set(nldat_ECG_input, 'domainIncr', ts, 'domainName', "Time (s)");
%%
%time_seg = 0:ts:length(x)*ts-ts;
%nldat_ECG_input = interp1(nldat_C3898_ECG, time_seg, 'linear');

nldat_sys = cat(2,nldat_ECG_input, nldat_ACCEL_output);
%set(nldat_ACCEL_output, 'domainIncr', ts, 'domainName', "Time (s)");
I = irf(nldat_sys,'nLags', 200);

%%
nlid_resid(I,nldat_sys);

%%
yp=nlsim(I,nldat_sys(:,1));
figure()
plot(yp)
figure()
nldat_ACCEL_clean=nldat_ACCEL_output-yp;
plot(nldat_ACCEL_clean)
%set(gca,'xlim',[10,20])

%%
figure(2)
hold on 
plot(nldat_ACCEL_clean)
plot(nldat_ACCEL_output)
% plot(pred)
legend(["cleaned", "input"])
%%
S1=spect(nldat_ACCEL_clean);
S2=spect(nldat_ACCEL_output);
figure()
h=line(S2)
h=line(S1);set (h,'Color', 'r')
%%
%everything below in old code
ECG_data=nldat_ECG_input.dataSet;

pred = nlsim(I,nldat_ECG_input);

%%
% cleaning ACCEL signal
pred = pred(1:length(time_seg));
clean = nldat_ACCEL_output.dataSet - pred.dataSet;
nldat_ACCEL_clean = nldat(clean, 'domainIncr', ts, 'domainValues', NaN);
set(nldat_ACCEL_output, 'domainIncr', ts, 'domainValues', NaN);
%%
% plotting results
figure(2)
hold on 
plot(nldat_ACCEL_clean)
plot(nldat_ACCEL_output)
% plot(pred)
legend(["cleaned", "input", "pred"])
hold off

% figure(3)
% plot(nldat_ACCEL_clean)
% 
% figure(4)
% plot(nldat_ACCEL_output(1:7500))
% 
% figure (5)
% plot(pred)
