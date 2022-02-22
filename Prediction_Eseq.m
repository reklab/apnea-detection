%% Load expected eseq strings
baseDir1=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_intermittentBreathing_obstruction_noTaps.mat']);
baseDir2=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_intermittentBreathing_voluntary_noTaps.mat']);
baseDir3=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_normalBreathing_noTaps.mat']);

load(baseDir1);
ESEQ_O=e_trial;
load(baseDir2);
ESEQ_V=e_trial;
load(baseDir3);
ESEQ_N=e_trial;

%% Load Laura's data

trials=["023", "024", "025"];
for i=1:length(trials)
    ntrial=convertStringsToChars(trials(i));
    baseDir1=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['_clean.mat']);
    load(baseDir1)
    baseDir2=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
    load(baseDir2)
    stat.ID=ID_array';
    Table=struct2table(stat);
    X=table2array(Table(:,1));
    locs=isnan(X);
    Table(locs==1,:)=[];
    if i==1
        Table_N=Table;
    elseif i==2
        Table_V=Table;
    else
        Table_O=Table;
    end
end



%% For Normal Breathing
yfit_N=Models.Metric30.TrainedClassifier.predictFcn(Table_N);
ID_Test_Array=Table_N.ID;
yfit_string_N=string(yfit_N);

Eseq_Predict1=eseq(categorical(yfit_string_N), 0, 0.02);
%for loop occurs because we had to cut of 125 samples from beginning due to
%5 sec sliding window
for i=1:length(Eseq_Predict1)
    Eseq_Predict1(i,1).startIdx=Eseq_Predict1(i,1).startIdx+125;
    Eseq_Predict1(i,1).endIdx=Eseq_Predict1(i,1).endIdx+125;
end

figure()
Eseq_Plot(ESEQ_N, Eseq_Predict1)
subplot (3,1,1);
title('Normal Breathing Expected Pattern')
subplot (3,1,2);
title('Normal Breathing Trial Predicted Pattern')
subplot (3,1,3);
title('Intersect')

%% For Voluntary Breath Holds
yfit_V=Models.Metric20.TrainedClassifier.predictFcn(Table_V);
ID_Test_Array=Table_V.ID;
yfit_string_V=string(yfit_V);

Eseq_Predict2=eseq(categorical(yfit_string_V), 0, 0.02);
%for loop occurs because we had to cut of 125 samples from beginning due to
%5 sec sliding window
for i=1:length(Eseq_Predict2)
    Eseq_Predict2(i,1).startIdx=Eseq_Predict2(i,1).startIdx+125;
    Eseq_Predict2(i,1).endIdx=Eseq_Predict2(i,1).endIdx+125;
end

figure()
Eseq_Plot(ESEQ_V, Eseq_Predict2)
subplot (3,1,1);
title('Voluntary Breath Hold Trial Expected Pattern')
subplot (3,1,2);
title('Voluntary Breath Hold Trial Predicted Pattern')
subplot (3,1,3);
title('Intersect')

%% For Obstructive Breath Holds
yfit_O=Models.Metric20.TrainedClassifier.predictFcn(Table_O);
ID_Test_Array=Table_O.ID;
yfit_string_O=string(yfit_O);

Eseq_Predict3=eseq(categorical(yfit_string_O), 0, 0.02);
%for loop occurs because we had to cut of 125 samples from beginning due to
%5 sec sliding window
for i=1:length(Eseq_Predict3)
    Eseq_Predict3(i,1).startIdx=Eseq_Predict3(i,1).startIdx+125;
    Eseq_Predict3(i,1).endIdx=Eseq_Predict3(i,1).endIdx+125;
end

figure()
Eseq_Plot(ESEQ_O, Eseq_Predict3)
subplot (3,1,1);
title('Obstructive Breath Hold Trial Expected Pattern')
subplot (3,1,2);
title('Obstructive Breath Hold Trial Predicted Pattern')
subplot (3,1,3);
title('Intersect')


%%
function Eseq_Plot (e1,e2)
e3=intersect(e1,e2);
subplot (3,1,1); plot (e1);
subplot (3,1,2); plot (e2); 
subplot (3,1,3); plot (e3); 
end