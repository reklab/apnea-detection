
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
for t=1:length(labels)
    if labels(t)=='N'
        groups(t)=1;
    elseif labels(t)=='V'
        groups(t)=2;
    elseif labels(t)=='O'
        groups(t)=3;
    end
end

% biplotG(coeff, score, 'Groups', groups, 'Varlabels', categories)
% figure()
% biplot(coeff(:,1:3),'Scores',score(:,1:3),'Varlabels',categories);
% mapcaplot(input,labels);

%%

a=table2array(T1);
a=str2double(a);

%%

pca_terms=zeros(66,9);

pca_top9=zeros(length(a),9);

for n=1:length(a)
    
    %computes values for each term for each PC 
    %selected top 9 PCs based on % variance accounted for (cut-off = 2%)
    
    for t=1:9
        pca_terms(:,t)=(a(n,1:66))'.*coeff(:,t);
    end
    
    %computes values for each PC
    
    pca_top9(n,:)=sum(pca_terms,1);

end

%%

principal_metrics=zeros(10,6);

for t=1:6
    [~,principal_metrics(:,t)]=maxk(coeff(:,t),10,'ComparisonMethod','abs');
end