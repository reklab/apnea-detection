# apnea-detection
codes related to the apnea detection project 

Steps for FFT analysis 
1) Run loadsave_Data
2) Run save_FFTfeatures
3) Run mean_freq_pk_phasediff to generate boxplots that compare the FFT features across breathing types

Steps for Decision Tree Model Generation and Evaluation
1) Run generate eseq to save expected eseqs for each trial type
2) Run loadsave_Data 
3) Run save metrics
4) Run machine learning to save T1, Table_Train, and Table_Test
5) Run oobPredictorImportance, use T1 and save label_tables **only for tree models
6) Create Models
    6a) Run Multiple Models- to get an idea of parameter values
    6b) or generate a model with any classifier function or the Classification Learner app
7) Run Prediction_eseq to test model on trials not included in the training set ("026", "027", "028","030", "031", "032")
8) Run PredictingMovementTrials to test the model on NB trials that contain movement ("029", "033")
9) Run PredictingBlindTrials to test model on unknown trials ("014", "015", "016")

Steps for PCA Model Generation and Evaluation:
1) Run generate eseq to save expected eseqs for each trial type
2) Run loadsave_Data 
3) Run save metrics
4) Run machine learning to save T1, Table_Train, and Table_Test
5) Run pca_analysis with Table_Train dataset (or another training dataset)
6) Create models using Classification Learner app or other method
7) Run Prediction_eseq to test model on trials not included in the training set ("026", "027", "028","030", "031", "032")
8) Run pca_blindtrials to test model performance on unknown trials ("014", "015", "016")
