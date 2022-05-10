%%

%run sections 1&3 of MachineLearning.m first to load training and testing
%data

%if using to test a previously generated PCA model, change all instances of
%Table_Train to Table_Test (or another testing data set)

input=table2array(Table_Train(:,1:66));
labels=table2array(Table_Train(:,67));

coeff=pca(input);

%save coefficient matrix for later generation of eseqs

savepath = '.../Dropbox/ApnexDetection_Project/Export/PCA/';
save('pca_coeff.mat','coeff');

%%

%convert T1 to doubles
a=table2array(Table_Train);
a=str2double(a);

pca_terms=zeros(66,66);
pca_values=zeros(length(a),66);

%compute PC values by multiplying coefficients and corresponding metric
%values, then summing all terms

for n=1:length(a)
    
    %computes values for each term for each PC 
    %selected top 9 PCs based on % variance accounted for (cut-off = 2%)
    
    for t=1:66
        pca_terms(:,t)=(a(n,1:66))'.*coeff(:,t);
    end
    
    %computes values for each PC by summing terms
    
    pca_values(n,:)=sum(pca_terms,1);

end

pca_values_balanced=array2table(pca_values);

%reassign correct labels to data points

pca_values_balanced(:,67)=Table_Train(:,67);

%%

%for selection of top 6 PCA components, do not run otherwise

principal_metrics=zeros(10,6);

for t=1:6
    [~,principal_metrics(:,t)]=maxk(coeff(:,t),10,'ComparisonMethod','abs');
end
