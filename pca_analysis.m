%run section 1 of MachineLearning.m first

input=table2array(T1(:,1:66));
labels=table2array(T1(:,67));

[coeff,score,latent]=pca(input);
mapcaplot(input,labels);