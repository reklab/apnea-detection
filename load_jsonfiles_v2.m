clc
clear all
tic

baseDir = 'trials_data_json/ANNE_data_trial';
descrip_path ='normalBreathing';
ntrial = '001';

filename = [baseDir 'trial' ntrial '_' descrip_path '.json'];
savepath = 'Export/10_06_2021/';
if ~exist(savepath, 'file')
    mkdir(savepath)
end

description = "voluntary intermittent breathing";
raw_data = loadjson(filename);

data_types = ["ACCEL", "ECG", "PPG", "Health", "Temp"];
sensors = ["C3892", "C3898", "L3572"];
toc/60

%% go through each cell in the raw data and assign it to a structure

s_ECG_C3898=struct('ECG', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});
s_ECG_C3892=struct('ECG', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});
s_PPG_L3572=struct('PPG_IR', {}, 'PPG_RED', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});
s_ACCEL_C3898=struct('ACCEL_X', {}, 'ACCEL_Y', {}, 'ACCEL_Z', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});
s_ACCEL_C3892=struct('ACCEL_X', {}, 'ACCEL_Y', {}, 'ACCEL_Z', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});
s_TEMP_C3898=struct('TEMP', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});
s_TEMP_C3892=struct('TEMP', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});
s_TEMP_L3572=struct('TEMP', {}, 'address', {}, 'dataType', {}, 'sensor_name', {}, 'timestamp', {});

i=1;j=1;k=1;m=1;n=1;p=1;x=1;z=1;

for a = 1:length(raw_data)
    
    cell = raw_data{a};
    
    if cell.dataType == "ECG"
        if cell.sensor_name == "C3898"
            s_ECG_C3898(i) = cell;
            i = i+1;
        elseif cell.sensor_name == "C3892"
            s_ECG_C3892(j) = cell;
            j = j+1;
        end
        
    elseif cell.dataType == "ACCEL"
        if cell.sensor_name == "C3898"
            s_ACCEL_C3898(k) = cell;
            k = k+1;
        elseif cell.sensor_name == "C3892"
            s_ACCEL_C3892(m) = cell;
            m = m+1;
        end
        
    elseif cell.dataType == "PPG"
        if cell.sensor_name == "L3572"
            s_PPG_L3572(n) = cell;
            n = n+1;
        end
    elseif cell.dataType == "Temp"
        if cell.sensor_name == "C3898"
            s_TEMP_C3898(p) = cell;
            p = p+1;
        elseif cell.sensor_name == "C3892"
            s_TEMP_C3892(x) = cell;
            x = x+1;
        elseif cell.sensor_name == "L3572"
            s_TEMP_L3572(z) = cell;
            z = z+1;
        end
    end
    
end


%% convert ECG to nldat

y = s_ECG_C3892.ECG;
pkg_length_ECG = length(y);

hold_ECG=zeros(pkg_length_ECG,length(s_ECG_C3892));
hold_time=zeros(pkg_length_ECG,length(s_ECG_C3892));
ECG_data1={s_ECG_C3892.ECG};
ECG_time1={s_ECG_C3892.timestamp};
i=1;
for t=1:length(s_ECG_C3892)
    if t == 1
        hold_ECG(:,i)=cell2mat(ECG_data1(1,t));
        hold_time(:,i)=cell2mat(ECG_time1(1,t));
        i = i+1;
    else
        if ~isequal(cell2mat(ECG_time1(1,t-1)), hold_time(t-1))
            if ~isequal(cell2mat(ECG_data1(1,t-1)), hold_ECG(t-1))
                hold_ECG(:,i)=cell2mat(ECG_data1(1,t));
                hold_time(:,i)=cell2mat(ECG_time1(1,t));
                i = i+1;
            else
                fprintf('ERROR: same data for different time points \n')
            end
        end
    end
end

hold_ECG=transpose(reshape(hold_ECG,1,[]));
hold_time=transpose(reshape(hold_time,1,[]));
hold_time=hold_time-hold_time(1,1);
nldat_ECG_C3892=nldat(hold_ECG);
set(nldat_ECG_C3892, 'DomainValues', hold_time, 'ChanNames', 'ECG', 'comment', ['ECG data from sensor 3892 ' description])
figure(1)
plot(nldat_ECG_C3892)
savefig(figure(1),[savepath, 'trial' num2str(ntrial), '_', descrip_path '_ECG3892'])

y = s_ECG_C3898.ECG;
pkg_length_ECG = length(y);

hold_ECG=zeros(pkg_length_ECG,length(s_ECG_C3898));
hold_time=zeros(pkg_length_ECG,length(s_ECG_C3898));
ECG_data1={s_ECG_C3898.ECG};
ECG_time1={s_ECG_C3898.timestamp};
i=1;
for t=1:length(s_ECG_C3898)
    if t == 1
        hold_ECG(:,i)=cell2mat(ECG_data1(1,t));
        hold_time(:,i)=cell2mat(ECG_time1(1,t));
        i = i+1;
    else
        if ~isequal(cell2mat(ECG_time1(1,t-1)), hold_time(t-1))
            if ~isequal(cell2mat(ECG_data1(1,t-1)), hold_ECG(t-1))
                hold_ECG(:,i)=cell2mat(ECG_data1(1,t));
                hold_time(:,i)=cell2mat(ECG_time1(1,t));
                i = i+1;
            else
                fprintf('ERROR: same data for different time points \n')
            end
        end
    end
