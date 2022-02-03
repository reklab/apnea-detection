%run section 1 of MachineLearning.m first

input=table2array(T1(:,1:66));
labels=table2array(T1(:,67));

[coeff,score,latent]=pca(input);
biplot(coeff(:,1:3),'Scores',score(:,1:3));

mapcaplot(input,labels);