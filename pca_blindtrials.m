
trials=["030", "031", "032"];
for i=1:length(trials)
    ntrial=convertStringsToChars(trials(i));
    baseDir1=strcat(['/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['_clean.mat']);
    load(baseDir1)
    baseDir2=strcat(['/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
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

%unknown1

input1=table2array(Table_Unknown1);

pca_terms1=zeros(66,66);
pca_values=zeros(length(input1),66);

%compute PC values by multiplying coefficients and corresponding metric
%values, then summing all terms

for n=1:length(input1)
    for t=1:66
        pca_terms1(:,t)=(input1(n,1:66))'.*coeff(:,t);  %computes values for each term for each PC 
    end
    pca_values(n,:)=sum(pca_terms1,1); %computes values for each PC by summing terms
end

pca_values1=array2table(pca_values);

%unknown2

input2=table2array(Table_Unknown2);

pca_terms2=zeros(66,66);
pca_values=zeros(length(input2),66);

for n=1:length(input2)
    for t=1:66
        pca_terms2(:,t)=(input2(n,1:66))'.*coeff(:,t);
    end
    pca_values(n,:)=sum(pca_terms2,1);
end
pca_values2=array2table(pca_values);

%unknown3

input3=table2array(Table_Unknown3);

pca_terms3=zeros(66,66);
pca_values=zeros(length(input3),66);

for n=1:length(input3)
    for t=1:66
        pca_terms3(:,t)=(input3(n,1:66))'.*coeff(:,t);
    end
    pca_values(n,:)=sum(pca_terms3,1);
end
pca_values3=array2table(pca_values);

%%

yfit_Unknown1=fine_knn_pca.predictFcn(pca_values1);
yfit_string_Unknown1=string(yfit_Unknown1);
Eseq_Predict1=eseq(categorical(yfit_string_Unknown1), 0, 0.02);

yfit_Unknown2=fine_knn_pca.predictFcn(pca_values2);
yfit_string_Unknown2=string(yfit_Unknown2);
Eseq_Predict2=eseq(categorical(yfit_string_Unknown2), 0, 0.02);

yfit_Unknown3=fine_knn_pca.predictFcn(pca_values3);
yfit_string_Unknown3=string(yfit_Unknown3);
Eseq_Predict3=eseq(categorical(yfit_string_Unknown3), 0, 0.02);

%for loop occurs because we had to cut of 125 samples from beginning due to
%5 sec sliding window
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
subplot (3,1,1); plot (Eseq_Predict1); title('Blind Trial 14')
subplot (3,1,2); plot (Eseq_Predict2); title('Blind Trial 15')
subplot (3,1,3); plot (Eseq_Predict3); title('Blind Trial 16')