
addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/reklab_public/utility_tools/')
addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/reklab_public/nlid_tools/')
addpath('/Users/jtam/Dropbox/ApnexDetection_Project/MATLAB tools/jsonlab-2.0/jsonlab-2.0/')
addpath('/Users/jtam/Desktop/school/BIEN470/GITHUB/apnea-detection/Untitled')
addpath('/Users/jtam/Dropbox/AUREA_retrieved_v2/METRICS/')
addpath('/Users/jtam/Dropbox/AUREA_retrieved_v2/Signal_Processing/')
addpath('/Users/jtam/Dropbox/AUREA_retrieved_v2/CardioRespiratory_Analysis/')
addpath('/Users/jtam/Dropbox/AUREA_retrieved_v2/biplotG/')

%%

%run section 1 of MachineLearning.m first

input=table2array(T1(:,1:66));
labels=table2array(T1(:,67));

[coeff,score,latent,~,explained]=pca(input);

categories=fieldnames(T);
categories=categories(1:66);

groups=zeros(length(labels),1);
for i=1:length(labels)
    if labels(i)=='N'
        groups(i)=1;
    elseif labels(i)=='V'
        groups(i)=2;
    elseif labels(i)=='O'
        groups(i)=3;
    end
end

% biplotG(coeff, score, 'Groups', groups, 'Varlabels', categories)
% figure()
% biplot(coeff(:,1:3),'Scores',score(:,1:3),'Varlabels',categories);
% mapcaplot(input,labels);

%%

a=table2array(T1);
a=str2double(a);

pca_top9=zeros(66,9);

%computes values for each term for each PC 
%selected top 9 PCs based on % variance accounted for (cut-off = 2%)

for i=1:9
    pca_top9(:,i)=(a(i,1:66))'.*coeff(:,i);
end

%computes values for each PC

pca_values=sum(pca_top9,1);

%%

principal_metrics=zeros(10,6);

for i=1:6
    [~,principal_metrics(:,i)]=maxk(coeff(:,i),10,'ComparisonMethod','abs');
end