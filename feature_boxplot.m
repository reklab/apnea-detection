%% feature_boxplot_v2
% function is called by mean_freq_pk_phasediff
% generates a boxplot of the frequency and amplitude features 

function feature_boxplot_v2(mean_freqs, se_freqs, mean_pks, se_pks,savepath, sensor)

directions = ["X", "Y", "Z"];
i=1;
for v = 1:length(directions)

    dir = directions{v};

    mean_freq.(dir) = mean_freqs([i,i+3,i+6]);
    mean_amp.(dir) = mean_pks([i,i+3,i+6]);
    
    se_freq.(dir) = se_freqs([i,i+3,i+6]);
    se_amp.(dir) = se_pks([i,i+3,i+6]);
    i = i+1;
end
%% individual boxplots for each each feature and each direction 
x_labels = categorical(["normal", "voluntary", "obstructive"]);
ftsz =14;
datasz = 150;
figure('position', [ 1         194        1440         800]);

i = 1;
for v = 1:length(directions)

    dir = directions{v};
    ax1 = subplot(3,2,i);
    scatter(x_labels, mean_freq.(dir), 'k', 'filled', 'marker', 's', 'SizeData', datasz)
    hold on
    errorbar(x_labels,mean_freq.(dir), se_freq.(dir), 'k', 'Marker', 'none', 'LineStyle', 'none');
    if i ==1
        title ([ sensor ': Peak frequency in direction ' dir]);
    else 
        title ([ 'Peak frequency in direction ' dir]);
    end
    ylabel ('Mean Across trials');
    set(ax1, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');
    if i>=4
            xlabel ('Breathing Type');
    end

    ax2 = subplot(3,2,i+1);
    scatter(x_labels, mean_amp.(dir), 'k', 'filled', 'marker', 's', 'SizeData', datasz)
    hold on
    errorbar(x_labels, mean_amp.(dir), se_amp.(dir), 'k', 'Marker', 'none', 'LineStyle', 'none');
    if i == 1
        title ([sensor ': Peak amplitude in direction ' dir]);
    else
        title (['Peak amplitude in direction ' dir]);
    end
    ylabel ('Mean Across trials');
    set(ax2, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');
    if i>=4
            xlabel ('Breathing Type');
    end

    i = i+2;
end

savefig(gcf, [savepath, 'boxplots_meanfreq_' sensor])

%% one boxplot with features compiled from all directions

x_labels = categorical(["X normal", "X voluntary", "X obstructive", "Y normal", "Y voluntary", "Y obstructive", "Z normal", "Z voluntary", "Z obstructive"]);
ftsz =16;
datasz = 150;
figure('position', [ 1         194        1440         800]);

ax1 = subplot(211);
scatter(x_labels, mean_freqs, 'k', 'filled', 'marker', 's', 'SizeData', datasz)
hold on
errorbar(x_labels,mean_freqs, se_freqs, 'k', 'Marker', 'none', 'LineStyle', 'none');
title ([sensor ': Peak frequency in direction']);
ylabel ('Mean Across trials');
set(ax1, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');

ax2 = subplot(212);
scatter(x_labels, mean_pks, 'k', 'filled', 'marker', 's', 'SizeData', datasz)
hold on
errorbar(x_labels, mean_pks, se_pks, 'k', 'Marker', 'none', 'LineStyle', 'none');
title ('Peak amplitude in direction');
ylabel ('Mean Across trials');
set(ax2, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');


savefig(gcf, [savepath, 'boxplot_meanfreq_' sensor '_singleplot'])

end