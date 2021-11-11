%determine presence of time gaps in the signals

%%
function [gaps, interval]=data_gaps(nldat, savefigs, savepath)

time = get(nldat, "domainValues");
data_type = get(nldat, "chanNames");
t=nldat.comment{1};

if sum(size(data_type))~=2
    data_type = 'ACCEL';
    sensor_name=t(12:16);
else
    data_type = char(data_type{1});
    sensor_name=t(1:5);
end

%intervals between subsequent data points
time = sort(unique(time));
interval=round(diff(time),5);

%collect gaps that differ from the "normal" gap by more than 2%
gaps=interval(abs(interval-mode(interval))>0.02*mode(interval));

if savefigs
    figure()
    hist(gaps,20)
    title(sprintf('Gaps for %s sensor %s (normal gap size = %s)', data_type, sensor_name, num2str(mode(interval))))
    savefig([savepath, 'gap_hist_' data_type '_' sensor_name])
    close all 
end

W = tabulate(interval);
T  = array2table(W);
save([savepath, 'tabulated_gaps_' data_type '_' sensor_name], 'T')

end