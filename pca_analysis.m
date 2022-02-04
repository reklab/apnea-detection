%run section 1 of MachineLearning.m first

input=table2array(T1(:,1:66));
labels=table2array(T1(:,67));

[coeff,score,latent]=pca(input);
% biplot(coeff(:,1:3),'Scores',score(:,1:3));

% mapcaplot(input,labels);

groups=labels_num;
biplotG(coeff, score, 'Groups', groups)

labels_num=zeros(length(labels),1);

for i=1:length(labels)
    if labels(i)=='N'
        labels_num(i)=1;
    elseif labels(i)=='V'
        labels_num(i)=2;
    elseif labels(i)=='O'
        labels_num(i)=3;
    end
end