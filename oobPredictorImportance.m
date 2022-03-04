%%
t = templateTree('MaxNumSplits',1,'Surrogate','on');
ens = fitrensemble(T(:,1:57),T(:,57),'Method','LSBoost','Learners',t);
imp = predictorImportance(ens)

%% oobPermutedPredictorImportance
Mdl = fitcensemble(T,'ID','Method','Bag','NumLearningCycles',50);

% rng('default') % For reproducibility
% t = templateTree('Reproducible',true); % For reproducibiliy of random predictor selections
% Mdl = fitcensemble(X,'salary','Method','Bag','NumLearningCycles',50,'Learners',t);

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