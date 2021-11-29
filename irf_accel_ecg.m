
function [ACCEL_output_dec,clean_ACCEL]=irf_accel_ecg(ACCEL_output, ECG_input,ts,ntrial,seg, savepath, save_figs)

%%
% ACCEL_output = hold_accel1_temp
% ECG_input=nldat_ECG
%%
time_seg = 0:ACCEL_output.domainIncr:length(ACCEL_output.dataSet)*ACCEL_output.domainIncr- ACCEL_output.domainIncr;

% time_ECG = 0:ECG_input.domainIncr:length(ECG_input.dataSet)*ECG_input.domainIncr- ECG_input.domainIncr;

% E1=find(time_seg==time_ECG(1));
% E2=find(time_seg==time_ECG(end));
% time_seg=time_seg(E1:E2);
% ACCEL_output=ACCEL_output(E1:E2);
%%

ECG_input = interp1(ECG_input, time_seg, 'linear');
set(ECG_input, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
%%
d=10; ts_dec = d*ts;
ACCEL_output_dec = decimate(ACCEL_output, d);
ECG_input_dec = decimate(ECG_input, d);

nldat_sys_dec = cat(2, ECG_input_dec, ACCEL_output_dec);
nldat_sys = cat(2,ECG_input, ACCEL_output);
set(nldat_sys, 'domainIncr', ts, 'domainValues', NaN, 'domainStart',0)
set(nldat_sys_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0)

%%
IR_length = 0.4;
nLags = IR_length/ts_dec;

I = irf(nldat_sys_dec, 'nLags', nLags);

pred = nlsim(I,ECG_input_dec);

ftsz = 16;
a=figure(1);
clean_ACCEL = nlid_resid(I, nldat_sys_dec);

b=figure(2);
plot(ACCEL_output)
h=line(clean_ACCEL);
h.Color = 'r';
legend(["raw data", "cleaned data"])
title('Acceleration Signal Clean and Raw Data', 'FontSize', ftsz)

c=figure(3);
plot(I)

%% Finalize and Save Plots
set(a, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(b, 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(c, 'Units', 'normalized', 'outerposition', [0 0 1 1])

if save_figs
    savefig(a, [savepath, 'residplot_' ntrial '_' seg])
    savefig(b, [savepath, 'accel_raw_clean_' ntrial '_' seg])
    savefig(c, [savepath, 'IRF_' ntrial '_' seg])
end

end