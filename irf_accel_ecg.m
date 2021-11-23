
% rough code outline to generate the impulse response
clc
ts = 0.002;
nldat_ACCEL_output = nldat_C3898_ACCEL(:,3);
%nldat_ACCEL_output=seg_nldat_C3898.seg1 (:,3);
x = nldat_ACCEL_output.dataSet;
time_seg = 0:ts:length(x)*ts-ts;

neg_nldat_C3898_ECG=nldat_C3898_ECG;
neg_nldat_C3898_ECG.dataSet=-neg_nldat_C3898_ECG.dataSet;
nldat_ECG_input = interp1(nldat_C3898_ECG, time_seg, 'linear');
nldat_sys = cat(2,nldat_ECG_input, nldat_ACCEL_output);
nldat_sys = cat(2,nldat_ECG_input(1:7500,:), nldat_ACCEL_output(1:7500,:));
% nldat_sys = cat(2,nldat_ACCEL_output, nldat_ECG_input);

I = irf(nldat_sys);

ECG_data=nldat_ECG_input.dataSet;
pred = conv(ECG_data(1:7500),I.dataSet);
%pred = conv(nldat_ECG_input.dataSet,I.dataSet);

%%
% time_ypred = 0:ts:length(pred)*ts-ts;
% plot(time_ypred, ypred, 'r')
% hold on
% plot(nldat_ECG_interp)

%pred = pred(1:length(time_seg));
pred = pred(1:7500);
ACCEL_data=nldat_ACCEL_output(1:7500).dataSet;
%clean = nldat_ACCEL_output.dataSet - pred;
clean=ACCEL_data-pred;

nldat_ACCEL_clean = nldat(clean, 'domainIncr', ts, 'domainValues', NaN);
set(nldat_ACCEL_output, 'domainIncr', ts, 'domainValues', NaN);
%%
figure(2)
hold on 
plot(nldat_ACCEL_output(1:7500))
plot(nldat_ACCEL_clean)
legend(["input", "cleaned"])
hold off

figure(3)
plot(nldat_ACCEL_clean)


figure(4)
plot(nldat_ACCEL_output(1:7500))

figure (5)
plot(pred)

%%
nldat_ACCEL_output=nldat_ACCEL_output(1:7500);
