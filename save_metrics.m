%% Analysis 4: call filtBankRespir with N = 251
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/METRICS/')
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/Signal_Processing/')
addpath('/Users/lauracarlton/Dropbox/AUREA_retrieved_v2/CardioRespiratory_Analysis/')
baseDir = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/';

trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013", "014", "015", "017", "018", "019", "020", "021", "022", "023", "024", "025"];
Ntrials = length(trials);
directions = ["X", "Y", "Z"];
nDir = length(directions);

for n = 1:6 %:Ntrials

    ntrial = trials{n};
    load([baseDir, 'trials_data_nldat/ANNE_data_trial' ntrial])

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
        descrip_path ='intermittentBreathing_obstruction'; description = 'interittent breathing - obstruction';
    else
        error('Unknown trial type')
    end

    filename = string([baseDir ntrial '_' descrip_path '.json']);
    savepath = ['/Users/lauracarlton/Dropbox/ApnexDetection_Project/trials_data_nldat/'];
    if ~exist(savepath, 'file')
        mkdir(savepath)
    end

    N=251;
    Nb = 101;
    Nmu1 = 101;
    Navg = 21;
    Fs = 50;

    for v = 1:nDir
        dir = directions{v};
        data_chest = nldat_chest_ACCEL_clean.dataSet;
        Z_chest = data_chest(:,v);
        data_abd = nldat_abd_ACCEL_clean.dataSet;
        Z_abd = data_abd(:,v);

        [stat.TotPWR_RR_A.(dir),stat.TotPWR_MV_A.(dir),stat.MaxPWR_MV_A.(dir),stat.MaxPWR_RR_A.(dir),stat.FMAX_A.(dir),stat.FMAXi_A.(dir)] = filtBankRespir(Z_chest,N,Fs);
        [stat.TotPWR_RR_C.(dir),stat.TotPWR_MV_C.(dir),stat.MaxPWR_MV_C.(dir),stat.MaxPWR_RR_C.(dir),stat.FMAX_C.(dir),stat.FMAXi_C.(dir)] = filtBankRespir(Z_abd,N,Fs);

        [stat.PHI.(dir),stat.FMAXi_ABD.(dir)] = asynchStat(Z_chest,Z_abd,N,Fs);

        [stat.BRC.(dir),stat.BAB.(dir),stat.BSU.(dir),stat.BDI.(dir),stat.BPH.(dir)] = breathStat(Z_chest,Z_abd,Nb,Nmu1,Navg,Fs);

    end

    save([savepath 'features_stats_trial' ntrial], 'stat')
end




