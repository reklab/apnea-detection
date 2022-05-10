%% New Machine Learning with 
clear all

trials = ["001", "002", "003", "008", "009", "010", "011", "012", "013", "017", "018", "019", "020", "021", "022", "023", "024", "025"];
for i=1:length(trials)
    ntrial=convertStringsToChars(trials(i));
    baseDir1=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['_clean.mat']);
    load(baseDir1)
    baseDir2=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
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


%% Training with 80% of breathhold data and an equivalent amount of NB data
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

%% Can we save data

savepath=['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/'];
save([savepath, 'ANNE_data_tables'], 'T1', 'Table_Train', 'Table_Test')


