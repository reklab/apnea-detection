%% NOTES BEFORE RUNNING
% Make sure current folder is DropBox
% Make sure to add all folders in ApnexDetection_Project
% Make sure to add nlid_tools and utility_tools from reklab public

% addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/reklab_public/utility_tools/')
% addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/reklab_public/nlid_tools/')
% addpath('/Users/jtam/Dropbox/ApnexDetection_Project/MATLAB tools/jsonlab-2.0/jsonlab-2.0/')
% addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/apnea-detection/Untitled')
% 
% addpath('C:\Users\vstur\OneDrive\Desktop\GitHub\apnea-detection')
% addpath('C:\Users\vstur\OneDrive\Desktop\GitHub\reklab_public\nlid_tools')
% addpath('C:\Users\vstur\OneDrive\Desktop\GitHub\reklab_public\utility_tools')
% addpath('C:\Users\vstur\OneDrive\Desktop\GitHub\reklab_public\nlid_tools\nlid_util');

addpath('/Users/lauracarlton/Dropbox/ApnexDetection_Project/MATLAB tools/jsonlab-2.0/jsonlab-2.0/')
addpath('/Users/lauracarlton/Documents/GitHub/reklab_public/utility_tools/');
addpath('/Users/lauracarlton/Documents/GitHub/reklab_public/nlid_tools/');
addpath('/Users/lauracarlton/Documents/GitHub/reklab_public/nlid_tools/nlid_util');

%% load raw data from the json file
clc
clear all

baseDir = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/trials_data_json/ANNE_data_trial';
% baseDir = '/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_json/ANNE_data_trial';
% baseDir = '/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_json/ANNE_data_trial';

% chose the desired trial
% ntrial = '011'; ChestSensor = 'C3900'; AbdSensor = 'C3895'; DigitSensor = 'L3569';
% descrip_path ='normalBreathing'; description = "normal breathing";

% ntrial = '012'; ChestSensor = 'C3900'; AbdSensor = 'C3895'; DigitSensor = 'L3569';
% descrip_path ='intermittentBreathing_voluntary'; description = "intermittent breathing - voluntary"; 

ntrial = '013'; ChestSensor = 'C3900'; AbdSensor = 'C3895'; DigitSensor = 'L3569';
descrip_path ='intermittentBreathing_obstruction'; description = 'interittent breathing - obstruction'; 

