%determine presence of time gaps in the signals

%%
function [gaps_C3892, gaps_C3898, interval_C3892, interval_C3898]=data_gaps(nldat_C3898, nldat_C3892,nldat_L3572)    

time_C3898 = get(nldat_C3898, "domainValues");
name_C3898 = get(nldat_C3898, "chanNames");
if sum(size(name_C3898))~=2
    name_C3898 = 'ACCEL';
else
    name_C3898 = char(name_C3898{1});
end

time_C3892 = get(nldat_C3892, "domainValues");
name_C3892 = get(nldat_C3892, "chanNames");
if sum(size(name_C3892))~=2
    name_C3892 = 'ACCEL';
else
    name_C3892 = char(name_C3892{1});
end

time_L3572 = get(nldat_L3572, "domainValues");
name_L3572 = get(nldat_L3572, "chanNames");
if sum(size(name_L3572))~=2
    name_L3572 = 'ACCEL';
else
    name_L3572 = char(name_L3572{1});
end

%intervals between subsequent data points
time_C3898 = sort(unique(time_C3898));
interval_C3898=round(diff(time_C3898),5);

time_C3892 = sort(unique(time_C3892));
interval_C3892=round(diff(time_C3892),5);

time_L3572 = sort(unique(time_L3572));
interval_L3572=diff(time_L3572);

%collect gaps that differ from the "normal" gap by more than 2%
gaps_C3898=interval_C3898(abs(interval_C3898-mode(interval_C3898))>0.02*mode(interval_C3898));
gaps_C3892=interval_C3892(abs(interval_C3892-mode(interval_C3892))>0.02*mode(interval_C3892));
gaps_L3572=interval_L3572(abs(interval_L3572-mode(interval_L3572))>0.02*mode(interval_L3572));

figure()
hist(gaps_C3898,20)
title(sprintf('Gaps for %s sensor C3898 (normal gap size = %s)', name_C3898, num2str(mode(interval_C3898))))
tabulate(interval_C3898)

figure()
hist(gaps_C3892,20)
title(sprintf('Gaps for %s sensor C3892 (normal gap size = %s)', name_C3892, num2str(mode(interval_C3892))))
tabulate(interval_C3892)

figure()
hist(gaps_L3572,20)
title(sprintf('Gaps for % sensor L3572 (normal gap size = %s)', name_L3572, num2str(mode(interval_L3572))))
tabulate(interval_L3572)