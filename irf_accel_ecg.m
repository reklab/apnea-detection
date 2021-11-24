
% rough code outline to generate the impulse response

function irf_accel_ecg(nldat_ACCEL_ouput, nldat_ECG)

ts = 0.002;
% nldat_ACCEL_output = nldat_C3898_ACCEL(:,3);
nldat_ACCEL_output = seg_C3898_ACCEL.seg2(:,3);
set(nldat_ACCEL_output, 'domainIncr', ts, 'domainValues', NaN);

ECG  = seg_ECG_C3898.seg2;
set(ECG, 'domainIncr', ts, 'domainValues', NaN);

x = nldat_ACCEL_output.dataSet;
time_seg = 0:ts:length(x)*ts-ts;

% nldat_ECG_input = interp1(nldat_C3898_ECG, time_seg, 'linear');
nldat_ECG_input = interp1(ECG, time_seg, 'linear');
set(nldat_ECG_input, 'domainIncr', ts, 'domainValues', NaN);

nldat_sys = cat(2,nldat_ECG_input, nldat_ACCEL_output);
plot(nldat_sys)

I = irf(nldat_sys, 'nLags', 60);
figure()
plot(I)

regr = conv(nldat_ECG_input.dataSet,I.dataSet);

%%
time_regr = 0:ts:length(regr)*ts-ts;
% plot(time_ypred, regr, 'r')
% hold on
% plot(nldat_ECG_input)

regr = regr(1:length(time_seg));
clean = nldat_ACCEL_output.dataSet - regr;

nldat_ACCEL_clean = nldat(clean, 'domainIncr', ts, 'domainValues', NaN);

%%
plot(nldat_ACCEL_clean)
hold on
plot(nldat_ACCEL_output)
legend(["cleaned", "input"])
hold off

end