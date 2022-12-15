clear; clc;


cogtest         = 'Math';
S               = subjects(cogtest);
sbjidlist       = S.sbj_idS_num;
sbjidlist(8)    = []; %!!! Change this depending on cognitive test!!!
ntwpropname     = 'gpsd'; 
bandname        = 'alpha';
conditionname   = 'control'; 

T = fig1analysis_udpate(cogtest, {ntwpropname}, sbjidlist, 'testtype','independent') ;
trow = ismember(upper(T.ntwprop), upper(ntwpropname)) & ismember(T.condition, conditionname) & ismember(T.band, bandname);
tmc_r1 = abs(T.tstat{trow}(2));
tmc_r2 = abs(T.tstat{trow}(3));
tmc_r3 = abs(T.tstat{trow}(4));
tmc_r4 = abs(T.tstat{trow}(5));
tmc_rall = abs(T.tstat{trow}(2:5))';
close all


%% Next get results using regression

% First get data frame
DF = df4linmodel('cogtestlist', {cogtest});
df_cogtest_rows = ismember(DF.cogtest, cogtest);
df_ntwprop_rows = ismember(DF.ntwprop, ntwpropname); 
df_light_rows   = ismember(DF.condition, 'light');
df_cntl_rows    = ismember(DF.condition, 'control');
df_bl_rows      = ismember(DF.condition, 'baseline');

switch conditionname
    case 'light'
        df_r1_rows = DF.rundummy == 1;
        df_r2_rows = DF.rundummy == 2;
        df_r3_rows = DF.rundummy == 3;
        df_r4_rows = DF.rundummy == 4; 
    case 'control'
        df_r1_rows = DF.rundummy == 5;
        df_r2_rows = DF.rundummy == 6;
        df_r3_rows = DF.rundummy == 7;
        df_r4_rows = DF.rundummy == 8;           
end

df_band_rows = ismember(DF.band, bandname);
df_sbj_rows     = any(DF.sbjid == sbjidlist,2);

% Find data to compare baseline with all 4 runs, baseline will be reference group
rows2use_bl = df_cogtest_rows & df_ntwprop_rows & df_bl_rows & df_band_rows & df_sbj_rows;
rows2use_r1 = df_cogtest_rows & df_ntwprop_rows & (df_bl_rows | df_r1_rows ) & df_band_rows & df_sbj_rows;
rows2use_r2 = df_cogtest_rows & df_ntwprop_rows & (df_bl_rows | df_r2_rows ) & df_band_rows & df_sbj_rows;
rows2use_r3 = df_cogtest_rows & df_ntwprop_rows & (df_bl_rows | df_r3_rows ) & df_band_rows & df_sbj_rows;
rows2use_r4 = df_cogtest_rows & df_ntwprop_rows & (df_bl_rows | df_r4_rows ) & df_band_rows & df_sbj_rows;
rows2use_rall = rows2use_r1 | rows2use_r2 | rows2use_r3 | rows2use_r4;

% Fit 5 different models, one BL mean only, 4 simple, one saturated  
lm_bl  = fitlm(DF, 'Y~1',Exclude=~rows2use_bl);
lm_r2  = fitlm(DF, 'Y~run',Exclude=~rows2use_r2,CategoricalVars='run');
lm_r3  = fitlm(DF, 'Y~run',Exclude=~rows2use_r3,CategoricalVars='run');
lm_r4  = fitlm(DF, 'Y~run',Exclude=~rows2use_r4,CategoricalVars='run');
lm_rall  = fitlm(DF, 'Y~run',Exclude=~rows2use_rall,CategoricalVars='run');

% Get t-statics for each model
tlm_r1 = abs(lm_r1.Coefficients.tStat(2));
tlm_r2 = abs(lm_r2.Coefficients.tStat(2));
tlm_r3 = abs(lm_r3.Coefficients.tStat(2));
tlm_r4 = abs(lm_r4.Coefficients.tStat(2));
tlm_rall = abs(lm_rall.Coefficients.tStat(2:end));

%% Compare the results

% note that when you run the one variable models, the t-statitics are
% the same. but not true when run the saturated model
% saturated model, the t-st
simplelm_match_r1 = round(tmc_r1,4) == round(tlm_r1,4);
simplelm_match_r2 = round(tmc_r2,4) == round(tlm_r2,4);
simplelm_match_r3 = round(tmc_r3,4) == round(tlm_r3,4);
simplelm_match_r4 = round(tmc_r4,4) == round(tlm_r4,4);
satlm_match = round(tmc_rall,4) == round(tlm_rall,4);


% Lets plot the results

df_bl =  DF(rows2use_bl ,:);
df_r1 =  DF((rows2use_r1 & not(rows2use_bl) )  ,:);
df_r2 =  DF((rows2use_r2 & not(rows2use_bl) )  ,:);
df_r3 =  DF((rows2use_r3 & not(rows2use_bl) )  ,:);
df_r4 =  DF((rows2use_r4 & not(rows2use_bl) )  ,:);
Y = [df_bl.Y df_r1.Y df_r2.Y df_r3.Y df_r4.Y];

close all;
figure
subplot(2,2,1)
datainfostring = sprintf('Cognitve Test: %s\nNetwork Property: %s\nFreq Band: %s\nCondition: %s\nSubjects: %s', cogtest, ntwpropname, bandname, conditionname, num2str(sbjidlist));
text(0,1, datainfostring)
axis off

subplot(2,2,2)
boxplot(Y, 'Colors','g','Notch','marker')
hold on
plot(lm_rall);
axis square

subplot(2,2,3)
noyesstring = {'| NO |','| YES |'};
resultsstring1 = sprintf('tstat match for Y ~ R1, %s', noyesstring{simplelm_match_r1+1});
resultsstring2 = sprintf('tstat match for Y ~ R2, %s', noyesstring{simplelm_match_r2+1});
resultsstring3 = sprintf('tstat match for Y ~ R3, %s', noyesstring{simplelm_match_r3+1});
resultsstring4= sprintf('tstat match for Y = R4, %s', noyesstring{simplelm_match_r4+1});
resultsstring5= sprintf('tstat match for Y = R1+R2+R3+R4, %s', [noyesstring{satlm_match+1}]);
resultsstring = sprintf(['%s\n%s\n%s\n%s\n%s'], resultsstring1,resultsstring2,resultsstring3,resultsstring4,resultsstring5);
text(0,1, resultsstring )
axis off



subplot(2,2,4)
interpretstring = sprintf('conclusion:\nwhen you run the one variable models, the t-statitics are the same.\n but not true when run the saturated model');
text(0,1, interpretstring )
axis off;





figure(gcf)
