
%% IRF_HR
% function that 
% 1. interpolates the data to make sure the ECG and the chest and abdomen acceleration
%    are the same length 
% 2. decimates ECG and ACCEL data to 50Hz
% 3. uses IRF to remove HR effects in ACCEL data

function [raw_ACCEL_chest,clean_ACCEL_chest,raw_ACCEL_abd, clean_ACCEL_abd]=IRF_HR(ACCEL_output_chest,ACCEL_output_abd, ECG_input,ts)

fs_interp = 500;
fs_ECG=250;

a = ACCEL_output_chest.domainValues;
sampleLength1 = a(end);
b = ACCEL_outpu_abd.domainValues;
sampleLength2 = b(end);

sampleLength = min(sampleLength1, sampleLength2);
time = 0:1/fs_interp:sampleLength;
time=time';

ACCEL_output_chest= interp1(ACCEL_output_chest, time, 'linear');
ACCEL_output_abd= interp1(ACCEL_output_abd, time, 'linear');
disp ('ACCEL data interpolated')

ACCEL_output_chest = data_detrend(ACCEL_output_chest, fs_interp);
ACCEL_output_abd = data_detrend(ACCEL_output_abd, fs_interp);
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
size = ACCEL_output_chest.dataSize;
time_ACCEL = 0:ts:ts*size(1)-ts;

ECG_input = interp1(ECG_input, time_ACCEL, 'linear');
set(ECG_input, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
ECG_input_dec = decimate(ECG_input, d);
set(ECG_input_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

for v = 1:nDir

    ACCEL_output_chest_hold = ACCEL_output_chest(:,v);
    set(ACCEL_output_chest_hold, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
    ACCEL_output_chest_dec = decimate(ACCEL_output_chest_hold, d);
    set(ACCEL_output_chest_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    size = ACCEL_output_chest_dec.dataSize;
    mid = size(1)/2;
    ACCEL_output_train = ACCEL_output_chest_dec(1:mid,:,:);
    ECG_input_train = ECG_input_dec(1:mid,:,:);

    nldat_sys_train = cat(2, ECG_input_train, ACCEL_output_train);
    set(nldat_sys_train, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    nldat_sys_clean = cat(2, ECG_input_dec, ACCEL_output_chest_dec);
    set(nldat_sys_clean, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    I = irf(nldat_sys_train, 'nLags', nLags, 'nSides', 2);
    residuals = nlid_resid(I, nldat_sys_clean);

    if v > 1
        clean_ACCEL = cat(2,clean_ACCEL, residuals);
        raw_ACCEL = cat(2,raw_ACCEL, ACCEL_output_chest_dec);
    else
        clean_ACCEL = residuals;
        raw_ACCEL = ACCEL_output_chest_dec;
    end
end

clean_ACCEL.comment = "Acceleration: cleaned";
raw_ACCEL.comment = "Acceleration: raw";

clean_ACCEL.dataSet = normalize(clean_ACCEL.dataSet);
raw_ACCEL.dataSet = normalize(raw_ACCEL.dataSet);

end


