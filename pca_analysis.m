%run section 1 of MachineLearning.m first

input=table2array(T1(:,1:66));
labels=table2array(T1(:,67));

[coeff,score,latent]=pca(input);

categories=fieldnames(stat);
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
% biplot(coeff(:,1:3),'Scores',score(:,1:3),'Varlabels',categories);
% mapcaplot(input,labels);

