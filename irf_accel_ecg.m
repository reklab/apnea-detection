
function [nldat_ACCEL_output_dec,clean_ACCEL_dec]=irf_accel_ecg(nldat_ACCEL_output, nldat_ECG_input,ts,ntrial,segment, savepath, save_figs)
% rough code outline to generate the impulse response
clc
% ts = 0.002;
%nldat_ACCEL_output = nldat_C3898_ACCEL(:,3);
%nldat_ACCEL_output=seg_C3898_ACCEL.seg3 (:,3);
time_seg=nldat_ACCEL_output.domainValues;
set(nldat_ACCEL_output, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);

% nldat_ECG_input=seg_ECG_C3898.seg3;
time_ECG=nldat_ECG_input.domainValues;

%%
E1=find(time_seg==time_ECG(1));
E2=find(time_seg==time_ECG(end));
time_seg=time_seg(E1:E2);
nldat_ACCEL_output=nldat_ACCEL_output(E1:E2);
%%
nldat_ECG_input = interp1(nldat_ECG_input, time_seg, 'linear');
set(nldat_ECG_input, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);

d= 10; ts_dec = d*ts;
nldat_ACCEL_output_dec = decimate(nldat_ACCEL_output, d);
nldat_ECG_input_dec = decimate(nldat_ECG_input, d);

%%
nldat_sys_dec = cat(2, nldat_ECG_input_dec, nldat_ACCEL_output_dec);
nldat_sys = cat(2,nldat_ECG_input, nldat_ACCEL_output);
set(nldat_sys, 'domainIncr', ts, 'domainValues', NaN, 'domainStart',0)
set(nldat_sys_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0)

% figure()
% plot(nldat_sys)
% figure()
% plot(nldat_sys_dec)
%%
IR_length = 0.4; % ms
nLags = IR_length/ts;
nLags_dec = IR_length/ts_dec;

I = irf(nldat_sys, 'nLags', nLags);
I_dec = irf(nldat_sys_dec, 'nLags', nLags_dec);
% figure()
% plot(I)
% figure()
% plot(I_dec)

%%
pred = nlsim(I,nldat_ECG_input);
pred_dec = nlsim(I_dec,nldat_ECG_input_dec);

a=figure(1)
% clean_ACCEL = nlid_resid(I, nldat_sys);
% figure()
clean_ACCEL_dec = nlid_resid(I_dec, nldat_sys_dec);

%%
% 
% fft_accel_clean_dec = fft(clean_ACCEL_dec);
% L = length(fft_accel_clean_dec.dataSet);
% 
% fft_accel_clean_dec.dataSet = fft_accel_clean_dec.dataSet/L;
% 
% incr = fft_accel_clean_dec.domainIncr;
% 
% fft_mag_dec_clean = abs(fft_accel_clean_dec);
% fft_phase_dec_clean = angle(fft_accel_clean_dec);
% 
% set(fft_mag_dec_clean, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'comment', "magnitude accel data")
% set(fft_phase_dec_clean, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'comment', "magnitude accel data")
% 
% fft_accel_unclean_dec = fft(nldat_ACCEL_output_dec);
% L = length(fft_accel_unclean_dec.dataSet);
% 
% fft_accel_unclean_dec.dataSet = fft_accel_unclean_dec.dataSet/L;
% 
% incr = fft_accel_unclean_dec.domainIncr;
% 
% fft_mag_dec_unclean = abs(fft_accel_unclean_dec);
% fft_phase_dec_unclean = angle(fft_accel_unclean_dec);
% 
% set(fft_mag_dec_unclean, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'comment', "magnitude accel data")
% set(fft_phase_dec_unclean, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'comment', "magnitude accel data")

%%
b=figure(2)
plot(nldat_ACCEL_output_dec)
h=line(clean_ACCEL_dec);
h.Color = 'r';
legend(["raw data", "cleaned data"])
title(['Acceleration'])

%% Finalize and Save Plots
set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])

if save_figs
    savefig(a, [savepath, 'resid_' ntrial '_' seg])
    savefig(b, [savepath, 'accel_raw_clean_' ntrial '_' seg])
end
%%
% S1=spect(clean_ACCEL_dec);
% S2=spect(nldat_ACCEL_output_dec);
% figure()
% plot(S1)
% hold on 
% plot(S2)
%end