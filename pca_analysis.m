%run section 1 of MachineLearning.m first

input=table2array(T1(:,1:66));
labels=table2array(T1(:,67));

[coeff,score,latent]=pca(input);

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

principal_metrics=zeros(10,6);

for i=1:6
    [~,principal_metrics(:,i)]=maxk(coeff(:,i),10);
end