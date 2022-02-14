%% IRF_HR v2

%% ==================
% function that 1. removes outliers from ACCEL data to account for the tapping
% 2. decimates ECG and ACCEL data to 50Hz
% 3. uses IRF to remove HR effects in ACCEL data

% function [ACCEL_output_dec,clean_ACCEL]=IRF_HR(ACCEL_output, ECG_input,ts)
% load data to estimate the IRF - use normal breathing trial

clear all
clc

addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/METRICS/')
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/Signal_Processing/')
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/CardioRespiratory_Analysis/')
baseDir = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/';
savepath = [baseDir, 'Export/figures_v6/'];
if ~exist(savepath, 'file')
    mkdir(savepath)
end
trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013","017", "018", "019", "020", "021", "022", "023", "024", "025"]; %
nTrials = length(trials);
directions = ["X", "Y", "Z"];
nDir = length(directions);
ts = 0.002;
d=10; ts_dec = d*ts;
IR_length = 0.4;
nLags = IR_length/ts_dec;

trainingTrial = '020';

load([baseDir, 'trials_data_nldat/ANNE_data_trial' trainingTrial '_raw'])

size = nldat_chest_ACCEL.dataSize;
time_ACCEL = 0:ts:ts*size(1)-ts;
ECG_input = nldat_chest_ECG;

ECG_input = interp1(ECG_input, time_ACCEL, 'linear');
set(ECG_input, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
ECG_input_dec = decimate(ECG_input, d);
set(ECG_input_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

for v = 1:nDir

    trainingDir = directions{v};
    ACCEL_output = nldat_chest_ACCEL(:,v);
    set(ACCEL_output, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
    ACCEL_output_dec = decimate(ACCEL_output, d);
    set(ACCEL_output_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    nldat_sys_dec = cat(2, ECG_input_dec, ACCEL_output_dec);
    set(nldat_sys_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    I_std.(trainingDir) = irf(nldat_sys_dec, 'nLags', nLags, 'nSides', 2);

end

%% try using one I on the other models to see if the model performance stays the same
vaf_specific = zeros(nTrials, nDir);
vaf_std_X = zeros(nTrials, nDir);
vaf_std_Y = zeros(nTrials, nDir);
vaf_std_Z = zeros(nTrials, nDir);
vaf_dirSpecific = zeros(nTrials, nDir);

for n=1:nTrials
    trial = trials{n};
    load([baseDir, 'trials_data_nldat/ANNE_data_trial' trial  '_raw'])

    size = nldat_chest_ACCEL.dataSize;
    time_ACCEL = 0:ts:ts*size(1)-ts;
    ECG_input = nldat_chest_ECG;

    ECG_input = interp1(ECG_input, time_ACCEL, 'linear');
    set(ECG_input, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
    ECG_input_dec = decimate(ECG_input, d);
    set(ECG_input_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

    for v = 1:nDir

        dir = directions{v};
        ACCEL_output = nldat_chest_ACCEL(:,v);
        set(ACCEL_output, 'domainIncr', ts, 'domainValues', NaN, 'domainStart', 0);
        ACCEL_output_dec = decimate(ACCEL_output, d);
        set(ACCEL_output_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);

        nldat_sys_dec = cat(2, ECG_input_dec, ACCEL_output_dec);
        set(nldat_sys_dec, 'domainIncr', ts_dec, 'domainValues', NaN, 'domainStart', 0);
        
        for a = 1:nDir
            IDir = directions{a};
            eval(['[~, vaf_std_' IDir '(n,v), ~] = nlid_resid(I_std.(IDir), nldat_sys_dec);']);
        end

        I = irf(nldat_sys_dec, 'nLags', nLags, 'nSides', 2);
        [~, vaf_specific(n,v), ~] = nlid_resid(I, nldat_sys_dec);

        [~, vaf_dirSpecific(n,v), ~] = nlid_resid(I_std.(dir), nldat_sys_dec);

    end

    % trial that applies direction specific curve to each direction still
    % trained with trial 17
    
end


close all
%%

mean_specific = mean(vaf_specific, "all"); std_specific = std(vaf_specific, [], 'all'); se_specific = std_specific/sqrt(27);
mean_dirSpecific = mean(vaf_dirSpecific, "all"); std_dirSpecific = std(vaf_dirSpecific, [], 'all'); se_dirSpecific = std_dirSpecific/sqrt(27);
mean_std_X = mean(vaf_std_X, "all"); std_std_X = std(vaf_std_X, [], 'all'); se_std_X = std_std_X/sqrt(27);
mean_std_Y = mean(vaf_std_Y, "all"); std_std_Y = std(vaf_std_Y, [], 'all'); se_std_Y = std_std_Y/sqrt(27);
mean_std_Z = mean(vaf_std_Z, "all"); std_std_Z = std(vaf_std_Z, [], 'all'); se_std_Z = std_std_Z/sqrt(27);

means = [mean_specific,mean_dirSpecific, mean_std_X, mean_std_Y, mean_std_Z];
se = [se_specific, se_dirSpecific, se_std_X, se_std_Y, se_std_Z];

x_labels = categorical(["trial specific", "direction specific" "standard_X", "standard_Y", "standard_Z"]);

figure()
scatter(x_labels, means, 'k', 'filled', 'marker', 's', 'SizeData', 100)
hold on
errorbar(x_labels,means, se, 'k', 'Marker', 'none', 'LineStyle', 'none');
ylabel("mean variance accounted for")
set(gca, 'FontSize',16, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');
title("Mean VAF using different IRF models - with all trials ")
savefig(gcf, [savepath, 'meanVAF_taps'])