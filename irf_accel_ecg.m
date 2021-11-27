
% rough code outline to generate the impulse response
clc
ts = 0.002;
nldat_ACCEL_output = nldat_C3898_ACCEL(:,3);
% nldat_ACCEL_output=seg_nldat_C3898.seg1 (:,3);
L=length(nldat_ACCEL_output);
x = nldat_ACCEL_output.dataSet;
time_seg = 0:ts:length(x)*ts-ts;

neg_nldat_C3898_ECG=nldat_C3898_ECG;
neg_nldat_C3898_ECG.dataSet=-neg_nldat_C3898_ECG.dataSet;
nldat_ECG_input = interp1(nldat_C3898_ECG, time_seg, 'linear');
nldat_sys = cat(2,nldat_ECG_input, nldat_ACCEL_output);
plot(nldat_sys)

I = irf(nldat_sys, 'nLags', 60);
figure()
plot(I)

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

