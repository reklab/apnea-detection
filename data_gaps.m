time_C3898 = get(nldat_C3898_ACCEL, "domainValues");
time_C3892 = get(nldat_C3892_ACCEL, "domainValues");
% time_L3572 = get(nldat_L3572_Temp, "domainValues");

%intervals between subsequent data points
time_C3898 = sort(unique(time_C3898));
interval_C3898=round(diff(time_C3898),5);

time_C3892 = sort(unique(time_C3892));
interval_C3892=round(diff(time_C3892),5);

% time_L3572 = sort(unique(time_L3572));
% interval_L3572=diff(time_L3572);

%collect gaps that differ from the "normal" gap by more than 2%
gaps_C3898=interval_C3898(abs(interval_C3898-mode(interval_C3898))>0.02*mode(interval_C3898));
gaps_C3892=interval_C3892(abs(interval_C3892-mode(interval_C3892))>0.02*mode(interval_C3892));
% gaps_L3572=interval_L3572(abs(interval_L3572-mode(interval_L3572))>0.02*mode(interval_L3572));

figure()
hist(gaps_C3898)
title(sprintf('Gaps for ACCEL sensor C3898 (normal gap size = %s)', num2str(mode(interval_C3898))))

figure()
hist(gaps_C3892)
title(sprintf('Gaps for ACCEL sensor C3892 (normal gap size = %s)', num2str(mode(interval_C3892))))

% figure()
% hist(gaps_L3572)
% title('Gaps for temperature sensor L3572');