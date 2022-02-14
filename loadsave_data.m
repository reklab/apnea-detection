
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
% addpath('C:\Users\vstur\Dropbox\AUREA_retrieved_v2\METRICS')
% addpath('C:\Users\vstur\Dropbox\AUREA_retrieved_v2\Signal_Processing')
% addpath('C:\Users\vstur\Dropbox\AUREA_retrieved_v2\CardioRespiratory_Analysis')

addpath('/Users/lauracarlton/Dropbox/ApnexDetection_Project/MATLAB tools/jsonlab-2.0/jsonlab-2.0/')
addpath('/Users/lauracarlton/Documents/GitHub/reklab_public/utility_tools/');
addpath('/Users/lauracarlton/Documents/GitHub/reklab_public/nlid_tools/');
addpath('/Users/lauracarlton/Documents/GitHub/reklab_public/nlid_tools/nlid_util');
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/METRICS/')
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/Signal_Processing/')
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/CardioRespiratory_Analysis/')
%% load raw data from the json file
clc
clear all

% baseDir = '/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_json/ANNE_data_trial';
% baseDir = '/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_json/ANNE_data_trial';
baseDir = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/trials_data_json/ANNE_data_trial';
% list = dir([baseDir 'trials_data_json/']);

trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013", "017", "018", "019", "020", "021", "022", "023", "024", "025"];
Ntrials = length(trials);

