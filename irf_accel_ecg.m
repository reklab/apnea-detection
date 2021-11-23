
% rough code outline to generate the impulse response
clc
ts = 0.002;
nldat_ACCEL_output = nldat_C3898_ACCEL(:,3);
x = nldat_ACCEL_output.dataSet;
time_seg = 0:ts:length(x)*ts-ts;

nldat_ECG_input = interp1(nldat_C3898_ECG, time_seg, 'linear');
nldat_sys = cat(2,nldat_ECG_input, nldat_ACCEL_output);

I = irf(nldat_sys);

pred = conv(nldat_ECG_input.dataSet,I.dataSet);

%%
time_ypred = 0:ts:length(pred)*ts-ts;
% plot(time_ypred, ypred, 'r')
% hold on
% plot(nldat_ECG_interp)

pred = pred(1:length(time_seg));
clean = nldat_ACCEL_output.dataSet - pred;

nldat_ACCEL_clean = nldat(clean, 'domainIncr', ts, 'domainValues', NaN);
set(nldat_ACCEL_output, 'domainIncr', ts, 'domainValues', NaN);
%%
plot(nldat_ACCEL_clean)
% hold on 
% plot(nldat_ACCEL_output)
% legend(["cleaned", "input"])
% hold off
