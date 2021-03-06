%% CHOOSE MODEL

Models=Boost_Trainer(Table_Train,'AdaBoostM2', 150, 50, 1, UseMetric);
% Models=fine_knn_pca;

PCA=0;

%use the following 4 lines if running a PCA model:
%PCA=1;
baseDir = '.../Dropbox/ApnexDetection_Project/';
load([baseDir,'Export/PCA/pca_coeff'])
%coeff=pca_coeff;

%% Parameters
timedelay=125; %based on lengths of sliding windows used to calculate metrics
trial_length=9000;

% N represents the length of the time correction window
N=100;

ApneaLength_Time=20; %length of breath holds
ApneaLength_Samples=ApneaLength_Time/0.02; %Number of data points during a breath hold

ApneaDetectionLength_Time=10; 
%time required for a correct detection

ApneaDetectionLength_Samples=ApneaDetectionLength_Time/0.02;  
%Number of data points required for a correct detection

%% Load expected eseq strings
baseDir1=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_intermittentBreathing_obstruction_noTaps.mat']);
baseDir2=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_intermittentBreathing_voluntary_noTaps.mat']);
baseDir3=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_normalBreathing_noTaps.mat']);

load(baseDir1);
ESEQ_O=e_trial;
load(baseDir2);
ESEQ_V=e_trial;
load(baseDir3);
ESEQ_N=e_trial;

%correct ESEQ_N
ESEQ_N.endIdx=8875;



%%
CSEQ_N=Eseq2Cseq(ESEQ_N);
CSEQ_O=Eseq2Cseq(ESEQ_O);
CSEQ_V=Eseq2Cseq(ESEQ_V);
%%
CSEQ_N=CSEQ_N(timedelay+1:trial_length-timedelay);
CSEQ_O=CSEQ_O(timedelay+1:trial_length-timedelay);
CSEQ_V=CSEQ_V(timedelay+1:trial_length-timedelay);


%% For Each trial, load features and assign expected ESEQ

