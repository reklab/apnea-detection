%% mean_pk_freq_phasediff
% loads the features extracted from the FFT of each 20sec segment of each trial
%  these features are - frequency with highest amplitude, the amplitude at
%                       that frequency, the phase difference between the chest and the abdomen
%                       at that frequency
% determines the mean, standard deviation and standard error for each
% feature of each breathing type across all the trials
% generates a boxplot of all the features 

clc
clear all

trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013", "017", "018", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "030", "031", "032"];
Ntrials = length(trials);
directions = ["X", "Y", "Z"];
nDir = length(directions);

nb = ["001", "008", "011", "017", "020", "023","026", "030"];
vb = ["002", "009", "012", "018", "021", "024","027","031"];
ob = ["003", "010", "013", "019", "022", "025","028", "032"];

holds = [2,4,6,8];
normal = [1,3,5,7,9];

baseDir = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/segment_FFTfeatures/';

pk_norm_abd = 0;
pk_norm_chest = 0;
freq_norm_abd = 0;
freq_norm_chest = 0;
pk_vol_abd = 0;
pk_vol_chest = 0;
freq_vol_abd = 0;
freq_vol_chest = 0;
pk_obs_abd = 0;
pk_obs_chest = 0;
freq_obs_abd = 0;
freq_obs_chest = 0;

for n = 1:Ntrials

    ntrial = trials{n};

    if ismember(ntrial,["001","002","003","008","009","010"])
        ChestSensor = 'C3898'; AbdSensor = 'C3892'; DigitSensor = 'L3572';
    else
        ChestSensor = 'C3900'; AbdSensor = 'C3895'; DigitSensor = 'L3569';
    end

    load([baseDir 'spectrum_pks_phase_clean_' ntrial])

    if ismember(ntrial, nb)
        descrip_path ='normalBreathing'; description = 'normal breathing';
        if pk_norm_abd == 0
            pk_norm_abd = sensor_abd.pks;
            pk_norm_chest = sensor_chest.pks;
        else
            pk_norm_abd = cat(1,pk_norm_abd,sensor_abd.pks);
            pk_norm_chest = cat(1,pk_norm_chest,sensor_chest.pks);
        end
        if freq_norm_abd == 0
            freq_norm_abd = sensor_abd.freq;
            freq_norm_chest = sensor_chest.freq;
        else
            freq_norm_abd = cat(1,freq_norm_abd,sensor_abd.freq);
            freq_norm_chest = cat(1,freq_norm_chest,sensor_chest.freq);
        end

    elseif ismember(ntrial, vb)
        descrip_path ='intermittentBreathing_voluntary'; description = 'intermittent breathing - voluntary';
        if pk_vol_abd == 0
            pk_vol_abd = sensor_abd.pks(holds,:);
            pk_vol_chest = sensor_chest.pks(holds,:);
        else
            pk_vol_abd = cat(1,pk_vol_abd,sensor_abd.pks(holds,:));
            pk_vol_chest = cat(1,pk_vol_chest,sensor_chest.pks(holds,:));
        end

        if pk_norm_abd == 0
            pk_norm_abd = sensor_abd.pks(normal,:);
            pk_norm_chest = sensor_chest.pks(normal,:);
        else
            pk_norm_abd = cat(1,pk_norm_abd,sensor_abd.pks(normal,:));
            pk_norm_chest = cat(1,pk_norm_chest,sensor_chest.pks(normal,:));
        end

        if freq_vol_abd == 0
            freq_vol_abd = sensor_abd.freq(holds,:);
            freq_vol_chest = sensor_chest.freq(holds,:);
        else
            freq_vol_abd = cat(1,freq_vol_abd,sensor_abd.freq(holds,:));
            freq_vol_chest = cat(1,freq_vol_chest,sensor_chest.freq(holds,:));
        end
        if freq_norm_abd == 0
            freq_norm_abd = sensor_abd.freq(normal,:);
            freq_norm_chest = sensor_chest.freq(normal,:);
        else
            freq_norm_abd = cat(1,freq_norm_abd,sensor_abd.freq(normal,:));
            freq_norm_chest = cat(1,freq_norm_chest,sensor_chest.freq(normal,:));
        end

    elseif ismember(ntrial, ob)
        descrip_path ='intermittentBreathing_obstruction'; description = 'interittent breathing - obstruction';
        if pk_obs_abd == 0
            pk_obs_abd = sensor_abd.pks(holds,:);
            pk_obs_chest = sensor_chest.pks(holds,:);
        else
            pk_obs_abd = cat(1,pk_obs_abd,sensor_abd.pks(holds,:));
            pk_obs_chest = cat(1,pk_obs_chest,sensor_chest.pks(holds,:));
        end

        if pk_norm_abd == 0
            pk_norm_abd = sensor_abd.pks(normal,:);
            pk_norm_chest = sensor_chest.pks(normal,:);
        else
            pk_norm_abd = cat(1,pk_norm_abd,sensor_abd.pks(normal,:));
            pk_norm_chest = cat(1,pk_norm_chest,sensor_chest.pks(normal,:));
        end

        if freq_obs_abd == 0
            freq_obs_abd = sensor_abd.freq(holds,:);
            freq_obs_chest = sensor_chest.freq(holds,:);
        else
            freq_obs_abd = cat(1,freq_obs_abd,sensor_abd.freq(holds,:));
            freq_obs_chest = cat(1,freq_obs_chest,sensor_chest.freq(holds,:));
        end
        if freq_norm_abd == 0
            freq_norm_abd = sensor_abd.freq(normal,:);
            freq_norm_chest = sensor_chest.freq(normal,:);
        else
            freq_norm_abd = cat(1,freq_norm_abd,sensor_abd.freq(normal,:));
            freq_norm_chest = cat(1,freq_norm_chest,sensor_chest.freq(normal,:));
        end
    end