filename = string([baseDir ntrial '_' descrip_path '.json']);
savepath = ['/Users/lauracarlton/Dropbox/ApnexDetection_Project/Export/figures_v5/' ntrial '/'];
% savepath= ['C:\Users\vstur\Dropbox\ApnexDetection_Project\Export\figures_v4\' ntrial '/'];
% savepath = ['/Users/jtam/Dropbox/ApnexDetection_Project/Export/figures_v4/' ntrial '/'];
if ~exist(savepath, 'file')
    mkdir(savepath)
end
savefigs = 0;

raw_data = loadjson(filename);

fprintf('Data loaded \n')
%% go through each cell in the raw data and assign it to a structure

package_gap_counter =0;
duplicate_data_counter = 0;
for a = 15:length(raw_data)

    cell = raw_data{a};
    datatype = cell.dataType;

    if datatype == "Health" || datatype == "SystemStatus"
        continue
    end
    sensor = cell.sensor_name;
    try
        all_data.(sensor).(datatype)(end+1) = cell;
    catch
        all_data.(sensor).(datatype) = cell;
        pkg_gap.(sensor).(datatype) = struct('gap_start', 0, 'gap_end', 0);
    end

    if length(all_data.(sensor).(datatype)) >= 2

        time_diff = zeros(length(cell.timestamp)-1,1);
        for j = 2:length(cell.timestamp)
            time_diff(j-1) = cell.timestamp(j) - cell.timestamp(j-1);
        end
        Ts = mean(time_diff);

        if cell.timestamp >1.5*Ts*length(cell.timestamp)+all_data.(sensor).(datatype)(end-1).timestamp
            %             fprintf('GAP in the data - sensor: %s datatype: %s \n', sensor, datatype)
            package_gap_counter = package_gap_counter+1;
            T1=all_data.(sensor).(datatype)(1).timestamp(1,1);
            TS=all_data.(sensor).(datatype)(end-1).timestamp(end);
            if pkg_gap.(sensor).(datatype)(1).gap_start==0
                pkg_gap.(sensor).(datatype)(1).gap_start=TS-T1;
                pkg_gap.(sensor).(datatype)(1).gap_end=cell.timestamp(1,1)-T1;
            else
                pkg_gap.(sensor).(datatype)(end+1).gap_start=TS-T1;
                pkg_gap.(sensor).(datatype)(end).gap_end=cell.timestamp(1,1)-T1;
            end
        elseif cell.timestamp == all_data.(sensor).(datatype)(end-1).timestamp
            vars = fieldnames(cell);
            p = find(vars == "address");
            vars(p:end) = [];

            data1 = zeros(length(vars),length(cell.timestamp));
            data2 = zeros(length(vars),length(cell.timestamp));
            for v = 1:length(vars)
                data1(v,:) = cell.(vars{v});
                data2(v,:) = all_data.(sensor).(datatype)(end-1).(vars{v});
            end
            if isequal(data1, data2)
                all_data.(sensor).(datatype)(end) = [];
                duplicate_data_counter = duplicate_data_counter+1;
            else
                %                 fprintf('ERROR: different data for same time points - sensor: %s datatype: %s \n', sensor, datatype)
                all_data.(sensor).(datatype)(end) = [];
                duplicate_data_counter = duplicate_data_counter+1;
            end
        end
    end
end

fprintf('Data converted to structure \n')
%% convert data to nldat
sensor_list = fieldnames(all_data);

for n = 1:length(sensor_list)

    sensor = sensor_list{n};
    data_list = fieldnames(all_data.(sensor));
    for d = 1:length(data_list)
        datatype = data_list{d};
        y = all_data.(sensor).(datatype);
        pkg_length = length(y);

        vars = fieldnames(all_data.(sensor).(datatype));
        a = find(vars=="address");
        vars(a:end) = [];

        for v = 1:length(vars)
            var = vars{v};

            data_length = length(all_data.(sensor).(datatype)(1).(var));
            hold_data = zeros(data_length, pkg_length);
            hold_time = zeros(data_length,pkg_length);
            data={all_data.(sensor).(datatype).(var)};
            time={all_data.(sensor).(datatype).timestamp};
            for t = 1:pkg_length
                hold_data(:,t)=cell2mat(data(1,t));
                hold_time(:,t)=cell2mat(time(1,t));
            end

            hold_data=transpose(reshape(hold_data,1,[]));
            hold_time=transpose(reshape(hold_time,1,[]));
            hold_time=hold_time-hold_time(1,1);
            hold_time = hold_time/1000;

            hold_nldat = nldat(hold_data);
            set(hold_nldat, 'domainValues', hold_time,'domainName', "Time (ms)", 'chanNames', string(var), 'comment', [sensor ' ' datatype])
            
            if isequal(sensor, ChestSensor)
                s = 'chest';
            elseif isequal(sensor, AbdSensor)
                s = 'abd';
            else
                s = 'digit';
            end

            if v > 1
                eval(['nldat_' s '_' datatype '=cat(2, nldat_' s '_' datatype ', hold_nldat);'])
            else
                eval ([ 'nldat_' s '_' datatype '= hold_nldat;']);
            end
        end
    end
end

fs_accel = 416; fs_ECG = 256;
set(nldat_abd_ACCEL, 'domainValues', NaN, 'domainIncr', 1/fs_accel)
set(nldat_chest_ACCEL, 'domainValues', NaN, 'domainIncr', 1/fs_accel)
% set(nldat_abd_ECG, 'domainValues', NaN, 'domainIncr', 1/fs_ECG)
set(nldat_chest_ECG, 'domainValues', NaN, 'domainIncr', 1/fs_ECG)


fprintf('Data converted to nldat objects \n')

%% Analysis 1: gap and duplicate counting
gap_analysis = 0;
if gap_analysis
    [gaps_chest_ACCEL, interval_chest_ACCEL] = data_gaps(nldat_chest_ACCEL, savefigs, savepath);
    [gaps_abd_ACCEL, interval_abd_ACCEL] = data_gaps(nldat_abd_ACCEL, savefigs, savepath);
    [gaps_chest_ECG, interval_chest_ECG] = data_gaps(nldat_chest_ECG, savefigs, savepath);
    [gaps_abd_ECG, interval_abd_ECG] = data_gaps(nldat_abd_ECG, savefigs, savepath);
    [gaps_chest_Temp, interval_chest_Temp] = data_gaps(nldat_chest_Temp, savefigs, savepath);
    [gaps_abd_Temp, interval_abd_Temp] = data_gaps(nldat_abd_Temp, savefigs, savepath);
    [gaps_digit_Temp, interval_digit_Temp] = data_gaps(nldat_digit_Temp, savefigs, savepath);
    [gaps_digit_PPG, interval_digit_PPG] = data_gaps(nldat_digit_PPG, savefigs, savepath);
end
%% Analysis 2.1: ACCEL detrend, interpolate, and segment
fs1 = 416;
fs2 = 500;
a = nldat_chest_ACCEL.dataSet;
sampleLength1 = length(a);
b = nldat_abd_ACCEL.dataSet;
sampleLength2 = length(b);

sampleLength = min(sampleLength1, sampleLength2);
time= 0 + (0:sampleLength)*nldat_chest_ACCEL.domainIncr;

% time = 0:1/fs2:sampleLength;
% time=time';

%always pass tapped sensor first
% [segm_locs,segm_pks]= segment_ID(nldat_chest_ACCEL, nldat_abd_ACCEL, pkg_gap,ntrial, savepath, savefigs);

nldat_chest_ACCEL= interp1(nldat_chest_ACCEL, time, 'linear');
nldat_abd_ACCEL= interp1(nldat_abd_ACCEL, time, 'linear');
disp ('Data interpolated')

[nldat_chest_ACCEL] = data_preprocess(nldat_chest_ACCEL, fs1, fs2, time);
[nldat_abd_ACCEL] = data_preprocess(nldat_abd_ACCEL, fs1, fs2, time);
disp ('Data detrended')

% time=nldat_chest_ACCEL.domainValues;
% [seg_chest_ACCEL] = segmentation(segm_pks, segm_locs, nldat_chest_ACCEL);
% [seg_abd_ACCEL] = segmentation(segm_pks, segm_locs, nldat_abd_ACCEL);
% disp ('Data segmented')
close all

%% code for trial 11-13
nSeg = 180/20;
a = 0;

for t = 1:nSeg*2
    if  mod(t,2) == 0
        a = a+2;
    else
        a = a+18;
    end
    T(t) = find(time==a);
end

T_stop = T(1:2:end-1);
T_start = T(2:2:end);

seg_chest_ACCEL.seg1 =  nldat_chest_ACCEL(1:T(1), :,1);
seg_abd_ACCEL.seg1 =  nldat_abd_ACCEL(1:T(1), :,1);

for t = 2:nSeg-1
    eval(['seg_chest_ACCEL.seg' num2str(t) '=nldat_chest_ACCEL(T_start(t-1):T_stop(t),:,1);']);
    eval(['seg_abd_ACCEL.seg' num2str(t) '=nldat_abd_ACCEL(T_start(t-1):T_stop(t),:,1);']);
end

seg_chest_ACCEL.seg9 =  nldat_chest_ACCEL(T(end-2):end, :,1);
seg_abd_ACCEL.seg9 =  nldat_abd_ACCEL(T(end-2):end, :,1);

%% Analysis 2.2: ECG interpolate and segment
fs_ECG=250;
c = nldat_chest_ECG.dataSet;
sampleLength3 = length(c);

time_ECG = 0 + (0:sampleLength3)*nldat_chest_ECG.domainIncr;

nldat_chest_ECG= interp1(nldat_chest_ECG, time_ECG, 'linear');
% nldat_abd_ECG= interp1(nldat_abd_ECG, time_ECG, 'linear');
disp ('ECG Data interpolated')

% [seg_chest_ECG] = segmentation(segm_pks, segm_locs, nldat_chest_ECG);

a = 0;

for t = 1:nSeg*2
    if  mod(t,2) == 0
        a = a+2;
    else
        a = a+18;
    end
    T(t) = find(time_ECG==a);
end

TE_stop = T(1:2:end-1);
TE_start = T(2:2:end);

seg_chest_ECG.seg1 =  nldat_chest_ECG(1:T(1), :,1);
% seg_abd_ACCEL.seg1 =  nldat_abd_ACCEL(1:T(1), :,1);

for t = 2:nSeg-1
    eval(['seg_chest_ECG.seg' num2str(t) '=nldat_chest_ECG(TE_start(t-1):TE_stop(t),:,1);']);
%     eval(['seg_abd_ACCEL.seg' num2str(t) '=nldat_abd_ACCEL(T_start(t-1):T_stop(t),:,1);']);
end

seg_chest_ECG.seg9 =  nldat_chest_ECG(T(end-2):end, :,1);
% seg_abd_ECG.seg9 =  nldat_abd_ECG(T(end):end, :,1);

%% Analysis 3. clean the data and generate figures 

directions = ["X", "Y", "Z"];
nDir = length(directions);
ts=1/fs2;
d= 10;
ts_d = ts/d;

for i =1:nSeg %length(segm_pks)+1

    segment=append('seg', num2str(i));
    hold_accel1=seg_chest_ACCEL.(segment);
    hold_accel2=seg_abd_ACCEL.(segment);
    nldat_ECG=seg_chest_ECG.(segment);

    savepath2=[savepath 'segment_' num2str(i) '_raw/'];
%     if ~exist(savepath2, 'file')
%         mkdir(savepath2)
%     end

    for v=1:nDir
        dir = directions{v};
        hold_accel1_temp=hold_accel1(:,v,:);
        hold_accel2_temp=hold_accel2(:,v,:);
        [hold_accel1_raw, hold_accel1_clean]=irf_accel_ecg(hold_accel1_temp, nldat_ECG, ts, ntrial, segment,savepath2, savefigs, dir, 'C3898');
        [hold_accel2_raw, hold_accel2_clean]=irf_accel_ecg(hold_accel2_temp, nldat_ECG, ts, ntrial, segment,savepath2, savefigs, dir, 'C3892');

        if v > 1
            eval(['nldat_chest_ACCEL_raw.' segment '=cat(2,nldat_chest_ACCEL_raw.' segment ', hold_accel1_raw);'])
            eval(['nldat_abd_ACCEL_raw.' segment '=cat(2,nldat_abd_ACCEL_raw.' segment ', hold_accel2_raw);'])
            eval(['nldat_chest_ACCEL_clean.' segment '=cat(2,nldat_chest_ACCEL_clean.' segment ', hold_accel1_clean);'])
            eval(['nldat_abd_ACCEL_clean.' segment '=cat(2,nldat_abd_ACCEL_clean.' segment ', hold_accel2_clean);'])
        else
            eval(['nldat_chest_ACCEL_raw.' segment '=hold_accel1_raw;'])
            eval(['nldat_abd_ACCEL_raw.' segment '=hold_accel2_raw;'])
            eval(['nldat_chest_ACCEL_clean.' segment '=hold_accel1_clean;'])
            eval(['nldat_abd_ACCEL_clean.' segment '=hold_accel2_clean;'])
        end
    end

    set(nldat_chest_ACCEL_raw.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Raw Acceleration Data Chest')
    set(nldat_chest_ACCEL_clean.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Clean Acceleration Data Chest')
    set(nldat_abd_ACCEL_raw.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Raw Acceleration Data Abdomen')
    set(nldat_abd_ACCEL_clean.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Clean Acceleration Data Abdomen')

    fft_ECG_analysis(nldat_ECG, ntrial, segment, savepath2, savefigs)
% 
    [freq_1, freq_2, phasediff_1, phasediff_2, pk_1, pk_2] = fft_analysis(nldat_chest_ACCEL_clean.(segment), nldat_abd_ACCEL_clean.(segment), ntrial, segment, savepath2, savefigs);
%     [freq_1, freq_2, phasediff_1, phasediff_2, pk_1, pk_2] = fft_analysis(nldat_chest_ACCEL_raw.(segment), nldat_abd_ACCEL_raw.(segment), ntrial, segment, savepath2, savefigs);

    [freq_1_band, freq_2_band, phasediff_1_band, phasediff_2_band, pk_1_band, pk_2_band] = freq_band_analysis(nldat_chest_ACCEL_clean.(segment), nldat_abd_ACCEL_clean.(segment), ntrial,segment, savepath2, savefigs);
    
    sensor_chest.freq(i,:) = freq_1;
    sensor_chest.phasediff(i,:) = phasediff_1;
    sensor_chest.pks(i,:) = pk_1;
    sensor_abd.freq(i,:) = freq_2;
    sensor_abd.phasediff(i,:) = phasediff_2;
    sensor_abd.pks(i,:) = pk_2;

    sensor_chest_fband.freq(i,:) = freq_1_band;
    sensor_chest_fband.phasediff(i,:) = phasediff_1_band;
    sensor_chest_fband.pks(i,:) = pk_1_band;
    sensor_abd_fband.freq(i,:) = freq_2_band;
    sensor_abd_fband.phasediff(i,:) = phasediff_2_band;
    sensor_abd_fband.pks(i,:) = pk_2_band;
end

save([savepath 'spectrum_pks_phase_clean'], 'sensor_chest', 'sensor_abd', 'sensor_chest_fband', 'sensor_abd_fband')



