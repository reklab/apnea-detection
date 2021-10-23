%% NOTES BEFORE RUNNING
% Make sure current folder is DropBox 
% Make sure to add all folders in ApnexDetection_Project
% Make sure to add nlid_tools and utility_tools from reklab public

% addpath('/MATLAB tools/jsonlab-2.0/jsonlab-2.0/')
%addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/reklab_public/utility_tools/')
%addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/reklab_public/nlid_tools/')

addpath('C:\Users\vstur\OneDrive\Desktop\GitHub\reklab_public\nlid_tools')
addpath('C:\Users\vstur\OneDrive\Desktop\GitHub\reklab_public\utility_tools')
%% load raw data from the json file 
clc
clear all
tic 
baseDir = 'trials_data_json/ANNE_data_trial';
descrip_path ='intermittentBreathing_voluntary';
ntrial = '002';

filename = string([baseDir ntrial '_' descrip_path '.json']);
%savepath = ['trials_data_json/Export/figures_v2/' ntrial '/'];
savepath= ['C:\Users\vstur\OneDrive\Desktop\BIEN 470 DATA\Images\trial002'];
if ~exist(savepath, 'file')
    mkdir(savepath)
end

description = "intermittent voluntary breathing";
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
        
        %CHECKING FOR PACKAGE SIZED GAPS
        %STILL NEED TO COMPARE TO HISTOGRAMS OF TIME GAPS
        
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
            % best time to test for gaps??
            
            hold_data=transpose(reshape(hold_data,1,[]));
            hold_time=transpose(reshape(hold_time,1,[]));
            hold_time=hold_time-hold_time(1,1);
            hold_time = hold_time/1000;
            
            hold_nldat = nldat(hold_data);
            set(hold_nldat, 'domainValues', hold_time,'domainName', "Time (ms)", 'chanNames', string(var), 'comment', [sensor ' ' datatype])

            if v > 1
                eval(['nldat_' sensor '_' datatype '=cat(2,hold_nldat,  nldat_' sensor '_' datatype ');'])
                
            else
                eval ([ 'nldat_' sensor '_' datatype '= hold_nldat;']);
            end
        end
    end
end
fprintf('Data converted to nldat objects \n')

%% analysis 
% this is where we should do the segment ID and then we can call the
% accel_analysis function for each segment - we can also alter savepath for
% each segment and then call the accel_analysis w the new savepath 
save_figs = 1;

%% MOVE INTO SEGMENT ACCEL AFTER PKS AND LOCS COMMAND
%DOMAIN WILL BE CHANGED 



%%
[segm_loc, seg_nldat1, seg_nldat2]=segment_accel(nldat_C3898_ACCEL, nldat_C3892_ACCEL, 'C3892', pkg_gap,ntrial, savepath);

%accel_analysis(nldat_C3898_ACCEL, nldat_C3892_ACCEL, ntrial, savepath, save_figs)

%UPDATE from Vic: For trial002 it ran everything besides the last segment (see
%facebook for weird error message. All the plots are saved on my computer right
%now



