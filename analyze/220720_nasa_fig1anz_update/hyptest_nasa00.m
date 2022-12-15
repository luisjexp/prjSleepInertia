function hyptest_nasa00(DFMASTER, desired_band)
%%
% desired_band = 'delta';
pvt_xpos = [1 2 3];
math_xpos = [1.25 2.25 3.25];

commonsubjects = intersect(suggestedsubject('PVT'), suggestedsubject('Math'));
avxchan = true;
runstage = '1';

% DELTA ANALYSIS: WITHIN PVT
[pvt, pvt_ymat, pvt_grpmeans,pvt_effects, pvt_effects_group, pvt_effects_groupmeans] =...
    hyptest_nasa00_getdf(DFMASTER,commonsubjects, 'PVT', desired_band, cnd_idx=pvt_xpos ,avxchan=avxchan, runstage=runstage);
[pvt_Tmat, pvt_Pmat]        = testpairs(pvt_ymat.Variables, 'paired');

[~, pvt_unk_Pmat]        = testpairs(pvt_effects_group.Variables, 'paired');


% DELTA ANALYSIS, WITHIN MATH
[math, math_Ymat, math_grpmeans, math_effects, math_effects_group, math_effects_groupmeans] =...
    hyptest_nasa00_getdf(DFMASTER,commonsubjects, 'Math', desired_band, cnd_idx = math_xpos, avxchan = avxchan, runstage=runstage);
[math_Tmat, math_Pmat]      = testpairs(math_Ymat.Variables, 'paired');
[~, math_unk_Pmat]      = testpairs(math_effects_group.Variables, 'paired');


% DELTA ANALYSIS, DIFFERENCES IN EFFECTS, VS BASELINE
cndeff_Ymat_cntl   = [pvt_effects_group.cntlEffect, math_effects_group.cntlEffect];
cndeff_Ymat_light  = [pvt_effects_group.lightEffect, math_effects_group.lightEffect];
cndeff_Ymat        = array2table([cndeff_Ymat_cntl, cndeff_Ymat_light], 'VariableNames', {'effectCntlPvt','effectCntlMath','effectLightPvt','effectLightMath'})

[xtask_cntlEffect_Tmat, xtask_cntlEffect_Pmat]      = testpairs(cndeff_Ymat_cntl, 'paired');
[xtask_lightEffect_Tmat, xtask_lightEffect_Pmat]  = testpairs(cndeff_Ymat_light,'paired');

cndeff_Tmat = [xtask_cntlEffect_Tmat(1,2), xtask_lightEffect_Tmat(1,2)]
xtask_effects_Pmat = [xtask_cntlEffect_Pmat(1,2), xtask_lightEffect_Pmat(1,2)]


% ####################################
% PLOT
% ####################################

close all
condcomp_str = {'nan', 'ControlEffect', 'LightEffect'};
writetxt = @(c,pmt) sprintf('p=%.05f', pmt( c(1), c(2)) );
drawtxt = @(x,y, txt, clr) text(x, y, txt, 'FontSize',8, 'HorizontalAlignment','right', 'BackgroundColor','w', 'fontsize',6, 'EdgeColor',clr);

axis_handle = subplot(1,2,1);
hold on;

bar(pvt_grpmeans.condition_idx, pvt_grpmeans.mean_mean_Y, 'BarWidth',.25)
bar(math_grpmeans.condition_idx, math_grpmeans.mean_mean_Y,'BarWidth',.25)

scatter(pvt.condition_idx, pvt.mean_Y, 'b', 'filled', 'SizeData',3)
scatter(math.condition_idx, math.mean_Y, 'r', 'SizeData',3)

% ########### PLOT Effect Of Conditions within PVT ###########
pmat = pvt_Pmat   ;
df_gmeans = pvt_grpmeans;

% - 
c = [1 2];

x = [df_gmeans.condition_idx(c(1)), df_gmeans.condition_idx(c(2))];
muy =  [df_gmeans.mean_mean_Y(c(1)), df_gmeans.mean_mean_Y(c(2))];
tstr = writetxt(c,pmat) ;
plot(x, muy, 'Color', 'b', 'linestyle', ':','LineWidth', 3)
drawtxt(mean(x),mean(muy), tstr, 'b')

% - 
c = [1 3];
x = [df_gmeans.condition_idx(c(1)), df_gmeans.condition_idx(c(2))];
muy =  [df_gmeans.mean_mean_Y(c(1)), df_gmeans.mean_mean_Y(c(2))];
tstr = writetxt(c,pmat) ;
plot(x, muy, 'Color', 'b', 'LineWidth', 3)
drawtxt(mean(x),mean(muy), tstr, 'b')

% - 
c = [2 3];
x = [df_gmeans.condition_idx(c(1)), df_gmeans.condition_idx(c(2))];
muy =  [df_gmeans.mean_mean_Y(c(1)), df_gmeans.mean_mean_Y(c(2))];
tstr = writetxt(c,pmat) ;
plot(x, muy, 'Color', 'b', 'LineWidth', 3)
drawtxt(mean(x),mean(muy), tstr, 'b')
% ########### PLOT Effect Of Conditions within Math ###########
pmat = math_Pmat   ;
tmat = math_Tmat;
df_gmeans = math_grpmeans;

c = [1 2];
x = [df_gmeans.condition_idx(c(1)), df_gmeans.condition_idx(c(2))];
muy =  [df_gmeans.mean_mean_Y(c(1)), df_gmeans.mean_mean_Y(c(2))];
tstr = writetxt(c,pmat) ;

