
% look at features on range of 0.25-0.35 Hz
% need to fft results from fft_analysis
% isolate segment thats 0.25-0.35
% looks at max frequency, amplitude and phase difference at that point 

function [freq_a, freq_b, phasediff_a, phasediff_b, pk_a, pk_b] = freq_band_analysis(nldat_accel1, nldat_accel2, ntrial,seg, savepath, save_figs)

% nldat_accel1 = nldat_chest_ACCEL_clean.seg1;
% nldat_accel2 = nldat_abd_ACCEL_clean.seg1;

ts = get(nldat_accel1, "domainIncr");
names = get(nldat_accel1, "chanNames");
nChans = length(names);
directions = ["X", "Y", "Z"];

fft_accel1 = fft(nldat_accel1);
fft_accel2 = fft(nldat_accel2);
L = length(fft_accel1.dataSet);

fft_accel1.dataSet = fft_accel1.dataSet/L;
fft_accel2.dataSet = fft_accel2.dataSet/L;

incr = fft_accel1.domainIncr;

fft_mag_accel1 = abs(fft_accel1);
fft_mag_accel2 = abs(fft_accel2);

mag_names = {"Amplitude X", "Amplitude Y", "Amplitude Z"};
set(fft_mag_accel1, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', mag_names, 'comment', "magnitude accel data")
set(fft_mag_accel2, 'domainIncr', incr, 'domainName', "Frequency (Hz)",'chanNames', mag_names, 'comment', "magnitude accel data")


%% generate phase difference 

phase_diff = zeros(length(fft_accel1.dataSet), nChans);
for v = 1:nChans
    phase_accel1_temp = angle(fft_accel1(:,v));
    phase_accel2_temp = angle(fft_accel2(:,v));

    phase_diff(:,v) = phase_accel1_temp.dataSet{:,v}-phase_accel2_temp.dataSet{:,v};
    nldat_temp = nldat(phase_diff(:,v));

    if v > 1
        nldat_phasediff=cat(2, nldat_phasediff, nldat_temp);
        phase_accel1 = cat(2, phase_accel1, phase_accel1_temp);
        phase_accel2 = cat(2, phase_accel2, phase_accel2_temp);
    else
        nldat_phasediff = nldat_temp;
        phase_accel1 = phase_accel1_temp;
        phase_accel2 = phase_accel2_temp;
    end
end

phase_names = {"Phase X (rad)", "Phase Y (rad)", "Phase Z (rad)"};

set(nldat_phasediff, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase difference")
set(phase_accel1, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase accel data")
set(phase_accel2, 'domainIncr', incr, 'domainName', "Frequency (Hz)", 'chanNames', phase_names, 'comment', "phase accel data")

%% interpolate data
incr = fft_mag_accel1.domainIncr;
dataLength = length(fft_mag_accel1.dataSet);
incr_new = 0.01;
radian_old = 0:incr:incr*dataLength-incr;
radian_new = 0:incr_new:radian_old(end);

mag_accel1_interp= interp1(fft_mag_accel1, radian_new, 'linear');
mag_accel2_interp= interp1(fft_mag_accel2, radian_new, 'linear');
phase_accel1_interp= interp1(phase_accel1, radian_new, 'linear');
phase_accel2_interp= interp1(phase_accel2, radian_new, 'linear');
phasediff_interp = interp1(nldat_phasediff, radian_new, 'linear');

set(mag_accel1_interp, 'domainIncr', incr_new, 'domainValues', NaN)
set(mag_accel2_interp, 'domainIncr', incr_new, 'domainValues', NaN)
set(phase_accel1_interp, 'domainIncr', incr_new, 'domainValues', NaN)
set(phase_accel2_interp, 'domainIncr', incr_new, 'domainValues', NaN)
set(phasediff_interp, 'domainIncr', incr_new, 'domainValues', NaN)

%% isolate frequencies 0.25-0.35Hz

domain1 = 0:incr_new:0.24;
domain2 = 0:incr_new:0.46;
start = domain1(end);
stop = domain2(end);

ind1 = find(radian_new==start);
ind2 = find(radian_new==stop);

freqband_mag1 = mag_accel1_interp(ind1:ind2,:,:);
freqband_mag2 = mag_accel2_interp(ind1:ind2,:,:);
freqband_phase1 = phase_accel1_interp(ind1:ind2,:,:);
freqband_phase2 = phase_accel2_interp(ind1:ind2,:,:);
freqband_phasediff = phasediff_interp(ind1:ind2,:,:);
%% perform feature extraction on islated frequency band 

hold_data1 = freqband_mag1.dataSet;
hold_data2 = freqband_mag2.dataSet;
domaint = 0:incr_new:length(hold_data1);
phasediff = freqband_phasediff.dataSet;

for v = 1:nChans
    dir = directions{v};

    [pk_1.(dir), index_a.(dir)] = max(hold_data1(:,v));
    [pk_2.(dir), index_b.(dir)] = max(hold_data2(:,v));

    freq_a(v) = domaint(index_a.(dir)(1));
    freq_b(v) = domaint(index_b.(dir)(1));

    phasediff_a(v) = phasediff(index_a.(dir)(1));
    phasediff_b(v) = phasediff(index_b.(dir)(1));

    pk_a(v) = pk_1.(dir)(1);
    pk_b(v) = pk_2.(dir)(1);

end


end