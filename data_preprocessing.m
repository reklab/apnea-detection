
%% ==================
% function that 1. interpolates the ECG data to match ACCEL
% 2. decimates ECG and ACCEL data to 50Hz
% 3. uses IRF to remove HR effects in ACCEL data
% 4. normalizes the ACCEL data

function [raw_ACCEL,clean_ACCEL,ECG_input]=data_preprocessing(ACCEL_output, ECG_input,ts, sampleLength)

fs_interp = 500;
fs_ECG=250;

ACCEL_output = data_detrend(ACCEL_output, fs_interp);
disp ('ACCEL data detrended')

c = ECG_input.domainValues;
sampleLength3 = c(end);
sampleLength = min(sampleLength, sampleLength3);
time_ECG = 0:1/fs_ECG:sampleLength;
time_ECG=time_ECG';

ECG_input= interp1(ECG_input, time_ECG, 'linear');
disp ('ECG Data interpolated')

%% 
directions = ["X", "Y", "Z"];
nDir = length(directions);
d=10; ts_dec = d*ts;
IR_length = 0.2;
nLags = IR_length/ts_dec;
size = ACCEL_output.dataSize;
time_ACCEL = 0:ts:ts*size(1)-ts;

ECG_input = interp1(ECG_input, time_ACCEL, 'linear');
set(ECG_input, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
ECG_input_dec = decimate(ECG_input, d);
set(ECG_input_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

for v = 1:nDir

    ACCEL_output_hold = ACCEL_output(:,v);
    set(ACCEL_output_hold, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
    ACCEL_output_dec = decimate(ACCEL_output_hold, d);
    set(ACCEL_output_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    size = ACCEL_output_dec.dataSize;
    mid = size(1)/2;
    ACCEL_output_train = ACCEL_output_dec(1:mid,:,:);
    ECG_input_train = ECG_input_dec(1:mid,:,:);

    nldat_sys_train = cat(2, ECG_input_train, ACCEL_output_train);
    set(nldat_sys_train, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    nldat_sys_clean = cat(2, ECG_input_dec, ACCEL_output_dec);
    set(nldat_sys_clean, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    I = irf(nldat_sys_train, 'nLags', nLags, 'nSides', 2);
    residuals = nlid_resid(I, nldat_sys_clean);

    if v > 1
        clean_ACCEL = cat(2,clean_ACCEL, residuals);
        raw_ACCEL = cat(2,raw_ACCEL, ACCEL_output_dec);
    else
        clean_ACCEL = residuals;
        raw_ACCEL = ACCEL_output_dec;
    end
end

clean_ACCEL.comment = "Acceleration: cleaned";
raw_ACCEL.comment = "Acceleration: raw";

clean_ACCEL.dataSet = normalize(clean_ACCEL.dataSet);
raw_ACCEL.dataSet = normalize(raw_ACCEL.dataSet);

disp('ACCEL data cleaned and normalized')
end


