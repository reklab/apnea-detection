
%% ================== 
% function that 1. removes outliers from ACCEL data to account for the tapping
% 2. decimates ECG and ACCEL data to 50Hz 
% 3. uses IRF to remove HR effects in ACCEL data

% function [ACCEL_output_dec,clean_ACCEL]=IRF_HR(ACCEL_output, ECG_input,ts)
ACCEL_output = nldat_chest_ACCEL;
ECG_input = nldat_chest_ECG;
ts = 0.002;

time_ACCEL = 0:ts:ts*length(ACCEL_output.dataSet)-ts;

ECG_input = interp1(ECG_input, time_ACCEL, 'linear');
set(ECG_input, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
set(ACCEL_output, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);

% temp = ACCEL_output.dataSet;
% [accel_data, ind] = rmoutliers(temp);
% set(ACCEL_output, 'dataSet', accel_data, 'domainValues', NaN, 'domainIncr', ts)
% 
% ECG_data = ECG_input.dataSet;
% ECG_data(ind, :) = [];
% set(ECG_input, 'dataSet', ECG_data, 'domainValues', NaN, 'domainIncr', ts)
% 

d=10; ts_dec = d*ts;
ACCEL_output_dec = decimate(ACCEL_output, d);
ECG_input_dec = decimate(ECG_input, d);
set(ECG_input_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);
set(ACCEL_output_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

nldat_sys_dec = cat(2, ECG_input_dec, ACCEL_output_dec);
nldat_sys = cat(2,ECG_input, ACCEL_output);
set(nldat_sys, 'domainIncr', ts, 'domainValues', NaN, 'domainStart',0);
set(nldat_sys_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

%%
IR_length = 0.4;
nLags = IR_length/ts_dec;
% T1=1;
% T2=20/ts_dec;

% L=length(nldat_sys_dec.dataSet);
% WindowJump=20/ts_dec;
% N=ceil(L/WindowJump);

% for n=1:N
% 
%     if T2 > L
%         T2 = L;
%     end
    I = irf(nldat_sys_dec, 'nLags', nLags, 'nSides', 2);
    figure()
%     plot(I)
    I_smooth = I;
%     hold on 
    I_smooth.dataSet = smooth(I_smooth.dataSet);
    plot(I_smooth)

    

    figure()
%     nldat_temp = nlid_resid(I, nldat_sys_dec);
    figure()
    nldat_temp_smooth = nlid_resid(I_smooth, nldat_sys_dec);
%     if n > 1
%         data_temp = nldat_temp.dataSet;
%         data_hold = cat(1, clean_ACCEL.dataSet, data_temp);
%         clean_ACCEL.dataSet = data_hold;
%     else
%         clean_ACCEL = nldat_temp;
%     end
% 
%     T1=T1+WindowJump;
%     T2=T2+WindowJump;
% end


% end