plot(x, muy, 'Color', 'r', 'linestyle', ':','LineWidth', 3)
drawtxt(mean(x),mean(muy), tstr, 'r')

% - 
c = [1 3];
x = [df_gmeans.condition_idx(c(1)), df_gmeans.condition_idx(c(2))];
muy =  [df_gmeans.mean_mean_Y(c(1)), df_gmeans.mean_mean_Y(c(2))];
tstr = writetxt(c,pmat) ;
plot(x, muy, 'Color', 'r', 'LineWidth', 3)
drawtxt(mean(x),mean(muy), tstr, 'r')

% - 
c = [2 3];
x = [df_gmeans.condition_idx(c(1)), df_gmeans.condition_idx(c(2))];
muy =  [df_gmeans.mean_mean_Y(c(1)), df_gmeans.mean_mean_Y(c(2))];
tstr = writetxt(c,pmat) ;
plot(x, muy, 'Color', 'r', 'LineWidth', 3)
drawtxt(mean(x),mean(muy), tstr, 'r')
% - tidy up
axis tight
legend({'PVT', 'MATH'})
axis_handle.XTick = linspace(min([pvt_xpos math_xpos]),  max([pvt_xpos math_xpos]), 3);
axis_handle.XTickLabel = {'Baseline', 'Control', 'Light'};
axis tight
ymx = max([pvt_grpmeans.mean_mean_Y;math_grpmeans.mean_mean_Y])*1.5;
ylim(min(ylim, ymx))
ylabel_str = sprintf('%s Clustering',desired_band)
ylabel(ylabel_str)

title_str = sprintf('%s Clustering in %s and %s task',desired_band, 'PVT', 'Math');
title(title_str );

% ########### PLOT EFFECTIVENESS OF COND VS BASELINE ###########
% Control

txt = sprintf('Effect of Control on %s clustering\n during %s vs %s',desired_band ,'PVT','Math Task');
x = [1 2]
t = cndeff_Tmat(1) ;
p = xtask_effects_Pmat(1) ;
cndeff = cndeff_Ymat{:,{'effectCntlMath','effectCntlPvt'}};


axis_handle = subplot(2,4,3); hold on;
boxplot(cndeff)
plot(x, mean(cndeff) , '--')
tstr =  sprintf('p=%.05f',p);
drawtxt(mean(x),mean(mean(cndeff)), tstr, 'k')


axis_handle.XTick = [1 2];
axis_handle.XTickLabel = {'Math Task', 'PV Task'};
ylim([min(min(cndeff_Ymat.Variables)), max(max(cndeff_Ymat.Variables))])
xlim(axis_handle, [0 3])
title(txt)
ylabel_str = sprintf('Change in %s Clustering',desired_band);
ylabel(ylabel_str)

%  Light

txt = sprintf('Effect of Light Exposure on %s clustering\n during %s vs %s',desired_band ,'PVT','Math Task');

x = [1 2]
t = cndeff_Tmat(2) ;
p = xtask_effects_Pmat(2) ;
cndeff = cndeff_Ymat{:,{'effectLightMath','effectLightPvt'}};


axis_handle = subplot(2,4,4); hold on;
boxplot(cndeff)
plot(x, mean(cndeff) , '--')
tstr =  sprintf('p=%.05f',p);
drawtxt(mean(x),mean(mean(cndeff)), tstr, 'k')


axis_handle.XTick = [1 2];
axis_handle.XTickLabel = {'Math Task', 'PV Task'};
ylim([min(min(cndeff_Ymat.Variables)), max(max(cndeff_Ymat.Variables))])
ylabel_str = sprintf('Change in %s Clustering',desired_band);
ylabel(ylabel_str)
xlim(axis_handle, [0 3])
title(txt)



% ########### PLOT UNK
txt = sprintf('Effect of Light Exposure on %s clustering\n during PVT',desired_band );

x = [1 2]
p = pvt_unk_Pmat(2) ;
cndeff = pvt_effects_group{:,{'cntlEffect','lightEffect'}};

axis_handle = subplot(2,4,7); hold on;
boxplot(cndeff)
plot(x, mean(cndeff) , '--')
tstr =  sprintf('p=%.05f',p);
drawtxt(mean(x),mean(mean(cndeff)), tstr, 'k')


axis_handle.XTick = [1 2];
axis_handle.XTickLabel = {'Effect of Control', 'Effect of Light'};
ylim([min(min(cndeff_Ymat.Variables)), max(max(cndeff_Ymat.Variables))])
ylabel_str = sprintf('Change in %s Clustering During PVT',desired_band);
ylabel(ylabel_str)
xlim(axis_handle, [0 3])
title(txt)

% Math
txt = sprintf('Effect of Light Exposure on %s clustering\n during Math',desired_band );

x = [1 2]
p = math_unk_Pmat(2) ;
cndeff = math_effects_group{:,{'cntlEffect','lightEffect'}};

axis_handle = subplot(2,4,8); hold on;
boxplot(cndeff)
plot(x, mean(cndeff) , '--')
tstr =  sprintf('p=%.05f',p);
drawtxt(mean(x),mean(mean(cndeff)), tstr, 'k')


axis_handle.XTick = [1 2];
axis_handle.XTickLabel = {'Effect of Control', 'Effect of Light'};
ylim([min(min(cndeff_Ymat.Variables)), max(max(cndeff_Ymat.Variables))])
ylabel_str = sprintf('Change in %s Clustering During Math',desired_band);
ylabel(ylabel_str)
xlim(axis_handle, [0 3])
title(txt)

figure(gcf)
