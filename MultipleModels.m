%Function to call train classifier to generate multiple models while varing
%the value of a single feature

%Need Table_Train, Table_Test, label_tables (contains metric name, imp, and metricNum)
baseDir1=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_tables']);
load(baseDir1)

baseDir2=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/label_tables']);
load(baseDir2)

clear Models


Max=5;
Min=1;
inc=1;


%% If varying the number of metrics
% n=5 %the value assigned to n means that the classifier is only called for multiples on n

% UseMetric=false(1,height(label_tables));
% N=height(label_tables);

% for i=1:1:height(label_tables)
%     UseMetric(label_tables.MetricNum(i))=true;
%     if rem(i,n)==0
%         L=sprintf('Metric%d', i)
%         [holdTF, holdVA]=Boost_Trainer(Table_Train, 'RUSBoost', 100, 25, 0.1, UseMetric);
%         Models.(L).TrainedClassifier=holdTF;
%         Models.(L).ValidationAcc=holdVA;
%     end
% end

%% If varying any other parameter
N=height(label_tables);
for i=1:1:N
    UseMetric(label_tables.MetricNum(i))=true;
end

%Can use either Boost_Trainer or Bag_Trainer
for i=Min:inc:Max
    L=sprintf('Metric%d', i)
    % Use if varying number of splits
%         [holdTF, holdVA]=Boost_Trainer(Table_Train,'AdaBoostM2', i, 25, 1, UseMetric);

    % Use if varying number of trees
%         [holdTF, holdVA]=Boost_Trainer(Table_Train,'AdaBoostM2', 50, i, 1, UseMetric);

    % Use if varying learning rate (ony for Boost_Trainer
%         j=[0.001, 0.01, 0.1, 0.5, 1];
%         [holdTF, holdVA]=Boost_Trainer(Table_Train,'AdaBoostM2', 50, 25, j(i), UseMetric);
    Models.(L).TrainedClassifier=holdTF;
    Models.(L).ValidationAcc=holdVA;
end
%%
clear CrossVal_Acc TestAcc Sensitivity Specificity WrongApnea
CrossVal_Acc=zeros(1,Max);
TestAcc=zeros(1,Max);
ID_Test_Array=Table_Test.ID;
Sensitivity=zeros(1,Max);
Specificity=zeros(1,Max);
CorrectApnea=zeros(1,Max);
%for i=n:n:height(label_tables) %use if varying number of metrics
for i=Min:inc:Max               %use if varying any other parameter
    L=sprintf('Metric%d', i);
    CrossVal_Acc(i)=Models.(L).ValidationAcc;
    
    Models.(L).yfit=Models.(L).TrainedClassifier.predictFcn(Table_Test);
    Models.(L).yfit_S=string(Models.(L).yfit);
    Models.(L).C=confusionmat(ID_Test_Array,Models.(L).yfit_S);
    
    
    Right=Models.(L).C(1,1)+Models.(L).C(2,2)+Models.(L).C(3,3);

    Models.(L).TestAcc=Right/height(Table_Test);
    TestAcc(i)=Models.(L).TestAcc;
    
    C=Models.(L).C;
    TP=(C(2,2)+C(2,3)+C(3,2)+C(3,3));
    FN=C(2,1)+C(3,1);
    TN=C(1,1);
    FP=C(1,2)+C(1,3);
    Sensitivity(i)=TP/(TP+FN);
    Specificity(i)=TN/(TN+FP);
    CorrectApnea(i)=(C(2,2)+C(3,3))/TP;
    Models.(L).Sensitivity=Sensitivity(i);
    Models.(L).Specificity=Specificity(i);
    Models.(L).WrongApnea=CorrectApnea(i);
end

 X=find(not(CorrectApnea==0));
CrossVal_Acc(CrossVal_Acc==0)=[];
TestAcc(TestAcc==0)=[];
Sensitivity(Sensitivity==0)=[];
Specificity(Specificity==0)=[];
CorrectApnea(CorrectApnea==0)=[];
%% Plot Data

%if varying learning rate for boost_Trainer
%i=j;


figure()
hold on
plot(i,TestAcc);
plot(i,CrossVal_Acc);
legend('Accuracy of Testing Group','Cross Validation Accuracy of Training Group', 'Accuracy if Model always predicts N')
xlabel('Training Time')
ylabel('Percent')
title('Accuracy of Testing and Training Group')

figure()
hold on
plot(i,Sensitivity);
plot(i,Specificity);
plot(i,CorrectApnea);
legend('Sensitivity','Specificity', 'Percent Correct Apnea')
xlabel('Training Time')
ylabel('Percent')
title('Sensitivity and Specificity')