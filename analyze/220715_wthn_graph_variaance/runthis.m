%% Visualizing diffreences in network state between subject and within subjects
% here you can see how nodes vary within subjects 
% In he original anlaysis, we only assessed differences between
% subjects - that is between the 'graphs' of different subjects. In doing
% so we ignored the variablity of the nodes (the channels) within each
% graph. 

% For example, if you select to assess 'gpsd', you will now be visualizing the 'local' psd, aka the 'power' of EACH node. 
% thus you will no longer be looking at the 'global' power distribution,  which was originally used in the first analysis.
% Also 
% note that path length is a global property of the network. that is no
% individual node has a path length. thus the analysis will not produce
% anything insightfull. good news is that my code is flexible enough to not
% crash and safe as well due to the 'averaging' method being used to
% extract the data


% First Run this to Get Data full data base
clear;
DFMASTER = df_generate();  

%% Select Desired Data to Visualize
%--- change this.....
desired_ntwprop     = 'pathl'; % gpsd, clust, or betw. NOT pathl

desired_condition   = 'control'; % control or light
desired_cogtest     = 'PVT'; % pvt, math, ...
desired_band        = 'delta'; % delta, theta...

%% VISUALIZE - do not edit
%----Extract desired data from data frame, do not edit
df_cogtest_rows     = DFMASTER.cogtest   == desired_cogtest; 
df_sbj_rows         = ismember(DFMASTER.sbj , suggestedsubject(desired_cogtest));
df_ntwprop_rows     = DFMASTER.ntwprop   == desired_ntwprop; 
df_band_rows        = DFMASTER.band  == desired_band;

df_bl_rows          = DFMASTER.condition  == 'baseline' | ismember(DFMASTER.run, 0);

df_cnd_Rall_rows = DFMASTER.condition == desired_condition;
df_cnd_R1_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run , 1);
df_cnd_R2_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 2);
df_cnd_R3_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 3);
df_cnd_R4_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 4);

DF = DFMASTER(df_cogtest_rows & df_ntwprop_rows & df_sbj_rows & (df_bl_rows | df_cnd_Rall_rows) & df_band_rows,:);
info_string = sprintf('%s | %s | %s | %s',desired_ntwprop, desired_cogtest, desired_band, desired_condition);


%---  Within subjects (node differences) + Between subject data (graph differences)
% Raw Data Frame of the network's state during all conditions for each
% desired subject and desired frequency band. this will include the data
% of each 'node' (the channel). 
df = varfun(@mean, DF, "InputVariables","Y","GroupingVariables",{'sbj', 'run', 'condition', 'chan'});
df_bl = df.mean_Y(df.run == 0);
df_r1 = df.mean_Y(df.run == 1);
df_r2 = df.mean_Y(df.run == 2);
df_r3 = df.mean_Y(df.run == 3);
df_r4 = df.mean_Y(df.run == 4);
df_mat = [df_bl, df_r1, df_r2, df_r3, df_r4];
[df_tstat, ~, df_tstat_sigpairs] = testpairs(df_mat, 'paired');



df_info_string = sprintf('%d data points (%d subjects x 5 runs x 23 channels)', numel(df_mat), numel(unique(df.sbj)));

%--- Betweeen Subjects (graph differences)
% Same as raw Data Frame, but averaged accross channels. This data frame is
% equivalent to the one used in the original analysis. the variablity
% between the nodes is ignored, their activity is in some sense averaged together. 
df_axc          = varfun(@mean, DF, "InputVariables","Y","GroupingVariables",{'sbj', 'run', 'condition'});
df_axc_bl       = df_axc.mean_Y(df_axc.run == 0);
df_axc_r1   = df_axc.mean_Y(df_axc.run == 1);
df_axc_r2   = df_axc.mean_Y(df_axc.run == 2);
df_axc_r3   = df_axc.mean_Y(df_axc.run == 3);
df_axc_r4   = df_axc.mean_Y(df_axc.run == 4);
df_axc_mat    = [df_axc_bl, df_axc_r1, df_axc_r2, df_axc_r3, df_axc_r4];
[df_axc_tstat, ~, df_axc_tstat_sigpairs] = testpairs(df_axc_mat, 'paired');

df_axc_info_string = sprintf('%d data points (%d subjects x 5 runs, Averaging accross 23 channels)', numel(df_axc_mat), numel(unique(df.sbj)));


%---PLOT. see figure text for details
runnames = {'baseline', 'r1', 'r2', 'r3','r4'};

close all;
ax_swarm = subplot(2,1,1);
scatt_plt = swarmchart3(df,"run","sbj","mean_Y");
scatt_plt.CData = df.sbj;

hold on;
scatt_plt = swarmchart3(df_axc,"run", "sbj","mean_Y", 'LineWidth',15, 'Marker','_');
scatt_plt.CData = df_axc.sbj;
ax_swarm.XTick = 0:4;
ax_swarm.XTickLabel = runnames;

ax_swarm.CameraPosition = 1.0e+03 * [0.0020    2.7868    0.0002];
title(info_string)


ax_ttst_df = subplot(2,3,4);
testpairs_plotsigpairs(df_tstat, runnames, df_tstat_sigpairs, ax_ttst_df)
title(['mult compare ', df_info_string])

ax_ttst_df_axc = subplot(2,3,5);
testpairs_plotsigpairs(df_axc_tstat, runnames, df_axc_tstat_sigpairs, ax_ttst_df_axc)
title(['mult compare ', df_axc_info_string])



subplot(2,3,6)
histogram(df_axc_mat, 'Normalization','probability');
hold on;
histogram(df_mat, 'Normalization','probability');
legend(df_axc_info_string, df_info_string)
xlabel(desired_ntwprop)
figure(gcf)