end

hold_ECG=transpose(reshape(hold_ECG,1,[]));
hold_time=transpose(reshape(hold_time,1,[]));
hold_time=hold_time-hold_time(1,1);
nldat_ECG_C3898=nldat(hold_ECG);
set(nldat_ECG_C3898, 'DomainValues', hold_time, 'ChanNames', 'ECG', 'ChanUnits','amplitude', 'comment', ['ECG data from sensor 3898 ' description])
figure(2)
plot(nldat_ECG_C3898)
savefig(figure(2),[savepath, 'trial' num2str(ntrial), '_', descrip_path '_ECG3898'])




%% convert ACCEL to nldat

y = s_ACCEL_C3898.ACCEL_X;
pkg_length_ACCEL = length(y);

hold_ACCELX=zeros(pkg_length_ACCEL,length(s_ACCEL_C3898));
hold_ACCELY=zeros(pkg_length_ACCEL,length(s_ACCEL_C3898));
hold_ACCELZ=zeros(pkg_length_ACCEL,length(s_ACCEL_C3898));
hold_time=zeros(pkg_length_ACCEL,length(s_ACCEL_C3898));
ACCEL_dataX={s_ACCEL_C3898.ACCEL_X};
ACCEL_dataY={s_ACCEL_C3898.ACCEL_Y};
ACCEL_dataZ={s_ACCEL_C3898.ACCEL_Z};
ACCEL_time1={s_ACCEL_C3898.timestamp};
i=1;
for t=1:length(s_ACCEL_C3898)
     if t == 1
        hold_ACCELX(:,i)=cell2mat(ACCEL_dataX(1,t));
        hold_ACCELY(:,i)=cell2mat(ACCEL_dataY(1,t));
        hold_ACCELZ(:,i)=cell2mat(ACCEL_dataZ(1,t));
        hold_time(:,i)=cell2mat(ACCEL_time1(1,t));
        i = i+1;
    else
        if ~isequal(cell2mat(ACCEL_time1(1,t-1)), hold_time(t-1))
            if ~isequal(cell2mat(ACCEL_dataX(1,t-1)), hold_ACCELX(t-1)) && ~isequal(cell2mat(ACCEL_dataY(1,t-1)), hold_ACCELY(t-1)) && ~isequal(cell2mat(ACCEL_dataZ(1,t-1)), hold_ACCELZ(t-1))
                hold_ACCELX(:,i)=cell2mat(ACCEL_dataX(1,t));
                hold_ACCELY(:,i)=cell2mat(ACCEL_dataY(1,t));
                hold_ACCELZ(:,i)=cell2mat(ACCEL_dataZ(1,t));
                hold_time(:,i)=cell2mat(ACCEL_time1(1,t));
                i = i+1;
            else
                fprintf('ERROR: same data for different time points \n')
            end
        end
    end
end

hold_ACCELX=transpose(reshape(hold_ACCELX,1,[]));
hold_ACCELY=transpose(reshape(hold_ACCELY,1,[]));
hold_ACCELZ=transpose(reshape(hold_ACCELZ,1,[]));
hold_time=transpose(reshape(hold_time,1,[]));
hold_time=hold_time-hold_time(1,1);
nldat_ACCELX=nldat(hold_ACCELX);
nldat_ACCELY=nldat(hold_ACCELY);
nldat_ACCELZ=nldat(hold_ACCELZ);
nldat_temp = cat(2,nldat_ACCELX, nldat_ACCELY);
nldat_ACCEL_C3898 = cat(2,nldat_temp, nldat_ACCELZ);
set(nldat_ACCEL_C3898, 'DomainValues', hold_time, 'ChanNames', ["ACCEL X", "ACCEL Y", "ACCEL Z"], 'ChanUnits','amplitude', 'comment', ['Acceleration data from sensor C3898 ' description])
figure(3)
plot(nldat_ACCEL_C3898)
savefig(figure(3),[savepath, 'trial' num2str(ntrial), '_', descrip_path '_ACCELC3898'])


y = s_ACCEL_C3892.ACCEL_X;
pkg_length_ACCEL = length(y);

