clear;
cogtestname = 'Math';
sbj2remove = [8 5 10];
ntwpropname = {'betw'}; % wpli seems to be broken
cndname     = 'light';
bandname    = 'delta'; 
close all;

% first run the orinal figire 1 analysis
fig1analysis(cogtestname, ntwpropname, sbj2remove, false) 


% Now generate the data frame and replicate the figure 1 analysis
% should procude same results equal
DF = df4linmodel;
cogtest_rows = ismember(DF.cogtest, cogtestname);
ntwprop_rows = ismember(DF.ntwprop, ntwpropname);
band_rows = ismember(DF.band, bandname);
cond_rows = ismember(DF.condition, cndname);
bl_rows  = ismember(DF.condition, 'baseline');
run1_rows = DF.run == 1;
run2_rows = DF.run == 2;
run3_rows = DF.run == 3;
run4_rows = DF.run == 4;

bl_idx = cogtest_rows & ntwprop_rows & bl_rows & band_rows;
r1_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run1_rows;
r2_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run2_rows;
r3_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run3_rows;
r4_idx = cogtest_rows & ntwprop_rows & cond_rows & band_rows & run4_rows;

df_bl = DF(bl_idx,:);
df_r1 = DF(r1_idx,:);
df_r2 = DF(r2_idx,:);
df_r3 = DF(r3_idx,:);
df_r4 = DF(r4_idx,:);


Y = [df_bl.Y  df_r1.Y df_r2.Y df_r3.Y df_r4.Y]
Y(sbj2remove,:) = [];

figure
boxplot(Y)

figure(gcf)
