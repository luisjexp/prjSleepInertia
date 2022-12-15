% validate baselines in different task databases

DF = dfmaster;
%%
clearvars -except DF
clc
desired_cogtask_1 = 'PVT';
desired_cogtask_2 = 'Math';
desired_band = 'alpha';
desired_ntwprop = 'gpsd';
sbjidx = 1
common_subjects = intersect(suggestedsubject(desired_cogtask_1), suggestedsubject(desired_cogtask_2))';
desired_subjects = common_subjects(sbjidx);
groupbyvars = {'chan'}

dftask1 = dfgetsubset(DF, desired_subjects, desired_cogtask_1, desired_ntwprop, desired_band,"addgroupvars",groupbyvars)
dftask2 = dfgetsubset(DF, desired_subjects, desired_cogtask_2, desired_ntwprop, desired_band, "addgroupvars",groupbyvars)

dfgetsubsetbl = @(df) df(df.condition == 'baseline',:);
dftask1_bl = dfgetsubsetbl(dftask1);
dftask2_bl = dfgetsubsetbl(dftask2);


close all;
compare_data(dftask2_bl.mean_Y, dftask1_bl.mean_Y)
figure(gcf)



%%
originalsbjbl = load('compareblofsamesubject')


close all
compare_data(originalsbjbl.maths1_bl, originalsbjbl.pvts1_bl)
figure(gcf)
%%
clearvars -except DF
desired_cogtask_1 = 'PVT';
desired_cogtask_2 = 'Math';
desired_ntwprop = 'clust'
desired_subject_idx = 8;

common_subjects = intersect(suggestedsubject(desired_cogtask_1), suggestedsubject(desired_cogtask_2))';
desired_subjects = common_subjects (desired_subject_idx )
desired_subject = common_subjects(desired_subject_idx);
dfgetbl = @(tbl) tbl(tbl.condition == 'baseline' & tbl.ntwprop == desired_ntwprop & ismember(tbl.sbj ,desired_subject), :);

dfgettaskdf = @(bl,task) bl(bl.cogtest == task,:);

dfbl = dfgetbl(DF);
dfbl_task1 = dfgettaskdf(dfbl, desired_cogtask_1)
dfbl_task2 = dfgettaskdf(dfbl, desired_cogtask_2)

close all
figure
compare_data(dfbl_task2.Y, dfbl_task1.Y)
title(desired_subject)
figure(gcf)