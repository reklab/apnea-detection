function find_phase(nldat_accel1, nldat_accel2, ntrial, seg, savepath)
% nldat_accel1 = nldat_C3898_ACCEL;
% nldat_accel2 = nldat_C3898_ACCEL;

time1 = nldat_accel1.domainValues;
ts = time1(2) - time1(1);
sampleLength = time1(end);

time = time1(1):ts:sampleLength;

nldat_accel1 = interp1(nldat_accel1, time, 'linear');   nldat_accel1 = detrend(nldat_accel1, 'linear');
set(nldat_accel1, 'domainValues', NaN, 'domainIncr', ts);
nldat_accel2 = interp1(nldat_accel2, time, 'linear');   nldat_accel2 = detrend(nldat_accel2, 'linear');
set(nldat_accel2, 'domainValues', NaN, 'domainIncr', ts);

names = get(nldat_accel1, "chanNames");
nChans = length(names);

fft_accel1 = fft(nldat_accel1);
fft_accel2 = fft(nldat_accel2);

nChans = 3;
directions = ["X", "Y", "Z"];
figure(1)
figure(2)
for v = 1:nChans
    dir = directions{v};
    phase_accel1 = phase(fft_accel1(:,v));  
    phase_accel2 = phase(fft_accel2(:,v));
    phase_incr = phase_accel1.domainIncr;
    figure(1)
    ax1 = subplot(nChans,1,v);
    plot(phase_accel1)
    hold on 
    plot(phase_accel2)
    title(['Phase for both sensors in the ' dir ' direction'])
    ax1.FontSize = 16;

    phase_diff(:,v) = phase_accel1.dataSet{:,v}-phase_accel2.dataSet{:,v};
    nldat_temp = nldat(phase_diff(:,v));

    if v > 1
        nldat_phasediff=cat(2, nldat_phasediff, nldat_temp);
    else
        nldat_phasediff = nldat_temp;
    end
end
disp_names = {" X", " Y", " Z"};

set(nldat_phasediff, 'domainIncr', phase_incr, 'domainValues', NaN, 'chanNames', disp_names, 'comment', ['phase difference'])


figure(2)
plot(nldat_phasediff)
set(figure(1), 'Units', 'normalized', 'outerposition', [0 0 1 1])
set(figure(2), 'Units', 'normalized', 'outerposition', [0 0 1 1])
savefig(figure(1), [savepath, 'phase_' ntrial '_' seg])
savefig(figure(2), [savepath, 'phase_diff' ntrial '_' seg])


close all 

%% using a sliding window
% 
% w = 6;
% L = length(time);
% accel1 = nldat_accel1.dataSet;
% accel2 = nldat_accel2.dataSet;
% 
% for i = 1:L-w+1
%     datawin(i,:) = i:i+w-1;
%     
%     ft_accel1_seg(i,:,:) = fft(accel1(datawin(i,:),:));
%     ft_accel2_seg(i,:,:) = fft(accel2(datawin(i,:),:));
%     
% end
% 
% ft_accel1_sw = mean(ft_accel1_seg,2);
% ft_accel2_sw = mean(ft_accel2_seg,2);
%     
% ft_accel1_sw = squeeze(ft_accel1_sw);
% ft_accel2_sw = squeeze(ft_accel2_sw);
% 
% nldat(ft_accel1_sw);nldat_fft_aceel1 = phase_accel1_sw = phase(ft_accel1_sw);
% phase_accel2_sw = phase(ft_accel2_sw);
end