
% turn ID_array into an eseq
clc
clear all 

baseDir = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/';

trials = ["001", "002", "003", "017", "018", "019"];
Ntrials = length(trials);
directions = ["X", "Y", "Z"];
nDir = length(directions);

nb = ["001", "017"];
vb = ["002", "018"];
ob = ["003", "019"];

savepath = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/';
if ~exist(savepath, 'file')
    mkdir(savepath)
end

fs_d = 50;

for n = 1:Ntrials

    ntrial = trials{n};
    load([baseDir, 'trials_data_nldat_v3/ANNE_data_trial' ntrial '_clean'])

    if ismember(ntrial,["001","002","003"])
        ChestSensor = 'C3898'; AbdSensor = 'C3892'; DigitSensor = 'L3572';
        startN_idx = [1, 42.5, 82.5, 122.5, 162.5].*fs_d;
        startH_idx = [22.5; 62.5; 102.5; 142.5].*fs_d;
        stopH_idx = [37.5, 77.5, 117.5, 157.5].*fs_d;
        stopN_idx = [17.5, 57.5, 97.5, 137.5,180].*fs_d;
        tapStatus = 'taps';
    else
        ChestSensor = 'C3900'; AbdSensor = 'C3895'; DigitSensor = 'L3569';
        startN_idx = [1, 40, 80, 120, 160].*fs_d;
        startH_idx = [20; 60; 100; 140].*fs_d;
        stopN_idx = [19.98, 59.98, 99.98, 139.98, 180].*fs_d;
        stopH_idx = [39.98, 79.98, 119.98, 159.98].*fs_d;
        tapStatus = 'noTaps';
    end


    e_trial = eseq;

    if ismember(ntrial, nb)
        descrip_path ='normalBreathing'; description = 'normal breathing';
        e_trial.startIdx = 1;
        e_trial.endIdx = 180*fs_d;
        e_trial(1,1).type='N';
        e_trial(1,1).domainIncr = 1/fs_d;

    else
        if ismember(ntrial, vb)
            descrip_path ='intermittentBreathing_voluntary'; description = 'intermittent breathing - voluntary';
            I = "V";
        elseif ismember(ntrial, ob)
            descrip_path ='intermittentBreathing_obstruction'; description = 'interittent breathing - obstruction';
            I = "O";
        else
            error('Unknown trial type')
        end

        j=1;h=1;
        for i = 1:2:2*length(stopN_idx)

            e_trial(i,1).startIdx=startN_idx(j);
            e_trial(i,1).endIdx=stopN_idx(j);
            e_trial(i,1).type='N';
            e_trial(i,1).domainIncr = 1/fs_d;
            j = j+1;

            if i > 8
                break
            else
                e_trial(i+1,1).startIdx=startH_idx(h);
                e_trial(i+1,1).endIdx=stopH_idx(h);
                e_trial(i+1,1).type= I;
                e_trial(i+1,1).domainIncr = 1/fs_d;
                h = h+1;
            end
        end
    end

    save([savepath, 'eseq_' descrip_path '_' tapStatus], 'e_trial')
end

