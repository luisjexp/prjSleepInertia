% CLAIM 1: 
% Similar to our previous findings, for the KDT, GNG, and MATH tasks,
% high frequency differences in global power between baseline and other
% test bouts were largely retained. 

% First Run this to Get Data full data base
clear;
DFMASTER = df_generate();  

%% ---First for each cognitive test, analyze how power in the high
% frequency bands - alpha and beta - changes after awakening in the control
% conditions. we assess this for each test bout after awakening and compare
% with baseline.

% ---- 
clearvars -except DFMASTER   
runnames = {'BL', 'R1', 'R2', 'R3', 'R4'};
desired_ntwprop     = 'gpsd'; % gpsd, clust, or betw. NOT pathl
desired_condition   = 'control'; % control or light

desired_cogtest_list = {'PVT', 'KDT', 'Math', 'GoNogo'};
desired_band_list = {'alpha', 'beta'};
des_cogtest_numel = numel(desired_cogtest_list);
des_band_list_numel = numel(desired_band_list);
close all;


for des_cogtest_idx = 1:des_cogtest_numel
    desired_cogtest = desired_cogtest_list{des_cogtest_idx};
    figure    
    for des_band_idx = 1:des_band_list_numel 
        desired_band        = desired_band_list{des_band_idx}; % delta, theta...
    
        %----Extract desired data from data frame, do not edit        
        df_cogtest_rows     = DFMASTER.cogtest   == desired_cogtest; 
        df_sbj_rows         = ismember(DFMASTER.sbj , suggestedsubject(desired_cogtest));
        df_ntwprop_rows     = DFMASTER.ntwprop   == desired_ntwprop; 
        df_band_rows        = DFMASTER.band   == desired_band;
        df_bl_rows          = DFMASTER.condition  == 'baseline' | ismember(DFMASTER.run, 0);
        
        df_cnd_Rall_rows = DFMASTER.condition == desired_condition;
        df_cnd_R1_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run , 1);
        df_cnd_R2_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 2);
        df_cnd_R3_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 3);
        df_cnd_R4_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 4);
        
        DF = DFMASTER(df_cogtest_rows & df_ntwprop_rows & df_sbj_rows & (df_bl_rows | df_cnd_Rall_rows) & df_band_rows,:);
        info_string = sprintf('%s | %s | %s | %s',desired_ntwprop, desired_cogtest, desired_band, desired_condition);
        
        
        %--- DF containing info about within and accross graph differences
        df = varfun(@mean, DF, "InputVariables","Y","GroupingVariables",{'sbj', 'run', 'condition', 'chan'});
        df_bl = df.mean_Y(df.run == 0);
        df_r1 = df.mean_Y(df.run == 1);
        df_r2 = df.mean_Y(df.run == 2);
        df_r3 = df.mean_Y(df.run == 3);
        df_r4 = df.mean_Y(df.run == 4);
        df_mat = [df_bl, df_r1, df_r2, df_r3, df_r4];
        [df_tstat, ~, df_tstat_sigpairs] = testpairs(df_mat, 'paired');
        df_info_string = sprintf('%d data points\n (%d subjects x 5 runs x 23 channels)', numel(df_mat), numel(unique(df.sbj)));
    
        %--- DF containing info after averaging accross nodes 
        df_axc          = varfun(@mean, DF, "InputVariables","Y","GroupingVariables",{'sbj', 'run', 'condition'});
        df_axc_bl       = df_axc.mean_Y(df_axc.run == 0);
        df_axc_r1   = df_axc.mean_Y(df_axc.run == 1);
        df_axc_r2   = df_axc.mean_Y(df_axc.run == 2);
        df_axc_r3   = df_axc.mean_Y(df_axc.run == 3);
        df_axc_r4   = df_axc.mean_Y(df_axc.run == 4);
        df_axc_mat    = [df_axc_bl, df_axc_r1, df_axc_r2, df_axc_r3, df_axc_r4];
        [df_axc_tstat, ~, df_axc_tstat_sigpairs] = testpairs(df_axc_mat, 'paired');
        df_axc_info_string = sprintf('%d data points\n (%d subjects x 5 runs, Averaging accross 23 channels)', numel(df_axc_mat), numel(unique(df.sbj)));





        % PLOT
        ax_swarm = subplot(3, des_band_list_numel,des_band_idx);
        scatt_plt = swarmchart3(df,"run","sbj","mean_Y", 'Marker','.');
        scatt_plt.CData = df.sbj;
        hold on;
        scatt_plt = swarmchart3(df_axc,"run", "sbj","mean_Y", 'LineWidth',5, 'Marker','_');
        scatt_plt.CData = df_axc.sbj;
        ax_swarm.XTick = 0:4;
        ax_swarm.XTickLabel = runnames;
        ax_swarm.CameraPosition = 1.0e+03 * [0.0020    2.7868    0.0002];
        title(info_string)   
        
        
        axis_ttst_df = subplot(3, des_band_list_numel,des_band_list_numel+des_band_idx);
        testpairs_plotsigpairs(df_tstat, runnames, df_tstat_sigpairs, axis_ttst_df)
        title(['mult compare ', df_info_string])
        
        
        axis_ttst_df_axs = subplot(3, des_band_list_numel,2*des_band_list_numel+des_band_idx);
        testpairs_plotsigpairs(df_axc_tstat, runnames, df_axc_tstat_sigpairs, axis_ttst_df_axs)
        title(['mult compare ', df_axc_info_string])
        


        drawnow;
        figure(gcf)
    end
