%% ATTEMPT TO REPLICATE FIGURE 3 AND GENERALIZE THE VISUAL TO OTHER NETWORK PROPERTIES

%% LOAD DATA
cog_task_list = {'PVT'};
df_long =  dflong('cogtestlist',cog_task_list,'getd2cdf',false);


%% RUN ANALAYSIS
% CHOOSE YOUR SETTINGS
clearvars -except df_long
clc;
cogtask = 'PVT';
bandname  = 'delta';
ntwprop = 'clust'; 
t = 1;

% --------------------
% GET RAW DATA
% First load it
experimentalvars = {'condition', 'chan','sbj','run','band_ord','cogtest'};
df = dflong2wide(df_long,cogtask,{'baseline','control','light'},bandname,t,"catvars",0,"grouping_vars",[],"keepchannels",true,"suppresswarnings",true);
df = df(:,[{ntwprop},experimentalvars()]);
[df_bl, df_cntl, df_light] = splitdfbycondition(df);
S = subjects(cogtask);
goodsbj_list = goodsbj(cogtask);

% --------------------
% PRE PROCESS 
% Next we need to get data for each channel
Cj_bl = zeros(numel(goodsbj_list),23);
Cj_ctrl = zeros(numel(goodsbj_list),23);
Cj_light = zeros(numel(goodsbj_list),23);
Cj_blVsCtrl = zeros(numel(goodsbj_list),23);
Cj_blVsLight = zeros(numel(goodsbj_list),23);


for cii = 1:23
    % Get [ntwprop] of each channel, for a given subject and condition
    Cj_bl(:,cii) = df_bl.(ntwprop)(df_bl.chan == cii);
    Cj_ctrl(:,cii) = df_cntl.(ntwprop)(df_cntl.chan == cii);
    Cj_light(:,cii) = df_light.(ntwprop)(df_light.chan == cii);

    % Differences in [ntwprop] of a given channel after waking
    Cj_blVsCtrl(:,cii) = Cj_bl(:,cii) -Cj_ctrl(:,cii);
    Cj_blVsLight(:,cii) = Cj_bl(:,cii) -Cj_light(:,cii);
    
end
% get the average [ntwprop] of the chanell
C_blVsCtrl = mean(Cj_blVsCtrl);
C_blVsLight = mean(Cj_blVsLight);


% --------------------
% RUN TESTS: 
% Test if [ntwpropy] of a given chanel changes after waking
test_blVsCtrl = zeros(23,1);
test_blVsLight = zeros(23,1);
for cii = 1:23
    test_blVsCtrl(cii) = ttest(Cj_bl(:,cii) ,Cj_ctrl(:,cii) );
    test_blVsLight(cii) = ttest(Cj_bl(:,cii) ,Cj_light(:,cii) );    
end

% --------------------
% INITIATE PLOTS
% Make info strings
settings_str = sprintf('%s task | %s %s | when t = %d',cogtask, bandname, ntwprop, t);
anzinfo_str = sprintf('Change in %s %s after waking for each "good" subject',bandname, ntwprop);
title_str = sprintf('%s\n%s',anzinfo_str, settings_str);
close all force
figure('Visible','on');
plotspersbj = 2;
T = tiledlayout(ceil(numel(goodsbj_list)/2),plotspersbj*2);
T.Title.String = title_str;

% --------------------
% PLOTS FOR INDIVIDUAL SUBJECTS
for jj = 1:3%numel(goodsbj_list)
    sbj_id = goodsbj_list(jj);
    sbj_clr = rand(1,3);

    % plots 4 control
    ax_ctrl = nexttile;    
    cj = Cj_blVsCtrl(jj,:);
    topoplot(cj, S.chan,'style','map')  ;
    ax_ctrl.Children(end-1).FaceColor = sbj_clr;
    set(ax_ctrl,'Visible','off','Color',sbj_clr,'XColor','none','YColor','none')
    
    % plots 4 control
    ax_light = nexttile;    
    cj = Cj_blVsCtrl(jj,:);
    topoplot(cj, S.chan,'style','map')  ;
    ax_light.Children(end-1).FaceColor = sbj_clr;
    set(ax_ctrl,'Visible','off','Color',sbj_clr,'XColor','none','YColor','none')
    
    drawnow    

end

% --------------------
% PLOTS AND TESTS OF AGGREGATED DATA
% plots 4 control
ax_ctrl = nexttile; 
topoplot(C_blVsCtrl, S.chan,'style','map')  ;
cx = ax_ctrl.Children(1).XData';  
cy = ax_ctrl.Children(1).YData';
cx_sig = cx(test_blVsCtrl==1);
cy_sig = cy(test_blVsCtrl==1);

hold on
ax_ctrl.Children(1).Color = 'k';
scatter(cx_sig,cy_sig,'*','MarkerEdgeColor','w')
set(ax_ctrl,'Visible','off','Color','k','XColor','none','YColor','none')

% now for light
ax_light= nexttile; 
topoplot(C_blVsLight, S.chan,'style','map')  ;
    ax_light.Children(end-1).FaceColor = 'k';

cx = ax_light.Children(1).XData';  
cy = ax_light.Children(1).YData';
cx_sig = cx(test_blVsLight==1);
cy_sig = cy(test_blVsLight==1);
chan_str = cellfun(@num2str, num2cell(find(test_blVsLight)), 'UniformOutput', false);

hold on
ax_light.Children(1).Color = 'k';
scatter(cx_sig,cy_sig,'o','MarkerEdgeColor','w','MarkerFaceColor','w')    
scatter(cx_sig,cy_sig,'*','MarkerEdgeColor','w')
set(ax_light,'Visible','off','Color','k','XColor','none','YColor','none')


% --------------------
% VALIDATE DATA SET JUST IN CASE
df_stats = groupsummary(df,{'condition','sbj'},'mean',ntwprop,'IncludeEmptyGroups',true);
goodsbj_list = sort(goodsbj(cogtask))';
valdf_dfhas_goodsbj = all(sort(unique(df.sbj)) == goodsbj_list) ;
valdf_sbjhave_bldata = all(sort(df_stats.sbj(df_stats.condition == 'baseline')) == goodsbj_list);
valdf_sbjhave_ctrldata = all(sort(df_stats.sbj(df_stats.condition == 'control')) == goodsbj_list);
valdf_sbjhave_lightdata = all(sort(df_stats.sbj(df_stats.condition == 'light')) == goodsbj_list);
valdf_sbjhave_23chan = all(df_stats.GroupCount == 23);

if ~(valdf_dfhas_goodsbj) || ~(valdf_sbjhave_bldata) || ~(valdf_sbjhave_ctrldata) || ~(valdf_sbjhave_lightdata) || ~(valdf_sbjhave_23chan)
    error('hey luis, your data frame has something wrong with it')
end


