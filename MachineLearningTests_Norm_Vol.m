data = 'clean';
ntrial = '010';
baseDir1 = ['/Users/vstur/Dropbox/ApnexDetection_Project/Export/figures_v4/' ntrial '/'];
load([baseDir1 'spectrum_pks_phase_' data])
normal = [1 3 5 7 9];
vol = [2 4 6 8];
freq_C3898_z=sensor_C3898.freq(:,3);
freq_C3892_z=sensor_C3892.freq(:,3);


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
ALL=struct('freq98',{},'freq92',{},'type', {})
for i=1:8
    ALL(i).freq98=freq_C3898_z(i);
    ALL(i).freq92=freq_C3892_z(i);
    if rem(i,2)==0
        ALL(i).type='V';
    else
        ALL(i).type='NB';
    end
end
T_ALL=struct2table(ALL);
gscatter(T.freq98,T.freq92,T.type);

%% Still need to test with adding trial 3 and 13
%% Also should look into classification learner app
