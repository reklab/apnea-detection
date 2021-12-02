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
% descrip_path ='normalBreathing'; description = "normal breathing"; ntrial = '008';
% descrip_path ='intermittentBreathing_voluntary'; description = "intermittent breathing - voluntary"; ntrial = '009';
descrip_path ='intermittentBreathing_obstruction'; description = 'interittent breathing - obstruction'; ntrial = '010';

filename = string([baseDir ntrial '_' descrip_path '.json']);
savepath = ['/Users/lauracarlton/Dropbox/ApnexDetection_Project/Export/figures_v4/' ntrial '/'];
% savepath= ['C:\Users\vstur\Dropbox\ApnexDetection_Project\Export\figures_v4\' ntrial '/'];
% savepath = ['/Users/jtam/Dropbox/ApnexDetection_Project/Export/figures_v4/' ntrial '/'];
if ~exist(savepath, 'file')
    mkdir(savepath)
end
savefigs = 1;

raw_data = loadjson(filename);

fprintf('Data loaded \n')
%% go through each cell in the raw data and assign it to a structure
pkg_gap=[];
package_gap_counter =1;
duplicate_data_counter = 1;
for a = 1:length(raw_data)

    cell = raw_data{a};
    datatype = cell.dataType;
    if datatype == "Health"
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

            if v > 1
                eval(['nldat_' sensor '_' datatype '=cat(2, nldat_' sensor '_' datatype ', hold_nldat);'])
                %                 eval(['nldat_' sensor '_' datatype '.comment = ['' sensor '' "' datatype ''];'])
            else
                eval ([ 'nldat_' sensor '_' datatype '= hold_nldat;']);
            end
        end
    end
end
fprintf('Data converted to nldat objects \n')

%% Analysis 1: gap and duplicate counting
gap_analysis = 0;
if gap_analysis
    [gaps_C3898_ACCEL, interval_C3898_ACCEL] = data_gaps(nldat_C3898_ACCEL, savefigs, savepath);
    [gaps_C3892_ACCEL, interval_C3892_ACCEL] = data_gaps(nldat_C3892_ACCEL, savefigs, savepath);
    [gaps_C3898_ECG, interval_C3898_ECG] = data_gaps(nldat_C3898_ECG, savefigs, savepath);
    [gaps_C3892_ECG, interval_C3892_ECG] = data_gaps(nldat_C3892_ECG, savefigs, savepath);
    [gaps_C3898_Temp, interval_C3898_Temp] = data_gaps(nldat_C3898_Temp, savefigs, savepath);
    [gaps_C3892_Temp, interval_C3892_Temp] = data_gaps(nldat_C3892_Temp, savefigs, savepath);
    [gaps_L3572_Temp, interval_L3572_Temp] = data_gaps(nldat_L3572_Temp, savefigs, savepath);
    [gaps_L3572_PPG, interval_L3572_PPG] = data_gaps(nldat_L3572_PPG, savefigs, savepath);
end
%% Analysis 2.1: ACCEL detrend, interpolate, and segment
fs1 = 416;
fs2 = 500;
a = nldat_C3898_ACCEL.domainValues;
sampleLength1 = a(end);
b = nldat_C3892_ACCEL.domainValues;
sampleLength2 = b(end);

sampleLength = min(sampleLength1, sampleLength2);
time = 0:1/fs2:sampleLength;
time=time';

%always pass tapped sensor first
[segm_locs,segm_pks]= segment_ID(nldat_C3898_ACCEL, nldat_C3892_ACCEL, pkg_gap,ntrial, savepath, savefigs);

nldat_C3898_ACCEL= interp1(nldat_C3898_ACCEL, time, 'linear');
nldat_C3892_ACCEL= interp1(nldat_C3892_ACCEL, time, 'linear');
disp ('Data interpolated')

[nldat_C3898_ACCEL] = data_preprocess(nldat_C3898_ACCEL, fs1, fs2, time);
[nldat_C3892_ACCEL] = data_preprocess(nldat_C3892_ACCEL, fs1, fs2, time);
disp ('Data detrended')

time=nldat_C3898_ACCEL.domainValues;
[seg_C3898_ACCEL] = segmentation(segm_pks, segm_locs, nldat_C3898_ACCEL);
[seg_C3892_ACCEL] = segmentation(segm_pks, segm_locs, nldat_C3892_ACCEL);
disp ('Data segmented')
close all

% % code for seg 8
% T1=find(time==159);
% T2=find(time==161);
% seg_C3892_ACCEL.seg1=nldat_C3892_ACCEL(1:T1,:,1);
% seg_C3898_ACCEL.seg1=nldat_C3898_ACCEL(1:T1,:,1);
% seg_C3892_ACCEL.seg2=nldat_C3892_ACCEL(T2:end,:,1);
% seg_C3898_ACCEL.seg2=nldat_C3898_ACCEL(T2:end,:,1);
%% Analysis 2.2: ECG interpolate and segment
fs_ECG=250;
c = nldat_C3898_ECG.domainValues;
sampleLength3 = c(end);
sampleLength = min(sampleLength, sampleLength3);
time_ECG = 0:1/fs_ECG:sampleLength;
time_ECG=time_ECG';

nldat_C3898_ECG= interp1(nldat_C3898_ECG, time_ECG, 'linear');
nldat_C3892_ECG= interp1(nldat_C3892_ECG, time_ECG, 'linear');
disp ('ECG Data interpolated')

[seg_C3898_ECG] = segmentation(segm_pks, segm_locs, nldat_C3898_ECG);

% %code for seg 8
% TE1=find(time_ECG==159)
% TE2=find(time_ECG==161)
% seg_C3898_ECG.seg1=nldat_C3898_ECG(1:TE1);
% seg_C3898_ECG.seg2=nldat_C3898_ECG(TE2:end);
%% Analysis 3. clean the data and generate figures 

directions = ["X", "Y", "Z"];
nDir = length(directions);
ts=1/fs2;
d= 10;
ts_d = ts/d;

for i =1:length(segm_pks)+1

    segment=append('seg', num2str(i));
    hold_accel1=seg_C3898_ACCEL.(segment);
    hold_accel2=seg_C3892_ACCEL.(segment);
    nldat_ECG=seg_C3898_ECG.(segment);

    savepath2=[savepath 'segment_' num2str(i) '_raw/'];
    if ~exist(savepath2, 'file')
        mkdir(savepath2)
    end

    for v=1:nDir
        dir = directions{v};
        hold_accel1_temp=hold_accel1(:,v,:);
        hold_accel2_temp=hold_accel2(:,v,:);
        [hold_accel1_raw, hold_accel1_clean]=irf_accel_ecg(hold_accel1_temp, nldat_ECG, ts, ntrial, segment,savepath2, savefigs, dir, 'C3898');
        [hold_accel2_raw, hold_accel2_clean]=irf_accel_ecg(hold_accel2_temp, nldat_ECG, ts, ntrial, segment,savepath2, savefigs, dir, 'C3892');

        if v > 1
            eval(['nldat_C3898_ACCEL_raw.' segment '=cat(2,nldat_C3898_ACCEL_raw.' segment ', hold_accel1_raw);'])
            eval(['nldat_C3892_ACCEL_raw.' segment '=cat(2,nldat_C3892_ACCEL_raw.' segment ', hold_accel2_raw);'])
            eval(['nldat_C3898_ACCEL_clean.' segment '=cat(2,nldat_C3898_ACCEL_clean.' segment ', hold_accel1_clean);'])
            eval(['nldat_C3892_ACCEL_clean.' segment '=cat(2,nldat_C3892_ACCEL_clean.' segment ', hold_accel2_clean);'])
        else
            eval(['nldat_C3898_ACCEL_raw.' segment '=hold_accel1_raw;'])
            eval(['nldat_C3892_ACCEL_raw.' segment '=hold_accel2_raw;'])
            eval(['nldat_C3898_ACCEL_clean.' segment '=hold_accel1_clean;'])
            eval(['nldat_C3892_ACCEL_clean.' segment '=hold_accel2_clean;'])
        end
    end

    set(nldat_C3898_ACCEL_raw.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Raw Acceleration Data C3898')
    set(nldat_C3898_ACCEL_clean.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Clean Acceleration Data C3898')
    set(nldat_C3892_ACCEL_raw.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Raw Acceleration Data C3892')
    set(nldat_C3892_ACCEL_clean.(segment), 'domainIncr',ts_d, 'domainValues', NaN, 'domainStart', 0, 'chanNames', directions, 'comment', 'Clean Acceleration Data C3892')

    fft_ECG_analysis(nldat_ECG, ntrial, segment, savepath2, savefigs)
% 
    [freq_1, freq_2, phasediff_1, phasediff_2, pk_1, pk_2] = fft_analysis(nldat_C3898_ACCEL_clean.(segment), nldat_C3892_ACCEL_clean.(segment), ntrial, segment, savepath2, savefigs);
%     [freq_1, freq_2, phasediff_1, phasediff_2, pk_1, pk_2] = fft_analysis(nldat_C3898_ACCEL_raw.(segment), nldat_C3892_ACCEL_raw.(segment), ntrial, segment, savepath2, savefigs);

    sensor_C3898.freq(i,:) = freq_1;
    sensor_C3898.phasediff(i,:) = phasediff_1;
    sensor_C3898.pks(i,:) = pk_1;
    sensor_C3892.freq(i,:) = freq_2;
    sensor_C3892.phasediff(i,:) = phasediff_2;
    sensor_C3892.pks(i,:) = pk_2;

end

save([savepath 'spectrum_pks_phase_clean'], 'sensor_C3898', 'sensor_C3892')



