%% Predicting Ehsan's unknown trials (trial 14,15,16)

%% Select Model
Models=Bag_Trainer(Table_Train, 150, 50, UseMetric);

%% Load Blind Data

trials=["014", "015", "016"];
for i=1:length(trials)
    ntrial=convertStringsToChars(trials(i));
    baseDir1=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['_clean.mat']);
    load(baseDir1)
    baseDir2=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
    load(baseDir2)
    Table=struct2table(stat);
    X=table2array(Table(:,1));
    locs=isnan(X);
    Table(locs==1,:)=[];
    if i==1
        Table_Unknown1=Table;
    elseif i==2
        Table_Unknown2=Table;
    else
        Table_Unknown3=Table;
    end
end

%%
yfit_Unknown1=Models.predictFcn(Table_Unknown1);
yfit_string_Unknown1=string(yfit_Unknown1);
Eseq_Predict1=eseq(categorical(yfit_string_Unknown1), 0, 0.02);

yfit_Unknown2=Models.predictFcn(Table_Unknown2);
yfit_string_Unknown2=string(yfit_Unknown2);
Eseq_Predict2=eseq(categorical(yfit_string_Unknown2), 0, 0.02);

yfit_Unknown3=Models.predictFcn(Table_Unknown3);
yfit_string_Unknown3=string(yfit_Unknown3);
Eseq_Predict3=eseq(categorical(yfit_string_Unknown3), 0, 0.02);


%Need to cut of 125 samples from beginning due to 5 sec sliding window
for i=1:length(Eseq_Predict1)
    Eseq_Predict1(i,1).startIdx=Eseq_Predict1(i,1).startIdx+125;
    Eseq_Predict1(i,1).endIdx=Eseq_Predict1(i,1).endIdx+125;
end
for i=1:length(Eseq_Predict2)
    Eseq_Predict2(i,1).startIdx=Eseq_Predict2(i,1).startIdx+125;
    Eseq_Predict2(i,1).endIdx=Eseq_Predict2(i,1).endIdx+125;
end
for i=1:length(Eseq_Predict3)
    Eseq_Predict3(i,1).startIdx=Eseq_Predict3(i,1).startIdx+125;
    Eseq_Predict3(i,1).endIdx=Eseq_Predict3(i,1).endIdx+125;
end

%% Plot
figure()
title('Predicting Blind Tests')
subplot (3,1,1); plot (Eseq_Predict1); title('Unknown 1: Trial 14')
subplot (3,1,2); plot (Eseq_Predict2); title('Unknown 2: Trial 15')
subplot (3,1,3); plot (Eseq_Predict3); title('Unknown 3: Trial 16')