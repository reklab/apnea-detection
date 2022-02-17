%Function to call train classifier with an increasing number of features
% addpath('C:\Users\vstur\OneDrive\Desktop\BIEN 470 DATA\7 Feb')
%Need Training Table, Testing Table, label_tables (contains metric name, imp, and metricNum)
%TrainClassifier Function

UseMetric=false(1,height(label_tables));

for i=1:height(label_tables)
    UseMetric(label_tables.MetricNum(i))=true;
    L=sprintf('Metric%d', i)
    [holdTF, holdVA]=TrainClassifier(Table_Train, UseMetric);
    Models.(L).TrainedClassifier=holdTF;
    Models.(L).ValidationAcc=holdVA;
    
end
%%
CrossVal_Acc=zeros(1,height(label_tables));
TestAcc=zeros(1,height(label_tables));
ID_Test_Array=Table_Test.ID;
for i=1:height(label_tables)
    L=sprintf('Metric%d', i);
    CrossVal_Acc(i)=Models.(L).ValidationAcc;
    
    Models.(L).yfit=Models.(L).TrainedClassifier.predictFcn(Table_Test);
    Models.(L).yfit_S=string(Models.(L).yfit);
    Models.(L).C=confusionmat(ID_Test_Array,Models.(L).yfit_S);
    
    Right=Models.(L).C(1,1)+Models.(L).C(2,2)+Models.(L).C(3,3);

    Models.(L).TestAcc=Right/height(Table_Test);
    TestAcc(i)=Models.(L).TestAcc;
    
end


%% Assume all data labeled as N
N_string=ID_Test_Array;
N_string(1:end)='N';
C_N=confusionmat(ID_Test_Array,N_string);
Right=C_N(1,1)+C_N(2,2)+C_N(3,3);
Acc=Right/height(Table_Test)
N_Acc(1:66)=Acc

figure()
hold on
plot(TestAcc);
plot(CrossVal_Acc);
plot(N_Acc);
legend('Accuracy of Testing Group','Cross Validation Accuracy of Training Group', 'Accuracy if Model always predicts N')