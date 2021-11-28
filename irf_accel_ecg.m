
% rough code outline to generate the impulse response
clc
ts = 0.002;
% nldat_ACCEL_output = nldat_C3898_ACCEL(:,3);
nldat_ACCEL_output=seg_C3898_ACCEL.seg1 (:,3);
L=length(nldat_ACCEL_output);
x = nldat_ACCEL_output.dataSet;
time_seg = 0:ts:length(x)*ts-ts;

nldat_ECG_input=nldat_ECG_C3898.seg1;
nldat_ECG_input.dataSet=-nldat_ECG_input.dataSet;
nldat_ECG_input = interp1(nldat_ECG_input, time_seg, 'linear');

d= 10; ts_dec = d*ts;
nldat_ACCEL_output_dec = decimate(nldat_ACCEL_output, d);
nldat_ECG_input_dec = decimate(nldat_ECG_input, d);

nldat_sys_dec = cat(2, nldat_ECG_input_dec, nldat_ACCEL_output_dec);
nldat_sys = cat(2,nldat_ECG_input, nldat_ACCEL_output);
set(nldat_sys, 'domainIncr', ts, 'domainValues', NaN)
set(nldat_sys_dec, 'domainIncr', ts_dec, 'domainValues', NaN)

figure()
plot(nldat_sys)
figure()
plot(nldat_sys_dec)

IR_length = 0.4; % ms
nLags = IR_length/ts;
nLags_dec = IR_length/ts_dec;

I = irf(nldat_sys, 'nLags', nLags);
I_dec = irf(nldat_sys_dec, 'nLags', nLags_dec);
figure()
plot(I)
figure()
plot(I_dec)

%ECG_data=nldat_ECG_input.dataSet;

pred = nlsim(I,nldat_ECG_input);
pred_dec = nlsim(I_dec,nldat_ECG_input_dec);

residuals = nlid_resid(I, nldat_ECG_input);
residuals_dec = nlid_resid(I_dec, nldat_ECG_input_dec);

%%
% cleaning ACCEL signal

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

