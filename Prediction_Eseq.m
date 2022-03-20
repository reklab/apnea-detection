%% CHOOSE MODEL
Models=Models_Bagged.Metric60.TrainedClassifier;
timedelay=125;
trial_length=9000;

M=0;
%% Load expected eseq strings
baseDir1=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_intermittentBreathing_obstruction_noTaps.mat']);
baseDir2=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_intermittentBreathing_voluntary_noTaps.mat']);
baseDir3=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/eseq/eseq_normalBreathing_noTaps.mat']);

load(baseDir1);
ESEQ_O=e_trial;
load(baseDir2);
ESEQ_V=e_trial;
load(baseDir3);
ESEQ_N=e_trial;

%correct ESEQ_N
ESEQ_N.endIdx=8875;

% ESEQ_O=correctESEQ(ESEQ_O, timedelay,trial_length);
% ESEQ_V=correctESEQ(ESEQ_V, timedelay,trial_length);
ESEQ_N=correctESEQ(ESEQ_N, timedelay,trial_length);



%%
CSEQ_N=Eseq2Cseq(ESEQ_N);
CSEQ_O=Eseq2Cseq(ESEQ_O);
CSEQ_V=Eseq2Cseq(ESEQ_V);

CSEQ_N=CSEQ_N(timedelay+1:trial_length-timedelay);
CSEQ_O=CSEQ_O(timedelay+1:trial_length-timedelay);
CSEQ_V=CSEQ_V(timedelay+1:trial_length-timedelay);


%% Load data

trials=["026", "027", "028","030", "031", "032"];
for i=1:length(trials)
    ntrial=strcat('Trial', trials(i));
    baseDir1=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/ANNE_data_trial'], trials(i), ['_clean.mat']);
    load(baseDir1);
    baseDir2=strcat(['/Users/vstur/Dropbox/ApnexDetection_Project/trials_data_nldat_v3/features_stats_trial'], trials(i), ['.mat']);
    load(baseDir2);
    Predict.(ntrial).T=struct2table(stat);
    Predict.(ntrial).T=Predict.(ntrial).T(timedelay+1:trial_length-timedelay,:);
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
    Predict.(ntrial).yfit=Models.predictFcn(Predict.(ntrial).T);
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

n=50;
%for i=1:length(trials)
for i=3:3
    ntrial=strcat('Trial', trials(i));
    Predict.(ntrial).yfit_corrected=time_correction(Predict.(ntrial).yfit,n);
    Predict.(ntrial).yfit_string_corrected=string(Predict.(ntrial).yfit_corrected);
    Predict.(ntrial).PredictESEQ_corrected=eseq(categorical(Predict.(ntrial).yfit_string_corrected), 0, 0.02);

    Predict.(ntrial).PredictESEQ_corrected=correctESEQ(Predict.(ntrial).PredictESEQ_corrected, timedelay,trial_length);
    Eseq_Plot(Predict.(ntrial).expectedESEQ, Predict.(ntrial).PredictESEQ_corrected, Predict.(ntrial).ID)
end

%Not seeing a lot happening in terms of actually smoothing but confusion
%matrix is changing
%% ReRun Confussion Matrix

for i=1:length(trials)
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
C=confusionchart(hold_c1,hold_c2);

%% Correct Detections
%What defines correct detection? 5 or 10 seconds of apnea
%This should act as some type of alarm system

ApneaDetectionLength_Time=10;
ApneaDetectionLength_Samples=ApneaDetectionLength_Time*50;

%will need to adjust function if lower than 10*50

