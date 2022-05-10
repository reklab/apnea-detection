%%
baseDir=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_tables']);
load(baseDir)

%% oobPermutedPredictorImportance
Mdl = fitcensemble(T1,'ID','Method','Bag','NumLearningCycles',50);


imp = oobPermutedPredictorImportance(Mdl);

figure;
bar(imp);
title('Out-of-Bag Permuted Predictor Importance Estimates');
ylabel('Estimates');
xlabel('Predictors');

%% Organizing Metrics based on importance
LABELS=T1.Properties.VariableNames;
label_tables= cell2table(reshape(LABELS(:,1:66), [66,1]), 'VariableNames',{'Metric'});
label_tables.imp=reshape(imp, [66,1]);
label_tables.MetricNum=reshape([1:66], [66,1]);
label_tables=sortrows(label_tables,2,'descend');

%% Save label_tables
savepath=['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/'];
save([savepath, 'label_tables'], 'label_tables')