%%
for n = 11 %:Ntrials
    clc
    clear all_data 
    %ntrial=convertStringsToChars(trials(n));
    % ntrial = '018';
    ntrial = trials{n};
    if ismember(ntrial,["001","002","003","008","009","010"])
        ChestSensor = 'C3898'; AbdSensor = 'C3892'; DigitSensor = 'L3572';
    else
        ChestSensor = 'C3900'; AbdSensor = 'C3895'; DigitSensor = 'L3569';
    end

    nb = ["001", "008", "011", "017", "020", "023"];
    vb = ["002", "009", "012", "018", "021", "024"];
    ob = ["003", "010", "013", "019", "022", "025"];

    if ismember(ntrial, nb)
        descrip_path ='normalBreathing'; description = 'normal breathing';
    elseif ismember(ntrial, vb)
        descrip_path ='intermittentBreathing_voluntary'; description = 'intermittent breathing - voluntary';
    elseif ismember(ntrial, ob)
        descrip_path ='intermittentBreathing_obstruction'; description = 'intermittent breathing - obstruction';
    else
        error('Unknown trial type')
    end

    filename = string([baseDir ntrial '_' descrip_path '.json']);
    savepath = ['/Users/lauracarlton/Dropbox/ApnexDetection_Project/trials_data_nldat_v2/'];
    %     savepath= ['C:\Users\vstur\Dropbox\ApnexDetection_Project\Export\figures_v4\' ntrial '/'];
    %     % savepath = ['/Users/jtam/Dropbox/ApnexDetection_Project/Export/figures_v4/' ntrial '/'];
    if ~exist(savepath, 'file')
        mkdir(savepath)
    end
    savefigs = 0;

    raw_data = loadjson(filename);

    fprintf(['Data loaded: ' description '\n'])
    %% go through each cell in the raw data and assign it to a structure

    package_gap_counter =0;
    duplicate_data_counter = 0;
    for a = 1:length(raw_data)

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
                data_chest={all_data.(sensor).(datatype).(var)};
                time={all_data.(sensor).(datatype).timestamp};
                for t = 1:pkg_length
                    hold_data(:,t)=cell2mat(data_chest(1,t));
                    hold_time(:,t)=cell2mat(time(1,t));
                end

                hold_data=transpose(reshape(hold_data,1,[]));
                hold_time=transpose(reshape(hold_time,1,[]));
                hold_time=hold_time-hold_time(1,1);
                hold_time = hold_time/1000;

                hold_nldat = nldat(hold_data);
                set(hold_nldat, 'domainValues', hold_time,'domainName', "Time (s)", 'chanNames', string(var), 'comment', [sensor ' ' datatype])

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
    %     set(nldat_abd_ACCEL, 'domainValues', NaN, 'domainIncr', 1/fs_accel)
    %     set(nldat_chest_ACCEL, 'domainValues', NaN, 'domainIncr', 1/fs_accel)
    %     % set(nldat_abd_ECG, 'domainValues', NaN, 'domainIncr', 1/fs_ECG)
    %     set(nldat_chest_ECG, 'domainValues', NaN, 'domainIncr', 1/fs_ECG)

    fprintf('Data converted to nldat objects \n')

    %% Fix Time Stamps
    TIME1=nldat_abd_ACCEL.domainValues;
    TIME2=nldat_chest_ACCEL.domainValues;
    TIME3=nldat_chest_ECG.domainValues;

    for x=2:length (TIME1)-1
        if TIME1(x+1) < TIME1(x)

            diff=TIME1(x)-TIME1(x+1);
            TIME1(x+1: end)= TIME1(x+1:end) +diff + (1/fs_accel);
        end
    end

    for x=2:length (TIME2)-1
        if TIME2(x+1) < TIME2(x)

            diff=TIME2(x)-TIME2(x+1);
            TIME2(x+1: end)= TIME2(x+1:end) +diff + (1/fs_accel);
        end
    end
    for x=2:length (TIME3)-1
        if TIME3(x+1) < TIME3(x)

            diff=TIME3(x)-TIME3(x+1);
            TIME3(x+1: end)= TIME3(x+1:end) +diff + (1/fs_accel);
        end
    end


    nldat_abd_ACCEL.domainValues=TIME1;
    nldat_chest_ACCEL.domainValues=TIME2;
    nldat_chest_ECG.domainValues=TIME3;
    %     disp(TIME1(end)); disp(TIME2(end));
    %% Analysis 2.1: ACCEL detrend, interpolate
    fs_accel = 416;
    fs_interp = 500;

    a = nldat_chest_ACCEL.domainValues;
    sampleLength1 = a(end);
    b = nldat_abd_ACCEL.domainValues;
    sampleLength2 = b(end);

    sampleLength = min(sampleLength1, sampleLength2);
    time = 0:1/fs_interp:sampleLength;
    time=time';

    nldat_chest_ACCEL= interp1(nldat_chest_ACCEL, time, 'linear');
    nldat_abd_ACCEL= interp1(nldat_abd_ACCEL, time, 'linear');
    disp ('Data interpolated')

    [nldat_chest_ACCEL] = data_detrend(nldat_chest_ACCEL, fs_interp);
    [nldat_abd_ACCEL] = data_detrend(nldat_abd_ACCEL, fs_interp);
    disp ('Data detrended')

    %% Analysis 2.2: ECG interpolate

    fs_ECG=250;
    c = nldat_chest_ECG.domainValues;
    sampleLength3 = c(end);
    sampleLength = min(sampleLength, sampleLength3);
    time_ECG = 0:1/fs_ECG:sampleLength;
    time_ECG=time_ECG';

    nldat_chest_ECG= interp1(nldat_chest_ECG, time_ECG, 'linear');
    disp ('ECG Data interpolated')

    %% Analysis 3. clean the data

    directions = ["X", "Y", "Z"];
    nDir = length(directions);
    ts=1/fs_interp;
    ts_d = ts*10;
    fs_d = 1/ts_d;

%     for v=1:nDir
%         dir = directions{v};
%         hold_accel_chest=nldat_chest_ACCEL(:,v,:);
%         hold_accel_abd=nldat_abd_ACCEL(:,v,:);
%         [hold_accel_chest_raw, hold_accel_chest_clean]=IRF_HR(hold_accel_chest, nldat_chest_ECG, ts);
%         [hold_accel_abd_raw, hold_accel_abd_clean]=IRF_HR(hold_accel_abd, nldat_chest_ECG, ts);
% 
%         if v > 1
%             nldat_chest_ACCEL_raw = cat(2,nldat_chest_ACCEL_raw, hold_accel_chest_raw);
%             nldat_abd_ACCEL_raw = cat(2,nldat_abd_ACCEL_raw, hold_accel_abd_raw);
%             nldat_chest_ACCEL_clean = cat(2,nldat_chest_ACCEL_clean, hold_accel_chest_clean);
%             nldat_abd_ACCEL_clean = cat(2,nldat_abd_ACCEL_clean, hold_accel_abd_clean);
%         else
%             nldat_chest_ACCEL_raw = hold_accel_chest_raw;
%             nldat_abd_ACCEL_raw = hold_accel_abd_raw;
%             nldat_chest_ACCEL_clean = hold_accel_chest_clean;
%             nldat_abd_ACCEL_clean = hold_accel_abd_clean;
%         end
%     end

    close all

    %% Redefine time domain and TimeInc
    set(nldat_chest_ACCEL, 'domainValues', NaN, 'domainIncr', 1/fs_interp)
    set(nldat_abd_ACCEL, 'domainValues', NaN, 'domainIncr', 1/fs_interp)
%     set(nldat_chest_ACCEL_clean, 'domainValues', NaN, 'domainIncr', 1/fs_d)
%     set(nldat_abd_ACCEL_clean, 'domainValues', NaN, 'domainIncr', 1/fs_d)
    set(nldat_chest_ECG, 'domainValues', NaN, 'domainIncr', 1/fs_ECG)

    %% Label breathing types

    % N = normal, V = voluntary, O = obstruction, A = artefact, T = transition

    dataLength = length(nldat_chest_ACCEL);

    ID_array = blanks(dataLength);

    %NORMAL BREATHING TRIALS
    if ntrial == "001" || ntrial == "008"
        stopN = 157.5*fs_interp;
        ID_array(1:stopN) = "N";
        ID_array(stopN:end) = "A";

    elseif ntrial == "011"
        stopN = 117.5*fs_interp;
        ID_array(1:stopN) = "N";
        ID_array(stopN:end) = "A";

    elseif ntrial == "017" || ntrial =="020" || ntrial=="023"
        ID_array(1:end)="N";
    end


    %VOLUNTARY BREATHING TRIALS
    if ntrial == "002" || ntrial == "009" || ntrial=="012"
        stopN = [17.5, 57.5, 97.5, 137.5].*fs_interp;
        stopV = [37.5, 77.5, 117.5, 157.5].*fs_interp;
        startV= [22.5; 62.5; 102.5; 142.5].*fs_interp;
        startN= [42.5, 82.5, 122.5, 162.5].*fs_interp;

        ID_array(1:end)='A';
        ID_array([1:stopN(1),startN(1):stopN(2), startN(2):stopN(3), startN(3):stopN(4), startN(4):end]) = 'N';
        ID_array([startV(1):stopV(1), startV(2):stopV(2), startV(3):stopV(3), startV(4):stopV(4)]) = 'V';

    elseif ntrial == "018" || ntrial =="021" || ntrial=="024"
        stopN = [17.5, 57.5, 97.5, 137.5].*fs_interp;
        stopV = [37.5, 77.5, 117.5, 157.5].*fs_interp;
        startV= [22.5; 62.5; 102.5; 142.5].*fs_interp;
        startN= [42.5, 82.5, 122.5, 162.5].*fs_interp;

        ID_array(1:end)='T';
        ID_array([1:stopN(1),startN(1):stopN(2), startN(2):stopN(3), startN(3):stopN(4), startN(4):end]) = 'N';
        ID_array([startV(1):stopV(1), startV(2):stopV(2), startV(3):stopV(3), startV(4):stopV(4)]) = 'V';

    end

    %OBSTRUCTIVE BREATHING TRIALS
    if ntrial == "003" || ntrial == "010" ||ntrial=="013"
        stopN = [17.5, 57.5, 97.5, 137.5].*fs_interp;
        stopO = [37.5, 77.5, 117.5, 157.5].*fs_interp;
        startO= [22.5; 62.5; 102.5; 142.5].*fs_interp;
        startN= [42.5, 82.5, 122.5, 162.5].*fs_interp;

        ID_array(1:end)='A';
        ID_array([1:stopN(1),startN(1):stopN(2), startN(2):stopN(3), startN(3):stopN(4), startN(4):end]) = 'N';
        ID_array([startO(1):stopO(1), startO(2):stopO(2), startO(3):stopO(3), startO(4):stopO(4)]) = 'O';

    elseif ntrial == "019" || ntrial =="022" || ntrial=="025"
        stopN = [17.5, 57.5, 97.5, 137.5].*fs_interp;
        stopO = [37.5, 77.5, 117.5, 157.5].*fs_interp;
        startO= [22.5; 62.5; 102.5; 142.5].*fs_interp;
        startN= [42.5, 82.5, 122.5, 162.5].*fs_interp;

        ID_array(1:end)='T';
        ID_array([1:stopN(1),startN(1):stopN(2), startN(2):stopN(3), startN(3):stopN(4), startN(4):end]) = 'N';
        ID_array([startO(1):stopO(1), startO(2):stopO(2), startO(3):stopO(3), startO(4):stopO(4)]) = 'O';

    end

    %% Save everything
    savepath= ['/Users/lauracarlton/Dropbox/ApnexDetection_Project/trials_data_nldat/'];
    save([savepath, 'ANNE_data_trial' ntrial '_raw'], 'nldat_abd_ACCEL', 'nldat_chest_ACCEL', 'nldat_chest_ECG', 'ID_array')
    fprintf('file saved \n')

end