hold_ACCELX=zeros(pkg_length_ACCEL,length(s_ACCEL_C3892));
hold_ACCELY=zeros(pkg_length_ACCEL,length(s_ACCEL_C3892));
hold_ACCELZ=zeros(pkg_length_ACCEL,length(s_ACCEL_C3892));
hold_time=zeros(pkg_length_ACCEL,length(s_ACCEL_C3892));
ACCEL_dataX={s_ACCEL_C3892.ACCEL_X};
ACCEL_dataY={s_ACCEL_C3892.ACCEL_Y};
ACCEL_dataZ={s_ACCEL_C3892.ACCEL_Z};
ACCEL_time1={s_ACCEL_C3892.timestamp};
i=1;
for t=1:length(s_ACCEL_C3892)
     if t == 1
        hold_ACCELX(:,i)=cell2mat(ACCEL_dataX(1,t));
        hold_ACCELY(:,i)=cell2mat(ACCEL_dataY(1,t));
        hold_ACCELZ(:,i)=cell2mat(ACCEL_dataZ(1,t));
        hold_time(:,i)=cell2mat(ACCEL_time1(1,t));
        i = i+1;
    else
        if ~isequal(cell2mat(ACCEL_time1(1,t-1)), hold_time(t-1))
            if ~isequal(cell2mat(ACCEL_dataX(1,t-1)), hold_ACCELX(t-1)) && ~isequal(cell2mat(ACCEL_dataY(1,t-1)), hold_ACCELY(t-1)) && ~isequal(cell2mat(ACCEL_dataZ(1,t-1)), hold_ACCELZ(t-1))
                hold_ACCELX(:,i)=cell2mat(ACCEL_dataX(1,t));
                hold_ACCELY(:,i)=cell2mat(ACCEL_dataY(1,t));
                hold_ACCELZ(:,i)=cell2mat(ACCEL_dataZ(1,t));
                hold_time(:,i)=cell2mat(ACCEL_time1(1,t));
                i = i+1;
            else
                fprintf('ERROR: same data for different time points \n')
            end
        end
    end
end

hold_ACCELX=transpose(reshape(hold_ACCELX,1,[]));
hold_ACCELY=transpose(reshape(hold_ACCELY,1,[]));
hold_ACCELZ=transpose(reshape(hold_ACCELZ,1,[]));
hold_time=transpose(reshape(hold_time,1,[]));
hold_time=hold_time-hold_time(1,1);
nldat_ACCELX=nldat(hold_ACCELX);
nldat_ACCELY=nldat(hold_ACCELY);
nldat_ACCELZ=nldat(hold_ACCELZ);
nldat_temp = cat(2,nldat_ACCELX, nldat_ACCELY);
nldat_ACCEL_C3892 = cat(2,nldat_temp, nldat_ACCELZ);
set(nldat_ACCEL_C3892, 'DomainValues', hold_time, 'ChanNames', ["ACCEL X", "ACCEL Y", "ACCEL Z"], 'ChanUnits','amplitude', 'comment',['Acceleration data from sensor C3892 ' description])
figure(4)
plot(nldat_ACCEL_C3892)
savefig(figure(4),[savepath, 'trial' num2str(ntrial), '_', descrip_path '_ACCELC3892'])

%% convert PPG to nldat

y = s_PPG_L3572.PPG_RED;
pkg_length_PPG = length(y);

hold_PPGred=zeros(pkg_length_PPG,length(s_PPG_L3572));
hold_PPGir=zeros(pkg_length_PPG,length(s_PPG_L3572));
hold_time=zeros(pkg_length_PPG,length(s_PPG_L3572));
PPG_dataRED={s_PPG_L3572.PPG_RED};
PPG_dataIR={s_PPG_L3572.PPG_IR};
PPG_time1={s_PPG_L3572.timestamp};
i=1;

for t=1:length(s_PPG_L3572)
    if t == 1
        hold_PPGred(:,t)=cell2mat(PPG_dataRED(1,t));
        hold_PPGir(:,t)=cell2mat(PPG_dataIR(1,t));
        hold_time(:,t)=cell2mat(PPG_time1(1,t));
        i = i+1;
    else
        if ~isequal(cell2mat(PPG_time1(1,t-1)), hold_time(t-1))
            if ~isequal(cell2mat(PPG_dataRED(1,t-1)), hold_PPGred(t-1)) && ~isequal(cell2mat(PPG_dataIR(1,t-1)), hold_PPGir(t-1))
                hold_PPGred(:,i)=cell2mat(PPG_dataRED(1,t));
                hold_PPGir(:,i)=cell2mat(PPG_dataIR(1,t));
                hold_time(:,i)=cell2mat(PPG_time1(1,t));
                i = i+1;
            else
                fprintf('ERROR: same data for different time points \n')
            end
        end
    end
end

hold_PPGred=transpose(reshape(hold_PPGred,1,[]));
hold_PPGir=transpose(reshape(hold_PPGir,1,[]));
hold_time=transpose(reshape(hold_time,1,[]));
hold_time=hold_time-hold_time(1,1);
nldat_PPGred=nldat(hold_PPGred);
nldat_PPGir=nldat(hold_PPGir);
nldat_PPG_L3572 = cat(2,nldat_PPGred, nldat_PPGir);
set(nldat_PPG_L3572, 'DomainValues', hold_time, 'ChanNames', ["PPG RED" "PPG IR"], 'ChanUnits','amplitude', 'comment', ['PPG data from sensor L3572 ' description])
figure(5)
plot(nldat_PPG_L3572)
savefig(figure(5),[savepath, 'trial' num2str(ntrial), '_', descrip_path '_PPG'])

% should output some figures to show kearney
% should add the code to the dropbox idk how i am still not invited
% what are the units for the data and the time stamps

