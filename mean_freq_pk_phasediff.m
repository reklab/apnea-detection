clc
clear all

data = 'clean';

ntrial = '009';
baseDir1 = ['/Users/lauracarlton/Dropbox/ApnexDetection_Project/Export/figures_v4/' ntrial '/'];
load([baseDir1 'spectrum_pks_phase_' data])

sensor_C3898_009 = sensor_C3898;
sensor_C3892_009 = sensor_C3892;

ntrial = '010';
baseDir2 = ['/Users/lauracarlton/Dropbox/ApnexDetection_Project/Export/figures_v4/' ntrial '/'];
load([baseDir2 'spectrum_pks_phase_' data])

savepath = '/Users/lauracarlton/Dropbox/ApnexDetection_Project/Export/figures_v4/';

sensor_C3898_010 = sensor_C3898;
sensor_C3892_010 = sensor_C3892;

normal = [1 3 5 7 9];
obst = [2 4 6 8];
vol = [2 4 6 8];

freq_009.Chest = sensor_C3898_009.freq;
phasediff_009.Chest = sensor_C3898_009.phasediff;
pk_009.Chest = sensor_C3898_009.pks;
freq_010.Chest = sensor_C3898_010.freq;
phasediff_010.Chest = sensor_C3898_010.phasediff;
pk_010.Chest = sensor_C3898_010.pks;

freq_009.Abdomen = sensor_C3892_009.freq;
phasediff_009.Abdomen = sensor_C3892_009.phasediff;
pk_009.Abdomen = sensor_C3892_009.pks;
freq_010.Abdomen = sensor_C3892_010.freq;
phasediff_010.Abdomen = sensor_C3892_010.phasediff;
pk_010.Abdomen = sensor_C3892_010.pks;

sensors = ["Chest", "Abdomen"];
%%
for s = 1:length(sensors)

    ssr = sensors{s};

    freq_normal9 = freq_009.(ssr)(normal,:);
    freq_normal10 = freq_010.(ssr)(normal,:);
    freq_normal.(ssr) = cat(1, freq_normal9, freq_normal10);
    phasediff9 = phasediff_009.(ssr)(normal,:);
    phasediff10 = phasediff_010.(ssr)(normal,:);
    phasediff_normal.(ssr) = cat(1, phasediff9, phasediff10);
    pk_normal9 = pk_009.(ssr)(normal,:);
    pk_normal10 = pk_010.(ssr)(normal,:);
    pk_normal.(ssr) = cat(1, pk_normal9, pk_normal10);

    mean_normal_freq.(ssr) = mean(freq_normal.(ssr),1); std_normal_freq = std(freq_normal.(ssr)); se_normal_freq.(ssr) = std_normal_freq/sqrt(10);
    mean_normal_phasediff.(ssr) = mean(phasediff_normal.(ssr),1); std_normal_phasediff = std(phasediff_normal.(ssr)); se_normal_phasediff.(ssr) = std_normal_phasediff/sqrt(10);
    mean_normal_pk.(ssr) = mean(pk_normal.(ssr),1); std_normal_pk = std(pk_normal.(ssr)); se_normal_pk.(ssr) = std_normal_pk/sqrt(10);

    freq_vol9 = freq_009.(ssr)(vol,:);
    freq_obst10 = freq_010.(ssr)(obst,:);

    phasediff9 = phasediff_009.(ssr)(vol,:);
    phasediff10 = phasediff_010.(ssr)(obst,:);

    pk_vol9 = pk_009.(ssr)(vol,:);
    pk_obst10 = pk_010.(ssr)(obst,:);

    mean_vol_freq.(ssr) = mean(freq_vol9,1); std_vol_freq = std(freq_vol9); se_vol_freq.(ssr) = std_vol_freq/sqrt(5);
    mean_vol_phasediff.(ssr) = mean(phasediff9,1); std_vol_phasediff = std(phasediff9); se_vol_phasediff.(ssr) = std_vol_phasediff/sqrt(5);
    mean_vol_pk.(ssr) = mean(pk_vol9,1); std_vol_pk = std(pk_vol9); se_vol_pk.(ssr) = std_vol_pk/sqrt(5);

    mean_obst_freq.(ssr) = mean(freq_obst10,1); std_obst_freq= std(freq_obst10); se_obst_freq.(ssr) = std_obst_freq/sqrt(5);
    mean_obst_phasediff.(ssr) = mean(phasediff10,1); std_obst_phasediff = std(phasediff10); se_obst_phasediff.(ssr) = std_obst_phasediff/sqrt(5);
    mean_obst_pk.(ssr) = mean(pk_obst10,1); std_obst_pk = std(pk_obst10); se_obst_pk.(ssr) = std_obst_pk/sqrt(5);

    mean_freqs = [mean_normal_freq.(ssr), mean_vol_freq.(ssr), mean_obst_freq.(ssr)];
    stddevs_freqs = [std_normal_freq, std_vol_freq, std_obst_freq];
    se_freqs = [se_normal_freq.(ssr), se_vol_freq.(ssr), se_obst_freq.(ssr)];
    mean_pks = [mean_normal_pk.(ssr), mean_vol_pk.(ssr), mean_obst_pk.(ssr)];
    stddevs_pks = [std_normal_pk, std_vol_pk, std_obst_pk];
    se_pks = [se_normal_pk.(ssr), se_vol_pk.(ssr), se_obst_pk.(ssr)];
    mean_phasediff = [mean_normal_phasediff.(ssr), mean_vol_phasediff.(ssr), mean_obst_phasediff.(ssr)];
    stddevs_phasediff = [std_normal_phasediff, std_vol_phasediff, std_obst_phasediff];
    se_phasediff = [se_normal_phasediff.(ssr), se_vol_phasediff.(ssr), se_obst_phasediff.(ssr)];

%     feature_boxplot(mean_freqs, se_freqs, mean_pks, se_pks, mean_phasediff, se_phasediff, savepath, ssr)
    %% make 3D plot
    directions = ["X", "Y", "Z"];

    for v = 1:length(directions)
        dir = directions{v};
        figure('position', [326,155,774,611]);
        scatter3(freq_normal.(ssr)(:,v), pk_normal.(ssr)(:,v), phasediff_normal.(ssr)(:,v), 50, 'filled', 'g')
        hold on
        scatter3(freq_vol9(:,v), pk_vol9(:,v), phasediff9(:,v), 50, 'filled', 'b')
        hold on
        scatter3(freq_obst10(:,v), pk_obst10(:,v), phasediff10(:,v), 50, 'filled', 'r')
        xlabel('Peak frequency')
        ylabel('Peak amplitude')
        zlabel('Phase difference')
        title([ssr ': Features for different breathing types in the ' dir ' direction'])
        legend(["NB", "VBH", "OBH"])
        set(gca, 'FontSize', 20)

        savefig(gcf, [savepath, '3D_scatter_fts_' dir '_' ssr])

    end
end
