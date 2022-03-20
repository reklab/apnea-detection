%% MOVEMENT TRIALS (029 AND 033)

if M==1
baseDir3=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_normalBreathing_noTaps.mat']);
load(baseDir3);
ESEQ_N=e_trial;

baseDir1=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial033_clean.mat']);
    load(baseDir1)
    baseDir2=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial033.mat']);
    load(baseDir2)
    %stat.ID=ID_array';
    Table_N_m=struct2table(stat);
    X=table2array(Table_N_m(:,1));
    locs=isnan(X);
    Table_N_m(locs==1,:)=[];

yfit_N=Models.Metric50.TrainedClassifier.predictFcn(Table_N_m);
%ID_Test_Array=Table_N.ID;
yfit_string_N=string(yfit_N);

Eseq_Predict1=eseq(categorical(yfit_string_N), 0, 0.02);
%for loop occurs because we had to cut of 125 samples from beginning due to
%5 sec sliding window
for i=1:length(Eseq_Predict1)
    Eseq_Predict1(i,1).startIdx=Eseq_Predict1(i,1).startIdx+125;
    Eseq_Predict1(i,1).endIdx=Eseq_Predict1(i,1).endIdx+125;
end

figure()
Eseq_Plot(ESEQ_N, Eseq_Predict1, 'N')
end


%% Functions
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
    
    %replaces correct predictions in predict array
    c2(find(cc1==cc2))='S';
    C5=categorical(cellstr(c2));
    E5=eseq(C5,0, 0.02);
    int25=intersect(e2, E5);
    
    subplot (4,1,1); eseq_plot(e1, 'b');
    subplot (4,1,2); eseq_plot(e2, 'b'); 
    subplot (4,1,3); eseq_plot(e3, 'g');
    hold on; eseq_plot(int14, 'r'); hold off
    subplot (4,1,4); eseq_plot(int14, 'g');
    hold on; eseq_plot(int25, 'r'); xlim([0 180]); hold off
    
    if n=='N'
        subplot (4,1,1);
        title('Normal Breathing Expected Pattern')
        subplot (4,1,2);
        title('Normal Breathing Trial Predicted Pattern')
        subplot (4,1,3);
        title('Correct in Green and Incorrect in Red')
        subplot (4,1,4);
        title('Incorrect Predictions in Red and Correct ID in Green')
    elseif n=='V'
        subplot (4,1,1);
        title('Voluntary Breath Hold Trial Expected Pattern')
        subplot (4,1,2);
        title('Voluntary Breath Hold Trial Predicted Pattern')
        subplot (4,1,3);
        title('Correct in Green and Incorrect in Red')
        subplot (4,1,4);
        title('Incorrect Predictions in Red and Correct ID in Green')
    elseif n=='O'
        subplot (4,1,1);
        title('Obstructive Breath Hold Trial Expected Pattern')
        subplot (4,1,2);
        title('Obstructive Breath Hold Trial Predicted Pattern')
        subplot (4,1,3);
        title('Correct in Green and Incorrect in Red')
        subplot (4,1,4);
        title('Incorrect Predictions in Red and Correct ID in Green')
    end

end
function eseq_plot(e, C)
            [c,d]=cseq(e);
            plot (d,c, 'color', C ,'marker', 'o', 'LineStyle', 'none')
end 