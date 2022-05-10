%% MOVEMENT TRIALS (029 AND 033)
%predicts breathing patterns in movement-NB trials
% to switch between trial 29 and 33, change baseDir1

%% Select Model
Models=Models.Metric50.TrainedClassifier


%% Loading Base Directories
baseDir1=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial033_clean.mat']);
    load(baseDir1)
baseDir2=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial033.mat']);
    load(baseDir2)

baseDir3=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_normalBreathing_noTaps.mat']);
    load(baseDir3);
    ESEQ_N=e_trial;
%%
stat.ID=ID_array';
Table_N_m=struct2table(stat);
X=table2array(Table_N_m(:,1));
locs=isnan(X);
Table_N_m(locs==1,:)=[];

yfit_N=Models.predictFcn(Table_N_m);

yfit_string_N=string(yfit_N);

Eseq_Predict1=eseq(categorical(yfit_string_N), 0, 0.02);

% for loop occurs because to adjust data samples that are left out of the
% predictiong due to lengths of sliding windows used to calculate metrics
for i=1:length(Eseq_Predict1)
    Eseq_Predict1(i,1).startIdx=Eseq_Predict1(i,1).startIdx+125;
    Eseq_Predict1(i,1).endIdx=Eseq_Predict1(i,1).endIdx+125;
end

figure()
Eseq_Plot(ESEQ_N, Eseq_Predict1, 'N')



%% Additional Functions
function Eseq_Plot (e1,e2,n)
    figure()
    e3=intersect(e1,e2);
    c1=Eseq2Cseq(e1);
    c2=Eseq2Cseq(e2);
    
    %to account for first 125 points
    c1(1:125)='U';
    c2(1:125)='U';
    cc1=char(c1);
    cc2=char(c2);
    
    % replaces correct predictions in expect array
    c1(find(cc1==cc2))='S';
    C4=categorical(cellstr(c1));
    E4=eseq(C4,0, 0.02);
    int14=intersect(e1, E4);
    
    subplot (3,1,1); eseq_plot(e1, 'b');
    subplot (3,1,2); eseq_plot(e2, 'b'); 
    subplot (3,1,3); eseq_plot(e3, 'g');
    hold on; eseq_plot(int14, 'r'); hold off

    
    if n=='N'
        subplot (3,1,1);
        title('Normal Breathing Expected Pattern')
        subplot (3,1,2);
        title('Normal Breathing Trial Predicted Pattern')
        subplot (3,1,3);
        title('Correct in Green and Incorrect in Red')

    elseif n=='V'
        subplot (3,1,1);
        title('Voluntary Breath Hold Trial Expected Pattern')
        subplot (3,1,2);
        title('Voluntary Breath Hold Trial Predicted Pattern')
        subplot (3,1,3);
        title('Correct in Green and Incorrect in Red')
        
    elseif n=='O'
        subplot (3,1,1);
        title('Obstructive Breath Hold Trial Expected Pattern')
        subplot (3,1,2);
        title('Obstructive Breath Hold Trial Predicted Pattern')
        subplot (3,1,3);
        title('Correct in Green and Incorrect in Red')
    end

end
function eseq_plot(e, C)
            [c,d]=cseq(e);
            plot (d,c, 'color', C ,'marker', 'o', 'LineStyle', 'none')
end 