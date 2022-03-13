%% New Machine Learning with 
clear all

trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013", "017", "018", "019", "020", "021", "022", "023", "024", "025"];
for i=1:length(trials)
    ntrial=convertStringsToChars(trials(i));
%     baseDir1=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['.mat']);
    baseDir1=strcat(['/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['.mat']);
    load(baseDir1)
%     baseDir2=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
    baseDir2=strcat(['/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
    load(baseDir2);
    ID=strings(length(ID_array),1);
    for n=1:length(ID_array)
    ID(n)=convertCharsToStrings(ID_array(n));
    end
    stat.ID=ID;
    
    T=struct2table(stat);
    if i==1
        %needed to make struct right format
        hold_struct=table2struct(T);
    else
        hold_struct2=table2struct(T);
        hold_struct(end+1:end+length(hold_struct2))=hold_struct2;
    end

end
T=struct2table(hold_struct);
X=table2array(T(:,1));
locs=isnan(X);
T(locs==1,:)=[];

ID_array=table2array(T(:,67));
IndexA = strfind(ID_array,'A');
IndexA = not(cellfun('isempty',IndexA));
IndexT = strfind(ID_array,'T');
IndexT = not(cellfun('isempty',IndexT));
IndexAT=IndexA+IndexT;

T1=T(IndexAT==0,:);


%% Training with 80% of data
Index_Train=zeros(height(T1),1);
R=randi(5,height(T1),1);
Table_Test=T1((R==5),:);
Table_Train=T1(not(R==5),:);

%% Training with 80% of breathholds and ___% of NB
ID_array=table2array(T1(:,67));
% IndexN = strfind(ID_array,'N');
% IndexN = not(cellfun('isempty',IndexN));
% IndexO = strfind(ID_array,'O');
% IndexO = not(cellfun('isempty',IndexO));
% IndexV = strfind(ID_array,'V');
% IndexV = not(cellfun('isempty',IndexV));

KeepArray=zeros(length(ID_array),1);

for i=1:length(ID_array)
    if ID_array(i)=="V"|| ID_array(i)=="O"
        R=randi(5);
        if ismember(R,[1:4])
            KeepArray(i)=1;
        end
    elseif ID_array(i)=="N"
        R=randi(19);
        if ismember(R,[1:3])
            KeepArray(i)=1;
        end
    else
        display('Not N,V,or O')
    end
end

Table_Train=T1((KeepArray==1),:);
Table_Test=T1(not(KeepArray==1),:);
%%
yfit=trainedModel.predictFcn(Table_Test);
ID_Test_Array=Table_Test.ID;
yfit_S=string(yfit);
C=confusionmat(ID_Test_Array,yfit_S);
Right=C(1,1)+C(2,2)+C(3,3);

Acc=Right/height(Table_Test);

%% Train without Laura's Trials

trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013", "017", "018", "019", "020", "021", "022", "023", "024", "025"];
% change for loop depending on if creating train or test models
j=0;
for i=18
%for i=1:length(trials)-3
    ntrial=convertStringsToChars(trials(i));
    baseDir1=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['_clean.mat']);
%     baseDir1=strcat(['/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_nldat/ANNE_data_trial'], trials(i), ['.mat']);
    load(baseDir1)
    baseDir2=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
%     baseDir2=strcat(['/Users/jtam/Dropbox/ApnexDetection_Project/trials_data_nldat/features_stats_trial'], trials(i), ['.mat']);
    load(baseDir2);
    ID=strings(length(ID_array),1);
    for n=1:length(ID_array)
    ID(n)=convertCharsToStrings(ID_array(n));
    end
    stat.ID=ID;
    
    T=struct2table(stat);
    if j==0
        %needed to make struct right format
        hold_struct=table2struct(T);
    else
        hold_struct2=table2struct(T);
        hold_struct(end+1:end+length(hold_struct2))=hold_struct2;
    end
    j=j+1;
end

T=struct2table(hold_struct);
X=table2array(T(:,1));
locs=isnan(X);
T(locs==1,:)=[];

ID_array=table2array(T(:,67));
IndexA = strfind(ID_array,'A');
IndexA = not(cellfun('isempty',IndexA));
IndexT = strfind(ID_array,'T');
IndexT = not(cellfun('isempty',IndexT));
IndexAT=IndexA+IndexT;

T_Train=T(IndexAT==0,:);

%%

%%
yfit2=trainedModel2.predictFcn(T_Test);
ID_Test_Array2=T_Test.ID;
yfit_S2=string(yfit2);
C2=confusionmat(ID_Test_Array2,yfit_S2);
Right2=C2(1,1)+C2(2,2)+C2(3,3);

Acc2=Right2/height(T_Test)

%% OLD Machine Learning
trials={'002', '003', '009', '010', '012', '013'};
OB_trials={'002', '009', '012'};
VB_trials={'003', '010', '013'};
normal = [1 3 5 7 9];
vol = [2 4 6 8];
obs = [2 4 6 8];
TEST=struct('ChestFreq',{},'AbdFreq',{},'ChestAmp', {}, 'AbdAmp', {}, 'type', {})
k=1;
for i=3:3
    ntrial=trials(i)
%     baseDir=string(fullfile('/Users/vstur/Dropbox/ApnexDetection_Project/Export/figures_v5/', trials(i), '/spectrum_pks_phase_clean'));
    baseDir=string(fullfile('/Users/jtam/Dropbox/ApnexDetection_Project/Export/figures_v5/', trials(i), '/spectrum_pks_phase_clean'));
    load(baseDir);
    chest_freq_z=sensor_chest.freq(:,3);
    abd_freq_z=sensor_abd.freq(:,3);
    abd_amp_z=sensor_abd.pks(:,3);
    chest_amp_z=sensor_chest.pks (:,3);
    for j=1:length(chest_freq_z)
        TEST(end+1).ChestFreq=chest_freq_z(j);
        TEST(end).AbdFreq=abd_freq_z(j);
        TEST(end).ChestAmp=chest_amp_z(j);
        TEST(end).AbdAmp=abd_amp_z(j);
        if ismember(j,normal)
            TEST(end).type='N';
        elseif ismember(trials(i),OB_trials) && ismember(j,obs)
            TEST(end).type='O';
        elseif ismember(trials(i),VB_trials) && ismember(j,vol)
            TEST(end).type='V';
        else
            disp('Error: trial type unknown')
            disp(i); disp(j)
        end
    end
end
%%
% Below is example code of training with first 8 segments and testing 9th

TRAIN=struct('freq98',{},'freq92',{},'type', {})
for i=1:8
    TRAIN(i).freq98=freq_C3898_z(i);
    TRAIN(i).freq92=freq_C3892_z(i);
    if rem(i,2)==0
        TRAIN(i).type='V';
    else
        TRAIN(i).type='NB';
    end
end
T_TRAIN=struct2table(TRAIN);

TEST=struct('freq98',{},'freq92',{},'type', {})
for i=9
    TEST(1).freq98=freq_C3898_z(i);
    TEST(1).freq92=freq_C3892_z(i);
    if rem(i,2)==0
        TEST(1).type='V';
    else
        TEST(1).type='NB';
    end
end
T_TEST=struct2table(TEST);    

knnmodel=fitcknn(T_TRAIN,"type")
P=predict(knnmodel,T_TEST);
% P should be NB

%%
%to visualize I would use the classification learner but this code also
%could be used

gscatter(T_TEST.freq98,T_TEST.freq92,T_TEST.type);

%% Also should look into classification learner app
