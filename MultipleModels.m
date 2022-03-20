%Function to call train classifier with an increasing number of features
% addpath('C:\Users\vstur\OneDrive\Desktop\BIEN 470 DATA\7 Feb')
%Need Training Table, Testing Table, label_tables (contains metric name, imp, and metricNum)
%TrainClassifier Function
n=5;
UseMetric=false(1,height(label_tables));
%N=height(label_tables;
Max=65;
Min=10;
inc=10;

% clear Models
% 
for i=1:1:height(label_tables)
    UseMetric(label_tables.MetricNum(i))=true;
    if rem(i,n)==0
    L=sprintf('Metric%d', i)
    [holdTF, holdVA]=Bag_Trainer(Table_Train, 100, 25, UseMetric);
    Models.(L).TrainedClassifier=holdTF;
    Models.(L).ValidationAcc=holdVA;
    end
end

% for i=1:1:40
%     UseMetric(label_tables.MetricNum(i))=true;
% end
% 
% 
% for i=Min:inc:Max
%     L=sprintf('Metric%d', i)
%     [holdTF, holdVA]=Bag_Trainer(Table_Train, i, 10, UseMetric);
%     Models.(L).TrainedClassifier=holdTF;
%     Models.(L).ValidationAcc=holdVA;
% end
%%
clear CrossVal_Acc TestAcc Sensitivity Specificity WrongApnea
CrossVal_Acc=zeros(1,Max);
TestAcc=zeros(1,Max);
ID_Test_Array=Table_Test.ID;
Sensitivity=zeros(1,Max);
Specificity=zeros(1,Max);
CorrectApnea=zeros(1,Max);
%for i=n:n:height(label_tables)
for i=Min:inc:Max   
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
%% Assume all data labeled as N
N_string=ID_Test_Array;
N_string(1:end)='N';
C_N=confusionmat(ID_Test_Array,N_string);
Right=C_N(1,1)+C_N(2,2)+C_N(3,3);
Acc=Right/height(Table_Test);
N_Acc(Min:Max)=Acc;

figure()
hold on
plot(X,TestAcc);
plot(X,CrossVal_Acc);
legend('Accuracy of Testing Group','Cross Validation Accuracy of Training Group', 'Accuracy if Model always predicts N')
xlabel('Number of Trees')
ylabel('Percent')
title('Accuracy of Testing and Training Group')

figure()
hold on
plot(X,Sensitivity);
plot(X,Specificity);
plot(X,CorrectApnea);
legend('Sensitivity','Specificity', 'Percent Correct Apnea')
xlabel('Number of Trees')
ylabel('Percent')
title('Sensitivity and Specificity')