for i=1:length(trials)
    ntrial=strcat('Trial', trials(i));
    ESEQ_hold=Intersect(Predict.(ntrial).expectedESEQ,Predict.(ntrial).PredictESEQ_corrected);
    sz = [length(ESEQ_hold) 3];
    varTypes = {'categorical','double','double'};
    varNames = {'Apnea','Length','Start'};
    Predict.(ntrial).ApneaTable= table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    for j=1:length(ESEQ_hold)
        if ESEQ_hold(j).type=='V' || ESEQ_hold(j).type=='O'
            Predict.(ntrial).ApneaTable(j,1)={ESEQ_hold(j).type};
            Predict.(ntrial).ApneaTable(j,2)={ESEQ_hold(j).nSamp};
            Predict.(ntrial).ApneaTable(j,3)={ESEQ_hold(j).startIdx};
        end
    end 
    Predict.(ntrial).ApneaTable=Predict.(ntrial).ApneaTable(not(Predict.(ntrial).ApneaTable.Length==0),:);
    % still need a way to take info from table, confirm correct position,
    % and calculate # correct and % time
    
    %Could instead do with a intersect ESEQ
    Predict.(ntrial).ApneaTable.Percent=Predict.(ntrial).ApneaTable.Length/ApneaDetectionLength_Time;
    S1=sum(Predict.(ntrial).ApneaTable.Percent)/4;
    
    Predict.(ntrial).ApneaTable=Predict.(ntrial).ApneaTable(find(Predict.(ntrial).ApneaTable.Length>ApneaDetectionLength_Samples),:);
    S2=0;
    S3=0;
    if height(Predict.(ntrial).ApneaTable)~=0
        S2=sum(Predict.(ntrial).ApneaTable.Percent)/4;
        S3=sum(Predict.(ntrial).ApneaTable.Percent)/height(Predict.(ntrial).ApneaTable);
    end
%     
    fprintf('For %s\nThe percent of apnea correctly predicted is %.3f\n',ntrial, S1);
    fprintf('Using a threshold of continuous predictions for %d seconds,\nThe percent of apnea identified is %.3f\n', ApneaDetectionLength_Time, S2);
    fprintf('The number of correctly predicted apnea events is %d\n', height(Predict.(ntrial).ApneaTable));
    if height(Predict.(ntrial).ApneaTable)==1
        fprintf('And a period of continuous predictions accounts for %.3f of that %d event\n', S3, height(Predict.(ntrial).ApneaTable))
    elseif height(Predict.(ntrial).ApneaTable)>1
        fprintf('And periods of continuous predictions account for %.3f of those %d events\n', S3, height(Predict.(ntrial).ApneaTable))
    end
        fprintf(' \n')
end


%Also calculate time covered by correct detection

%% TEST CODE SECTION


%%

function E= correctESEQ(E, td, t_max)
    for i=1:length(E)
        E(i,1).startIdx=E(i,1).startIdx+td;
        E(i,1).endIdx=E(i,1).endIdx+td;
    end
    if E(length(E),1).endIdx > (t_max-td)
        E(length(E),1).endIdx=t_max-td;
        disp ('ESEQ too long')
    end
end

function c2=time_correction(c1,n)
    c2=c1;
    for j=n+1:length(c1)-n
        window=c1(j-n:j+n);
        window=categorical(window);
        A=categories(window);
        B=countcats(window);
        L=find(B==max(B));
            if length(L)==1
                c2(j)=A(L);
                
            elseif length(L)==2
                if ismember (char(c1(j)),B(L))
%                     disp ('Max tied (2)- leave as is')
                else
%                     disp ('Error: Max tied (2)')
                    c2(j)=c2(j-1);
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
    
    %replaces correct predictions in predict array
    c2(find(cc1==cc2))='S';
    C5=categorical(cellstr(c2));
    E5=eseq(C5,0, 0.02);
    int25=Intersect(e2, E5);
    
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

function cseq = Eseq2Cseq (eseq)
% eseq2cseq - converts an event sequent to to a categorical sequence

cseq=categorical;
for i=1:length(eseq)
  cseq(eseq(i).startIdx:eseq(i).endIdx,1)=eseq(i).type; 
end
end


function eseq_plot(e, C)
            [c,d]=cseq(e);
%             if c=='b'
%                 c=[0 0 1];
%             elseif c=='g'
%                 c=[0 1 0];
%             elseif c=='r'
%                 c=[1 0 0];
%             else
%                 disp('color not found')
%             end
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