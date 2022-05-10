%% save_FFTfeatures
% loads the nldat containing acceleration and ECG of each trial 
% segments each trial into 20s segments that correspond to a sepcific
% brething type 
% calls the fft_analysis function which determines the most prominent
% frequency, amplitude at that frequency and the phase difference between
% the chest and abdomen at that frequency
% saves these features for each segment of each trial in a structure

clear all
clc

addpath('.../Dropbox/AUREA_retrieved_v2/METRICS/')
addpath('.../Dropbox/AUREA_retrieved_v2/Signal_Processing/')
addpath('.../Dropbox/AUREA_retrieved_v2/CardioRespiratory_Analysis/')
baseDir = '.../Dropbox/ApnexDetection_Project/';

trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013", "017", "018", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "029", "030", "031", "032", "033"];
Ntrials = length(trials);
directions = ["X", "Y", "Z"];
nDir = length(directions);

nb = ["001", "008", "011", "017", "020", "023","026", "030"];
nb_m= ["029", "033"];
vb = ["002", "009", "012", "018", "021", "024","027","031"];
ob = ["003", "010", "013", "019", "022", "025","028", "032"];
blind= ["014", "015", "016"];

for n = 1:Ntrials

    ntrial = trials{n};
    load([baseDir, 'trials_data_nldat_v3/ANNE_data_trial' ntrial '_clean'])

    if ismember(ntrial,["001","002","003","008","009","010"])
        ChestSensor = 'C3898'; AbdSensor = 'C3892'; DigitSensor = 'L3572';
    else
        ChestSensor = 'C3900'; AbdSensor = 'C3895'; DigitSensor = 'L3569';
    end

    if ismember(ntrial, nb)
        descrip_path ='normalBreathing'; description = 'normal breathing';
    elseif ismember(ntrial, vb)
        descrip_path ='intermittentBreathing_voluntary'; description = 'intermittent breathing - voluntary';
    elseif ismember(ntrial, ob)
        descrip_path ='intermittentBreathing_obstruction'; description = 'interittent breathing - obstruction';
    elseif ismember(ntrial, nb_m)
        descrip_path ='normalBreathing_movement'; description = 'normal breathing -movement ';
    else
        descrip_path ='blindTest'; description = 'blind test';
    end

    filename = string([baseDir ntrial '_' descrip_path '.json']);
    savepath = '.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/segment_FFTfeatures/';
    if ~exist(savepath, 'file')
        mkdir(savepath)
    end

    dataSize = ACCEL_abd_clean.dataSize;
    sampleLength  = dataSize(1);
    time = 0:1/50:sampleLength;
    time=time';

    T_start = [1, find(time==22.5), find(time==42.5), find(time==62.5), find(time==82.5), find(time==102.5), find(time==122.5), find(time==142.5), find(time==162.5)];
    T_stop = [find(time==17.5), find(time==37.5), find(time==57.5), find(time==77.5), find(time==97.5), find(time==117.5), find(time==137.5), find(time==157.5), sampleLength];
    nSeg = length(T_start);

    for t = 1:nSeg
        eval(['seg_chest_ACCEL.seg' num2str(t) '=ACCEL_abd_clean(T_start(' num2str(t) '):T_stop(' num2str(t) '),:,1);'])
        eval(['seg_abd_ACCEL.seg' num2str(t) '=ACCEL_chest_clean(T_start(' num2str(t) '):T_stop(' num2str(t) '),:,1);'])
    end

    savefigs = 0;
    for i = 1:nSeg
        segment=append('seg', num2str(i));
        [freq_1, freq_2, phasediff_1, phasediff_2, pk_1, pk_2] = fft_analysis(seg_chest_ACCEL.(segment), seg_abd_ACCEL.(segment), ntrial, segment, savepath, savefigs);

        sensor_chest.freq(i,:) = freq_1;
        sensor_chest.phasediff(i,:) = phasediff_1;
        sensor_chest.pks(i,:) = pk_1;
        sensor_abd.freq(i,:) = freq_2;
        sensor_abd.phasediff(i,:) = phasediff_2;
        sensor_abd.pks(i,:) = pk_2;

    end

    save([savepath 'spectrum_pks_phase_clean_' ntrial], 'sensor_chest', 'sensor_abd')

    
end