end

 
%% ---Next compare how power changes for low vs high frequency bands.
% here, we define the power high frequency bands as the average power of
% the alpha and beta bands, and low frequencies are defined as the average
% of the delta and theta bands. the same analysis is conducted as the one
% above but instead using these definitions.

clearvars -except DFMASTER   
clc
runnames = {'BL', 'R1', 'R2', 'R3', 'R4'};
desired_ntwprop     = 'gpsd'; % gpsd, clust, or betw. NOT pathl
desired_condition   = 'control'; % control or light

desired_cogtest_list = {'PVT', 'KDT', 'Math', 'GoNogo'};
des_cogtest_numel = numel(desired_cogtest_list);


close all;
desired_band_list = {'Lower Frequencies', 'Higher Frequencies'};
df_tstat_MASTER = cell(des_cogtest_numel, 2);
df_tstat_sigpairs_MASTER = cell(des_cogtest_numel, 2);
df_tstat_sigpairs_ts_MASTER = cell(des_cogtest_numel, 2);

for des_cogtest_idx = 1:des_cogtest_numel
    desired_cogtest = desired_cogtest_list{des_cogtest_idx};
    figure    
    for des_band_idx = 1:2
        desired_band        = desired_band_list{des_band_idx}; 
        switch desired_band
            case {'Higher Frequencies'}
                df_band_rows        = any(DFMASTER.band  == {'alpha', 'beta'},2);        
            case {'Lower Frequencies'}
                df_band_rows        = any(DFMASTER.band  == {'delta', 'theta'},2);                        
        end

        df_cogtest_rows     = DFMASTER.cogtest   == desired_cogtest; 
        df_sbj_rows         = ismember(DFMASTER.sbj , suggestedsubject(desired_cogtest));
        df_ntwprop_rows     = DFMASTER.ntwprop   == desired_ntwprop;         
        df_bl_rows          = DFMASTER.condition  == 'baseline' | ismember(DFMASTER.run, 0);
        df_cnd_Rall_rows = DFMASTER.condition == desired_condition;
        df_cnd_R1_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run , 1);
        df_cnd_R2_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 2);
        df_cnd_R3_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 3);
        df_cnd_R4_rows  = DFMASTER.condition  == desired_condition & ismember(DFMASTER.run, 4);
        
        DF = DFMASTER(df_cogtest_rows & df_ntwprop_rows & df_sbj_rows & (df_bl_rows | df_cnd_Rall_rows) & df_band_rows,:);
        info_string = sprintf('%s | %s | %s | %s',desired_ntwprop, desired_cogtest, desired_band, desired_condition);
        
        
        %--- DF containing info about within and accross graph differences
        df = varfun(@mean, DF, "InputVariables","Y","GroupingVariables",{'sbj', 'run', 'condition', 'chan'});
        df_bl = df.mean_Y(df.run == 0);
        df_r1 = df.mean_Y(df.run == 1);
        df_r2 = df.mean_Y(df.run == 2);
        df_r3 = df.mean_Y(df.run == 3);
        df_r4 = df.mean_Y(df.run == 4);
        df_mat = [df_bl, df_r1, df_r2, df_r3, df_r4];
        [df_tstat, df_tstat_pval, df_tstat_sigpairs] = testpairs(df_mat, 'paired');
        df_info_string = sprintf('%d data points\n(%d subjects x 5 runs x 23 channels)', numel(df_mat), numel(unique(df.sbj)));



        %--- DF containing info after averaging accross nodes 
        df_axc          = varfun(@mean, DF, "InputVariables","Y","GroupingVariables",{'sbj', 'run', 'condition'});
        df_axc = rmcats(df_axc);        
        df_axc_bl       = df_axc.mean_Y(df_axc.run == 0);
        df_axc_r1   = df_axc.mean_Y(df_axc.run == 1);
        df_axc_r2   = df_axc.mean_Y(df_axc.run == 2);
        df_axc_r3   = df_axc.mean_Y(df_axc.run == 3);
        df_axc_r4           = df_axc.mean_Y(df_axc.run == 4);
        df_axc_mat    = [df_axc_bl, df_axc_r1, df_axc_r2, df_axc_r3, df_axc_r4];
        [df_axc_tstat, ~, df_axc_tstat_sigpairs] = testpairs(df_axc_mat, 'paired');
        df_tstat_MASTER{des_cogtest_idx,des_band_idx} = df_axc_tstat;        
        df_tstat_sigpairs_MASTER{des_cogtest_idx,des_band_idx} = df_axc_tstat_sigpairs;


        df_axc_info_string = sprintf('%d data points\n(%d subjects x 5 runs, Averaging accross 23 channels)', numel(df_axc_mat), numel(unique(df.sbj)));


        % PLOT
        ax_swarm = subplot(3, 2,des_band_idx); hold on;
        scatt_plt = swarmchart(df,"run","mean_Y", 'Marker','.','MarkerFaceAlpha',.01, 'MarkerEdgeAlpha',.01);
        scatt_plt.CData = df.sbj;
        hold on;
        scatt_plt = swarmchart(df_axc,"run","mean_Y", 'LineWidth',1, 'Marker','_');
        scatt_plt.CData = df_axc.sbj;

        line(xlim, mean(df_mat(:,1))*[1 1], 'color', 'r');
        
        
        ax_swarm.XTick = 0:4;
        ax_swarm.XTickLabel = runnames';
        ylabel('Power')
        title(info_string)   
        
        axis_ttst_df = subplot(3, 2,2+des_band_idx);
        testpairs_plotsigpairs(df_tstat, runnames, df_tstat_sigpairs, axis_ttst_df)
        title(['mult compare ', df_info_string])
        
        
        axis_ttst_df_axs = subplot(3, 2,4+des_band_idx);
        testpairs_plotsigpairs(df_axc_tstat, runnames, df_axc_tstat_sigpairs, axis_ttst_df_axs)
        title(['mult compare ', df_axc_info_string])
       

        drawnow;
        figure(gcf)
    end
end
%% ---Third ask how many test bouts after awakening does power changes.
% do this for all cognitive tests and also for high frequency and low
% frequencies bands. 

x_num_sigRuns = cellfun(@(x) sum(x == 1, 'all')/2, df_tstat_sigpairs_MASTER);

figure;
close all
plot(0:3, x_num_sigRuns, 'Marker','.', 'LineStyle','none', 'MarkerSize',40)

h = gca;
h.XTick = 0:3;
h.XTickLabel = desired_cogtest_list;
ylim([-1 max(ylim)+1])
xlabel('Task')
xlim([-.5 3.5])

plotinfo_string = sprintf('Number of Testbouts\nwhere power is significantly different from baseline');
ylabel('Number of Testbouts')
title(plotinfo_string)
legend({'Lower Frequencies (delta, theta)', 'upper frequencies (alpha,beta)'})
figure(gcf)













