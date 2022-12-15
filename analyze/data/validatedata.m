% does each subject have the same data frame?
clear all; clc
cd /Users/Luis/Dropbox/DEVCOM/prjSleepinertia/analyze/data/


sbjid1 = '2952';
night_str       = 'night2';
getblmat = @(data)  data.(night_str)(1).wpli.mat

pvts1       = load(sprintf("PVT\\RCM%s_metrics_050322_PVT_ASR5_nodyn.mat", sbjid1));
pvts1_bl = getblmat(pvts1.data);


maths1 = load(sprintf('Math\\RCM%s_metrics_050322_Add_ASR5_nodyn.mat', sbjid1));
maths1_bl = getblmat(maths1.data);


close all
compare_data(maths1_bl, pvts1_bl)
figure(gcf)

%%
save('compareblofsamesubject')