trials=["026", "027", "028","030", "031", "032"];
for i=1:length(trials)
    ntrial=strcat('Trial', trials(i));
    baseDir1=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['_clean.mat']);
    load(baseDir1);
    baseDir2=strcat(['.../Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
    load(baseDir2);
    Predict.(ntrial).T=struct2table(stat);
    Predict.(ntrial).T=Predict.(ntrial).T(timedelay+1:trial_length-timedelay,:);
    if PCA==1
        input1=table2array(Predict.(ntrial).T);

        pca_terms1=zeros(66,66);
        pca_values=zeros(length(input1),66);

        %compute PC values by multiplying coefficients and corresponding metric
        %values, then summing all terms

        for n=1:length(input1)
            for t=1:66
                pca_terms1(:,t)=(input1(n,1:66))'.*coeff(:,t);  %computes values for each term for each PC 
            end
            pca_values(n,:)=sum(pca_terms1,1); %computes values for each PC by summing terms
        end

        pca_values1=array2table(pca_values);
        Predict.(ntrial).pca_values=array2table(pca_values);
    end
    
    if contains(trials(i),"026") || contains(trials(i),"030")
        Predict.(ntrial).ID='N';
        Predict.(ntrial).expectedCSEQ=CSEQ_N;
        Predict.(ntrial).expectedESEQ=ESEQ_N;
    elseif contains(trials(i),"027") || contains(trials(i),"031")
        Predict.(ntrial).ID='V';
        Predict.(ntrial).expectedCSEQ=CSEQ_V;
        Predict.(ntrial).expectedESEQ=ESEQ_V;
    elseif contains(trials(i),"028") || contains(trials(i),"032")
        Predict.(ntrial).ID='O';
        Predict.(ntrial).expectedCSEQ=CSEQ_O;
        Predict.(ntrial).expectedESEQ=ESEQ_O;
    else
        disp('Trial ID not found')
    end
end



%% Predict and Plot

for i=1:length(trials)
    ntrial=strcat('Trial', trials(i));
    if PCA==0
        Predict.(ntrial).yfit=Models.predictFcn(Predict.(ntrial).T);
    elseif PCA==1
        Predict.(ntrial).yfit=Models.predictFcn(Predict.(ntrial).pca_values);
    end
    Predict.(ntrial).yfit_string=string(Predict.(ntrial).yfit);
    Predict.(ntrial).PredictESEQ=eseq(categorical(Predict.(ntrial).yfit_string), 0, 0.02);
    
    Predict.(ntrial).PredictESEQ=correctESEQ(Predict.(ntrial).PredictESEQ, timedelay,trial_length);
    
    Eseq_Plot(Predict.(ntrial).expectedESEQ, Predict.(ntrial).PredictESEQ, Predict.(ntrial).ID)
end


%% Generate One Confussion Matrix Pre Time Correction

for i=1:length(trials)
    ntrial=strcat('Trial', trials(i));
    c1=cellstr(char(Predict.(ntrial).expectedCSEQ));
    c2=Predict.(ntrial).yfit;
    if i==1
        hold_c1=c1;
        hold_c2=c2;
    else
        hold_c1=[hold_c1;c1];
        hold_c2=[hold_c2;c2];
    end
end
C=confusionchart(hold_c1,hold_c2);


%% Time Correction

for i=1:length(trials)

    ntrial=strcat('Trial', trials(i));
    Predict.(ntrial).yfit_corrected=time_correction(Predict.(ntrial).yfit,N);
    Predict.(ntrial).yfit_string_corrected=string(Predict.(ntrial).yfit_corrected);
    Predict.(ntrial).PredictESEQ_corrected=eseq(categorical(Predict.(ntrial).yfit_string_corrected), 0, 0.02);

    Predict.(ntrial).PredictESEQ_corrected=correctESEQ(Predict.(ntrial).PredictESEQ_corrected, timedelay,trial_length);
    Eseq_Plot(Predict.(ntrial).expectedESEQ, Predict.(ntrial).PredictESEQ_corrected, Predict.(ntrial).ID)
end


%% ReRun Confussion Matrix

for i=1:length(trials)
% for i=1:3
    ntrial=strcat('Trial', trials(i));
    c1=cellstr(char(Predict.(ntrial).expectedCSEQ));
    c2=Predict.(ntrial).yfit_corrected;
    if i==1
        hold_c1=c1;
        hold_c2=c2;
    else
        hold_c1=[hold_c1;c1];
        hold_c2=[hold_c2;c2];
    end
end
C=confusionchart(hold_c1,hold_c2,'RowSummary','row-normalized', 'ColumnSummary','column-normalized')

%% Correct Detections


for i=1:length(trials)
    ntrial=strcat('Trial', trials(i));
        ESEQ_hold1=Predict.(ntrial).PredictESEQ_corrected;
        ESEQ_hold2=Intersect(Predict.(ntrial).expectedESEQ,Predict.(ntrial).PredictESEQ_corrected);
        sz1 = [length(ESEQ_hold1) 3];
        varTypes = {'categorical','double','double'};
        varNames = {'Apnea','Length','Start'};
        Predict.(ntrial).ApneaTable1= table('Size',sz1,'VariableTypes',varTypes,'VariableNames',varNames);
        for j=1:length(ESEQ_hold1)
            if ESEQ_hold1(j).type=='V' || ESEQ_hold1(j).type=='O'
                Predict.(ntrial).ApneaTable1(j,1)={ESEQ_hold1(j).type};
                Predict.(ntrial).ApneaTable1(j,2)={ESEQ_hold1(j).nSamp};
                Predict.(ntrial).ApneaTable1(j,3)={ESEQ_hold1(j).startIdx};
            end
        end 
        Predict.(ntrial).ApneaTable1=Predict.(ntrial).ApneaTable1(not(Predict.(ntrial).ApneaTable1.Length==0),:);
        S_N=100*(trial_length-2*timedelay-sum(Predict.(ntrial).ApneaTable1.Length))/(trial_length-2*timedelay);
        
        
        sz2 = [length(ESEQ_hold2) 3];
        Predict.(ntrial).ApneaTable2= table('Size',sz2,'VariableTypes',varTypes,'VariableNames',varNames);
        for j=1:length(ESEQ_hold2)
            if ESEQ_hold2(j).type=='V' || ESEQ_hold2(j).type=='O'
                Predict.(ntrial).ApneaTable2(j,1)={ESEQ_hold2(j).type};
                Predict.(ntrial).ApneaTable2(j,2)={ESEQ_hold2(j).nSamp};
                Predict.(ntrial).ApneaTable2(j,3)={ESEQ_hold2(j).startIdx};
            end
        end 
        Predict.(ntrial).ApneaTable2=Predict.(ntrial).ApneaTable2(not(Predict.(ntrial).ApneaTable2.Length==0),:);


         Predict.(ntrial).ApneaTable2.Percent=100*Predict.(ntrial).ApneaTable2.Length/ApneaLength_Samples;
         S1=sum(Predict.(ntrial).ApneaTable2.Percent)/4;
 
        Predict.(ntrial).ApneaTable2=Predict.(ntrial).ApneaTable2(find(Predict.(ntrial).ApneaTable2.Length>ApneaDetectionLength_Samples),:);
        S2=0;
        S3=0;
        if height(Predict.(ntrial).ApneaTable2)~=0
            S2=sum(Predict.(ntrial).ApneaTable2.Percent)/4;
            S3=sum(Predict.(ntrial).ApneaTable2.Percent)/height(Predict.(ntrial).ApneaTable);
        end
        if i==1||i==4
            fprintf('For %s (a normal breathing-only trial)\nNormal breathing was predicted for %.3f percent of the trial\n',ntrial, S_N);
        else
            fprintf('For %s\nThe percent of apnea correctly predicted is %.3f\n',ntrial, S1);
            fprintf('Using a threshold of continuous predictions for %d seconds,\nThe percent of apnea identified is %.3f\n', ApneaDetectionLength_Time, S2);
            fprintf('The number of correctly predicted apnea events is %d\n', height(Predict.(ntrial).ApneaTable));
            if height(Predict.(ntrial).ApneaTable)==1
                fprintf('And a period of continuous predictions accounts for %.3f of that %d event\n', S3, height(Predict.(ntrial).ApneaTable))
            elseif height(Predict.(ntrial).ApneaTable)>1
                fprintf('And periods of continuous predictions account for %.3f of those %d events\n', S3, height(Predict.(ntrial).ApneaTable))
            end
        end
     fprintf(' \n')
end




%% 

function E= correctESEQ(E, td, t_max)
    for i=1:length(E)
        E(i,1).startIdx=E(i,1).startIdx+td;
        E(i,1).endIdx=E(i,1).endIdx+td;
    end
    if E(length(E),1).endIdx > (t_max-td)
        E(length(E),1).endIdx=t_max-td;
        %disp ('ESEQ too long')
    end
end

function c1=time_correction(c1,n)
    %c2=c1;
    for j=n+1:length(c1)-n
        window=c1(j-n:j+n);
        window=categorical(window);
        A=categories(window);
        B=countcats(window);
        L=find(B==max(B));
            if length(L)==1
                c1(j)=A(L);
                
            elseif length(L)==2
                if ismember (char(c1(j)),B(L))
%                     disp ('Max tied (2)- leave as is')
                else
%                     disp ('Neither max is the same as prediction(j)')
                    c1(j)=c1(j-1);
                end
            elseif length(L)==3
                disp ('Max tied (3) -leave as is')
            else 
                disp ('Error: L greater than 3')
            end

    end
    
end
function Eseq_Plot (e1,e2,n)
    figure()
    e3=Intersect(e1,e2);
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
    int14=Intersect(e1, E4);
    
    subplot (3,1,1); eseq_plot(e1, 'b'); xlabel('Time (seconds)');
    subplot (3,1,2); eseq_plot(e2, 'b'); xlabel('Time (seconds)');
    subplot (3,1,3); eseq_plot(e3, 'g'); xlabel('Time (seconds)');
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

function cseq = Eseq2Cseq (eseq)
% eseq2cseq - converts an event sequent to to a categorical sequence

cseq=categorical;
for i=1:length(eseq)
  cseq(eseq(i).startIdx:eseq(i).endIdx,1)=eseq(i).type; 
end
end


function eseq_plot(e, C)
            [c,d]=cseq(e);
            plot (d,c, 'color', C ,'marker', 'o', 'LineStyle', 'none')
end 

function eInter = Intersect (e1,e2);
            % return events where e1 and e2  are of the same type and intersect
            % assumes that e1 and e2 are in increaeing time and msut have
            % same domainStart and domainIcrc=
            eInter=eseq;
            n1=length(e1);
            n2=length(e2);
            d1=domain(e1);
            d2=domain(e2);
            iInter=0;
            for i1=1:n1,
                e1Cur=e1(i1);
                e1CurStart=e1Cur.startIdx;
                e1CurEnd=e1Cur.endIdx;
                for i2=1:n2,
                    e2Cur=e2(i2);
                    e2CurStart=e2Cur.startIdx;
                    e2CurEnd=e2Cur.endIdx;
                    if e1CurEnd<e2CurStart | e2CurEnd<e1CurStart
                        continue
                    else
                        if e1Cur.type==e2Cur.type
                            iInter=iInter+1;
                            eInter(iInter,1).domainStart=e1.domainStart;
                            eInter(iInter,1).domainIncr=e1.domainIncr;
                            eInter(iInter,1).startIdx=max(e1CurStart, e2CurStart);
                            eInter(iInter,1).endIdx=min(e1CurEnd,e2CurEnd);
                            eInter(iInter,1).nSamp=  eInter(iInter,1).endIdx - eInter(iInter,1).startIdx +1;
                            eInter(iInter,1).type=e1Cur.type;
                        end
                    end
                end
            end
        end