
function feature_boxplot(mean_freqs, se_freqs, mean_pks, se_pks, mean_phasediff, se_phasediff, savepath, sensor)

directions = ["X", "Y", "Z"];
i=1;
for v = 1:length(directions)

    dir = directions{v};

    mean_freq.(dir) = mean_freqs([i,i+3,i+6]);
    mean_amp.(dir) = mean_pks([i,i+3,i+6]);
    mean_phzdiff.(dir) = mean_phasediff([i,i+3,i+6]);
    
    se_freq.(dir) = se_freqs([i,i+3,i+6]);
    se_amp.(dir) = se_pks([i,i+3,i+6]);
    se_phzdiff.(dir) = se_phasediff([i,i+3,i+6]);
    i = i+1;
end
%%
x_labels = categorical(["normal", "voluntary", "obstructive"]);
ftsz =14;
datasz = 150;
figure('position', [ 1         194        1440         800]);

i = 1;
for v = 1:length(directions)

    dir = directions{v};
    ax1 = subplot(3,3,i);
    scatter(x_labels, mean_freq.(dir), 'k', 'filled', 'marker', 's', 'SizeData', datasz)
    hold on
    errorbar(x_labels,mean_freq.(dir), se_freq.(dir), 'k', 'Marker', 'none', 'LineStyle', 'none');
    title ([ sensor ': Peak frequency in direction ' dir]);
    % xlabel ('Breathing Type and Direction');
    ylabel ('Mean Across trials');
    % ylim([0,3])
    set(ax1, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');
    if i>6
            xlabel ('Breathing Type');
    end

    ax2 = subplot(3,3,i+1);
    scatter(x_labels, mean_amp.(dir), 'k', 'filled', 'marker', 's', 'SizeData', datasz)
    hold on
    errorbar(x_labels, mean_amp.(dir), se_amp.(dir), 'k', 'Marker', 'none', 'LineStyle', 'none');
    title (['Peak amplitude in direction ' dir]);
    % xlabel ('Breathing Type and Direction');
    ylabel ('Mean Across trials');
    set(ax2, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');
    if i>6
            xlabel ('Breathing Type');
    end

    ax3 = subplot(3,3,i+2);
    scatter(x_labels, mean_phzdiff.(dir), 'k', 'filled', 'marker', 's', 'SizeData', datasz)
    hold on
    errorbar(x_labels, mean_phzdiff.(dir), se_phzdiff.(dir), 'k', 'Marker', 'none', 'LineStyle', 'none');
    title (['Phase difference at peak in direction ' dir]);
    ylabel ('Mean Across trials');
    set(ax3, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');
    if i>6
            xlabel ('Breathing Type');
    end

    i = i+3;
end

savefig(gcf, [savepath, 'boxplots_meanfreq_' sensor])

%% one big boxplot

x_labels = categorical(["X normal", "X voluntary", "X obstructive", "Y normal", "Y voluntary", "Y obstructive", "Z normal", "Z voluntary", "Z obstructive"]);
ftsz =16;
datasz = 150;
figure('position', [ 1         194        1440         800]);

ax1 = subplot(311);
scatter(x_labels, mean_freqs, 'k', 'filled', 'marker', 's', 'SizeData', datasz)
hold on
errorbar(x_labels,mean_freqs, se_freqs, 'k', 'Marker', 'none', 'LineStyle', 'none');
title ([sensor ': Peak frequency in direction']);
% xlabel ('Breathing Type and Direction');
ylabel ('Mean Across trials');
% ylim([0,3])
set(ax1, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');

ax2 = subplot(312);
scatter(x_labels, mean_pks, 'k', 'filled', 'marker', 's', 'SizeData', datasz)
hold on
errorbar(x_labels, mean_pks, se_pks, 'k', 'Marker', 'none', 'LineStyle', 'none');
title ('Peak amplitude in direction');
% xlabel ('Breathing Type and Direction');
ylabel ('Mean Across trials');
set(ax2, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');

ax3 = subplot(313);
scatter(x_labels, mean_phasediff, 'k', 'filled', 'marker', 's', 'SizeData', datasz)
hold on
errorbar(x_labels, mean_phasediff, se_phasediff, 'k', 'Marker', 'none', 'LineStyle', 'none');
title ('Phase difference at peak in direction');
xlabel ('Breathing Type');
ylabel ('Mean Across trials');
set(ax3, 'FontSize',ftsz, 'XGrid', 'on', 'YGrid', 'on', 'GridLineStyle', '--', 'FontWeight', 'bold');

savefig(gcf, [savepath, 'boxplot_meanfreq_' sensor '_singleplot'])

end