end

%% calculate the mean, standard deviation and standard error for the chest and abdomen of each breathing type 

nNorm = length(pk_norm_abd);
nHold = length(pk_vol_abd);
mean_normal_freq_chest = mean(freq_norm_chest,1); std_normal_freq_chest = std(freq_norm_chest); se_normal_freq_chest = std_normal_freq_chest/sqrt(nNorm);
mean_normal_freq_abd = mean(freq_norm_abd,1); std_normal_freq_abd = std(freq_norm_abd); se_normal_freq_abd = std_normal_freq_abd/sqrt(nNorm);

mean_vol_freq_chest = mean(freq_vol_chest,1); std_vol_freq_chest = std(freq_vol_chest); se_vol_freq_chest = std_vol_freq_chest/sqrt(nHold);
mean_vol_freq_abd = mean(freq_vol_abd,1); std_vol_freq_abd = std(freq_vol_abd); se_vol_freq_abd = std_vol_freq_abd/sqrt(nHold);

mean_obs_freq_chest = mean(freq_obs_chest,1); std_obs_freq_chest = std(freq_obs_chest); se_obs_freq_chest = std_obs_freq_chest/sqrt(nHold);
mean_obs_freq_abd = mean(freq_obs_abd,1); std_obs_freq_abd = std(freq_obs_abd); se_obs_freq_abd = std_obs_freq_abd/sqrt(nHold);

mean_normal_pk_chest = mean(pk_norm_chest,1); std_normal_pk_chest = std(pk_norm_chest); se_normal_pk_chest = std_normal_pk_chest/sqrt(nNorm);
mean_normal_pk_abd = mean(pk_norm_abd,1); std_normal_pk_abd = std(pk_norm_abd); se_normal_pk_abd = std_normal_pk_abd/sqrt(nNorm);

mean_vol_pk_chest = mean(pk_vol_chest,1); std_vol_pk_chest = std(pk_vol_chest); se_vol_pk_chest = std_vol_pk_chest/sqrt(nHold);
mean_vol_pk_abd = mean(pk_vol_abd,1); std_vol_pk_abd = std(pk_vol_abd); se_vol_pk_abd = std_vol_pk_abd/sqrt(nHold);

mean_obs_pk_chest = mean(pk_obs_chest,1); std_obs_pk_chest = std(pk_obs_chest); se_obs_pk_chest = std_obs_pk_chest/sqrt(nHold);
mean_obs_pk_abd = mean(pk_obs_abd,1); std_obs_pk_abd = std(pk_obs_abd); se_obs_pk_abd = std_obs_pk_abd/sqrt(nHold);

%% generate vectors contaning the means, standard deviations and standard errors for each breathing type 

mean_freqs_chest = [mean_normal_freq_chest, mean_vol_freq_chest, mean_obs_freq_chest];
mean_freqs_abd = [mean_normal_freq_abd, mean_vol_freq_abd, mean_obs_freq_abd];
stddevs_freqs_chest = [std_normal_freq_chest, std_vol_freq_chest, std_obs_freq_chest];
stddevs_freqs_abd = [std_normal_freq_abd, std_vol_freq_abd, std_obs_freq_abd];
se_freqs_chest = [se_normal_freq_chest, se_vol_freq_chest, se_obs_freq_chest];
se_freqs_abd = [se_normal_freq_abd, se_vol_freq_abd, se_obs_freq_abd];

mean_pks_chest = [mean_normal_pk_chest, mean_vol_pk_chest, mean_obs_pk_chest];
mean_pks_abd = [mean_normal_pk_abd, mean_vol_pk_abd, mean_obs_pk_abd];
stddevs_pks_chest = [std_normal_pk_chest, std_vol_pk_chest, std_obs_pk_chest];
stddevs_pks_abd = [std_normal_pk_abd, std_vol_pk_abd, std_obs_pk_abd];
se_pks_chest = [se_normal_pk_chest, se_vol_pk_chest, se_obs_pk_chest];
se_pks_abd = [se_normal_pk_abd, se_vol_pk_abd, se_obs_pk_abd];

%% call feature_boxplot_v2 to generate a boxplot to compare the means and standard errors

feature_boxplot_v2(mean_freqs_chest, se_freqs_chest, mean_pks_chest, se_pks_chest, baseDir, 'Chest')
feature_boxplot_v2(mean_freqs_abd, se_freqs_abd, mean_pks_abd, se_pks_abd, baseDir, 'Abdomen')

